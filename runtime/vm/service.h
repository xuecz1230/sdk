// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef VM_SERVICE_H_
#define VM_SERVICE_H_

#include "include/dart_tools_api.h"

#include "vm/allocation.h"
#include "vm/object_id_ring.h"
#include "vm/os_thread.h"

namespace dart {

class Array;
class EmbedderServiceHandler;
class GCEvent;
class GrowableObjectArray;
class Instance;
class Isolate;
class JSONStream;
class Object;
class RawInstance;
class ServiceEvent;
class String;

class ServiceIdZone {
 public:
  ServiceIdZone();
  virtual ~ServiceIdZone();

  // Returned string will be zone allocated.
  virtual char* GetServiceId(const Object& obj) = 0;

 private:
};


class RingServiceIdZone : public ServiceIdZone {
 public:
  explicit RingServiceIdZone(ObjectIdRing* ring, ObjectIdRing::IdPolicy policy);
  virtual ~RingServiceIdZone();

  // Returned string will be zone allocated.
  virtual char* GetServiceId(const Object& obj);

  void set_policy(ObjectIdRing::IdPolicy policy) {
    policy_ = policy;
  }

  ObjectIdRing::IdPolicy policy() const {
    return policy_;
  }

 private:
  ObjectIdRing* ring_;
  ObjectIdRing::IdPolicy policy_;
};


class StreamInfo {
 public:
  explicit StreamInfo(const char* id) : id_(id), enabled_(false) {}

  const char* id() { return id_; }

  void set_enabled(bool value) { enabled_ = value; }
  bool enabled() { return enabled_; }

 private:
  const char* id_;
  bool enabled_;
};


class Service : public AllStatic {
 public:
  // Handles a message which is not directed to an isolate.
  static void HandleRootMessage(const Array& message);

  // Handles a message which is directed to a particular isolate.
  static void HandleIsolateMessage(Isolate* isolate, const Array& message);

  static void HandleEvent(ServiceEvent* event);

  static void RegisterIsolateEmbedderCallback(
      const char* name,
      Dart_ServiceRequestCallback callback,
      void* user_data);

  static void RegisterRootEmbedderCallback(
      const char* name,
      Dart_ServiceRequestCallback callback,
      void* user_data);

  static void SetEmbedderStreamCallbacks(
      Dart_ServiceStreamListenCallback listen_callback,
      Dart_ServiceStreamCancelCallback cancel_callback);

  static void SendEchoEvent(Isolate* isolate, const char* text);
  static void SendGraphEvent(Isolate* isolate);
  static void SendInspectEvent(Isolate* isolate, const Object& inspectee);

  static void SendEmbedderEvent(Isolate* isolate,
                                const char* stream_id,
                                const char* event_kind,
                                const uint8_t* bytes,
                                intptr_t bytes_len);

  static void SendLogEvent(Isolate* isolate,
                           int64_t sequence_number,
                           int64_t timestamp,
                           intptr_t level,
                           const String& name,
                           const String& message,
                           const Instance& zone,
                           const Object& error,
                           const Instance& stack_trace);

  // Well-known streams.
  static StreamInfo isolate_stream;
  static StreamInfo debug_stream;
  static StreamInfo gc_stream;
  static StreamInfo echo_stream;
  static StreamInfo graph_stream;
  static StreamInfo logging_stream;

  static bool ListenStream(const char* stream_id);
  static void CancelStream(const char* stream_id);

  static Dart_ServiceStreamListenCallback stream_listen_callback() {
    return stream_listen_callback_;
  }
  static Dart_ServiceStreamCancelCallback stream_cancel_callback() {
    return stream_cancel_callback_;
  }

 private:
  static void InvokeMethod(Isolate* isolate, const Array& message);

  static void EmbedderHandleMessage(EmbedderServiceHandler* handler,
                                    JSONStream* js);

  static EmbedderServiceHandler* FindIsolateEmbedderHandler(const char* name);
  static EmbedderServiceHandler* FindRootEmbedderHandler(const char* name);

  static void SendEvent(const char* stream_id,
                        const char* event_type,
                        const Object& eventMessage);

  // Does not take ownership of 'data'.
  static void SendEventWithData(const char* stream_id,
                                const char* event_type,
                                const String& meta,
                                const uint8_t* data,
                                intptr_t size);

  static void PostEvent(const char* stream_id,
                        const char* kind,
                        JSONStream* event);

  static EmbedderServiceHandler* isolate_service_handler_head_;
  static EmbedderServiceHandler* root_service_handler_head_;
  static Dart_ServiceStreamListenCallback stream_listen_callback_;
  static Dart_ServiceStreamCancelCallback stream_cancel_callback_;

  static bool needs_isolate_events_;
  static bool needs_debug_events_;
  static bool needs_gc_events_;
  static bool needs_echo_events_;
  static bool needs_graph_events_;
};

}  // namespace dart

#endif  // VM_SERVICE_H_
