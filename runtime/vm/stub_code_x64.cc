// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/globals.h"
#if defined(TARGET_ARCH_X64)

#include "vm/assembler.h"
#include "vm/compiler.h"
#include "vm/dart_entry.h"
#include "vm/flow_graph_compiler.h"
#include "vm/heap.h"
#include "vm/instructions.h"
#include "vm/object_store.h"
#include "vm/resolver.h"
#include "vm/scavenger.h"
#include "vm/stack_frame.h"
#include "vm/stub_code.h"
#include "vm/tags.h"

#define __ assembler->

namespace dart {

DEFINE_FLAG(bool, inline_alloc, true, "Inline allocation of objects.");
DEFINE_FLAG(bool, use_slow_path, false,
    "Set to true for debugging & verifying the slow paths.");
DECLARE_FLAG(bool, trace_optimized_ic_calls);
DECLARE_FLAG(int, optimization_counter_threshold);
DECLARE_FLAG(bool, support_debugger);
DECLARE_FLAG(bool, lazy_dispatchers);

// Input parameters:
//   RSP : points to return address.
//   RSP + 8 : address of last argument in argument array.
//   RSP + 8*R10 : address of first argument in argument array.
//   RSP + 8*R10 + 8 : address of return value.
//   RBX : address of the runtime function to call.
//   R10 : number of arguments to the call.
// Must preserve callee saved registers R12 and R13.
void StubCode::GenerateCallToRuntimeStub(Assembler* assembler) {
  const intptr_t thread_offset = NativeArguments::thread_offset();
  const intptr_t argc_tag_offset = NativeArguments::argc_tag_offset();
  const intptr_t argv_offset = NativeArguments::argv_offset();
  const intptr_t retval_offset = NativeArguments::retval_offset();

  __ EnterStubFrame();

  COMPILE_ASSERT(
      (CallingConventions::kCalleeSaveCpuRegisters & (1 << R12)) != 0);
  __ LoadIsolate(R12);

  // Save exit frame information to enable stack walking as we are about
  // to transition to Dart VM C++ code.
  __ movq(Address(THR, Thread::top_exit_frame_info_offset()), RBP);

#if defined(DEBUG)
  { Label ok;
    // Check that we are always entering from Dart code.
    __ movq(RAX, Immediate(VMTag::kDartTagId));
    __ cmpq(RAX, Address(R12, Isolate::vm_tag_offset()));
    __ j(EQUAL, &ok, Assembler::kNearJump);
    __ Stop("Not coming from Dart code.");
    __ Bind(&ok);
  }
#endif

  // Mark that the isolate is executing VM code.
  __ movq(Address(R12, Isolate::vm_tag_offset()), RBX);

  // Reserve space for arguments and align frame before entering C++ world.
  __ subq(RSP, Immediate(sizeof(NativeArguments)));
  if (OS::ActivationFrameAlignment() > 1) {
    __ andq(RSP, Immediate(~(OS::ActivationFrameAlignment() - 1)));
  }

  // Pass NativeArguments structure by value and call runtime.
  __ movq(Address(RSP, thread_offset), THR);  // Set thread in NativeArgs.
  // There are no runtime calls to closures, so we do not need to set the tag
  // bits kClosureFunctionBit and kInstanceFunctionBit in argc_tag_.
  __ movq(Address(RSP, argc_tag_offset), R10);  // Set argc in NativeArguments.
  __ leaq(RAX, Address(RBP, R10, TIMES_8, 1 * kWordSize));  // Compute argv.
  __ movq(Address(RSP, argv_offset), RAX);  // Set argv in NativeArguments.
  __ addq(RAX, Immediate(1 * kWordSize));  // Retval is next to 1st argument.
  __ movq(Address(RSP, retval_offset), RAX);  // Set retval in NativeArguments.
#if defined(_WIN64)
  ASSERT(sizeof(NativeArguments) > CallingConventions::kRegisterTransferLimit);
  __ movq(CallingConventions::kArg1Reg, RSP);
#endif
  __ CallCFunction(RBX);

  // Mark that the isolate is executing Dart code.
  __ movq(Address(R12, Isolate::vm_tag_offset()),
          Immediate(VMTag::kDartTagId));

  // Reset exit frame information in Isolate structure.
  __ movq(Address(THR, Thread::top_exit_frame_info_offset()), Immediate(0));

  __ LeaveStubFrame();
  __ ret();
}


// Print the stop message.
DEFINE_LEAF_RUNTIME_ENTRY(void, PrintStopMessage, 1, const char* message) {
  OS::Print("Stop message: %s\n", message);
}
END_LEAF_RUNTIME_ENTRY


// Input parameters:
//   RSP : points to return address.
//   RDI : stop message (const char*).
// Must preserve all registers.
void StubCode::GeneratePrintStopMessageStub(Assembler* assembler) {
  __ EnterCallRuntimeFrame(0);
  // Call the runtime leaf function. RDI already contains the parameter.
#if defined(_WIN64)
  __ movq(CallingConventions::kArg1Reg, RDI);
#endif
  __ CallRuntime(kPrintStopMessageRuntimeEntry, 1);
  __ LeaveCallRuntimeFrame();
  __ ret();
}


// Input parameters:
//   RSP : points to return address.
//   RSP + 8 : address of return value.
//   RAX : address of first argument in argument array.
//   RBX : address of the native function to call.
//   R10 : argc_tag including number of arguments and function kind.
void StubCode::GenerateCallNativeCFunctionStub(Assembler* assembler) {
  const intptr_t native_args_struct_offset = 0;
  const intptr_t thread_offset =
      NativeArguments::thread_offset() + native_args_struct_offset;
  const intptr_t argc_tag_offset =
      NativeArguments::argc_tag_offset() + native_args_struct_offset;
  const intptr_t argv_offset =
      NativeArguments::argv_offset() + native_args_struct_offset;
  const intptr_t retval_offset =
      NativeArguments::retval_offset() + native_args_struct_offset;

  __ EnterStubFrame();

  COMPILE_ASSERT(
      (CallingConventions::kCalleeSaveCpuRegisters & (1 << R12)) != 0);
  __ LoadIsolate(R12);

  // Save exit frame information to enable stack walking as we are about
  // to transition to native code.
  __ movq(Address(THR, Thread::top_exit_frame_info_offset()), RBP);

#if defined(DEBUG)
  { Label ok;
    // Check that we are always entering from Dart code.
    __ movq(R8, Immediate(VMTag::kDartTagId));
    __ cmpq(R8, Address(R12, Isolate::vm_tag_offset()));
    __ j(EQUAL, &ok, Assembler::kNearJump);
    __ Stop("Not coming from Dart code.");
    __ Bind(&ok);
  }
#endif

  // Mark that the isolate is executing Native code.
  __ movq(Address(R12, Isolate::vm_tag_offset()), RBX);

  // Reserve space for the native arguments structure passed on the stack (the
  // outgoing pointer parameter to the native arguments structure is passed in
  // RDI) and align frame before entering the C++ world.
  __ subq(RSP, Immediate(sizeof(NativeArguments)));
  if (OS::ActivationFrameAlignment() > 1) {
    __ andq(RSP, Immediate(~(OS::ActivationFrameAlignment() - 1)));
  }

  // Pass NativeArguments structure by value and call native function.
  __ movq(Address(RSP, thread_offset), THR);  // Set thread in NativeArgs.
  __ movq(Address(RSP, argc_tag_offset), R10);  // Set argc in NativeArguments.
  __ movq(Address(RSP, argv_offset), RAX);  // Set argv in NativeArguments.
  __ leaq(RAX, Address(RBP, 2 * kWordSize));  // Compute return value addr.
  __ movq(Address(RSP, retval_offset), RAX);  // Set retval in NativeArguments.

  // Pass the pointer to the NativeArguments.
  __ movq(CallingConventions::kArg1Reg, RSP);
  // Pass pointer to function entrypoint.
  __ movq(CallingConventions::kArg2Reg, RBX);
  __ CallCFunction(&NativeEntry::NativeCallWrapperLabel());

  // Mark that the isolate is executing Dart code.
  __ movq(Address(R12, Isolate::vm_tag_offset()),
          Immediate(VMTag::kDartTagId));

  // Reset exit frame information in Isolate structure.
  __ movq(Address(THR, Thread::top_exit_frame_info_offset()), Immediate(0));

  __ LeaveStubFrame();
  __ ret();
}


// Input parameters:
//   RSP : points to return address.
//   RSP + 8 : address of return value.
//   RAX : address of first argument in argument array.
//   RBX : address of the native function to call.
//   R10 : argc_tag including number of arguments and function kind.
void StubCode::GenerateCallBootstrapCFunctionStub(Assembler* assembler) {
  const intptr_t native_args_struct_offset = 0;
  const intptr_t thread_offset =
      NativeArguments::thread_offset() + native_args_struct_offset;
  const intptr_t argc_tag_offset =
      NativeArguments::argc_tag_offset() + native_args_struct_offset;
  const intptr_t argv_offset =
      NativeArguments::argv_offset() + native_args_struct_offset;
  const intptr_t retval_offset =
      NativeArguments::retval_offset() + native_args_struct_offset;

  __ EnterStubFrame();

  COMPILE_ASSERT(
      (CallingConventions::kCalleeSaveCpuRegisters & (1 << R12)) != 0);
  __ LoadIsolate(R12);

  // Save exit frame information to enable stack walking as we are about
  // to transition to native code.
  __ movq(Address(THR, Thread::top_exit_frame_info_offset()), RBP);

#if defined(DEBUG)
  { Label ok;
    // Check that we are always entering from Dart code.
    __ movq(R8, Immediate(VMTag::kDartTagId));
    __ cmpq(R8, Address(R12, Isolate::vm_tag_offset()));
    __ j(EQUAL, &ok, Assembler::kNearJump);
    __ Stop("Not coming from Dart code.");
    __ Bind(&ok);
  }
#endif

  // Mark that the isolate is executing Native code.
  __ movq(Address(R12, Isolate::vm_tag_offset()), RBX);

  // Reserve space for the native arguments structure passed on the stack (the
  // outgoing pointer parameter to the native arguments structure is passed in
  // RDI) and align frame before entering the C++ world.
  __ subq(RSP, Immediate(sizeof(NativeArguments)));
  if (OS::ActivationFrameAlignment() > 1) {
    __ andq(RSP, Immediate(~(OS::ActivationFrameAlignment() - 1)));
  }

  // Pass NativeArguments structure by value and call native function.
  __ movq(Address(RSP, thread_offset), THR);  // Set thread in NativeArgs.
  __ movq(Address(RSP, argc_tag_offset), R10);  // Set argc in NativeArguments.
  __ movq(Address(RSP, argv_offset), RAX);  // Set argv in NativeArguments.
  __ leaq(RAX, Address(RBP, 2 * kWordSize));  // Compute return value addr.
  __ movq(Address(RSP, retval_offset), RAX);  // Set retval in NativeArguments.

  // Pass the pointer to the NativeArguments.
  __ movq(CallingConventions::kArg1Reg, RSP);
  __ CallCFunction(RBX);

  // Mark that the isolate is executing Dart code.
  __ movq(Address(R12, Isolate::vm_tag_offset()),
          Immediate(VMTag::kDartTagId));

  // Reset exit frame information in Isolate structure.
  __ movq(Address(THR, Thread::top_exit_frame_info_offset()), Immediate(0));

  __ LeaveStubFrame();
  __ ret();
}


// Input parameters:
//   R10: arguments descriptor array.
void StubCode::GenerateCallStaticFunctionStub(Assembler* assembler) {
  __ EnterStubFrame();
  __ pushq(R10);  // Preserve arguments descriptor array.
  // Setup space on stack for return value.
  __ PushObject(Object::null_object(), PP);
  __ CallRuntime(kPatchStaticCallRuntimeEntry, 0);
  __ popq(RAX);  // Get Code object result.
  __ popq(R10);  // Restore arguments descriptor array.
  // Remove the stub frame as we are about to jump to the dart function.
  __ LeaveStubFrame();

  __ movq(RBX, FieldAddress(RAX, Code::instructions_offset()));
  __ addq(RBX, Immediate(Instructions::HeaderSize() - kHeapObjectTag));
  __ jmp(RBX);
}


// Called from a static call only when an invalid code has been entered
// (invalid because its function was optimized or deoptimized).
// R10: arguments descriptor array.
void StubCode::GenerateFixCallersTargetStub(Assembler* assembler) {
  __ EnterStubFrame();
  __ pushq(R10);  // Preserve arguments descriptor array.
  // Setup space on stack for return value.
  __ PushObject(Object::null_object(), PP);
  __ CallRuntime(kFixCallersTargetRuntimeEntry, 0);
  __ popq(RAX);  // Get Code object.
  __ popq(R10);  // Restore arguments descriptor array.
  __ movq(RAX, FieldAddress(RAX, Code::instructions_offset()));
  __ addq(RAX, Immediate(Instructions::HeaderSize() - kHeapObjectTag));
  __ LeaveStubFrame();
  __ jmp(RAX);
  __ int3();
}


// Called from object allocate instruction when the allocation stub has been
// disabled.
void StubCode::GenerateFixAllocationStubTargetStub(Assembler* assembler) {
  __ EnterStubFrame();
  // Setup space on stack for return value.
  __ PushObject(Object::null_object(), PP);
  __ CallRuntime(kFixAllocationStubTargetRuntimeEntry, 0);
  __ popq(RAX);  // Get Code object.
  __ movq(RAX, FieldAddress(RAX, Code::instructions_offset()));
  __ addq(RAX, Immediate(Instructions::HeaderSize() - kHeapObjectTag));
  __ LeaveStubFrame();
  __ jmp(RAX);
  __ int3();
}


// Input parameters:
//   R10: smi-tagged argument count, may be zero.
//   RBP[kParamEndSlotFromFp + 1]: last argument.
static void PushArgumentsArray(Assembler* assembler) {
  __ LoadObject(R12, Object::null_object(), PP);
  // Allocate array to store arguments of caller.
  __ movq(RBX, R12);  // Null element type for raw Array.
  const ExternalLabel array_label(StubCode::AllocateArrayEntryPoint());
  __ call(&array_label);
  __ SmiUntag(R10);
  // RAX: newly allocated array.
  // R10: length of the array (was preserved by the stub).
  __ pushq(RAX);  // Array is in RAX and on top of stack.
  __ leaq(R12, Address(RBP, R10, TIMES_8, kParamEndSlotFromFp * kWordSize));
  __ leaq(RBX, FieldAddress(RAX, Array::data_offset()));
  // R12: address of first argument on stack.
  // RBX: address of first argument in array.
  Label loop, loop_condition;
#if defined(DEBUG)
  static const bool kJumpLength = Assembler::kFarJump;
#else
  static const bool kJumpLength = Assembler::kNearJump;
#endif  // DEBUG
  __ jmp(&loop_condition, kJumpLength);
  __ Bind(&loop);
  __ movq(RDI, Address(R12, 0));
  // No generational barrier needed, since array is in new space.
  __ InitializeFieldNoBarrier(RAX, Address(RBX, 0), RDI);
  __ addq(RBX, Immediate(kWordSize));
  __ subq(R12, Immediate(kWordSize));
  __ Bind(&loop_condition);
  __ decq(R10);
  __ j(POSITIVE, &loop, Assembler::kNearJump);
}


DECLARE_LEAF_RUNTIME_ENTRY(intptr_t, DeoptimizeCopyFrame,
                           intptr_t deopt_reason,
                           uword saved_registers_address);

DECLARE_LEAF_RUNTIME_ENTRY(void, DeoptimizeFillFrame, uword last_fp);


// Used by eager and lazy deoptimization. Preserve result in RAX if necessary.
// This stub translates optimized frame into unoptimized frame. The optimized
// frame can contain values in registers and on stack, the unoptimized
// frame contains all values on stack.
// Deoptimization occurs in following steps:
// - Push all registers that can contain values.
// - Call C routine to copy the stack and saved registers into temporary buffer.
// - Adjust caller's frame to correct unoptimized frame size.
// - Fill the unoptimized frame.
// - Materialize objects that require allocation (e.g. Double instances).
// GC can occur only after frame is fully rewritten.
// Stack after EnterDartFrame(0, PP, kNoRegister) below:
//   +------------------+
//   | Saved PP         | <- PP
//   +------------------+
//   | PC marker        | <- TOS
//   +------------------+
//   | Saved FP         | <- FP of stub
//   +------------------+
//   | return-address   |  (deoptimization point)
//   +------------------+
//   | ...              | <- SP of optimized frame
//
// Parts of the code cannot GC, part of the code can GC.
static void GenerateDeoptimizationSequence(Assembler* assembler,
                                           bool preserve_result) {
  // DeoptimizeCopyFrame expects a Dart frame, i.e. EnterDartFrame(0), but there
  // is no need to set the correct PC marker or load PP, since they get patched.
  __ EnterFrame(0);
  __ pushq(Immediate(0));
  __ pushq(PP);

  // The code in this frame may not cause GC. kDeoptimizeCopyFrameRuntimeEntry
  // and kDeoptimizeFillFrameRuntimeEntry are leaf runtime calls.
  const intptr_t saved_result_slot_from_fp =
      kFirstLocalSlotFromFp + 1 - (kNumberOfCpuRegisters - RAX);
  // Result in RAX is preserved as part of pushing all registers below.

  // Push registers in their enumeration order: lowest register number at
  // lowest address.
  for (intptr_t i = kNumberOfCpuRegisters - 1; i >= 0; i--) {
    __ pushq(static_cast<Register>(i));
  }
  __ subq(RSP, Immediate(kNumberOfXmmRegisters * kFpuRegisterSize));
  intptr_t offset = 0;
  for (intptr_t reg_idx = 0; reg_idx < kNumberOfXmmRegisters; ++reg_idx) {
    XmmRegister xmm_reg = static_cast<XmmRegister>(reg_idx);
    __ movups(Address(RSP, offset), xmm_reg);
    offset += kFpuRegisterSize;
  }

  // Pass address of saved registers block.
  __ movq(CallingConventions::kArg1Reg, RSP);
  __ ReserveAlignedFrameSpace(0);  // Ensure stack is aligned before the call.
  __ CallRuntime(kDeoptimizeCopyFrameRuntimeEntry, 1);
  // Result (RAX) is stack-size (FP - SP) in bytes.

  if (preserve_result) {
    // Restore result into RBX temporarily.
    __ movq(RBX, Address(RBP, saved_result_slot_from_fp * kWordSize));
  }

  // There is a Dart Frame on the stack. We must restore PP and leave frame.
  __ LeaveDartFrame();

  __ popq(RCX);   // Preserve return address.
  __ movq(RSP, RBP);  // Discard optimized frame.
  __ subq(RSP, RAX);  // Reserve space for deoptimized frame.
  __ pushq(RCX);  // Restore return address.

  // DeoptimizeFillFrame expects a Dart frame, i.e. EnterDartFrame(0), but there
  // is no need to set the correct PC marker or load PP, since they get patched.
  __ EnterFrame(0);
  __ pushq(Immediate(0));
  __ pushq(PP);

  if (preserve_result) {
    __ pushq(RBX);  // Preserve result as first local.
  }
  __ ReserveAlignedFrameSpace(0);
  // Pass last FP as a parameter.
  __ movq(CallingConventions::kArg1Reg, RBP);
  __ CallRuntime(kDeoptimizeFillFrameRuntimeEntry, 1);
  if (preserve_result) {
    // Restore result into RBX.
    __ movq(RBX, Address(RBP, kFirstLocalSlotFromFp * kWordSize));
  }
  // Code above cannot cause GC.
  // There is a Dart Frame on the stack. We must restore PP and leave frame.
  __ LeaveDartFrame();

  // Frame is fully rewritten at this point and it is safe to perform a GC.
  // Materialize any objects that were deferred by FillFrame because they
  // require allocation.
  // Enter stub frame with loading PP. The caller's PP is not materialized yet.
  __ EnterStubFrame();
  if (preserve_result) {
    __ pushq(Immediate(0));  // Workaround for dropped stack slot during GC.
    __ pushq(RBX);  // Preserve result, it will be GC-d here.
  }
  __ pushq(Immediate(Smi::RawValue(0)));  // Space for the result.
  __ CallRuntime(kDeoptimizeMaterializeRuntimeEntry, 0);
  // Result tells stub how many bytes to remove from the expression stack
  // of the bottom-most frame. They were used as materialization arguments.
  __ popq(RBX);
  __ SmiUntag(RBX);
  if (preserve_result) {
    __ popq(RAX);  // Restore result.
    __ Drop(1);  // Workaround for dropped stack slot during GC.
  }
  __ LeaveStubFrame();

  __ popq(RCX);  // Pop return address.
  __ addq(RSP, RBX);  // Remove materialization arguments.
  __ pushq(RCX);  // Push return address.
  __ ret();
}


// TOS: return address + call-instruction-size (5 bytes).
// RAX: result, must be preserved
void StubCode::GenerateDeoptimizeLazyStub(Assembler* assembler) {
  // Correct return address to point just after the call that is being
  // deoptimized.
  __ popq(RBX);
  __ subq(RBX, Immediate(ShortCallPattern::InstructionLength()));
  __ pushq(RBX);
  GenerateDeoptimizationSequence(assembler, true);  // Preserve RAX.
}


void StubCode::GenerateDeoptimizeStub(Assembler* assembler) {
  GenerateDeoptimizationSequence(assembler, false);  // Don't preserve RAX.
}


static void GenerateDispatcherCode(Assembler* assembler,
                                   Label* call_target_function) {
  __ Comment("NoSuchMethodDispatch");
  // When lazily generated invocation dispatchers are disabled, the
  // miss-handler may return null.
  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));
  __ cmpq(RAX, raw_null);
  __ j(NOT_EQUAL, call_target_function);
  __ EnterStubFrame();
  // Load the receiver.
  __ movq(RDI, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
  __ movq(RAX, Address(
      RBP, RDI, TIMES_HALF_WORD_SIZE, kParamEndSlotFromFp * kWordSize));
  __ pushq(raw_null);  // Setup space on stack for result.
  __ pushq(RAX);  // Receiver.
  __ pushq(RBX);
  __ pushq(R10);  // Arguments descriptor array.
  __ movq(R10, RDI);
  // EDX: Smi-tagged arguments array length.
  PushArgumentsArray(assembler);
  const intptr_t kNumArgs = 4;
  __ CallRuntime(kInvokeNoSuchMethodDispatcherRuntimeEntry, kNumArgs);
  __ Drop(4);
  __ popq(RAX);  // Return value.
  __ LeaveStubFrame();
  __ ret();
}


