abstract class IAdminRepository {
  Future<Map<String, int>> getDashboardMetrics();
  Future<List<Map<String, dynamic>>> getAuditLogs({int limit = 50});
  Future<void> logAdminAction({
    required String actionType,
    required String entityType,
    required String description,
    String adminEmail,
  });
  Future<List<Map<String, dynamic>>> getAllUsers();
  Future<void> updateUserStatus(String userId, String status);
  Future<List<Map<String, dynamic>>> query(String tableName, {String? where, List<dynamic>? whereArgs, String? orderBy, int? limit});
  Future<int> insert(String tableName, Map<String, dynamic> row);
  Future<int> update(String tableName, String primaryKey, String keyValue, Map<String, dynamic> updatedFields);
  Future<int> delete(String tableName, String primaryKey, String keyValue);
}
