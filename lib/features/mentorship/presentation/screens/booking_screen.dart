import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/features/directory/data/models/alumni_model.dart';
import 'package:alumni_connect/features/directory/data/mock/directory_mock_data.dart';

class BookingScreen extends StatefulWidget {
  final String alumniId;

  const BookingScreen({super.key, required this.alumniId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _selectedTopicIndex = 0;
  int _selectedDateIndex = 2; // Default Thứ 6 - 18/10
  int _selectedTimeIndex = 0; // Default 19:30 - 20:15
  final TextEditingController _questionController = TextEditingController(
    text: 'Em chào anh Long, em là An (K16 SE). Em đang chuẩn bị phỏng vấn OJT kỳ Fall tại FPT Software. Em mong muốn anh chia sẻ kinh nghiệm phỏng vấn kỹ thuật và cách tối ưu Database Indexing cho dự án Capstone của em ạ.',
  );

  static const List<String> topics = [
    'Định hướng & Phỏng vấn Backend / Fullstack (OJT & Fresher)',
    'Rà soát CV & Tối ưu Portfolio / Đồ án Capstone',
    'Tư vấn Thiết kế Kiến trúc Hệ thống (System Design) & Cloud AWS',
  ];

  static const List<Map<String, String>> days = [
    {'day': 'T4', 'date': '16/10'},
    {'day': 'T5', 'date': '17/10'},
    {'day': 'T6', 'date': '18/10'},
    {'day': 'T7', 'date': '19/10'},
    {'day': 'CN', 'date': '20/10'},
  ];

  static const List<Map<String, dynamic>> slots = [
    {'time': '19:30 - 20:15', 'available': true},
    {'time': '20:30 - 21:15', 'available': true},
    {'time': '21:30 - 22:15', 'available': true},
    {'time': '18:00 - 18:45', 'available': false},
  ];

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alumni = DirectoryMockData.alumniList.firstWhere(
      (a) => a.id == widget.alumniId,
      orElse: () => DirectoryMockData.alumniList.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Đặt lịch Mentoring 1-1'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mentor Summary Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(alumni.avatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alumni.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${alumni.currentRole} @ ${alumni.company}',
                        style: const TextStyle(fontSize: 12, color: AppColors.fptBlue, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Text(
                          'Google Meet • 45 phút • Miễn phí cho SV FPT',
                          style: TextStyle(fontSize: 10, color: Color(0xFF065F46), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Step 1: Chọn chủ đề
          const Text(
            '1. Chọn chủ đề bạn cần tư vấn',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          ...List.generate(topics.length, (idx) {
            final isSelected = _selectedTopicIndex == idx;
            return GestureDetector(
              onTap: () => setState(() => _selectedTopicIndex = idx),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.fptOrange.withValues(alpha: 0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.fptOrange : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? AppColors.fptOrange : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        topics[idx],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),

          // Step 2: Chọn ngày & giờ
          const Text(
            '2. Chọn ngày & thời gian khả dụng',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final isSelected = _selectedDateIndex == idx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDateIndex = idx),
                  child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.fptOrange : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppColors.fptOrange : AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          days[idx]['day']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          days[idx]['date']!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Slots grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(slots.length, (idx) {
              final slot = slots[idx];
              final available = slot['available'] as bool;
              final isSelected = _selectedTimeIndex == idx;

              return GestureDetector(
                onTap: available ? () => setState(() => _selectedTimeIndex = idx) : null,
                child: Container(
                  width: (MediaQuery.of(context).size.width - 40) / 2,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !available
                        ? const Color(0xFFF1F5F9)
                        : (isSelected ? AppColors.fptOrange.withValues(alpha: 0.1) : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: !available
                          ? Colors.transparent
                          : (isSelected ? AppColors.fptOrange : AppColors.border),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      slot['time'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: !available
                            ? AppColors.textMuted
                            : (isSelected ? AppColors.fptOrange : AppColors.textPrimary),
                        decoration: !available ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Step 3: Câu hỏi & Đính kèm CV
          const Text(
            '3. Bạn cần mentor giải đáp những gì?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _questionController,
            maxLines: 4,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // File CV attachment chip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: const [
                Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'NguyenVanAn_CV_SE.pdf (1.4 MB)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(Icons.check_circle, color: AppColors.fptGreen, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Submit CTA Button
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 Đã gửi yêu cầu đặt lịch Mentoring thành công!'),
                  backgroundColor: AppColors.fptGreen,
                ),
              );
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.fptOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Xác nhận & Gửi yêu cầu Đặt lịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
