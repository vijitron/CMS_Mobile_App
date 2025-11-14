// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized access layer for all Supabase calls used by the app.
/// - All methods are null/shape-safe and return [] or false on error,
///   so your UI won't crash if the schema is still empty.
/// - Adjust table names below if your actual tables differ.
class SupabaseService {
  static final SupabaseClient supabase = Supabase.instance.client;

  // ======================================================
  // ===============  GENERIC HELPERS  ====================
  // ======================================================

  /// Convenience: read whole table with optional order.
  static Future<List<Map<String, dynamic>>> _readTable(
    String table, {
    String? orderBy,
    bool ascending = false,
    int? limit,
  }) async {
    try {
      final query = supabase.from(table).select();

      // Apply ordering and limits safely
      PostgrestTransformBuilder request = query;
      if (orderBy != null) {
        request = request.order(orderBy, ascending: ascending);
      }
      if (limit != null) {
        request = request.limit(limit);
      }

      final response = await request;

      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      } else if (response is Map && response['data'] is List) {
        // Handle legacy or alternate response structure
        return (response['data'] as List).cast<Map<String, dynamic>>();
      }

      return [];
    } catch (e, st) {
      print('❌ Error reading table "$table": $e');
      print(st);
      return [];
    }
  }

  /// Convenience: generic insert.
  static Future<bool> _insert(String table, Map<String, dynamic> values) async {
    try {
      await supabase.from(table).insert(values);
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Insert error on "$table": $e');
      return false;
    }
  }

  /// Convenience: generic update by equality filter.
  static Future<bool> _update(
    String table,
    Map<String, dynamic> values, {
    required String eqCol,
    required dynamic eqVal,
  }) async {
    try {
      await supabase.from(table).update(values).eq(eqCol, eqVal);
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Update error on "$table": $e');
      return false;
    }
  }

  /// Convenience: generic delete by equality filter.
  static Future<bool> _delete(
    String table, {
    required String eqCol,
    required dynamic eqVal,
  }) async {
    try {
      await supabase.from(table).delete().eq(eqCol, eqVal);
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Delete error on "$table": $e');
      return false;
    }
  }

  // ======================================================
  // =================  REALTIME STREAMS  =================
  // ======================================================

  /// Example: realtime stream for a table with a known primary key column.
  /// NOTE: Choose the correct primary key name for each table if you add more.
  static Stream<List<Map<String, dynamic>>> listenToLoadChanges() {
    return supabase
        .from('load_readings')
        .stream(primaryKey: ['id'])
        .order('timestamp', ascending: false);
  }

  // ======================================================
  // ===================  LOAD READINGS  ==================
  // ======================================================

  static Future<List<Map<String, dynamic>>> getLoadReadings() async {
    return _readTable('load_readings', orderBy: 'timestamp', ascending: false);
  }

  /// Insert new load reading
  static Future<bool> insertLoad({
    required String craneId,
    required double loadWeight,
    required double capacity,
    required double percentage,
    required String safetyStatus,
  }) {
    return _insert('load_readings', {
      'crane_id': craneId,
      'load_weight': loadWeight,
      'capacity': capacity,
      'percentage': percentage,
      'safety_status': safetyStatus,
      // timestamp defaults in DB if set; otherwise add: 'timestamp': DateTime.now().toIso8601String()
    });
  }

  /// Update existing load reading by row id
  static Future<bool> updateLoad({
    required dynamic id, // can be int/uuid/text
    double? loadWeight,
    double? capacity,
    double? percentage,
    String? safetyStatus,
  }) {
    final body = <String, dynamic>{};
    if (loadWeight != null) body['load_weight'] = loadWeight;
    if (capacity != null) body['capacity'] = capacity;
    if (percentage != null) body['percentage'] = percentage;
    if (safetyStatus != null) body['safety_status'] = safetyStatus;
    if (body.isEmpty) return Future.value(true);
    return _update('load_readings', body, eqCol: 'id', eqVal: id);
  }

  /// Delete load reading by row id
  static Future<bool> deleteLoad(dynamic id) {
    return _delete('load_readings', eqCol: 'id', eqVal: id);
  }

  // ======================================================
  // =================  VIBRATION DATA  ===================
  // ======================================================

  static Future<List<Map<String, dynamic>>> getVibrationData() async {
    return _readTable('vibration_data', orderBy: 'timestamp', ascending: false);
  }

  // ======================================================
  // ==================  ENERGY USAGE  ====================
  // ======================================================

  static Future<List<Map<String, dynamic>>> getEnergyUsage() async {
    return _readTable('energy_usage', orderBy: 'timestamp', ascending: false);
  }

  // ======================================================
  // ================  TEMPERATURE DATA  ==================
  // ======================================================

  static Future<List<Map<String, dynamic>>> getTemperatureData() async {
    return _readTable(
      'temperature_data',
      orderBy: 'timestamp',
      ascending: false,
    );
  }

  // ======================================================
  // ===================  BRAKE STATUS  ===================
  // ======================================================

  static Future<List<Map<String, dynamic>>> getBrakeStatus() async {
    return _readTable('brake_status', orderBy: 'timestamp', ascending: false);
  }

  // Optional helpers for brake_status CRUD if you need them in dialogs:
  static Future<bool> insertBrakeStatus({
    required String craneId,
    required String brakePosition, // engaged/disengaged/partial
    required double wearLevel, // %
    required double pressure,
    required String status, // normal/maintenance/critical
    String? lastMaintenance, // yyyy-mm-dd
  }) {
    return _insert('brake_status', {
      'crane_id': craneId,
      'brake_position': brakePosition,
      'wear_level': wearLevel,
      'pressure': pressure,
      'status': status,
      if (lastMaintenance != null) 'last_maintenance': lastMaintenance,
    });
  }

  static Future<bool> updateBrakeStatus({
    required dynamic id,
    String? craneId,
    String? brakePosition,
    double? wearLevel,
    double? pressure,
    String? status,
    String? lastMaintenance,
  }) {
    final body = <String, dynamic>{};
    if (craneId != null) body['crane_id'] = craneId;
    if (brakePosition != null) body['brake_position'] = brakePosition;
    if (wearLevel != null) body['wear_level'] = wearLevel;
    if (pressure != null) body['pressure'] = pressure;
    if (status != null) body['status'] = status;
    if (lastMaintenance != null) body['last_maintenance'] = lastMaintenance;
    if (body.isEmpty) return Future.value(true);
    return _update('brake_status', body, eqCol: 'id', eqVal: id);
  }

  static Future<bool> deleteBrakeStatus(dynamic id) {
    return _delete('brake_status', eqCol: 'id', eqVal: id);
  }

  // ======================================================
  // ==================  ZONE LOCATIONS  ==================
  // ======================================================

  static Future<List<Map<String, dynamic>>> getZoneLocations() async {
    return _readTable('zone_locations', orderBy: 'timestamp', ascending: false);
  }

  // ======================================================
  // =====================  ALERTS  =======================
  // ======================================================

  /// Required by Alerts page
  static Future<List<Map<String, dynamic>>> getAlerts() async {
    return _readTable('alerts', orderBy: 'created_at', ascending: false);
  }

  static Future<bool> addAlert(
    String craneId,
    String type,
    String message,
    String severity,
  ) {
    return _insert('alerts', {
      'crane_id': craneId,
      'alert_type': type,
      'message': message,
      'severity': severity, // e.g., critical/high/warning/info
    });
  }

  static Future<bool> markAlertAsResolved(String alertId) {
    return _update('alerts', {'resolved': true}, eqCol: 'id', eqVal: alertId);
  }

  // ======================================================
  // ======================  LOGS  ========================
  // ======================================================

  static Future<List<Map<String, dynamic>>> getErrorLogs() async {
    return _readTable('error_logs', orderBy: 'timestamp', ascending: false);
  }

  /// Used by TestConnection page
  static Future<List<Map<String, dynamic>>> getOperationsLog() async {
    // Change table name if yours is different (e.g., "operations")
    return _readTable('operations_log', orderBy: 'timestamp', ascending: false);
  }

  // ======================================================
  // =====================  REPORTS  ======================
  // ======================================================

  static Future<List<Map<String, dynamic>>> getReports() async {
    return _readTable('reports', orderBy: 'created_at', ascending: false);
  }

  static Future<List<Map<String, dynamic>>> getDataExports() async {
    return _readTable('data_exports', orderBy: 'created_at', ascending: false);
  }

  // ======================================================
  // =================  MACHINES / CRANES  ================
  // ======================================================

  /// Required by Dashboard and TestConnection
  /// NOTE: If your crane table is named differently, change 'machines'.
  static Future<List<Map<String, dynamic>>> getMachines() async {
    return _readTable('machines', orderBy: 'created_at', ascending: false);
  }

  static Future<bool> insertMachine({
    required String machineId,
    required String name,
    required String model,
    required String location,
    required String status, // e.g., working/idle/off/overload/error
    String? installedDate, // yyyy-mm-dd
    String? lastServiceDate, // yyyy-mm-dd
  }) {
    return _insert('machines', {
      'machine_id': machineId,
      'name': name,
      'model': model,
      'location': location,
      'status': status,
      if (installedDate != null) 'installed_date': installedDate,
      if (lastServiceDate != null) 'last_service_date': lastServiceDate,
    });
  }

  static Future<bool> updateMachine({
    required dynamic id,
    String? machineId,
    String? name,
    String? model,
    String? location,
    String? status,
    String? installedDate,
    String? lastServiceDate,
  }) {
    final body = <String, dynamic>{};
    if (machineId != null) body['machine_id'] = machineId;
    if (name != null) body['name'] = name;
    if (model != null) body['model'] = model;
    if (location != null) body['location'] = location;
    if (status != null) body['status'] = status;
    if (installedDate != null) body['installed_date'] = installedDate;
    if (lastServiceDate != null) body['last_service_date'] = lastServiceDate;
    if (body.isEmpty) return Future.value(true);
    return _update('machines', body, eqCol: 'id', eqVal: id);
  }

  static Future<bool> deleteMachine(dynamic id) {
    return _delete('machines', eqCol: 'id', eqVal: id);
  }

  // ======================================================
  // ====================  IOT GATEWAYS  ==================
  // ======================================================

  static Future<List<Map<String, dynamic>>> getIotGateways() async {
    return _readTable('iot_gateways', orderBy: 'created_at', ascending: false);
  }

  static Future<bool> insertGateway({
    required String gatewayId,
    required String location,
    required String status, // online/offline
    required String ipAddress,
    String? lastSeen, // timestamp text
  }) {
    return _insert('iot_gateways', {
      'gateway_id': gatewayId,
      'location': location,
      'status': status,
      'ip_address': ipAddress,
      if (lastSeen != null) 'last_seen': lastSeen,
    });
  }

  static Future<bool> updateGateway({
    required dynamic id,
    String? gatewayId,
    String? location,
    String? status,
    String? ipAddress,
    String? lastSeen,
  }) {
    final body = <String, dynamic>{};
    if (gatewayId != null) body['gateway_id'] = gatewayId;
    if (location != null) body['location'] = location;
    if (status != null) body['status'] = status;
    if (ipAddress != null) body['ip_address'] = ipAddress;
    if (lastSeen != null) body['last_seen'] = lastSeen;
    if (body.isEmpty) return Future.value(true);
    return _update('iot_gateways', body, eqCol: 'id', eqVal: id);
  }

  static Future<bool> deleteGateway(dynamic id) {
    return _delete('iot_gateways', eqCol: 'id', eqVal: id);
  }

  // ======================================================
  // ======================  DEVICES  =====================
  // ======================================================

  static Future<List<Map<String, dynamic>>> getDevices() async {
    return _readTable('devices', orderBy: 'created_at', ascending: false);
  }

  static Future<bool> insertDevice({
    required String deviceId,
    required String name,
    required String type,
    required String gatewayId,
    required String status, // online/offline/error
    String? lastReading, // timestamp text
  }) {
    return _insert('devices', {
      'device_id': deviceId,
      'name': name,
      'type': type,
      'gateway_id': gatewayId,
      'status': status,
      if (lastReading != null) 'last_reading': lastReading,
    });
  }

  static Future<bool> updateDevice({
    required dynamic id,
    String? deviceId,
    String? name,
    String? type,
    String? gatewayId,
    String? status,
    String? lastReading,
  }) {
    final body = <String, dynamic>{};
    if (deviceId != null) body['device_id'] = deviceId;
    if (name != null) body['name'] = name;
    if (type != null) body['type'] = type;
    if (gatewayId != null) body['gateway_id'] = gatewayId;
    if (status != null) body['status'] = status;
    if (lastReading != null) body['last_reading'] = lastReading;
    if (body.isEmpty) return Future.value(true);
    return _update('devices', body, eqCol: 'id', eqVal: id);
  }

  static Future<bool> deleteDevice(dynamic id) {
    return _delete('devices', eqCol: 'id', eqVal: id);
  }

  // ======================================================
  // =====================  APP USERS  ====================
  // ======================================================

  static Future<List<Map<String, dynamic>>> getAppUsers() async {
    return _readTable('app_users', orderBy: 'created_at', ascending: false);
  }

  // ======================================================
  // =====================  RULES / RBE  ==================
  // ======================================================

  /// Required by TestConnection and Rules page
  static Future<List<Map<String, dynamic>>> getRules() async {
    return _readTable('rules', orderBy: 'created_at', ascending: false);
  }
}
