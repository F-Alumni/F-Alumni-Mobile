import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/core/theme/app_typography.dart';
import 'package:alumni_connect/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:alumni_connect/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:alumni_connect/features/lab3/presentation/viewmodels/avatar_upload_view_model.dart';
import 'package:alumni_connect/features/lab3/presentation/viewmodels/crashlytics_demo_view_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _majorController;
  late TextEditingController _cohortController;
  late TextEditingController _calendarController;
  late TextEditingController _avatarController;
  late TextEditingController _newSkillController;

  late String _selectedCampus;
  late bool _isVerified;
  late bool _isPublicToRecruiters;
  late bool _showEmailPublicly;
  late bool _showPhonePublicly;
  late bool _showCalendarPublicly;
  late List<String> _skills;

  final List<String> _campusOptions = [
    'FPT Đà Nẵng',
    'FPT Hòa Lạc',
    'FPT TP.HCM',
    'FPT Quy Nhơn',
    'FPT Cần Thơ',
  ];

  @override
  void initState() {
    super.initState();
    final profile =
        (context.read<ProfileCubit>().state as ProfileLoaded).profile;
    _nameController = TextEditingController(text: profile.name);
    _bioController = TextEditingController(text: profile.bio);
    _majorController = TextEditingController(text: profile.major);
    _cohortController = TextEditingController(text: profile.cohort);
    _calendarController = TextEditingController(
      text: profile.calendarUrl ?? '',
    );
    _avatarController = TextEditingController(text: profile.avatarUrl);
    _newSkillController = TextEditingController();

    _selectedCampus = switch (profile.campus.trim().toUpperCase()) {
      'HCM' || 'FU-HCM' || 'TP.HCM' || 'TP. HỒ CHÍ MINH' => 'FPT TP.HCM',
      'DN' || 'FU-DN' || 'ĐÀ NẴNG' => 'FPT Đà Nẵng',
      'HL' || 'FU-HL' || 'HÒA LẠC' => 'FPT Hòa Lạc',
      'QN' || 'FU-QN' || 'QUY NHƠN' => 'FPT Quy Nhơn',
      'CT' || 'FU-CT' || 'CẦN THƠ' => 'FPT Cần Thơ',
      _ =>
        _campusOptions.contains(profile.campus)
            ? profile.campus
            : _campusOptions.first,
    };
    _isVerified = profile.isVerified;
    _isPublicToRecruiters = profile.isPublicToRecruiters;
    _showEmailPublicly = profile.showEmailPublicly;
    _showPhonePublicly = profile.showPhonePublicly;
    _showCalendarPublicly = profile.showCalendarPublicly;
    _skills = List.from(profile.skills);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _majorController.dispose();
    _cohortController.dispose();
    _calendarController.dispose();
    _avatarController.dispose();
    _newSkillController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final cubit = context.read<ProfileCubit>();
    final profileSaved = await cubit.updateProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      major: _majorController.text.trim(),
      cohort: _cohortController.text.trim(),
      campus: _selectedCampus,
      calendarUrl: _calendarController.text.trim(),
      avatarUrl: _avatarController.text.trim(),
      skills: _skills,
    );

    if (!profileSaved) {
      if (!mounted) return;
      final state = cubit.state;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state is ProfileError ? state.message : 'Không thể lưu hồ sơ.',
          ),
        ),
      );
      return;
    }

    final privacySaved = await cubit.updatePrivacySettings(
      isPublicToRecruiters: _isPublicToRecruiters,
      showEmailPublicly: _showEmailPublicly,
      showPhonePublicly: _showPhonePublicly,
      showCalendarPublicly: _showCalendarPublicly,
    );

    if (!privacySaved) {
      if (!mounted) return;
      final state = cubit.state;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state is ProfileError
                ? state.message
                : 'Không thể lưu cài đặt riêng tư.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    context.pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu thay đổi hồ sơ & cài đặt thành công!'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addSkill() {
    final skill = _newSkillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _newSkillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  Future<void> _uploadAvatar(ImageSource source) async {
    final url = await ref
        .read(avatarUploadViewModelProvider.notifier)
        .pickAndUploadAvatar(source: source);
    if (!mounted) return;
    if (url != null) {
      setState(() => _avatarController.text = url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ảnh đã tải lên Firebase Storage.')),
      );
      return;
    }

    final error = ref.read(avatarUploadViewModelProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất tài khoản?'),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng FPT Alumni Connect? Bạn sẽ cần đăng nhập lại qua FPT Mail để tiếp tục.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              // US-08: real logout — router redirect will navigate to /onboarding
              context.read<AuthCubit>().logout();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarUpload = ref.watch(avatarUploadViewModelProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Chỉnh sửa hồ sơ & Cài đặt',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              'Lưu',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Avatar Edit Section
            // User Avatar Edit Section (US-04)
            Center(
              child: GestureDetector(
                onTap: _showAvatarPickerModal,
                child: Tooltip(
                  message: 'Chạm để đổi ảnh đại diện (US-04)',
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.surfaceVariant,
                        backgroundImage: _avatarController.text.trim().isEmpty
                            ? null
                            : NetworkImage(_avatarController.text.trim()),
                        child: _avatarController.text.trim().isEmpty
                            ? const Icon(Icons.person_outline, size: 42)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            if (avatarUpload.isUploading) ...[
              LinearProgressIndicator(value: avatarUpload.progress),
              const SizedBox(height: 4),
              Center(child: Text('${(avatarUpload.progress * 100).round()}%')),
            ],
            Center(
              child: TextButton.icon(
                onPressed: _showAvatarPickerModal,
                icon: const Icon(Icons.photo_camera_back_outlined, size: 16),
                label: const Text(
                  'Thay đổi ảnh đại diện',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isVerified ? 'Email đã xác minh' : 'Email chưa xác minh',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isVerified
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section 1: Thông tin cá nhân (US-04)
            _buildSectionHeader('Thông tin cá nhân (US-04)'),
            const SizedBox(height: 12),
            _buildTextField('Họ và tên', _nameController, Icons.person_outline),
            const SizedBox(height: 12),
            _buildTextField(
              'Giới thiệu ngắn (Bio)',
              _bioController,
              Icons.info_outline,
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            // Campus Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCampus,
              decoration: InputDecoration(
                labelText: 'Cơ sở Đại học FPT',
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.secondary,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _campusOptions.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCampus = val);
              },
            ),
            const SizedBox(height: 12),

            // Major & Cohort
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    'Ngành học',
                    _majorController,
                    Icons.school_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField('Khóa', _cohortController, Icons.tag),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Google Calendar Link (US-11)
            // Google Calendar Integration (US-11)
            _buildCalendarIntegrationCard(),
            const SizedBox(height: 16),

            // Skills & Interests
            _buildSectionHeader('Kỹ năng & Chuyên môn'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((skill) {
                return Chip(
                  label: Text(skill, style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.surfaceVariant,
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _removeSkill(skill),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newSkillController,
                    decoration: InputDecoration(
                      hintText: 'Thêm kỹ năng mới (VD: Docker, React Native)',
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  onPressed: _addSkill,
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildTextField(
              'URL ảnh đại diện',
              _avatarController,
              Icons.account_circle_outlined,
              hintText: 'https://...',
            ),
            const SizedBox(height: 12),

            // Section 2: Quyền riêng tư & Bảo mật (US-08, US-09)
            _buildSectionHeader('Quyền riêng tư & Bảo mật (US-08, US-09)'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Hiển thị công ty trên hồ sơ công khai',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Điều khiển trường công ty hiện tại trong hồ sơ công khai.',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _isPublicToRecruiters,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) =>
                        setState(() => _isPublicToRecruiters = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text(
                      'Hiển thị link Google Calendar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: _showCalendarPublicly,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) =>
                        setState(() => _showCalendarPublicly = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text(
                      'Hiển thị email',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Cho phép người khác xem email trên hồ sơ công khai.',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _showEmailPublicly,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) =>
                        setState(() => _showEmailPublicly = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text(
                      'Hiển thị số điện thoại',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Cho phép người khác xem số điện thoại trên hồ sơ công khai.',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _showPhonePublicly,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) =>
                        setState(() => _showPhonePublicly = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text(
                      'Cho phép nhận tin nhắn từ người lạ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Backend chưa có cài đặt cho phép hoặc chặn tin nhắn từ người lạ.',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: false,
                    activeThumbColor: AppColors.primary,
                    onChanged: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: Quản lý tài khoản (Đổi MK, Đăng xuất - US-08)
            _buildSectionHeader('Tài khoản & Phiên làm việc'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/change-password'),
                icon: const Icon(Icons.lock_reset),
                label: const Text('Đổi mật khẩu (US-07)'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/blocked-users'),
                icon: const Icon(Icons.block_outlined),
                label: const Text('Quản lý tài khoản đã chặn (US-10)'),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.lock_outline,
                      color: AppColors.secondary,
                    ),
                    title: const Text('Đổi mật khẩu tài khoản'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/change-password'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.accent,
                    ),
                    title: const Text('Trạng thái xác minh email'),
                    trailing: Text(
                      _isVerified ? 'Đã xác minh' : 'Chưa xác minh',
                      style: TextStyle(
                        color: _isVerified ? AppColors.accent : AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (kDebugMode) ...[
              _buildSectionHeader('Lab 3 Debug Area'),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => ref
                    .read(crashlyticsDemoViewModelProvider.notifier)
                    .triggerTestCrash(),
                icon: const Icon(Icons.bug_report_outlined),
                label: const Text('Gửi test crash tới Crashlytics'),
              ),
              const SizedBox(height: 24),
            ],

            // Logout Button (US-08)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showLogoutDialog,
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text(
                  'Đăng xuất khỏi thiết bị (US-08)',
                  style: TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.titleSmall.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  void _showAvatarPickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn ảnh đại diện (US-04)',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text('Chọn ảnh từ thư viện thiết bị'),
                subtitle: const Text('Tải ảnh lên Firebase Storage'),
                onTap: () {
                  Navigator.pop(ctx);
                  unawaited(_uploadAvatar(ImageSource.gallery));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarIntegrationCard() {
    final hasCalendar = _calendarController.text.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasCalendar
              ? AppColors.accent.withValues(alpha: 0.5)
              : AppColors.border,
          width: hasCalendar ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Liên kết Google Calendar (US-11)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasCalendar
                          ? 'Đã lưu đường dẫn lịch hẹn'
                          : 'Chưa lưu đường dẫn lịch hẹn',
                      style: TextStyle(
                        fontSize: 11,
                        color: hasCalendar
                            ? AppColors.accent
                            : AppColors.textSecondary,
                        fontWeight: hasCalendar
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: hasCalendar
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasCalendar ? Icons.check_circle : Icons.link_off,
                      size: 12,
                      color: hasCalendar
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasCalendar ? 'Đã lưu' : 'Chưa có',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: hasCalendar
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _calendarController,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'https://calendar.google.com/calendar/u/0/...',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              prefixIcon: const Icon(
                Icons.link,
                size: 18,
                color: AppColors.textSecondary,
              ),
              suffixIcon: hasCalendar
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        setState(() => _calendarController.clear());
                      },
                    )
                  : null,
            ),
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Cách lấy link Google Calendar'),
                      content: const Text(
                        '1. Mở Google Calendar trên máy tính\n'
                        '2. Vào Cài đặt lịch của bạn > Quyền truy cập cho sự kiện\n'
                        '3. Chọn "Chia sẻ công khai" hoặc tạo một "Lịch hẹn (Appointment Schedule)"\n'
                        '4. Sao chép liên kết chia sẻ và dán vào ô bên trên.',
                      ),
                      actions: [
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Đã hiểu'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.help_outline, size: 14),
                label: const Text(
                  'Hướng dẫn lấy link',
                  style: TextStyle(fontSize: 11),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const Spacer(),
              if (hasCalendar)
                OutlinedButton.icon(
                  onPressed: () {
                    final uri = Uri.tryParse(_calendarController.text.trim());
                    final isValid =
                        uri != null &&
                        uri.scheme == 'https' &&
                        (uri.host == 'calendar.google.com' ||
                            uri.host == 'calendar.app.google');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isValid ? '✅ Đường dẫn Google Calendar hợp lệ!' : '⚠️ Đường dẫn có thể chưa đúng định dạng Google Calendar.',
                        ),
                        backgroundColor: isValid
                            ? AppColors.accent
                            : AppColors.warning,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified_outlined, size: 14),
                  label: const Text('Kiểm tra', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
