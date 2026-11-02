import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/core/theme/app_typography.dart';
import 'package:alumni_connect/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:alumni_connect/features/profile/presentation/cubit/profile_cubit.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _majorController;
  late TextEditingController _cohortController;
  late TextEditingController _calendarController;
  late TextEditingController _newSkillController;

  late String _selectedCampus;
  late bool _isAlumni;
  late bool _isPublicToRecruiters;
  late bool _showContactInfo;
  late bool _allowMessagesFromStrangers;
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
    final profile = (context.read<ProfileCubit>().state as ProfileLoaded).profile;
    _nameController = TextEditingController(text: profile.name);
    _bioController = TextEditingController(text: profile.bio);
    _majorController = TextEditingController(text: profile.major);
    _cohortController = TextEditingController(text: profile.cohort);
    _calendarController = TextEditingController(text: profile.calendarUrl ?? '');
    _newSkillController = TextEditingController();

    _selectedCampus = profile.campus;
    _isAlumni = profile.isAlumni;
    _isPublicToRecruiters = profile.isPublicToRecruiters;
    _showContactInfo = profile.showContactInfo;
    _allowMessagesFromStrangers = profile.allowMessagesFromStrangers;
    _skills = List.from(profile.skills);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _majorController.dispose();
    _cohortController.dispose();
    _calendarController.dispose();
    _newSkillController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    context.read<ProfileCubit>().updateProfile(
          name: _nameController.text.trim(),
          bio: _bioController.text.trim(),
          major: _majorController.text.trim(),
          cohort: _cohortController.text.trim(),
          campus: _selectedCampus,
          calendarUrl: _calendarController.text.trim(),
          skills: _skills,
          isAlumni: _isAlumni,
        );

    context.read<ProfileCubit>().updatePrivacySettings(
          isPublicToRecruiters: _isPublicToRecruiters,
          showContactInfo: _showContactInfo,
          allowMessagesFromStrangers: _allowMessagesFromStrangers,
        );

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
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: const NetworkImage(
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
                    ),
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
                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.shield_outlined, size: 14, color: AppColors.accent),
                    SizedBox(width: 4),
                    Text(
                      'Sinh viên K16 • FPT Verified',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent),
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
              value: _selectedCampus,
              decoration: InputDecoration(
                labelText: 'Cơ sở Đại học FPT',
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.secondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  child: _buildTextField('Ngành học', _majorController, Icons.school_outlined),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField('Khóa', _cohortController, Icons.tag),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Google Calendar Link (US-11)
            _buildTextField(
              'Link Google Calendar (US-11)',
              _calendarController,
              Icons.calendar_month_outlined,
              hintText: 'https://calendar.google.com/...',
            ),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 32),
                  onPressed: _addSkill,
                ),
              ],
            ),
            const SizedBox(height: 24),

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
                    title: const Text('Công khai hồ sơ với nhà tuyển dụng', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text(
                      'Cho phép cựu sinh viên và HR tìm thấy hồ sơ của bạn để giới thiệu việc làm (Referral)',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _isPublicToRecruiters,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _isPublicToRecruiters = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Hiển thị email & số điện thoại', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text(
                      'Chỉ hiển thị cho người có trong danh sách kết nối của bạn',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _showContactInfo,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _showContactInfo = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Cho phép nhận tin nhắn từ người lạ', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text(
                      'Người chưa kết nối có thể gửi lời mời nhắn tin',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _allowMessagesFromStrangers,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _allowMessagesFromStrangers = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: Quản lý tài khoản (Đổi MK, Đăng xuất - US-08)
            _buildSectionHeader('Tài khoản & Phiên làm việc'),
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
                    leading: const Icon(Icons.lock_outline, color: AppColors.secondary),
                    title: const Text('Đổi mật khẩu tài khoản'),
                    trailing: const Icon(Icons.chevron_right),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Liên kết đổi mật khẩu đã gửi về email FPT')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.verified_user_outlined, color: AppColors.accent),
                    title: const Text('Xác minh tài khoản Alumni'),
                    trailing: const Text('Đã kích hoạt', style: TextStyle(color: AppColors.accent, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button (US-08)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showLogoutDialog,
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text('Đăng xuất khỏi thiết bị (US-08)', style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