void StubCode::GenerateMegamorphicMissStub(Assembler* assembler) {
  __ EnterStubFrame();
  // Load the receiver into RAX.  The argument count in the arguments
  // descriptor in R10 is a smi.
  __ movq(RAX, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
  // Three words (saved pp, saved fp, stub's pc marker)
  // in the stack above the return address.
  __ movq(RAX, Address(RSP, RAX, TIMES_4,
                       kSavedAboveReturnAddress * kWordSize));
  // Preserve IC data and arguments descriptor.
  __ pushq(RBX);
  __ pushq(R10);

  // Space for the result of the runtime call.
  __ PushObject(Object::null_object(), PP);
  __ pushq(RAX);  // Receiver.
  __ pushq(RBX);  // IC data.
  __ pushq(R10);  // Arguments descriptor.
  __ CallRuntime(kMegamorphicCacheMissHandlerRuntimeEntry, 3);
  // Discard arguments.
  __ popq(RAX);
  __ popq(RAX);
  __ popq(RAX);
  __ popq(RAX);  // Return value from the runtime call (function).
  __ popq(R10);  // Restore arguments descriptor.
  __ popq(RBX);  // Restore IC data.
  __ LeaveStubFrame();

  if (!FLAG_lazy_dispatchers) {
    Label call_target_function;
    GenerateDispatcherCode(assembler, &call_target_function);
    __ Bind(&call_target_function);
  }

  __ movq(RCX, FieldAddress(RAX, Function::instructions_offset()));
  __ addq(RCX, Immediate(Instructions::HeaderSize() - kHeapObjectTag));
  __ jmp(RCX);
}


// Called for inline allocation of arrays.
// Input parameters:
//   R10 : Array length as Smi.
//   RBX : array element type (either NULL or an instantiated type).
// NOTE: R10 cannot be clobbered here as the caller relies on it being saved.
// The newly allocated object is returned in RAX.
void StubCode::GenerateAllocateArrayStub(Assembler* assembler) {
  // Must load pool pointer before being able to patch.
  Register new_pp = R13;
  __ LoadPoolPointer(new_pp);
  Label slow_case;
  // Compute the size to be allocated, it is based on the array length
  // and is computed as:
  // RoundedAllocationSize((array_length * kwordSize) + sizeof(RawArray)).
  __ movq(RDI, R10);  // Array Length.
  // Check that length is a positive Smi.
  __ testq(RDI, Immediate(kSmiTagMask));
  if (FLAG_use_slow_path) {
    __ jmp(&slow_case);
  } else {
    __ j(NOT_ZERO, &slow_case);
  }
  __ cmpq(RDI, Immediate(0));
  __ j(LESS, &slow_case);
  // Check for maximum allowed length.
  const Immediate& max_len =
      Immediate(reinterpret_cast<int64_t>(Smi::New(Array::kMaxElements)));
  __ cmpq(RDI, max_len);
  __ j(GREATER, &slow_case);

  // Check for allocation tracing.
  __ MaybeTraceAllocation(kArrayCid,
                          &slow_case,
                          /* near_jump = */ false,
                          /* inline_isolate = */ false);

  const intptr_t fixed_size = sizeof(RawArray) + kObjectAlignment - 1;
  __ leaq(RDI, Address(RDI, TIMES_4, fixed_size));  // RDI is a Smi.
  ASSERT(kSmiTagShift == 1);
  __ andq(RDI, Immediate(-kObjectAlignment));

  const intptr_t cid = kArrayCid;
  Heap::Space space = Heap::SpaceForAllocation(cid);
  __ LoadIsolate(R13);
  __ movq(R13, Address(R13, Isolate::heap_offset()));
  __ movq(RAX, Address(R13, Heap::TopOffset(space)));

  // RDI: allocation size.
  __ movq(RCX, RAX);
  __ addq(RCX, RDI);
  __ j(CARRY, &slow_case);

  // Check if the allocation fits into the remaining space.
  // RAX: potential new object start.
  // RCX: potential next object start.
  // RDI: allocation size.
  // R13: heap.
  __ cmpq(RCX, Address(R13, Heap::EndOffset(space)));
  __ j(ABOVE_EQUAL, &slow_case);

  // Successfully allocated the object(s), now update top to point to
  // next object start and initialize the object.
  __ movq(Address(R13, Heap::TopOffset(space)), RCX);
  __ addq(RAX, Immediate(kHeapObjectTag));
  __ UpdateAllocationStatsWithSize(cid, RDI, space,
                                   /* inline_isolate = */ false);
  // Initialize the tags.
  // RAX: new object start as a tagged pointer.
  // RDI: allocation size.
  {
    Label size_tag_overflow, done;
    __ cmpq(RDI, Immediate(RawObject::SizeTag::kMaxSizeTag));
    __ j(ABOVE, &size_tag_overflow, Assembler::kNearJump);
    __ shlq(RDI, Immediate(RawObject::kSizeTagPos - kObjectAlignmentLog2));
    __ jmp(&done, Assembler::kNearJump);

    __ Bind(&size_tag_overflow);
    __ movq(RDI, Immediate(0));
    __ Bind(&done);

    // Get the class index and insert it into the tags.
    __ orq(RDI, Immediate(RawObject::ClassIdTag::encode(cid)));
    __ movq(FieldAddress(RAX, Array::tags_offset()), RDI);  // Tags.
  }

  // RAX: new object start as a tagged pointer.
  // Store the type argument field.
  __ InitializeFieldNoBarrier(RAX,
                              FieldAddress(RAX, Array::type_arguments_offset()),
                              RBX);

  // Set the length field.
  __ InitializeFieldNoBarrier(RAX,
                              FieldAddress(RAX, Array::length_offset()),
                              R10);

  // Initialize all array elements to raw_null.
  // RAX: new object start as a tagged pointer.
  // RCX: new object end address.
  // RDI: iterator which initially points to the start of the variable
  // data area to be initialized.
  __ LoadObject(R12, Object::null_object(), PP);
  __ leaq(RDI, FieldAddress(RAX, sizeof(RawArray)));
  Label done;
  Label init_loop;
  __ Bind(&init_loop);
  __ cmpq(RDI, RCX);
#if defined(DEBUG)
  static const bool kJumpLength = Assembler::kFarJump;
#else
  static const bool kJumpLength = Assembler::kNearJump;
#endif  // DEBUG
  __ j(ABOVE_EQUAL, &done, kJumpLength);
  // No generational barrier needed, since we are storing null.
  __ InitializeFieldNoBarrier(RAX, Address(RDI, 0), R12);
  __ addq(RDI, Immediate(kWordSize));
  __ jmp(&init_loop, kJumpLength);
  __ Bind(&done);
  __ ret();  // returns the newly allocated object in RAX.

  // Unable to allocate the array using the fast inline code, just call
  // into the runtime.
  __ Bind(&slow_case);
  // Create a stub frame as we are pushing some objects on the stack before
  // calling into the runtime.
  __ EnterStubFrame();
  // Setup space on stack for return value.
  __ PushObject(Object::null_object(), PP);
  __ pushq(R10);  // Array length as Smi.
  __ pushq(RBX);  // Element type.
  __ CallRuntime(kAllocateArrayRuntimeEntry, 2);
  __ popq(RAX);  // Pop element type argument.
  __ popq(R10);  // Pop array length argument.
  __ popq(RAX);  // Pop return value from return slot.
  __ LeaveStubFrame();
  __ ret();
}


// Called when invoking Dart code from C++ (VM code).
// Input parameters:
//   RSP : points to return address.
//   RDI : entrypoint of the Dart function to call.
//   RSI : arguments descriptor array.
//   RDX : arguments array.
//   RCX : current thread.
void StubCode::GenerateInvokeDartCodeStub(Assembler* assembler) {
  // Save frame pointer coming in.
  __ EnterFrame(0);

  const Register kEntryPointReg = CallingConventions::kArg1Reg;
  const Register kArgDescReg    = CallingConventions::kArg2Reg;
  const Register kArgsReg       = CallingConventions::kArg3Reg;
  const Register kThreadReg     = CallingConventions::kArg4Reg;

  // At this point, the stack looks like:
  // | saved RBP                                      | <-- RBP
  // | saved PC (return to DartEntry::InvokeFunction) |

  const intptr_t kInitialOffset = 1;
  // Save arguments descriptor array.
  const intptr_t kArgumentsDescOffset = -(kInitialOffset) * kWordSize;
  __ pushq(kArgDescReg);

  // Save C++ ABI callee-saved registers.
  __ PushRegisters(CallingConventions::kCalleeSaveCpuRegisters,
                   CallingConventions::kCalleeSaveXmmRegisters);

  // We now load the pool pointer(PP) as we are about to invoke dart code and we
  // could potentially invoke some intrinsic functions which need the PP to be
  // set up.
  __ LoadPoolPointer(PP);

  // If any additional (or fewer) values are pushed, the offsets in
  // kExitLinkSlotFromEntryFp will need to be changed.

  // Set up THR, which caches the current thread in Dart code.
  if (THR != kThreadReg) {
    __ movq(THR, kThreadReg);
  }
  // Load Isolate pointer into kIsolateReg.
  const Register kIsolateReg = RBX;
  __ LoadIsolate(kIsolateReg);

  // Save the current VMTag on the stack.
  __ movq(RAX, Address(kIsolateReg, Isolate::vm_tag_offset()));
  __ pushq(RAX);

  // Mark that the isolate is executing Dart code.
  __ movq(Address(kIsolateReg, Isolate::vm_tag_offset()),
          Immediate(VMTag::kDartTagId));

  // Save top resource and top exit frame info. Use RAX as a temporary register.
  // StackFrameIterator reads the top exit frame info saved in this frame.
  __ movq(RAX, Address(THR, Thread::top_resource_offset()));
  __ pushq(RAX);
  __ movq(Address(THR, Thread::top_resource_offset()),
          Immediate(0));
  __ movq(RAX, Address(THR, Thread::top_exit_frame_info_offset()));
  // The constant kExitLinkSlotFromEntryFp must be kept in sync with the
  // code below.
  __ pushq(RAX);
#if defined(DEBUG)
  {
    Label ok;
    __ leaq(RAX, Address(RBP, kExitLinkSlotFromEntryFp * kWordSize));
    __ cmpq(RAX, RSP);
    __ j(EQUAL, &ok);
    __ Stop("kExitLinkSlotFromEntryFp mismatch");
    __ Bind(&ok);
  }
#endif
  __ movq(Address(THR, Thread::top_exit_frame_info_offset()),
          Immediate(0));

  // Load arguments descriptor array into R10, which is passed to Dart code.
  __ movq(R10, Address(kArgDescReg, VMHandles::kOffsetOfRawPtrInHandle));

  // Push arguments. At this point we only need to preserve kEntryPointReg.
  ASSERT(kEntryPointReg != RDX);

  // Load number of arguments into RBX.
  __ movq(RBX, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
  __ SmiUntag(RBX);

  // Compute address of 'arguments array' data area into RDX.
  __ movq(RDX, Address(kArgsReg, VMHandles::kOffsetOfRawPtrInHandle));
  __ leaq(RDX, FieldAddress(RDX, Array::data_offset()));

  // Set up arguments for the Dart call.
  Label push_arguments;
  Label done_push_arguments;
  __ testq(RBX, RBX);  // check if there are arguments.
  __ j(ZERO, &done_push_arguments, Assembler::kNearJump);
  __ movq(RAX, Immediate(0));
  __ Bind(&push_arguments);
  __ pushq(Address(RDX, RAX, TIMES_8, 0));
  __ incq(RAX);
  __ cmpq(RAX, RBX);
  __ j(LESS, &push_arguments, Assembler::kNearJump);
  __ Bind(&done_push_arguments);

  // Call the Dart code entrypoint.
  __ call(kEntryPointReg);  // R10 is the arguments descriptor array.

  // Read the saved arguments descriptor array to obtain the number of passed
  // arguments.
  __ movq(kArgDescReg, Address(RBP, kArgumentsDescOffset));
  __ movq(R10, Address(kArgDescReg, VMHandles::kOffsetOfRawPtrInHandle));
  __ movq(RDX, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
  // Get rid of arguments pushed on the stack.
  __ leaq(RSP, Address(RSP, RDX, TIMES_4, 0));  // RDX is a Smi.

  // Restore the saved top exit frame info and top resource back into the
  // Isolate structure.
  __ LoadIsolate(kIsolateReg);
  __ popq(Address(THR, Thread::top_exit_frame_info_offset()));
  __ popq(Address(THR, Thread::top_resource_offset()));

  // Restore the current VMTag from the stack.
  __ popq(Address(kIsolateReg, Isolate::vm_tag_offset()));

  // Restore C++ ABI callee-saved registers.
  __ PopRegisters(CallingConventions::kCalleeSaveCpuRegisters,
                  CallingConventions::kCalleeSaveXmmRegisters);

  // Restore the frame pointer.
  __ LeaveFrame();

  __ ret();
}


// Called for inline allocation of contexts.
// Input:
// R10: number of context variables.
// Output:
// RAX: new allocated RawContext object.
void StubCode::GenerateAllocateContextStub(Assembler* assembler) {
  __ LoadObject(R12, Object::null_object(), PP);
  if (FLAG_inline_alloc) {
    Label slow_case;
    // First compute the rounded instance size.
    // R10: number of context variables.
    intptr_t fixed_size = (sizeof(RawContext) + kObjectAlignment - 1);
    __ leaq(R13, Address(R10, TIMES_8, fixed_size));
    __ andq(R13, Immediate(-kObjectAlignment));

    // Now allocate the object.
    // R10: number of context variables.
    const intptr_t cid = kContextCid;
    Heap::Space space = Heap::SpaceForAllocation(cid);
    __ LoadIsolate(RCX);
    __ movq(RCX, Address(RCX, Isolate::heap_offset()));
    __ movq(RAX, Address(RCX, Heap::TopOffset(space)));
    __ addq(R13, RAX);
    // Check if the allocation fits into the remaining space.
    // RAX: potential new object.
    // R13: potential next object start.
    // R10: number of context variables.
    // RCX: heap.
    __ cmpq(R13, Address(RCX, Heap::EndOffset(space)));
    if (FLAG_use_slow_path) {
      __ jmp(&slow_case);
    } else {
      __ j(ABOVE_EQUAL, &slow_case);
    }

    // Successfully allocated the object, now update top to point to
    // next object start and initialize the object.
    // RAX: new object.
    // R13: next object start.
    // R10: number of context variables.
    // RCX: heap.
    __ movq(Address(RCX, Heap::TopOffset(space)), R13);
    // R13: Size of allocation in bytes.
    __ subq(R13, RAX);
    __ addq(RAX, Immediate(kHeapObjectTag));
    // Generate isolate-independent code to allow sharing between isolates.
    __ UpdateAllocationStatsWithSize(cid, R13, space,
                                     /* inline_isolate */ false);

    // Calculate the size tag.
    // RAX: new object.
    // R10: number of context variables.
    {
      Label size_tag_overflow, done;
      __ leaq(R13, Address(R10, TIMES_8, fixed_size));
      __ andq(R13, Immediate(-kObjectAlignment));
      __ cmpq(R13, Immediate(RawObject::SizeTag::kMaxSizeTag));
      __ j(ABOVE, &size_tag_overflow, Assembler::kNearJump);
      __ shlq(R13, Immediate(RawObject::kSizeTagPos - kObjectAlignmentLog2));
      __ jmp(&done);

      __ Bind(&size_tag_overflow);
      // Set overflow size tag value.
      __ movq(R13, Immediate(0));

      __ Bind(&done);
      // RAX: new object.
      // R10: number of context variables.
      // R13: size and bit tags.
      __ orq(R13,
             Immediate(RawObject::ClassIdTag::encode(cid)));
      __ movq(FieldAddress(RAX, Context::tags_offset()), R13);  // Tags.
    }

    // Setup up number of context variables field.
    // RAX: new object.
    // R10: number of context variables as integer value (not object).
    __ movq(FieldAddress(RAX, Context::num_variables_offset()), R10);

    // Setup the parent field.
    // RAX: new object.
    // R10: number of context variables.
    // No generational barrier needed, since we are storing null.
    __ InitializeFieldNoBarrier(RAX,
                                FieldAddress(RAX, Context::parent_offset()),
                                R12);

    // Initialize the context variables.
    // RAX: new object.
    // R10: number of context variables.
    {
      Label loop, entry;
      __ leaq(R13, FieldAddress(RAX, Context::variable_offset(0)));
#if defined(DEBUG)
      static const bool kJumpLength = Assembler::kFarJump;
#else
      static const bool kJumpLength = Assembler::kNearJump;
#endif  // DEBUG
      __ jmp(&entry, kJumpLength);
      __ Bind(&loop);
      __ decq(R10);
      // No generational barrier needed, since we are storing null.
      __ InitializeFieldNoBarrier(RAX,
                                  Address(R13, R10, TIMES_8, 0),
                                  R12);
      __ Bind(&entry);
      __ cmpq(R10, Immediate(0));
      __ j(NOT_EQUAL, &loop, Assembler::kNearJump);
    }

    // Done allocating and initializing the context.
    // RAX: new object.
    __ ret();

    __ Bind(&slow_case);
  }
  // Create a stub frame.
  __ EnterStubFrame();
  __ pushq(R12);  // Setup space on stack for the return value.
  __ SmiTag(R10);
  __ pushq(R10);  // Push number of context variables.
  __ CallRuntime(kAllocateContextRuntimeEntry, 1);  // Allocate context.
  __ popq(RAX);  // Pop number of context variables argument.
  __ popq(RAX);  // Pop the new context object.
  // RAX: new object
  // Restore the frame pointer.
  __ LeaveStubFrame();
  __ ret();
}


DECLARE_LEAF_RUNTIME_ENTRY(void, StoreBufferBlockProcess, Isolate* isolate);

// Helper stub to implement Assembler::StoreIntoObject.
// Input parameters:
//   RDX: Address being stored
void StubCode::GenerateUpdateStoreBufferStub(Assembler* assembler) {
  // Save registers being destroyed.
  __ pushq(RAX);
  __ pushq(RCX);

  Label add_to_buffer;
  // Check whether this object has already been remembered. Skip adding to the
  // store buffer if the object is in the store buffer already.
  // Spilled: RAX, RCX
  // RDX: Address being stored
  Label reload;
  __ Bind(&reload);
  __ movq(RCX, FieldAddress(RDX, Object::tags_offset()));
  __ testq(RCX, Immediate(1 << RawObject::kRememberedBit));
  __ j(EQUAL, &add_to_buffer, Assembler::kNearJump);
  __ popq(RCX);
  __ popq(RAX);
  __ ret();

  // Update the tags that this object has been remembered.
  // RDX: Address being stored
  // RAX: Current tag value
  __ Bind(&add_to_buffer);
  __ movq(RCX, RAX);
  __ orq(RCX, Immediate(1 << RawObject::kRememberedBit));
  // Compare the tag word with RAX, update to RCX if unchanged.
  __ LockCmpxchgq(FieldAddress(RDX, Object::tags_offset()), RCX);
  __ j(NOT_EQUAL, &reload);

  // Load the StoreBuffer block out of the thread. Then load top_ out of the
  // StoreBufferBlock and add the address to the pointers_.
  // RDX: Address being stored
  __ movq(RAX, Address(THR, Thread::store_buffer_block_offset()));
  __ movl(RCX, Address(RAX, StoreBufferBlock::top_offset()));
  __ movq(Address(RAX, RCX, TIMES_8, StoreBufferBlock::pointers_offset()), RDX);

  // Increment top_ and check for overflow.
  // RCX: top_
  // RAX: StoreBufferBlock
  Label L;
  __ incq(RCX);
  __ movl(Address(RAX, StoreBufferBlock::top_offset()), RCX);
  __ cmpl(RCX, Immediate(StoreBufferBlock::kSize));
  // Restore values.
  __ popq(RCX);
  __ popq(RAX);
  __ j(EQUAL, &L, Assembler::kNearJump);
  __ ret();

  // Handle overflow: Call the runtime leaf function.
  __ Bind(&L);
  // Setup frame, push callee-saved registers.
  __ EnterCallRuntimeFrame(0);
  __ movq(CallingConventions::kArg1Reg, THR);
  __ CallRuntime(kStoreBufferBlockProcessRuntimeEntry, 1);
  __ LeaveCallRuntimeFrame();
  __ ret();
}


// Called for inline allocation of objects.
// Input parameters:
//   RSP + 8 : type arguments object (only if class is parameterized).
//   RSP : points to return address.
void StubCode::GenerateAllocationStubForClass(
    Assembler* assembler, const Class& cls,
    uword* entry_patch_offset, uword* patch_code_pc_offset) {
  // Must load pool pointer before being able to patch.
  Register new_pp = R13;
  __ LoadPoolPointer(new_pp);
  *entry_patch_offset = assembler->CodeSize();

  const intptr_t kObjectTypeArgumentsOffset = 1 * kWordSize;
  // The generated code is different if the class is parameterized.
  const bool is_cls_parameterized = cls.NumTypeArguments() > 0;
  ASSERT(!is_cls_parameterized ||
         (cls.type_arguments_field_offset() != Class::kNoTypeArguments));
  // kInlineInstanceSize is a constant used as a threshold for determining
  // when the object initialization should be done as a loop or as
  // straight line code.
  const int kInlineInstanceSize = 12;  // In words.
  const intptr_t instance_size = cls.instance_size();
  ASSERT(instance_size > 0);
  __ LoadObject(R12, Object::null_object(), PP);
  if (is_cls_parameterized) {
    __ movq(RDX, Address(RSP, kObjectTypeArgumentsOffset));
    // RDX: instantiated type arguments.
  }
  if (FLAG_inline_alloc && Heap::IsAllocatableInNewSpace(instance_size) &&
      !cls.trace_allocation()) {
    Label slow_case;
    // Allocate the object and update top to point to
    // next object start and initialize the allocated object.
    // RDX: instantiated type arguments (if is_cls_parameterized).
    Heap* heap = Isolate::Current()->heap();
    Heap::Space space = Heap::SpaceForAllocation(cls.id());
    __ movq(RCX, Immediate(heap->TopAddress(space)));
    __ movq(RAX, Address(RCX, 0));
    __ leaq(RBX, Address(RAX, instance_size));
    // Check if the allocation fits into the remaining space.
    // RAX: potential new object start.
    // RBX: potential next object start.
    // RCX: heap top address.
    __ movq(R13, Immediate(heap->EndAddress(space)));
    __ cmpq(RBX, Address(R13, 0));
    if (FLAG_use_slow_path) {
      __ jmp(&slow_case);
    } else {
      __ j(ABOVE_EQUAL, &slow_case);
    }
    __ movq(Address(RCX, 0), RBX);
    __ UpdateAllocationStats(cls.id(), space);

    // RAX: new object start (untagged).
    // RBX: next object start.
    // RDX: new object type arguments (if is_cls_parameterized).
    // Set the tags.
    uword tags = 0;
    tags = RawObject::SizeTag::update(instance_size, tags);
    ASSERT(cls.id() != kIllegalCid);
    tags = RawObject::ClassIdTag::update(cls.id(), tags);
    __ movq(Address(RAX, Instance::tags_offset()), Immediate(tags));
    __ addq(RAX, Immediate(kHeapObjectTag));

    // Initialize the remaining words of the object.
    // RAX: new object (tagged).
    // RBX: next object start.
    // RDX: new object type arguments (if is_cls_parameterized).
    // R12: raw null.
    // First try inlining the initialization without a loop.
    if (instance_size < (kInlineInstanceSize * kWordSize)) {
      // Check if the object contains any non-header fields.
      // Small objects are initialized using a consecutive set of writes.
      for (intptr_t current_offset = Instance::NextFieldOffset();
           current_offset < instance_size;
           current_offset += kWordSize) {
        __ InitializeFieldNoBarrier(RAX,
                                    FieldAddress(RAX, current_offset),
                                    R12);
      }
    } else {
      __ leaq(RCX, FieldAddress(RAX, Instance::NextFieldOffset()));
      // Loop until the whole object is initialized.
      // RAX: new object (tagged).
      // RBX: next object start.
      // RCX: next word to be initialized.
      // RDX: new object type arguments (if is_cls_parameterized).
      Label init_loop;
      Label done;
      __ Bind(&init_loop);
      __ cmpq(RCX, RBX);
#if defined(DEBUG)
      static const bool kJumpLength = Assembler::kFarJump;
#else
      static const bool kJumpLength = Assembler::kNearJump;
#endif  // DEBUG
      __ j(ABOVE_EQUAL, &done, kJumpLength);
      __ InitializeFieldNoBarrier(RAX, Address(RCX, 0), R12);
      __ addq(RCX, Immediate(kWordSize));
      __ jmp(&init_loop, Assembler::kNearJump);
      __ Bind(&done);
    }
    if (is_cls_parameterized) {
      // RDX: new object type arguments.
      // Set the type arguments in the new object.
      intptr_t offset = cls.type_arguments_field_offset();
      __ InitializeFieldNoBarrier(RAX, FieldAddress(RAX, offset), RDX);
    }
    // Done allocating and initializing the instance.
    // RAX: new object (tagged).
    __ ret();

    __ Bind(&slow_case);
  }
  // If is_cls_parameterized:
  // RDX: new object type arguments.
  // Create a stub frame.
  __ EnterStubFrame();  // Uses PP to access class object.
  __ pushq(R12);  // Setup space on stack for return value.
  __ PushObject(cls, PP);  // Push class of object to be allocated.
  if (is_cls_parameterized) {
    __ pushq(RDX);  // Push type arguments of object to be allocated.
  } else {
    __ pushq(R12);  // Push null type arguments.
  }
  __ CallRuntime(kAllocateObjectRuntimeEntry, 2);  // Allocate object.
  __ popq(RAX);  // Pop argument (type arguments of object).
  __ popq(RAX);  // Pop argument (class of object).
  __ popq(RAX);  // Pop result (newly allocated object).
  // RAX: new object
  // Restore the frame pointer.
  __ LeaveStubFrame();
  __ ret();
  *patch_code_pc_offset = assembler->CodeSize();
  __ JmpPatchable(&StubCode::FixAllocationStubTargetLabel(), new_pp);
}


// Called for invoking "dynamic noSuchMethod(Invocation invocation)" function
// from the entry code of a dart function after an error in passed argument
// name or number is detected.
// Input parameters:
//   RSP : points to return address.
//   RSP + 8 : address of last argument.
//   R10 : arguments descriptor array.
void StubCode::GenerateCallClosureNoSuchMethodStub(Assembler* assembler) {
  __ EnterStubFrame();

  // Load the receiver.
  __ movq(R13, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
  __ movq(RAX, Address(RBP, R13, TIMES_4, kParamEndSlotFromFp * kWordSize));

  __ LoadObject(R12, Object::null_object(), PP);
  __ pushq(R12);  // Setup space on stack for result from noSuchMethod.
  __ pushq(RAX);  // Receiver.
  __ pushq(R10);  // Arguments descriptor array.

  __ movq(R10, R13);  // Smi-tagged arguments array length.
  PushArgumentsArray(assembler);

  const intptr_t kNumArgs = 3;
  __ CallRuntime(kInvokeClosureNoSuchMethodRuntimeEntry, kNumArgs);
  // noSuchMethod on closures always throws an error, so it will never return.
  __ int3();
}


// Cannot use function object from ICData as it may be the inlined
// function and not the top-scope function.
void StubCode::GenerateOptimizedUsageCounterIncrement(Assembler* assembler) {
  Register ic_reg = RBX;
  Register func_reg = RDI;
  if (FLAG_trace_optimized_ic_calls) {
    __ EnterStubFrame();
    __ pushq(func_reg);     // Preserve
    __ pushq(ic_reg);       // Preserve.
    __ pushq(ic_reg);       // Argument.
    __ pushq(func_reg);     // Argument.
    __ CallRuntime(kTraceICCallRuntimeEntry, 2);
    __ popq(RAX);          // Discard argument;
    __ popq(RAX);          // Discard argument;
    __ popq(ic_reg);       // Restore.
    __ popq(func_reg);     // Restore.
    __ LeaveStubFrame();
  }
  __ incl(FieldAddress(func_reg, Function::usage_counter_offset()));
}


// Loads function into 'temp_reg', preserves 'ic_reg'.
void StubCode::GenerateUsageCounterIncrement(Assembler* assembler,
                                             Register temp_reg) {
  if (FLAG_optimization_counter_threshold >= 0) {
    Register ic_reg = RBX;
    Register func_reg = temp_reg;
    ASSERT(ic_reg != func_reg);
    __ Comment("Increment function counter");
    __ movq(func_reg, FieldAddress(ic_reg, ICData::owner_offset()));
    __ incl(FieldAddress(func_reg, Function::usage_counter_offset()));
  }
}


// Note: RBX must be preserved.
// Attempt a quick Smi operation for known operations ('kind'). The ICData
// must have been primed with a Smi/Smi check that will be used for counting
// the invocations.
static void EmitFastSmiOp(Assembler* assembler,
                          Token::Kind kind,
                          intptr_t num_args,
                          Label* not_smi_or_overflow,
                          bool should_update_result_range) {
  __ Comment("Fast Smi op");
  if (FLAG_throw_on_javascript_int_overflow) {
    // The overflow check is more complex than implemented below.
    return;
  }
  ASSERT(num_args == 2);
  __ movq(RCX, Address(RSP, + 1 * kWordSize));  // Right
  __ movq(RAX, Address(RSP, + 2 * kWordSize));  // Left.
  __ movq(R12, RCX);
  __ orq(R12, RAX);
  __ testq(R12, Immediate(kSmiTagMask));
  __ j(NOT_ZERO, not_smi_or_overflow);
  switch (kind) {
    case Token::kADD: {
      __ addq(RAX, RCX);
      __ j(OVERFLOW, not_smi_or_overflow);
      break;
    }
    case Token::kSUB: {
      __ subq(RAX, RCX);
      __ j(OVERFLOW, not_smi_or_overflow);
      break;
    }
    case Token::kEQ: {
      Label done, is_true;
      __ cmpq(RAX, RCX);
      __ j(EQUAL, &is_true, Assembler::kNearJump);
      __ LoadObject(RAX, Bool::False(), PP);
      __ jmp(&done, Assembler::kNearJump);
      __ Bind(&is_true);
      __ LoadObject(RAX, Bool::True(), PP);
      __ Bind(&done);
      break;
    }
    default: UNIMPLEMENTED();
  }


  if (should_update_result_range) {
    Label done;
    __ movq(RSI, RAX);
    __ UpdateRangeFeedback(RSI, 2, RBX, RCX, &done);
    __ Bind(&done);
  }

  // RBX: IC data object (preserved).
  __ movq(R12, FieldAddress(RBX, ICData::ic_data_offset()));
  // R12: ic_data_array with check entries: classes and target functions.
  __ leaq(R12, FieldAddress(R12, Array::data_offset()));
  // R12: points directly to the first ic data array element.
#if defined(DEBUG)
  // Check that first entry is for Smi/Smi.
  Label error, ok;
  const Immediate& imm_smi_cid =
      Immediate(reinterpret_cast<intptr_t>(Smi::New(kSmiCid)));
  __ cmpq(Address(R12, 0 * kWordSize), imm_smi_cid);
  __ j(NOT_EQUAL, &error, Assembler::kNearJump);
  __ cmpq(Address(R12, 1 * kWordSize), imm_smi_cid);
  __ j(EQUAL, &ok, Assembler::kNearJump);
  __ Bind(&error);
  __ Stop("Incorrect IC data");
  __ Bind(&ok);
#endif

  if (FLAG_optimization_counter_threshold >= 0) {
    const intptr_t count_offset = ICData::CountIndexFor(num_args) * kWordSize;
    // Update counter.
    __ movq(R8, Address(R12, count_offset));
    __ addq(R8, Immediate(Smi::RawValue(1)));
    __ movq(R13, Immediate(Smi::RawValue(Smi::kMaxValue)));
    __ cmovnoq(R13, R8);
    __ StoreIntoSmiField(Address(R12, count_offset), R13);
  }

  __ ret();
}


// Generate inline cache check for 'num_args'.
//  RBX: Inline cache data object.
//  TOS(0): return address
// Control flow:
// - If receiver is null -> jump to IC miss.
// - If receiver is Smi -> load Smi class.
// - If receiver is not-Smi -> load receiver's class.
// - Check if 'num_args' (including receiver) match any IC data group.
// - Match found -> jump to target.
// - Match not found -> jump to IC miss.
void StubCode::GenerateNArgsCheckInlineCacheStub(
    Assembler* assembler,
    intptr_t num_args,
    const RuntimeEntry& handle_ic_miss,
    Token::Kind kind,
    RangeCollectionMode range_collection_mode,
    bool optimized) {
  ASSERT(num_args > 0);
#if defined(DEBUG)
  { Label ok;
    // Check that the IC data array has NumArgsTested() == num_args.
    // 'NumArgsTested' is stored in the least significant bits of 'state_bits'.
    __ movl(RCX, FieldAddress(RBX, ICData::state_bits_offset()));
    ASSERT(ICData::NumArgsTestedShift() == 0);  // No shift needed.
    __ andq(RCX, Immediate(ICData::NumArgsTestedMask()));
    __ cmpq(RCX, Immediate(num_args));
    __ j(EQUAL, &ok, Assembler::kNearJump);
    __ Stop("Incorrect stub for IC data");
    __ Bind(&ok);
  }
#endif  // DEBUG

  Label stepping, done_stepping;
  if (FLAG_support_debugger && !optimized) {
    __ Comment("Check single stepping");
    __ LoadIsolate(RAX);
    __ cmpb(Address(RAX, Isolate::single_step_offset()), Immediate(0));
    __ j(NOT_EQUAL, &stepping);
    __ Bind(&done_stepping);
  }

  __ Comment("Range feedback collection");
  Label not_smi_or_overflow;
  if (range_collection_mode == kCollectRanges) {
    ASSERT((num_args == 1) || (num_args == 2));
    if (num_args == 2) {
      __ movq(RAX, Address(RSP, + 2 * kWordSize));
      __ UpdateRangeFeedback(RAX, 0, RBX, RCX, &not_smi_or_overflow);
    }

    __ movq(RAX, Address(RSP, + 1 * kWordSize));
    __ UpdateRangeFeedback(RAX, (num_args - 1), RBX, RCX, &not_smi_or_overflow);
  }
  if (kind != Token::kILLEGAL) {
    EmitFastSmiOp(
        assembler,
        kind,
        num_args,
        &not_smi_or_overflow,
        range_collection_mode == kCollectRanges);
  }
  __ Bind(&not_smi_or_overflow);

  __ Comment("Extract ICData initial values and receiver cid");
  // Load arguments descriptor into R10.
  __ movq(R10, FieldAddress(RBX, ICData::arguments_descriptor_offset()));
  // Loop that checks if there is an IC data match.
  Label loop, update, test, found;
  // RBX: IC data object (preserved).
  __ movq(R12, FieldAddress(RBX, ICData::ic_data_offset()));
  // R12: ic_data_array with check entries: classes and target functions.
  __ leaq(R12, FieldAddress(R12, Array::data_offset()));
  // R12: points directly to the first ic data array element.

  // Get the receiver's class ID (first read number of arguments from
  // arguments descriptor array and then access the receiver from the stack).
  __ movq(RAX, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
  __ movq(R13, Address(RSP, RAX, TIMES_4, 0));  // RAX (argument count) is Smi.
  __ LoadTaggedClassIdMayBeSmi(RAX, R13);
  // RAX: receiver's class ID as smi.
  __ movq(R13, Address(R12, 0));  // First class ID (Smi) to check.
  __ jmp(&test);

  __ Comment("ICData loop");
  __ Bind(&loop);
  for (int i = 0; i < num_args; i++) {
    if (i > 0) {
      // If not the first, load the next argument's class ID.
      __ movq(RAX, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
      __ movq(R13, Address(RSP, RAX, TIMES_4, - i * kWordSize));
      __ LoadTaggedClassIdMayBeSmi(RAX, R13);
      // RAX: next argument class ID (smi).
      __ movq(R13, Address(R12, i * kWordSize));
      // R13: next class ID to check (smi).
    }
    __ cmpq(RAX, R13);  // Class id match?
    if (i < (num_args - 1)) {
      __ j(NOT_EQUAL, &update);  // Continue.
    } else {
      // Last check, all checks before matched.
      __ j(EQUAL, &found);  // Break.
    }
  }
  __ Bind(&update);
  // Reload receiver class ID.  It has not been destroyed when num_args == 1.
  if (num_args > 1) {
    __ movq(RAX, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
    __ movq(R13, Address(RSP, RAX, TIMES_4, 0));
    __ LoadTaggedClassIdMayBeSmi(RAX, R13);
  }

  const intptr_t entry_size = ICData::TestEntryLengthFor(num_args) * kWordSize;
  __ addq(R12, Immediate(entry_size));  // Next entry.
  __ movq(R13, Address(R12, 0));  // Next class ID.

  __ Bind(&test);
  __ cmpq(R13, Immediate(Smi::RawValue(kIllegalCid)));  // Done?
  __ j(NOT_EQUAL, &loop, Assembler::kNearJump);

  __ Comment("IC miss");
  __ LoadObject(R12, Object::null_object(), PP);
  // Compute address of arguments (first read number of arguments from
  // arguments descriptor array and then compute address on the stack).
  __ movq(RAX, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
  __ leaq(RAX, Address(RSP, RAX, TIMES_4, 0));  // RAX is Smi.
  __ EnterStubFrame();
  __ pushq(R10);  // Preserve arguments descriptor array.
  __ pushq(RBX);  // Preserve IC data object.
  __ pushq(R12);  // Setup space on stack for result (target code object).
  // Push call arguments.
  for (intptr_t i = 0; i < num_args; i++) {
    __ movq(RCX, Address(RAX, -kWordSize * i));
    __ pushq(RCX);
  }
  __ pushq(RBX);  // Pass IC data object.
  __ CallRuntime(handle_ic_miss, num_args + 1);
  // Remove the call arguments pushed earlier, including the IC data object.
  for (intptr_t i = 0; i < num_args + 1; i++) {
    __ popq(RAX);
  }
  __ popq(RAX);  // Pop returned function object into RAX.
  __ popq(RBX);  // Restore IC data array.
  __ popq(R10);  // Restore arguments descriptor array.
  __ LeaveStubFrame();
  Label call_target_function;
  if (!FLAG_lazy_dispatchers) {
    GenerateDispatcherCode(assembler, &call_target_function);
  } else {
    __ jmp(&call_target_function);
  }

  __ Bind(&found);
  // R12: Pointer to an IC data check group.
  const intptr_t target_offset = ICData::TargetIndexFor(num_args) * kWordSize;
  const intptr_t count_offset = ICData::CountIndexFor(num_args) * kWordSize;
  __ movq(RAX, Address(R12, target_offset));

  if (FLAG_optimization_counter_threshold >= 0) {
    // Update counter.
    __ Comment("Update caller's counter");
    __ movq(R8, Address(R12, count_offset));
    __ addq(R8, Immediate(Smi::RawValue(1)));
    __ movq(R13, Immediate(Smi::RawValue(Smi::kMaxValue)));
    __ cmovnoq(R13, R8);
    __ StoreIntoSmiField(Address(R12, count_offset), R13);
  }

  __ Comment("Call target");
  __ Bind(&call_target_function);
  // RAX: Target function.
  Label is_compiled;
  __ movq(RCX, FieldAddress(RAX, Function::instructions_offset()));
  __ addq(RCX, Immediate(Instructions::HeaderSize() - kHeapObjectTag));
  if (range_collection_mode == kCollectRanges) {
    __ movq(R8, Address(RSP, + 1 * kWordSize));
    if (num_args == 2) {
      __ movq(R13, Address(RSP, + 2 * kWordSize));
    }
    __ EnterStubFrame();
    __ pushq(RBX);
    if (num_args == 2) {
      __ pushq(R13);
    }
    __ pushq(R8);
    __ call(RCX);

    Label done;
    __ movq(RDX, RAX);
    __ movq(RBX, Address(RBP, kFirstLocalSlotFromFp * kWordSize));
    __ UpdateRangeFeedback(RDX, 2, RBX, RCX, &done);
    __ Bind(&done);
    __ LeaveStubFrame();
    __ ret();
  } else {
    __ jmp(RCX);
  }

  if (FLAG_support_debugger && !optimized) {
    __ Bind(&stepping);
    __ EnterStubFrame();
    __ pushq(RBX);
    __ CallRuntime(kSingleStepHandlerRuntimeEntry, 0);
    __ popq(RBX);
    __ LeaveStubFrame();
    __ jmp(&done_stepping);
  }
}


// Use inline cache data array to invoke the target or continue in inline
// cache miss handler. Stub for 1-argument check (receiver class).
//  RBX: Inline cache data object.
//  TOS(0): Return address.
// Inline cache data object structure:
// 0: function-name
// 1: N, number of arguments checked.
// 2 .. (length - 1): group of checks, each check containing:
//   - N classes.
//   - 1 target function.
void StubCode::GenerateOneArgCheckInlineCacheStub(Assembler* assembler) {
  GenerateUsageCounterIncrement(assembler, RCX);
  GenerateNArgsCheckInlineCacheStub(assembler, 1,
      kInlineCacheMissHandlerOneArgRuntimeEntry,
      Token::kILLEGAL,
      kIgnoreRanges);
}


void StubCode::GenerateTwoArgsCheckInlineCacheStub(Assembler* assembler) {
  GenerateUsageCounterIncrement(assembler, RCX);
  GenerateNArgsCheckInlineCacheStub(assembler, 2,
      kInlineCacheMissHandlerTwoArgsRuntimeEntry,
      Token::kILLEGAL,
      kIgnoreRanges);
}


void StubCode::GenerateSmiAddInlineCacheStub(Assembler* assembler) {
  GenerateUsageCounterIncrement(assembler, RCX);
  GenerateNArgsCheckInlineCacheStub(assembler, 2,
      kInlineCacheMissHandlerTwoArgsRuntimeEntry,
      Token::kADD,
      kCollectRanges);
}


void StubCode::GenerateSmiSubInlineCacheStub(Assembler* assembler) {
  GenerateUsageCounterIncrement(assembler, RCX);
  GenerateNArgsCheckInlineCacheStub(assembler, 2,
      kInlineCacheMissHandlerTwoArgsRuntimeEntry,
      Token::kSUB,
      kCollectRanges);
}


void StubCode::GenerateSmiEqualInlineCacheStub(Assembler* assembler) {
  GenerateUsageCounterIncrement(assembler, RCX);
  GenerateNArgsCheckInlineCacheStub(assembler, 2,
      kInlineCacheMissHandlerTwoArgsRuntimeEntry,
      Token::kEQ,
      kIgnoreRanges);
}


void StubCode::GenerateUnaryRangeCollectingInlineCacheStub(
    Assembler* assembler) {
  GenerateUsageCounterIncrement(assembler, RCX);
  GenerateNArgsCheckInlineCacheStub(assembler, 1,
      kInlineCacheMissHandlerOneArgRuntimeEntry,
      Token::kILLEGAL,
      kCollectRanges);
}


void StubCode::GenerateBinaryRangeCollectingInlineCacheStub(
    Assembler* assembler) {
  GenerateUsageCounterIncrement(assembler, RCX);
  GenerateNArgsCheckInlineCacheStub(assembler, 2,
      kInlineCacheMissHandlerTwoArgsRuntimeEntry,
      Token::kILLEGAL,
      kCollectRanges);
}


// Use inline cache data array to invoke the target or continue in inline
// cache miss handler. Stub for 1-argument check (receiver class).
//  RDI: function which counter needs to be incremented.
//  RBX: Inline cache data object.
//  TOS(0): Return address.
// Inline cache data object structure:
// 0: function-name
// 1: N, number of arguments checked.
// 2 .. (length - 1): group of checks, each check containing:
//   - N classes.
//   - 1 target function.
void StubCode::GenerateOneArgOptimizedCheckInlineCacheStub(
    Assembler* assembler) {
  GenerateOptimizedUsageCounterIncrement(assembler);
  GenerateNArgsCheckInlineCacheStub(assembler, 1,
      kInlineCacheMissHandlerOneArgRuntimeEntry,
      Token::kILLEGAL,
      kIgnoreRanges, true /* optimized */);
}


void StubCode::GenerateTwoArgsOptimizedCheckInlineCacheStub(
    Assembler* assembler) {
  GenerateOptimizedUsageCounterIncrement(assembler);
  GenerateNArgsCheckInlineCacheStub(assembler, 2,
      kInlineCacheMissHandlerTwoArgsRuntimeEntry,
      Token::kILLEGAL,
      kIgnoreRanges, true /* optimized */);
}


// Intermediary stub between a static call and its target. ICData contains
// the target function and the call count.
// RBX: ICData
void StubCode::GenerateZeroArgsUnoptimizedStaticCallStub(Assembler* assembler) {
  GenerateUsageCounterIncrement(assembler, RCX);
#if defined(DEBUG)
  { Label ok;
    // Check that the IC data array has NumArgsTested() == 0.
    // 'NumArgsTested' is stored in the least significant bits of 'state_bits'.
    __ movl(RCX, FieldAddress(RBX, ICData::state_bits_offset()));
    ASSERT(ICData::NumArgsTestedShift() == 0);  // No shift needed.
    __ andq(RCX, Immediate(ICData::NumArgsTestedMask()));
    __ cmpq(RCX, Immediate(0));
    __ j(EQUAL, &ok, Assembler::kNearJump);
    __ Stop("Incorrect IC data for unoptimized static call");
    __ Bind(&ok);
  }
#endif  // DEBUG

  // Check single stepping.
  Label stepping, done_stepping;
  if (FLAG_support_debugger) {
    __ LoadIsolate(RAX);
    __ movzxb(RAX, Address(RAX, Isolate::single_step_offset()));
    __ cmpq(RAX, Immediate(0));
#if defined(DEBUG)
      static const bool kJumpLength = Assembler::kFarJump;
#else
      static const bool kJumpLength = Assembler::kNearJump;
#endif  // DEBUG
    __ j(NOT_EQUAL, &stepping, kJumpLength);
    __ Bind(&done_stepping);
  }

  // RBX: IC data object (preserved).
  __ movq(R12, FieldAddress(RBX, ICData::ic_data_offset()));
  // R12: ic_data_array with entries: target functions and count.
  __ leaq(R12, FieldAddress(R12, Array::data_offset()));
  // R12: points directly to the first ic data array element.
  const intptr_t target_offset = ICData::TargetIndexFor(0) * kWordSize;
  const intptr_t count_offset = ICData::CountIndexFor(0) * kWordSize;

  if (FLAG_optimization_counter_threshold >= 0) {
    // Increment count for this call.
    __ movq(R8, Address(R12, count_offset));
    __ addq(R8, Immediate(Smi::RawValue(1)));
    __ movq(R13, Immediate(Smi::RawValue(Smi::kMaxValue)));
    __ cmovnoq(R13, R8);
    __ StoreIntoSmiField(Address(R12, count_offset), R13);
  }

  // Load arguments descriptor into R10.
  __ movq(R10, FieldAddress(RBX, ICData::arguments_descriptor_offset()));

  // Get function and call it, if possible.
  __ movq(RAX, Address(R12, target_offset));
  __ movq(RCX, FieldAddress(RAX, Function::instructions_offset()));
  // RCX: Target instructions.
  __ addq(RCX, Immediate(Instructions::HeaderSize() - kHeapObjectTag));
  __ jmp(RCX);

  if (FLAG_support_debugger) {
    __ Bind(&stepping);
    __ EnterStubFrame();
    __ pushq(RBX);  // Preserve IC data object.
    __ CallRuntime(kSingleStepHandlerRuntimeEntry, 0);
    __ popq(RBX);
    __ LeaveStubFrame();
    __ jmp(&done_stepping, Assembler::kNearJump);
  }
}


void StubCode::GenerateOneArgUnoptimizedStaticCallStub(Assembler* assembler) {
  GenerateUsageCounterIncrement(assembler, RCX);
  GenerateNArgsCheckInlineCacheStub(
      assembler,
      1,
      kStaticCallMissHandlerOneArgRuntimeEntry,
      Token::kILLEGAL,
      kIgnoreRanges);
}


void StubCode::GenerateTwoArgsUnoptimizedStaticCallStub(Assembler* assembler) {
  GenerateUsageCounterIncrement(assembler, RCX);
  GenerateNArgsCheckInlineCacheStub(assembler,
      2,
      kStaticCallMissHandlerTwoArgsRuntimeEntry,
      Token::kILLEGAL,
      kIgnoreRanges);
}


// Stub for compiling a function and jumping to the compiled code.
// RCX: IC-Data (for methods).
// R10: Arguments descriptor.
// RAX: Function.
void StubCode::GenerateLazyCompileStub(Assembler* assembler) {
  __ EnterStubFrame();
  __ pushq(R10);  // Preserve arguments descriptor array.
  __ pushq(RBX);  // Preserve IC data object.
  __ pushq(RAX);  // Pass function.
  __ CallRuntime(kCompileFunctionRuntimeEntry, 1);
  __ popq(RAX);  // Restore function.
  __ popq(RBX);  // Restore IC data array.
  __ popq(R10);  // Restore arguments descriptor array.
  __ LeaveStubFrame();

  __ movq(RAX, FieldAddress(RAX, Function::instructions_offset()));
  __ addq(RAX, Immediate(Instructions::HeaderSize() - kHeapObjectTag));
  __ jmp(RAX);
}


// RBX: Contains an ICData.
// TOS(0): return address (Dart code).
void StubCode::GenerateICCallBreakpointStub(Assembler* assembler) {
  __ EnterStubFrame();
  // Preserve IC data.
  __ pushq(RBX);
  // Room for result. Debugger stub returns address of the
  // unpatched runtime stub.
  __ LoadObject(R12, Object::null_object(), PP);
  __ pushq(R12);  // Room for result.
  __ CallRuntime(kBreakpointRuntimeHandlerRuntimeEntry, 0);
  __ popq(RAX);  // Address of original.
  __ popq(RBX);  // Restore IC data.
  __ LeaveStubFrame();
  __ jmp(RAX);   // Jump to original stub.
}


//  TOS(0): return address (Dart code).
void StubCode::GenerateRuntimeCallBreakpointStub(Assembler* assembler) {
  __ EnterStubFrame();
  // Room for result. Debugger stub returns address of the
  // unpatched runtime stub.
  __ LoadObject(R12, Object::null_object(), PP);
  __ pushq(R12);  // Room for result.
  __ CallRuntime(kBreakpointRuntimeHandlerRuntimeEntry, 0);
  __ popq(RAX);  // Address of original.
  __ LeaveStubFrame();
  __ jmp(RAX);   // Jump to original stub.
}


// Called only from unoptimized code.
void StubCode::GenerateDebugStepCheckStub(Assembler* assembler) {
  // Check single stepping.
  Label stepping, done_stepping;
  __ LoadIsolate(RAX);
  __ movzxb(RAX, Address(RAX, Isolate::single_step_offset()));
  __ cmpq(RAX, Immediate(0));
  __ j(NOT_EQUAL, &stepping, Assembler::kNearJump);
  __ Bind(&done_stepping);
  __ ret();

  __ Bind(&stepping);
  __ EnterStubFrame();
  __ CallRuntime(kSingleStepHandlerRuntimeEntry, 0);
  __ LeaveStubFrame();
  __ jmp(&done_stepping, Assembler::kNearJump);
}


// Used to check class and type arguments. Arguments passed on stack:
// TOS + 0: return address.
// TOS + 1: instantiator type arguments (can be NULL).
// TOS + 2: instance.
// TOS + 3: SubtypeTestCache.
// Result in RCX: null -> not found, otherwise result (true or false).
static void GenerateSubtypeNTestCacheStub(Assembler* assembler, int n) {
  ASSERT((1 <= n) && (n <= 3));
  const intptr_t kInstantiatorTypeArgumentsInBytes = 1 * kWordSize;
  const intptr_t kInstanceOffsetInBytes = 2 * kWordSize;
  const intptr_t kCacheOffsetInBytes = 3 * kWordSize;
  __ movq(RAX, Address(RSP, kInstanceOffsetInBytes));
  __ LoadObject(R12, Object::null_object(), PP);
  if (n > 1) {
    __ LoadClass(R10, RAX, kNoRegister);
    // Compute instance type arguments into R13.
    Label has_no_type_arguments;
    __ movq(R13, R12);
    __ movl(RDI, FieldAddress(R10,
        Class::type_arguments_field_offset_in_words_offset()));
    __ cmpl(RDI, Immediate(Class::kNoTypeArguments));
    __ j(EQUAL, &has_no_type_arguments, Assembler::kNearJump);
    __ movq(R13, FieldAddress(RAX, RDI, TIMES_8, 0));
    __ Bind(&has_no_type_arguments);
  }
  __ LoadClassId(R10, RAX);
  // RAX: instance, R10: instance class id.
  // R13: instance type arguments or null, used only if n > 1.
  __ movq(RDX, Address(RSP, kCacheOffsetInBytes));
  // RDX: SubtypeTestCache.
  __ movq(RDX, FieldAddress(RDX, SubtypeTestCache::cache_offset()));
  __ addq(RDX, Immediate(Array::data_offset() - kHeapObjectTag));
  // RDX: Entry start.
  // R10: instance class id.
  // R13: instance type arguments.
  Label loop, found, not_found, next_iteration;
  __ SmiTag(R10);
  __ Bind(&loop);
  __ movq(RDI, Address(RDX, kWordSize * SubtypeTestCache::kInstanceClassId));
  __ cmpq(RDI, R12);
  __ j(EQUAL, &not_found, Assembler::kNearJump);
  __ cmpq(RDI, R10);
  if (n == 1) {
    __ j(EQUAL, &found, Assembler::kNearJump);
  } else {
    __ j(NOT_EQUAL, &next_iteration, Assembler::kNearJump);
    __ movq(RDI,
        Address(RDX, kWordSize * SubtypeTestCache::kInstanceTypeArguments));
    __ cmpq(RDI, R13);
    if (n == 2) {
      __ j(EQUAL, &found, Assembler::kNearJump);
    } else {
      __ j(NOT_EQUAL, &next_iteration, Assembler::kNearJump);
      __ movq(RDI,
          Address(RDX,
                  kWordSize * SubtypeTestCache::kInstantiatorTypeArguments));
      __ cmpq(RDI, Address(RSP, kInstantiatorTypeArgumentsInBytes));
      __ j(EQUAL, &found, Assembler::kNearJump);
    }
  }

  __ Bind(&next_iteration);
  __ addq(RDX, Immediate(kWordSize * SubtypeTestCache::kTestEntryLength));
  __ jmp(&loop, Assembler::kNearJump);
  // Fall through to not found.
  __ Bind(&not_found);
  __ movq(RCX, R12);
  __ ret();

  __ Bind(&found);
  __ movq(RCX, Address(RDX, kWordSize * SubtypeTestCache::kTestResult));
  __ ret();
}


// Used to check class and type arguments. Arguments passed on stack:
// TOS + 0: return address.
// TOS + 1: instantiator type arguments or NULL.
// TOS + 2: instance.
// TOS + 3: cache array.
// Result in RCX: null -> not found, otherwise result (true or false).
void StubCode::GenerateSubtype1TestCacheStub(Assembler* assembler) {
  GenerateSubtypeNTestCacheStub(assembler, 1);
}


// Used to check class and type arguments. Arguments passed on stack:
// TOS + 0: return address.
// TOS + 1: instantiator type arguments or NULL.
// TOS + 2: instance.
// TOS + 3: cache array.
// Result in RCX: null -> not found, otherwise result (true or false).
void StubCode::GenerateSubtype2TestCacheStub(Assembler* assembler) {
  GenerateSubtypeNTestCacheStub(assembler, 2);
}


// Used to check class and type arguments. Arguments passed on stack:
// TOS + 0: return address.
// TOS + 1: instantiator type arguments.
// TOS + 2: instance.
// TOS + 3: cache array.
// Result in RCX: null -> not found, otherwise result (true or false).
void StubCode::GenerateSubtype3TestCacheStub(Assembler* assembler) {
  GenerateSubtypeNTestCacheStub(assembler, 3);
}


// Return the current stack pointer address, used to stack alignment
// checks.
// TOS + 0: return address
// Result in RAX.
void StubCode::GenerateGetStackPointerStub(Assembler* assembler) {
  __ leaq(RAX, Address(RSP, kWordSize));
  __ ret();
}


// Jump to the exception or error handler.
// TOS + 0: return address
// Arg1: program counter
// Arg2: stack pointer
// Arg3: frame_pointer
// Arg4: exception object
// Arg5: stacktrace object
// Arg6: thread
// No Result.
void StubCode::GenerateJumpToExceptionHandlerStub(Assembler* assembler) {
  ASSERT(kExceptionObjectReg == RAX);
  ASSERT(kStackTraceObjectReg == RDX);
  ASSERT(CallingConventions::kArg4Reg != kStackTraceObjectReg);
  ASSERT(CallingConventions::kArg1Reg != kStackTraceObjectReg);

#if defined(_WIN64)
  Register stacktrace_reg = RBX;
  __ movq(stacktrace_reg, Address(RSP, 5 * kWordSize));
  __ movq(THR, Address(RSP, 6 * kWordSize));
  Register isolate_reg = RDI;
#else
  Register stacktrace_reg = CallingConventions::kArg5Reg;
  __ movq(THR, CallingConventions::kArg6Reg);
  Register isolate_reg = CallingConventions::kArg6Reg;
#endif
  __ LoadIsolate(isolate_reg);
  __ movq(RBP, CallingConventions::kArg3Reg);
  __ movq(RSP, CallingConventions::kArg2Reg);
  __ movq(kStackTraceObjectReg, stacktrace_reg);
  __ movq(kExceptionObjectReg, CallingConventions::kArg4Reg);
  // Set the tag.
  __ movq(Address(isolate_reg, Isolate::vm_tag_offset()),
          Immediate(VMTag::kDartTagId));
  // Clear top exit frame.
  __ movq(Address(THR, Thread::top_exit_frame_info_offset()),
          Immediate(0));
  __ jmp(CallingConventions::kArg1Reg);  // Jump to the exception handler code.
}


// Calls to the runtime to optimize the given function.
// RDI: function to be reoptimized.
// R10: argument descriptor (preserved).
void StubCode::GenerateOptimizeFunctionStub(Assembler* assembler) {
  __ EnterStubFrame();
  __ LoadObject(R12, Object::null_object(), PP);
  __ pushq(R10);
  __ pushq(R12);  // Setup space on stack for return value.
  __ pushq(RDI);
  __ CallRuntime(kOptimizeInvokedFunctionRuntimeEntry, 1);
  __ popq(RAX);  // Disard argument.
  __ popq(RAX);  // Get Code object.
  __ popq(R10);  // Restore argument descriptor.
  __ movq(RAX, FieldAddress(RAX, Code::instructions_offset()));
  __ addq(RAX, Immediate(Instructions::HeaderSize() - kHeapObjectTag));
  __ LeaveStubFrame();
  __ jmp(RAX);
  __ int3();
}


DECLARE_LEAF_RUNTIME_ENTRY(intptr_t,
                           BigintCompare,
                           RawBigint* left,
                           RawBigint* right);


// Does identical check (object references are equal or not equal) with special
// checks for boxed numbers.
// Left and right are pushed on stack.
// Return ZF set.
// Note: A Mint cannot contain a value that would fit in Smi, a Bigint
// cannot contain a value that fits in Mint or Smi.
static void GenerateIdenticalWithNumberCheckStub(Assembler* assembler,
                                                 const Register left,
                                                 const Register right) {
  Label reference_compare, done, check_mint, check_bigint;
  // If any of the arguments is Smi do reference compare.
  __ testq(left, Immediate(kSmiTagMask));
  __ j(ZERO, &reference_compare);
  __ testq(right, Immediate(kSmiTagMask));
  __ j(ZERO, &reference_compare);

  // Value compare for two doubles.
  __ CompareClassId(left, kDoubleCid);
  __ j(NOT_EQUAL, &check_mint, Assembler::kNearJump);
  __ CompareClassId(right, kDoubleCid);
  __ j(NOT_EQUAL, &done, Assembler::kNearJump);

  // Double values bitwise compare.
  __ movq(left, FieldAddress(left, Double::value_offset()));
  __ cmpq(left, FieldAddress(right, Double::value_offset()));
  __ jmp(&done, Assembler::kNearJump);

  __ Bind(&check_mint);
  __ CompareClassId(left, kMintCid);
  __ j(NOT_EQUAL, &check_bigint, Assembler::kNearJump);
  __ CompareClassId(right, kMintCid);
  __ j(NOT_EQUAL, &done, Assembler::kNearJump);
  __ movq(left, FieldAddress(left, Mint::value_offset()));
  __ cmpq(left, FieldAddress(right, Mint::value_offset()));
  __ jmp(&done, Assembler::kNearJump);

  __ Bind(&check_bigint);
  __ CompareClassId(left, kBigintCid);
  __ j(NOT_EQUAL, &reference_compare, Assembler::kNearJump);
  __ CompareClassId(right, kBigintCid);
  __ j(NOT_EQUAL, &done, Assembler::kNearJump);
  __ EnterStubFrame();
  __ ReserveAlignedFrameSpace(0);
  __ movq(CallingConventions::kArg1Reg, left);
  __ movq(CallingConventions::kArg2Reg, right);
  __ CallRuntime(kBigintCompareRuntimeEntry, 2);
  // Result in RAX, 0 means equal.
  __ LeaveStubFrame();
  __ cmpq(RAX, Immediate(0));
  __ jmp(&done);

  __ Bind(&reference_compare);
  __ cmpq(left, right);
  __ Bind(&done);
}


// Called only from unoptimized code. All relevant registers have been saved.
// TOS + 0: return address
// TOS + 1: right argument.
// TOS + 2: left argument.
// Returns ZF set.
void StubCode::GenerateUnoptimizedIdenticalWithNumberCheckStub(
    Assembler* assembler) {
  // Check single stepping.
  Label stepping, done_stepping;
  if (FLAG_support_debugger) {
    __ LoadIsolate(RAX);
    __ movzxb(RAX, Address(RAX, Isolate::single_step_offset()));
    __ cmpq(RAX, Immediate(0));
    __ j(NOT_EQUAL, &stepping);
    __ Bind(&done_stepping);
  }

  const Register left = RAX;
  const Register right = RDX;

  __ movq(left, Address(RSP, 2 * kWordSize));
  __ movq(right, Address(RSP, 1 * kWordSize));
  GenerateIdenticalWithNumberCheckStub(assembler, left, right);
  __ ret();

  if (FLAG_support_debugger) {
    __ Bind(&stepping);
    __ EnterStubFrame();
    __ CallRuntime(kSingleStepHandlerRuntimeEntry, 0);
    __ LeaveStubFrame();
    __ jmp(&done_stepping);
  }
}


// Called from optimized code only.
// TOS + 0: return address
// TOS + 1: right argument.
// TOS + 2: left argument.
// Returns ZF set.
void StubCode::GenerateOptimizedIdenticalWithNumberCheckStub(
    Assembler* assembler) {
  const Register left = RAX;
  const Register right = RDX;

  __ movq(left, Address(RSP, 2 * kWordSize));
  __ movq(right, Address(RSP, 1 * kWordSize));
  GenerateIdenticalWithNumberCheckStub(assembler, left, right);
  __ ret();
}


void StubCode::EmitMegamorphicLookup(
    Assembler* assembler, Register receiver, Register cache, Register target) {
  ASSERT((cache != RAX) && (cache != RDI));
  __ LoadTaggedClassIdMayBeSmi(RAX, receiver);
  // RAX: class ID of the receiver (smi).
  __ movq(RDI, FieldAddress(cache, MegamorphicCache::buckets_offset()));
  __ movq(RBX, FieldAddress(cache, MegamorphicCache::mask_offset()));
  // RDI: cache buckets array.
  // RBX: mask.
  __ movq(RCX, RAX);

  Label loop, update, call_target_function;
  __ jmp(&loop);

  __ Bind(&update);
  __ AddImmediate(RCX, Immediate(Smi::RawValue(1)), PP);
  __ Bind(&loop);
  __ andq(RCX, RBX);
  const intptr_t base = Array::data_offset();
  // RCX is smi tagged, but table entries are two words, so TIMES_8.
  __ movq(RDX, FieldAddress(RDI, RCX, TIMES_8, base));

  ASSERT(kIllegalCid == 0);
  __ testq(RDX, RDX);
  __ j(ZERO, &call_target_function, Assembler::kNearJump);
  __ cmpq(RDX, RAX);
  __ j(NOT_EQUAL, &update, Assembler::kNearJump);

  __ Bind(&call_target_function);
  // Call the target found in the cache.  For a class id match, this is a
  // proper target for the given name and arguments descriptor.  If the
  // illegal class id was found, the target is a cache miss handler that can
  // be invoked as a normal Dart function.
  __ movq(RAX, FieldAddress(RDI, RCX, TIMES_8, base + kWordSize));
  __ movq(target, FieldAddress(RAX, Function::instructions_offset()));
  // TODO(srdjan): Evaluate performance impact of moving the instruction below
  // to the call site, instead of having it here.
  __ AddImmediate(
      target, Immediate(Instructions::HeaderSize() - kHeapObjectTag), PP);
}


// Called from megamorphic calls.
//  RDI: receiver.
//  RBX: lookup cache.
// Result:
//  RCX: entry point.
void StubCode::GenerateMegamorphicLookupStub(Assembler* assembler) {
  EmitMegamorphicLookup(assembler, RDI, RBX, RCX);
  __ ret();
}

}  // namespace dart

#endif  // defined TARGET_ARCH_X64
