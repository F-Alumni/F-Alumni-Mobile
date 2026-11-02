import 'package:alumni_connect/features/admin/data/models/admin_models.dart';

class AdminMockData {
  static final List<AdminUserItem> mockUsers = [
    const AdminUserItem(
      id: 'usr_long',
      name: 'Trần Hoàng Long',
      email: 'longth@fpt.edu.vn',
      studentId: 'SE140123',
      role: 'Alumni Mentor',
      campus: 'FPT Hòa Lạc',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      isLocked: false,
    ),
    const AdminUserItem(
      id: 'usr_thao',
      name: 'Lê Thị Thu Thảo',
      email: 'thaoltt@fpt.edu.vn',
      studentId: 'SE130456',
      role: 'Verified Alumni',
      campus: 'FPT Đà Nẵng',
      avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
      isLocked: false,
    ),
    const AdminUserItem(
      id: 'usr_an',
      name: 'Nguyễn Văn An',
      email: 'annvde160123@fpt.edu.vn',
      studentId: 'DE160123',
      role: 'Sinh viên K16',
      campus: 'FPT Đà Nẵng',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      isLocked: false,
    ),
    const AdminUserItem(
      id: 'usr_spam',
      name: 'Nguyễn Viết Spam',
      email: 'spammer.bot@gmail.com',
      studentId: 'USR-8821',
      role: 'Tài khoản thường',
      campus: 'Toàn quốc',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      isLocked: true,
      lockReason: 'Vi phạm chia sẻ spam / gian lận Capstone (AD-03)',
    ),
    const AdminUserItem(
      id: 'usr_phuong',
      name: 'Hoàng Mai Phương',
      email: 'phuonghm@alumni.fpt.edu.vn',
      studentId: 'GD120456',
      role: 'Chờ duyệt Alumni',
      campus: 'FPT TP.HCM',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      isLocked: false,
      isPendingVerification: true,
      diplomaCode: 'Bằng tốt nghiệp K12 QTKD - Số hiệu: GD120456',
    ),
  ];

  static final List<ModerationReportItem> mockReports = [
    const ModerationReportItem(
      id: 'rep_1',
      postId: 'post_violation_1',
      postTitle: 'Dịch vụ làm hộ đồ án tốt nghiệp Capstone cam kết A+ điểm số',
      postAuthor: 'Nguyễn Viết Spam',
      reporterName: 'Trần Minh Quân (Sinh viên K17)',
      reason: 'Quảng cáo gian lận học thuật & vi phạm quy chế ĐH FPT',
      reportTime: '15 phút trước',
      isResolved: false,
      isHidden: false,
    ),
    const ModerationReportItem(
      id: 'rep_2',
      postId: 'post_violation_2',
      postTitle: 'Chia sẻ tài liệu đề thi Final Exam có đáp án kỳ Fall',
      postAuthor: 'Lê Văn B',
      reporterName: 'Nguyễn Văn An',
      reason: 'Lộ đề thi chưa được phép công khai',
      reportTime: '1 giờ trước',
      isResolved: false,
      isHidden: false,
    ),
  ];
}
