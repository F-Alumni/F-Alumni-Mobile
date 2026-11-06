class AdminUserItem {
  final String id;
  final String name;
  final String email;
  final String studentId;
  final String
  role; // 'Alumni Mentor', 'Verified Alumni', 'Sinh viên', 'Tài khoản thường'
  final String systemRole;
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
    this.systemRole = 'USER',
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
    String? systemRole,
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
      systemRole: systemRole ?? this.systemRole,
      campus: campus ?? this.campus,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLocked: isLocked ?? this.isLocked,
      lockReason: lockReason ?? this.lockReason,
      isPendingVerification:
          isPendingVerification ?? this.isPendingVerification,
      diplomaCode: diplomaCode ?? this.diplomaCode,
    );
  }
}
