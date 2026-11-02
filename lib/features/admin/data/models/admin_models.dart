class AdminUserItem {
  final String id;
  final String name;
  final String email;
  final String studentId;
  final String role; // 'Alumni Mentor', 'Verified Alumni', 'Sinh viên', 'Tài khoản thường'
  final String campus;
  final String avatarUrl;
  final bool isLocked; // AD-03
  final String? lockReason;
  final bool isPendingVerification; // Chờ duyệt cấp Alumni
  final String? diplomaCode; // Bằng tốt nghiệp

  const AdminUserItem({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
    required this.role,
    required this.campus,
    required this.avatarUrl,
    this.isLocked = false,
    this.lockReason,
    this.isPendingVerification = false,
    this.diplomaCode,
  });

  AdminUserItem copyWith({
    String? id,
    String? name,
    String? email,
    String? studentId,
    String? role,
    String? campus,
    String? avatarUrl,
    bool? isLocked,
    String? lockReason,
    bool? isPendingVerification,
    String? diplomaCode,
  }) {
    return AdminUserItem(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      role: role ?? this.role,
      campus: campus ?? this.campus,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLocked: isLocked ?? this.isLocked,
      lockReason: lockReason ?? this.lockReason,
      isPendingVerification: isPendingVerification ?? this.isPendingVerification,
      diplomaCode: diplomaCode ?? this.diplomaCode,
    );
  }
}

class ModerationReportItem {
  final String id;
  final String postId;
  final String postTitle;
  final String postAuthor;
  final String reporterName;
  final String reason;
  final String reportTime;
  final bool isResolved; // Đã xử lý hay chưa
  final bool isHidden; // AD-05 (Đã ẩn hoặc gỡ bài)

  const ModerationReportItem({
    required this.id,
    required this.postId,
    required this.postTitle,
    required this.postAuthor,
    required this.reporterName,
    required this.reason,
    required this.reportTime,
    this.isResolved = false,
    this.isHidden = false,
  });

  ModerationReportItem copyWith({
    String? id,
    String? postId,
    String? postTitle,
    String? postAuthor,
    String? reporterName,
    String? reason,
    String? reportTime,
    bool? isResolved,
    bool? isHidden,
  }) {
    return ModerationReportItem(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      postTitle: postTitle ?? this.postTitle,
      postAuthor: postAuthor ?? this.postAuthor,
      reporterName: reporterName ?? this.reporterName,
      reason: reason ?? this.reason,
      reportTime: reportTime ?? this.reportTime,
      isResolved: isResolved ?? this.isResolved,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}
