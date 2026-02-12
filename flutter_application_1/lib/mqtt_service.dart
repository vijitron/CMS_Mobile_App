// lib/mqtt_service.dart
// ✅ WORKS ON BOTH WEB AND ANDROID/iOS
// This file uses conditional imports — Dart picks the right implementation automatically.

export 'mqtt_service_stub.dart'
    if (dart.library.html) 'mqtt_service_web.dart'
    if (dart.library.io) 'mqtt_service_mobile.dart';