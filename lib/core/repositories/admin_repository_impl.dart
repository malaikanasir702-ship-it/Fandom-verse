import '../database/sqlite_helper.dart';
import 'i_admin_repository.dart';

class AdminRepositoryImpl implements IAdminRepository {
  final SqliteHelper _dbHelper;

  AdminRepositoryImpl({SqliteHelper? dbHelper})
      : _dbHelper = dbHelper ?? SqliteHelper.instance;

  @override
  Future<Map<String, int>> getDashboardMetrics() {
    return _dbHelper.getAdminDashboardMetrics();
  }

  @override
  Future<List<Map<String, dynamic>>> getAuditLogs({int limit = 50}) {
    return _dbHelper.getAuditLogs(limit: limit);
  }

  @override
  Future<void> logAdminAction({
    required String actionType,
    required String entityType,
    required String description,
    String adminEmail = 'admin@fandomverse.com',
  }) {
    return _dbHelper.logAdminAction(
      actionType: actionType,
      entityType: entityType,
      description: description,
      adminEmail: adminEmail,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getAllUsers() {
    return _dbHelper.getAllUsers();
  }

  @override
  Future<void> updateUserStatus(String userId, String status) {
    return _dbHelper.updateUserStatus(userId, status);
  }

  @override
  Future<List<Map<String, dynamic>>> query(String tableName, {String? where, List<dynamic>? whereArgs, String? orderBy, int? limit}) {
    return _dbHelper.query(tableName, where: where, whereArgs: whereArgs, orderBy: orderBy, limit: limit);
  }

  @override
  Future<int> insert(String tableName, Map<String, dynamic> row) {
    return _dbHelper.insert(tableName, row);
  }

  @override
  Future<int> update(String tableName, String primaryKey, String keyValue, Map<String, dynamic> updatedFields) {
    return _dbHelper.update(tableName, primaryKey, keyValue, updatedFields);
  }

  @override
  Future<int> delete(String tableName, String primaryKey, String keyValue) {
    return _dbHelper.delete(tableName, primaryKey, keyValue);
  }
}
