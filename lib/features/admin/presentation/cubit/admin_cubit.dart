import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/admin/data/models/admin_models.dart';
import 'package:alumni_connect/features/admin/data/mock/admin_mock_data.dart';

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoaded extends AdminState {
  final List<AdminUserItem> users;
  final List<ModerationReportItem> reports;
  final String userSearchQuery;
  final String userRoleFilter;

  AdminLoaded({
    required this.users,
    required this.reports,
    this.userSearchQuery = '',
    this.userRoleFilter = 'Tất cả',
  });

  // KPI Metrics (AD-08)
  int get totalUsers => users.length + 4845; // Demo baseline 4,850 users
  int get verifiedAlumniCount => 1920;
  int get activeStudentsCount => 2810;
  int get pendingOrLockedCount => users.where((u) => u.isLocked || u.isPendingVerification).length;
  int get unresolvedReportsCount => reports.where((r) => !r.isResolved).length;

  List<AdminUserItem> get filteredUsers {
    return users.where((u) {
      final matchesFilter = userRoleFilter == 'Tất cả' ||
          (userRoleFilter == 'Mentor' && u.role.contains('Mentor')) ||
          (userRoleFilter == 'Bị khóa' && u.isLocked) ||
          (userRoleFilter == 'Chờ duyệt' && u.isPendingVerification);

      final matchesSearch = userSearchQuery.isEmpty ||
          u.name.toLowerCase().contains(userSearchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(userSearchQuery.toLowerCase()) ||
          u.studentId.toLowerCase().contains(userSearchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();
  }

  AdminLoaded copyWith({
    List<AdminUserItem>? users,
    List<ModerationReportItem>? reports,
    String? userSearchQuery,
    String? userRoleFilter,
  }) {
    return AdminLoaded(
      users: users ?? this.users,
      reports: reports ?? this.reports,
      userSearchQuery: userSearchQuery ?? this.userSearchQuery,
      userRoleFilter: userRoleFilter ?? this.userRoleFilter,
    );
  }
}

class AdminCubit extends Cubit<AdminState> {
  AdminCubit() : super(AdminInitial());

  void loadAdminData() {
    emit(AdminLoaded(
      users: List.from(AdminMockData.mockUsers),
      reports: List.from(AdminMockData.mockReports),
    ));
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
  void toggleLockUser(String userId) {
    if (state is AdminLoaded) {
      final current = state as AdminLoaded;
      final updated = current.users.map((u) {
        if (u.id == userId) {
          final newLockedState = !u.isLocked;
          return u.copyWith(
            isLocked: newLockedState,
            lockReason: newLockedState ? 'Đã khóa bởi Admin vì vi phạm nội quy' : null,
          );
        }
        return u;
      }).toList();
      emit(current.copyWith(users: updated));
    }
  }

  // Duyệt cấp bằng Alumni
  void approveAlumni(String userId) {
    if (state is AdminLoaded) {
      final current = state as AdminLoaded;
      final updated = current.users.map((u) {
        if (u.id == userId) {
          return u.copyWith(
            isPendingVerification: false,
            role: 'Verified Alumni',
          );
        }
        return u;
      }).toList();
      emit(current.copyWith(users: updated));
    }
  }

  // AD-05 & AD-07: Gỡ bài viết vi phạm
  void removeReportedPost(String reportId) {
    if (state is AdminLoaded) {
      final current = state as AdminLoaded;
      final updated = current.reports.map((r) {
        if (r.id == reportId) {
          return r.copyWith(isResolved: true, isHidden: true);
        }
        return r;
      }).toList();
      emit(current.copyWith(reports: updated));
    }
  }

  // Bỏ qua báo cáo
  void dismissReport(String reportId) {
    if (state is AdminLoaded) {
      final current = state as AdminLoaded;
      final updated = current.reports.map((r) {
        if (r.id == reportId) {
          return r.copyWith(isResolved: true);
        }
        return r;
      }).toList();
      emit(current.copyWith(reports: updated));
    }
  }
}
