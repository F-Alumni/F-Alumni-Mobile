import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:alumni_connect/core/network/alumni_api.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';
import 'package:alumni_connect/features/events/data/event_repository.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late final EventRepository _repository = EventRepository(AlumniApi());
  bool _isSubmitting = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _maxAttendeesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCampus = 'Tất cả cơ sở';
  String _selectedFormat = 'Trực tiếp (Offline)';
  String _bannerUrl = '';

  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);

  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 30);

  final List<String> _campuses = [
    'Tất cả cơ sở',
    'Hòa Lạc',
    'TP. Hồ Chí Minh',
    'Đà Nẵng',
    'Cần Thơ',
    'Quy Nhơn',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _maxAttendeesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _showBannerPickerModal() async {
    final controller = TextEditingController(text: _bannerUrl);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đường dẫn ảnh bìa'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'https://example.com/event-banner.jpg',
            helperText: 'Backend hiện nhận URL ảnh, chưa hỗ trợ tải file lên.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final uri = Uri.tryParse(controller.text.trim());
              if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đường dẫn ảnh không hợp lệ.')),
                );
                return;
              }
              setState(() => _bannerUrl = uri.toString());
              Navigator.pop(dialogContext);
            },
            child: const Text('Lưu URL'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Thời gian kết thúc phải diễn ra sau thời gian bắt đầu!',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final maxAtt = int.tryParse(_maxAttendeesController.text.trim());

    setState(() => _isSubmitting = true);
    try {
      final location = _selectedFormat.contains('Online')
          ? '${_locationController.text.trim()} (Google Meet)'
          : _locationController.text.trim();
      final created = await _repository.createEvent(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: location,
        campus: EventRepository.campusCode(_selectedCampus),
        startTime: startDateTime,
        endTime: endDateTime,
        maxAttendees: maxAtt,
        bannerUrl: _bannerUrl,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tạo sự kiện thành công.'),
          backgroundColor: AppColors.fptOrange,
        ),
      );
      context.pop(created);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không tạo được sự kiện: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Tạo sự kiện mới',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            child: const Text(
              'Đăng ngay',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.fptOrange,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Forum API hiện chưa có chức năng lưu bản nháp.',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    context.pop();
                  },
                  icon: const Icon(
                    Icons.bookmark_border,
                    size: 18,
                    color: AppColors.fptBlue,
                  ),
                  label: const Text(
                    'Lưu bản nháp',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.fptBlue,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.fptBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  icon: const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Đăng sự kiện',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.fptOrange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Banner Upload Area ──────────────────────────────────────
              InkWell(
                onTap: _showBannerPickerModal,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.fptOrange.withOpacity(0.4),
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: _bannerUrl.isEmpty
                            ? const Center(
                                child: Icon(Icons.add_photo_alternate_outlined,
                                    size: 44, color: AppColors.textMuted),
                              )
                            : Image.network(
                                _bannerUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.black.withOpacity(0.35),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.photo_camera,
                                  color: AppColors.fptOrange,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Chạm để đổi ảnh bìa sự kiện',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '(Backend hiện nhận URL ảnh, chưa hỗ trợ tải file)',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Field 1: Tiêu đề sự kiện ────────────────────────────────
              _buildFieldLabel('Tiêu đề sự kiện', isRequired: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText:
                      'VD: FPT Alumni Tech Talk 2026: Đón đầu kỷ nguyên AI',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.fptOrange,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề sự kiện';
                  }
                  if (val.trim().length < 5) {
                    return 'Tiêu đề sự kiện tối thiểu 5 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── Field 2: Cơ sở FPTU ────────────────────────────────────
              _buildFieldLabel('Cơ sở FPTU tổ chức', isRequired: true),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCampus,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.textSecondary,
                    ),
                    items: _campuses.map((campus) {
                      return DropdownMenuItem<String>(
                        value: campus,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.school_outlined,
                              size: 18,
                              color: AppColors.fptBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              campus,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCampus = val;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Field 3: Thời gian tổ chức ──────────────────────────────
              _buildFieldLabel('Thời gian tổ chức', isRequired: true),
              const SizedBox(height: 6),
              // Bắt đầu
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Bắt đầu:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: _pickStartDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: AppColors.fptOrange,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(_startDate),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _pickStartTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: AppColors.fptOrange,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _startTime.format(context),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Kết thúc
                    Row(
                      children: [
                        const Text(
                          'Kết thúc:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: _pickEndDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: AppColors.fptBlue,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(_endDate),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _pickEndTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: AppColors.fptBlue,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _endTime.format(context),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Field 4: Địa điểm & Hình thức ───────────────────────────
              _buildFieldLabel(
                'Hình thức & Địa điểm tổ chức',
                isRequired: true,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Trực tiếp (Offline)'),
                    selected: _selectedFormat == 'Trực tiếp (Offline)',
                    selectedColor: AppColors.fptOrange,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: _selectedFormat == 'Trực tiếp (Offline)'
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFormat = 'Trực tiếp (Offline)';
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Online (Google Meet/Zoom)'),
                    selected: _selectedFormat == 'Online (Google Meet/Zoom)',
                    selectedColor: AppColors.fptBlue,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: _selectedFormat == 'Online (Google Meet/Zoom)'
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFormat = 'Online (Google Meet/Zoom)';
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: _selectedFormat == 'Trực tiếp (Offline)'
                      ? 'VD: Hội trường Trống Đồng, ĐH FPT Hòa Lạc'
                      : 'VD: https://meet.google.com/abc-xyz hoặc Zoom ID',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: Icon(
                    _selectedFormat == 'Trực tiếp (Offline)'
                        ? Icons.location_on_outlined
                        : Icons.link,
                    color: AppColors.fptOrange,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.fptOrange,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập địa điểm hoặc đường dẫn online';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Field 5: Giới hạn số lượng tham dự ──────────────────────
              _buildFieldLabel('Số lượng người tham dự tối đa (Tùy chọn)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _maxAttendeesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'VD: 100 (Để trống nếu không giới hạn chỗ)',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.group_outlined,
                    color: AppColors.fptGreen,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
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
              const SizedBox(height: 16),

              // ── Field 6: Mô tả chi tiết ─────────────────────────────────
              _buildFieldLabel('Mô tả chi tiết sự kiện', isRequired: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Nội dung chia sẻ, timeline chương trình, giới thiệu diễn giả và lưu ý khi tham gia...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.fptOrange,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập mô tả chi tiết sự kiện';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Notice Box ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.fptOrange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.fptOrange.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.fptOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sự kiện sau khi đăng sẽ được gửi thông báo đến các cựu sinh viên & sinh viên thuộc cơ sở bạn đã chọn.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
      ],
    );
  }
}
