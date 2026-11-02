import 'package:alumni_connect/features/feed/data/models/feed_models.dart';

class FeedMockData {
  static const List<MentorStory> mockStories = [
    MentorStory(
      id: '0',
      name: 'Bạn',
      role: 'Tạo story mới',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      isUser: true,
    ),
    MentorStory(
      id: '1',
      name: 'Anh Long',
      role: 'Tech Lead @ TechCorp',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      isOnline: true,
    ),
    MentorStory(
      id: '2',
      name: 'Chị Thảo',
      role: 'Sr PM @ FPT Software',
      avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
      isOnline: true,
    ),
    MentorStory(
      id: '3',
      name: 'Chị Trâm',
      role: 'Sr Designer @ Grab',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      isOnline: true,
    ),
    MentorStory(
      id: '4',
      name: 'Anh Thành',
      role: 'Solutions Architect @ AWS',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      isOnline: false,
    ),
    MentorStory(
      id: '5',
      name: 'TS. Hà',
      role: 'AI Researcher',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      isOnline: true,
    ),
  ];

  static final List<PostItem> mockPosts = [
    PostItem(
      id: 'post_thao',
      authorName: 'Lê Thị Thu Thảo',
      authorRole: 'Alumni K13 • Senior Product Manager @ FPT Software',
      authorAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
      timeAgo: '2 giờ trước',
      isVerified: true,
      title: 'Kinh nghiệm chuẩn bị CV & phỏng vấn xin việc cho sinh viên chuẩn bị đi OJT kỳ Fall 2026',
      content:
          'Chào các em sinh viên K16, K17 FPTU! Kỳ OJT sắp tới là bước đệm cực kỳ quan trọng để các em bước ra môi trường doanh nghiệp thực tế. Dưới đây là 3 lời khuyên từ góc nhìn của cựu sinh viên và Hiring Manager:\n\n'
          '1. Định dạng CV chuẩn ATS & tập trung vào đồ án môn học (Capstone / Lab dự án thực tế). Đừng chỉ liệt kê các môn đã học, hãy viết rõ kết quả đạt được và công nghệ sử dụng!\n\n'
          '2. Ôn tập vững cấu trúc dữ liệu, OOP và giải thuật cơ bản. Khi phỏng vấn Freshers, các Tech Leads quan tâm nhất đến tư duy logic và khả năng tự học của các em.\n\n'
          '3. Thái độ chuyên nghiệp: Văn hóa chào hỏi, tác phong doanh nghiệp FPT Software. Hãy luôn chuẩn bị trước ít nhất 2 câu hỏi hỏi lại nhà tuyển dụng.',
      attachmentTitle: 'Infographic: Quy trình 4 bước phỏng vấn OJT F-Complex & Hola Park',
      attachmentSubtitle: 'Tài liệu hướng dẫn độc quyền từ FPT Alumni Network • 2.4 MB',
      attachmentImageUrl: 'https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=600',
      campus: 'FPT Đà Nẵng',
      category: 'Chia sẻ kinh nghiệm',
      tags: ['#OJT', '#FPTSoftware', '#KinhNghiem', '#AlumniSharing', '#FPTUniversity'],
      likes: 128,
      comments: 34,
      shares: 15,
      isLiked: true,
      isSaved: true,
      commentList: [
        const CommentItem(
          id: 'cmt_1',
          authorName: 'Trần Minh Quân',
          authorRole: 'Sinh viên K17 • Kỹ thuật phần mềm',
          authorAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
          timeAgo: '1 giờ trước',
          content: 'Cho em hỏi nếu chưa có chứng chỉ AWS thì cơ hội pass OJT bên FPT Software thế nào ạ?',
          likes: 12,
          isLiked: true,
          replies: [
            CommentItem(
              id: 'cmt_1_1',
              authorName: 'Lê Thị Thu Thảo',
              authorRole: 'Tác giả • K13 Alumni',
              authorAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
              timeAgo: '45 phút trước',
              content:
                  '@Trần Minh Quân Không bắt buộc đâu em nhé! Quan trọng nhất là nền tảng OOP, kiến thức Data Structure và thái độ học hỏi cầu thị. Chứng chỉ AWS sẽ là điểm cộng rất lớn khi vào các BU Cloud sau này.',
              likes: 8,
              isAuthor: true,
            ),
          ],
        ),
        const CommentItem(
          id: 'cmt_2',
          authorName: 'Nguyễn Hải Đăng',
          authorRole: 'Tech Lead @ VTI • Alumni K15',
          authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          timeAgo: '30 phút trước',
          content: 'Bài viết rất tâm huyết và chuẩn xác! Chúc các em K17 đợt này tự tin phỏng vấn OJT thành công rực rỡ.',
          likes: 5,
        ),
      ],
    ),
    PostItem(
      id: 'post_1',
      authorName: 'Trần Hoàng Long',
      authorRole: 'Cựu SV K14 • Tech Lead @ TechCorp',
      authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      timeAgo: '4 giờ trước',
      isVerified: true,
      title: 'Kinh nghiệm phỏng vấn Backend Developer (Java / Golang / Node.js)',
      content:
          'Chia sẻ một số kinh nghiệm phỏng vấn Backend Developer cho các bạn sinh viên FPT chuẩn bị đi OJT kỳ Fall và tốt nghiệp. Các bạn nhớ chú trọng kỹ năng tối ưu Database Indexing và thiết kế Microservices nhé!',
      attachmentTitle: 'Tài liệu: backend-interview-roadmap.fpt',
      attachmentSubtitle: 'PDF Sơ đồ tư duy 12 trang • Phân tích System Design & DB Tuning',
      campus: 'FPT Hòa Lạc',
      category: 'Hỏi đáp & Thảo luận',
      tags: ['#FPTAlumni', '#BackendDev', '#CareerAdvice', '#TechLead'],
      likes: 84,
      comments: 18,
      shares: 12,
    ),
    PostItem(
      id: 'post_2',
      authorName: 'Lê Thuỳ Dung',
      authorRole: 'Cựu SV K15 • HR Talent Partner @ FPT Software',
      authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      timeAgo: '6 giờ trước',
      isVerified: true,
      title: 'FPT Software Global tuyển gấp 15 Fresher/Junior Frontend',
      content:
          'FPT Software Global đang mở đợt tuyển gấp 15 vị trí Fresher/Junior Frontend cho dự án khách hàng Nhật & Mỹ. Cóc FPT nộp qua post này sẽ được chị bảo chứng Referral chuyển thẳng CV tới Hiring Manager trong 24h nhé!',
      isJobPost: true,
      companyName: 'FPT Software Global',
      jobTitle: 'Frontend Engineer (React / Next.js / TypeScript)',
      jobSalary: '15,000,000 - 22,000,000 VNĐ / tháng',
      jobPerks: 'Cấp MacBook M3 • Trợ cấp thi AWS • Cơ hội Onsite Tokyo',
      campus: 'FPT TP.HCM',
      category: 'Cơ hội việc làm / Thực tập',
      tags: ['#Tuyendung', '#FPTSoftware', '#HotReferral', '#Frontend'],
      likes: 120,
      comments: 42,
      shares: 35,
    ),
  ];
}
