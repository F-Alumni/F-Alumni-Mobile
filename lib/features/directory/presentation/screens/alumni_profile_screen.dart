import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/features/directory/data/models/alumni_model.dart';
import 'package:alumni_connect/features/directory/data/mock/directory_mock_data.dart';

class AlumniProfileScreen extends StatelessWidget {
  final String alumniId;

  const AlumniProfileScreen({super.key, required this.alumniId});

  @override
  Widget build(BuildContext context) {
    final alumni = DirectoryMockData.alumniList.firstWhere(
      (a) => a.id == alumniId,
      orElse: () => DirectoryMockData.alumniList.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Hồ sơ Cựu sinh viên'),
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 90),
        children: [
          // Header Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundImage: NetworkImage(alumni.avatarUrl),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.fptGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      alumni.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: AppColors.fptGreen, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${alumni.currentRole} @ ${alumni.company}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.fptBlue),
                ),
                const SizedBox(height: 4),
                Text(
                  '${alumni.cohort} ${alumni.major} • ${alumni.campus}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),

                // Status pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Text(
                    '● Đang mở lịch Mentoring 1-1 (Miễn phí cho SV FPT)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                  ),
                ),
                const SizedBox(height: 16),

                // Stats row
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('520+', 'Kết nối'),
                      _buildDivider(),
                      _buildStat('${alumni.completedSessions}', 'Buổi Mentor'),
                      _buildDivider(),
                      _buildStat('${alumni.rating} ⭐', '${alumni.reviewsCount} Đánh giá'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Bio Card
          _buildSectionCard(
            title: 'Giới thiệu bản thân (Bio)',
            content: Text(
              alumni.bio,
              style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF334155)),
            ),
          ),
          const SizedBox(height: 10),

          // Skills & Mentorship Topics
          _buildSectionCard(
            title: 'Lĩnh vực cố vấn & Kỹ năng',
            content: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: alumni.skills.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    s,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Experience
          _buildSectionCard(
            title: 'Hành trình sự nghiệp',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('• 2022 - Hiện tại: Tech Lead @ TechCorp Vietnam', style: TextStyle(fontSize: 13, height: 1.5)),
                Text('• 2020 - 2022: Senior Backend Engineer @ FPT Software Global', style: TextStyle(fontSize: 13, height: 1.5)),
                Text('• 2016 - 2020: Thủ khoa Kỹ thuật phần mềm - Đại học FPT (K14)', style: TextStyle(fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            OutlinedButton(
              onPressed: () => context.push('/chat/${alumni.id}'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.fptBlue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(12),
              ),
              child: const Icon(Icons.chat_bubble_outline, color: AppColors.fptBlue),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/booking/${alumni.id}'),
                icon: const Icon(Icons.calendar_month),
                label: const Text('Đặt lịch Mentoring 1-1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.fptOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  Widget _buildStat(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1, color: AppColors.border);
  }
}
