import 'package:flutter/material.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';

/// The backend currently accepts user reports but does not expose an admin
/// queue or moderation actions. Keep this screen explicit about that gap.
class AdminModerationScreen extends StatelessWidget {
  const AdminModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.fact_check_outlined,
                size: 56,
                color: AppColors.textMuted,
              ),
              SizedBox(height: 16),
              Text(
                'Chưa thể quản lý báo cáo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Backend hiện chưa có API để xem hàng đợi hoặc xử lý báo cáo. '
                'Các thao tác kiểm duyệt sẽ khả dụng khi API được bổ sung.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
