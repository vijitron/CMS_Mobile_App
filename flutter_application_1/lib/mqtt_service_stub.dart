// lib/mqtt_service_stub.dart
// Fallback stub — should never actually be used at runtime.
import 'dart:async';

class MQTTService {
  static final MQTTService _instance = MQTTService._internal();
  factory MQTTService() => _instance;
  MQTTService._internal();

  final StreamController<String> _messageStream =
      StreamController<String>.broadcast();
  Stream<String> get messageStream => _messageStream.stream;

  Future<bool> connect() async => false;
  void publish(String topic, String message) {}
  bool get isConnected => false;
}