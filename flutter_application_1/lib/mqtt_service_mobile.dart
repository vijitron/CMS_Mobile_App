// lib/mqtt_service_mobile.dart
// ✅ ANDROID / iOS / DESKTOP — uses TCP on port 1883 (standard MQTT port)
import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  static final MQTTService _instance = MQTTService._internal();
  factory MQTTService() => _instance;
  MQTTService._internal();

  MqttServerClient? client;

  final StreamController<String> _messageStream =
      StreamController<String>.broadcast();
  Stream<String> get messageStream => _messageStream.stream;

  Future<bool> connect() async {
    try {
      print('🚀 MQTT MOBILE: Connecting via TCP...');

      client = MqttServerClient.withPort(
        '172.29.197.87',  // ← Your broker IP (same machine, no ws:// prefix)
        'client_mobile_${DateTime.now().millisecondsSinceEpoch}',
        1883,             // ← Standard MQTT TCP port (NOT 9001 WebSocket)
      );

      client!.logging(on: false);
      client!.keepAlivePeriod = 60;
      client!.autoReconnect = true;
      client!.setProtocolV311();

      // Important for Android: set a reasonable timeout
      client!.connectTimeoutPeriod = 10000;

      client!.connectionMessage = MqttConnectMessage()
          .withClientIdentifier(
              'flutter_mobile_${DateTime.now().millisecondsSinceEpoch}')
          .startClean()
          .withWillQos(MqttQos.atMostOnce);

      await client!.connect();

      if (client!.connectionStatus!.state == MqttConnectionState.connected) {
        print('✅ MQTT MOBILE: Connected!');
        client!.subscribe('crane/monitor', MqttQos.atLeastOnce);
        _listen();
        return true;
      }

      print('❌ MQTT MOBILE: Failed — ${client!.connectionStatus}');
      return false;
    } catch (e) {
      print('🚨 MQTT MOBILE ERROR: $e');
      return false;
    }
  }

  void _listen() {
    client!.updates!.listen((events) {
      final MqttPublishMessage recMsg =
          events[0].payload as MqttPublishMessage;
      final message = utf8.decode(recMsg.payload.message!);
      print('📩 MQTT MOBILE RECEIVED → $message');
      _messageStream.add(message);
    });
  }

  void publish(String topic, String message) {
    if (!isConnected) {
      print('⚠️ MQTT MOBILE: Cannot publish — not connected');
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print('📤 MQTT MOBILE SENT → $topic : $message');
  }

  bool get isConnected =>
      client?.connectionStatus?.state == MqttConnectionState.connected;
}