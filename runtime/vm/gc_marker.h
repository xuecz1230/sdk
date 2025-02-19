// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef VM_GC_MARKER_H_
#define VM_GC_MARKER_H_

#include "vm/allocation.h"

namespace dart {

// Forward declarations.
class HandleVisitor;
class Heap;
class Isolate;
class MarkingVisitor;
class ObjectPointerVisitor;
class PageSpace;
class RawWeakProperty;

// The class GCMarker is used to mark reachable old generation objects as part
// of the mark-sweep collection. The marking bit used is defined in RawObject.
class GCMarker : public ValueObject {
 public:
  explicit GCMarker(Heap* heap) : heap_(heap), marked_bytes_(0) { }
  ~GCMarker() { }

  void MarkObjects(Isolate* isolate,
                   PageSpace* page_space,
                   bool invoke_api_callbacks,
                   bool collect_code);

  intptr_t marked_words() { return marked_bytes_ >> kWordSizeLog2; }

 private:
  void Prologue(Isolate* isolate, bool invoke_api_callbacks);
  void Epilogue(Isolate* isolate, bool invoke_api_callbacks);
  void IterateRoots(Isolate* isolate,
                    ObjectPointerVisitor* visitor,
                    bool visit_prologue_weak_persistent_handles);
  void IterateWeakRoots(Isolate* isolate,
                        HandleVisitor* visitor,
                        bool visit_prologue_weak_persistent_handles);
  void IterateWeakReferences(Isolate* isolate, MarkingVisitor* visitor);
  void DrainMarkingStack(Isolate* isolate, MarkingVisitor* visitor);
  void ProcessWeakTables(PageSpace* page_space);
  void ProcessObjectIdTable(Isolate* isolate);


  Heap* heap_;
  uintptr_t marked_bytes_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(GCMarker);
};

}  // namespace dart

#endif  // VM_GC_MARKER_H_
