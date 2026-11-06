import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/admin/data/models/admin_models.dart';
import 'package:alumni_connect/features/admin/data/admin_repository.dart';

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminError extends AdminState {
  AdminError(this.message);
  final String message;
}

class AdminLoaded extends AdminState {
  final List<AdminUserItem> users;
  final int totalUserCount;
  final String userSearchQuery;
  final String userRoleFilter;

  AdminLoaded({
    required this.users,
    this.totalUserCount = 0,
    this.userSearchQuery = '',
    this.userRoleFilter = 'Tất cả',
  });

  // KPI Metrics (AD-08)
  int get totalUsers => totalUserCount;
  int get verifiedAlumniCount => -1;
  int get activeStudentsCount => -1;
  int get unresolvedReportsCount => -1;

  List<AdminUserItem> get filteredUsers {
    return users.where((u) {
      final matchesFilter =
          userRoleFilter == 'Tất cả' ||
          (userRoleFilter == 'Cựu sinh viên' &&
              u.role.toLowerCase() == 'alumni') ||
          (userRoleFilter == 'Bị khóa' && u.isLocked) ||
          (userRoleFilter == 'Chưa xác minh' && u.isPendingVerification);

      final matchesSearch =
          userSearchQuery.isEmpty ||
          u.name.toLowerCase().contains(userSearchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(userSearchQuery.toLowerCase()) ||
          u.studentId.toLowerCase().contains(userSearchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();
  }

  AdminLoaded copyWith({
    List<AdminUserItem>? users,
    int? totalUserCount,
    String? userSearchQuery,
    String? userRoleFilter,
  }) {
    return AdminLoaded(
      users: users ?? this.users,
      totalUserCount: totalUserCount ?? this.totalUserCount,
      userSearchQuery: userSearchQuery ?? this.userSearchQuery,
      userRoleFilter: userRoleFilter ?? this.userRoleFilter,
    );
  }
}

class AdminCubit extends Cubit<AdminState> {
  AdminCubit(this._repository) : super(AdminInitial());
  final AdminRepository _repository;

  Future<void> loadAdminData() async {
    emit(AdminLoading());
    try {
      final page = await _repository.loadUsers();
      emit(AdminLoaded(users: page.users, totalUserCount: page.totalCount));
    } catch (error) {
      emit(AdminError(error.toString()));
    }
  }

  void searchUsers(String query) {
    if (state is AdminLoaded) {
      emit((state as AdminLoaded).copyWith(userSearchQuery: query));
    }
  }

  void filterUsersByRole(String role) {
    if (state is AdminLoaded) {
      emit((state as AdminLoaded).copyWith(userRoleFilter: role));
    }
  }

  // AD-03: Khóa hoặc mở khóa tài khoản
  Future<void> toggleLockUser(String userId) async {
    final current = state;
    if (current is! AdminLoaded) return;
    final user = current.users.where((item) => item.id == userId).firstOrNull;
    if (user == null) return;
    try {
      if (user.isLocked) {
        await _repository.unsuspend(userId);
      } else {
        await _repository.suspend(userId, 'Suspended by administrator');
      }
      await loadAdminData();
    } catch (error) {
      emit(AdminError(error.toString()));
    }
  }

  Future<void> toggleAdminRole(String userId) async {
    final current = state;
    if (current is! AdminLoaded) return;
    final user = current.users.where((item) => item.id == userId).firstOrNull;
    if (user == null) return;
    try {
      await _repository.updateSystemRole(
        userId,
        user.systemRole.toUpperCase() == 'ADMIN' ? 'USER' : 'ADMIN',
        user.role,
      );
      await loadAdminData();
    } catch (error) {
      emit(AdminError(error.toString()));
    }
  }
}
