// lib/mqtt_service_web.dart
// ✅ FLUTTER WEB ONLY — uses WebSocket (ws://) on port 9001
import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

class MQTTService {
  static final MQTTService _instance = MQTTService._internal();
  factory MQTTService() => _instance;
  MQTTService._internal();

  MqttBrowserClient? client;

  final StreamController<String> _messageStream =
      StreamController<String>.broadcast();
  Stream<String> get messageStream => _messageStream.stream;

  Future<bool> connect() async {
    try {
      print('🚀 MQTT WEB: Connecting via WebSocket...');

      client = MqttBrowserClient.withPort(
        'ws://172.29.197.87',
        'client_web_${DateTime.now().millisecondsSinceEpoch}',
        9001,
      );

      client!.logging(on: false);
      client!.keepAlivePeriod = 60;
      client!.autoReconnect = true;
      client!.setProtocolV311();

      client!.connectionMessage = MqttConnectMessage()
          .withClientIdentifier(
              'flutter_web_${DateTime.now().millisecondsSinceEpoch}')
          .startClean()
          .withWillQos(MqttQos.atMostOnce);

      await client!.connect();

      if (client!.connectionStatus!.state == MqttConnectionState.connected) {
        print('✅ MQTT WEB: Connected!');
        client!.subscribe('crane/monitor', MqttQos.atLeastOnce);
        _listen();
        return true;
      }

      print('❌ MQTT WEB: Failed — ${client!.connectionStatus}');
      return false;
    } catch (e) {
      print('🚨 MQTT WEB ERROR: $e');
      return false;
    }
  }

  void _listen() {
    client!.updates!.listen((events) {
      final MqttPublishMessage recMsg =
          events[0].payload as MqttPublishMessage;
      final message = utf8.decode(recMsg.payload.message!);
      print('📩 MQTT WEB RECEIVED → $message');
      _messageStream.add(message);
    });
  }

  void publish(String topic, String message) {
    if (!isConnected) {
      print('⚠️ MQTT WEB: Cannot publish — not connected');
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print('📤 MQTT WEB SENT → $topic : $message');
  }

  bool get isConnected =>
      client?.connectionStatus?.state == MqttConnectionState.connected;
}