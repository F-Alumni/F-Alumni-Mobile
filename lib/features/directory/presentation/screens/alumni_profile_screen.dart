import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/features/directory/data/models/alumni_model.dart';
import 'package:alumni_connect/core/network/alumni_api.dart';
import 'package:alumni_connect/features/directory/data/directory_repository.dart';
import 'package:alumni_connect/features/chat/presentation/cubit/chat_cubit.dart';

class AlumniProfileScreen extends StatelessWidget {
  final String alumniId;

  const AlumniProfileScreen({super.key, required this.alumniId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AlumniModel>(
      future: DirectoryRepository(AlumniApi()).getProfile(alumniId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildProfile(context, snapshot.data!);
      },
    );
  }

  Widget _buildProfile(BuildContext context, AlumniModel alumni) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Hồ sơ Cựu sinh viên'),
        actions: [],
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
                      backgroundImage: alumni.avatarUrl.isEmpty
                          ? null
                          : NetworkImage(alumni.avatarUrl),
                      child: alumni.avatarUrl.isEmpty
                          ? const Icon(Icons.person_outline)
                          : null,
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (alumni.isVerified)
                      const Icon(
                        Icons.verified,
                        color: AppColors.fptGreen,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${alumni.currentRole} @ ${alumni.company}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.fptBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${alumni.cohort} ${alumni.major} • ${alumni.campus}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // Status pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Text(
                    '● Đang mở lịch Mentoring 1-1 (Miễn phí cho SV FPT)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Bio Card
          _buildSectionCard(
            title: 'Giới thiệu bản thân (Bio)',
            content: Text(
              alumni.bio,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF334155),
              ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    s,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
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
              onPressed: () async {
                try {
                  final id = await context.read<ChatCubit>().createConversation(
                    alumni.id,
                  );
                  if (context.mounted) context.push('/chat/$id');
                } catch (error) {
                  if (context.mounted)
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error.toString())));
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.fptBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.fptBlue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Backend hiện chưa có API đặt lịch mentor.'),
                  ),
                ),
                icon: const Icon(Icons.calendar_month),
                label: const Text(
                  'Đặt lịch Mentoring 1-1',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.fptOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }
}
