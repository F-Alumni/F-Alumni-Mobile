import 'package:alumni_connect/core/network/alumni_api.dart';
import 'package:alumni_connect/features/admin/data/models/admin_models.dart';

class AdminDirectoryPage {
  const AdminDirectoryPage({required this.users, required this.totalCount});
  final List<AdminUserItem> users;
  final int totalCount;
}

class AdminRepository {
  AdminRepository(this.api);
  final AlumniApi api;

  Future<AdminDirectoryPage> loadUsers() async {
    final page = await api.user.get(
      '/api/v1/users',
      query: {'pageNumber': '1', 'pageSize': '100'},
    );
    final items = page['items'] as List<dynamic>? ?? const [];
    final users = items.map((item) {
      final row = item as Map<String, dynamic>;
      final accountType = '${row['accountType'] ?? ''}';
      return AdminUserItem(
        id: '${row['id'] ?? ''}',
        name: '${row['displayName'] ?? row['fullName'] ?? ''}',
        email: '${row['email'] ?? ''}',
        studentId: '${row['studentCode'] ?? ''}',
        role: accountType,
        systemRole: '${row['role'] ?? 'USER'}',
        campus: '${row['campus'] ?? ''}',
        avatarUrl: '${row['avatarUrl'] ?? ''}',
        isLocked: '${row['status'] ?? ''}'.toLowerCase() == 'suspended',
        isPendingVerification:
            '${row['status'] ?? ''}'.toLowerCase() == 'pendingverification',
      );
    }).toList();
    return AdminDirectoryPage(
      users: users,
      totalCount: (page['totalCount'] as num?)?.toInt() ?? users.length,
    );
  }

  Future<void> suspend(String userId, String reason) async =>
      api.user.post('/api/v1/users/$userId/suspend', body: {'reason': reason});

  Future<void> unsuspend(String userId) async =>
      api.user.post('/api/v1/users/$userId/unsuspend');

  Future<void> updateSystemRole(
    String userId,
    String role,
    String accountType,
  ) async => api.user.put(
    '/api/v1/users/$userId/role',
    body: {'role': role, 'accountType': accountType},
  );
}
