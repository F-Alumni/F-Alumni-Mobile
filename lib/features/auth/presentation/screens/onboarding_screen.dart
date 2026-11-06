import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/core/theme/app_typography.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      illustration: Icons.people_alt_rounded,
      illustrationColor: Color(0xFFF27024),
      title: 'Kết nối Cộng đồng FPT',
      subtitle:
          'Xây dựng mạng lưới cựu sinh viên và sinh viên FPT toàn quốc. Tìm kiếm mentor, đồng nghiệp và cơ hội hợp tác.',
      tag: 'US-02',
    ),
    _OnboardingPage(
      illustration: Icons.work_outline_rounded,
      illustrationColor: Color(0xFF0066B2),
      title: 'Cơ hội Việc làm & Referral',
      subtitle:
          'Khám phá hàng trăm việc làm từ alumni đang làm tại các công ty lớn. Được giới thiệu trực tiếp qua mạng lưới FPT.',
      tag: 'US-05',
    ),
    _OnboardingPage(
      illustration: Icons.psychology_outlined,
      illustrationColor: Color(0xFF0DB04B),
      title: 'AI Trợ lý Thông minh',
      subtitle:
          'Nhận tư vấn OJT, nghề nghiệp và học thuật từ AI được đào tạo trên kiến thức cộng đồng FPT. Hỏi đáp 24/7.',
      tag: 'AI-01',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Bỏ qua',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _pages.length,
                itemBuilder: (_, idx) => _OnboardingPageView(page: _pages[idx]),
              ),
            ),

            // Page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? AppColors.primary
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Bắt đầu ngay!'
                        : 'Tiếp theo',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Already have account link
            GestureDetector(
              onTap: () => context.go('/login'),
              child: Text(
                'Đã có tài khoản? Đăng nhập ngay',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Data class for each onboarding page ─────────────────────────────────────

class _OnboardingPage {
  final IconData illustration;
  final Color illustrationColor;
  final String title;
  final String subtitle;
  final String tag;

  const _OnboardingPage({
    required this.illustration,
    required this.illustrationColor,
    required this.title,
    required this.subtitle,
    required this.tag,
  });
}

// ─── Page widget ──────────────────────────────────────────────────────────────

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;
  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration circle
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: page.illustrationColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  page.illustration,
                  size: 80,
                  color: page.illustrationColor,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // User story tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: page.illustrationColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                page.tag,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: page.illustrationColor,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Subtitle
            Text(
              page.subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
