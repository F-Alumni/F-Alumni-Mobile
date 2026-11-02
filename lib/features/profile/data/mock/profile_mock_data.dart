import 'package:alumni_connect/features/profile/data/models/user_profile_model.dart';

class ProfileMockData {
  static const UserProfile currentUser = UserProfile(
    id: 'user_an',
    name: 'Nguyễn Văn An',
    email: 'annvde160123@fpt.edu.vn',
    studentId: 'DE160123',
    cohort: 'K16',
    major: 'Kỹ thuật phần mềm (SE)',
    campus: 'FPT Đà Nẵng',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
    bio: 'Sinh viên năm cuối ngành Kỹ thuật phần mềm đam mê Mobile Development (Flutter) & Cloud Computing. Đang tìm kiếm cơ hội OJT & Mentorship phỏng vấn tại FPT Software.',
    isAlumni: false,
    isVerified: true,
    skills: ['Flutter', 'Dart', 'Clean Architecture', 'AWS', 'BLoC / Cubit', 'Git / GitHub', 'RESTful API'],
    interests: ['Học hỏi từ Mentor', 'Cơ hội OJT', 'Dự án Open-source', 'AI & Machine Learning'],
    calendarUrl: 'https://calendar.google.com/calendar/u/0/r',
    isPublicToRecruiters: true,
    showContactInfo: false,
    allowMessagesFromStrangers: true,
    totalPosts: 8,
    totalConnections: 124,
    mentoringSessions: 4,
  );
}
