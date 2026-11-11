import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/auth/presentation/cubit/auth_cubit.dart';

enum AccountFlowMode {
  register,
  verifyEmail,
  forgotPassword,
  resetPassword,
  changePassword,
}

class AccountFlowScreen extends StatefulWidget {
  const AccountFlowScreen({super.key, required this.mode, this.email = ''});

  final AccountFlowMode mode;
  final String email;

  @override
  State<AccountFlowScreen> createState() => _AccountFlowScreenState();
}

class _AccountFlowScreenState extends State<AccountFlowScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController();
  late final _email = TextEditingController(text: widget.email);
  late final _password = TextEditingController();
  late final _currentPassword = TextEditingController();
  late final _otp = TextEditingController();
  String _selectedAccountType = 'Alumni';
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _currentPassword.dispose();
    _otp.dispose();
    super.dispose();
  }

  String get _title => switch (widget.mode) {
    AccountFlowMode.register => 'Tạo tài khoản',
    AccountFlowMode.verifyEmail => 'Xác minh email',
    AccountFlowMode.forgotPassword => 'Quên mật khẩu',
    AccountFlowMode.resetPassword => 'Đặt lại mật khẩu',
    AccountFlowMode.changePassword => 'Đổi mật khẩu',
  };

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final auth = context.read<AuthCubit>();
    String? error;
    switch (widget.mode) {
      case AccountFlowMode.register:
        error = await auth.register(
          email: _email.text,
          password: _password.text,
          fullName: _name.text,
          accountType: _selectedAccountType,
        );
        if (error == null && mounted)
          context.go(
            '/verify-email?email=${Uri.encodeQueryComponent(_email.text.trim())}',
          );
      case AccountFlowMode.verifyEmail:
        error = await auth.verifyEmail(email: _email.text, otpCode: _otp.text);
      case AccountFlowMode.forgotPassword:
        error = await auth.requestPasswordReset(_email.text);
        if (error == null && mounted)
          context.go(
            '/reset-password?email=${Uri.encodeQueryComponent(_email.text.trim())}',
          );
      case AccountFlowMode.resetPassword:
        error = await auth.resetPassword(
          email: _email.text,
          otpCode: _otp.text,
          newPassword: _password.text,
        );
        if (error == null && mounted) context.go('/login');
      case AccountFlowMode.changePassword:
        error = await auth.changePassword(
          currentPassword: _currentPassword.text,
          newPassword: _password.text,
        );
        if (error == null && mounted) context.pop();
    }
    if (mounted) {
      setState(() => _busy = false);
      if (error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      } else if (widget.mode == AccountFlowMode.forgotPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mã xác minh đã được gửi nếu email hợp lệ.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (mode == AccountFlowMode.register) ...[
                _field(_name, 'Họ và tên'),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                    value: _selectedAccountType,
                    decoration: const InputDecoration(
                      labelText: 'Vai trò (Role)',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Alumni',
                        child: Text('Cựu sinh viên (Alumni)'),
                      ),
                      DropdownMenuItem(
                        value: 'Student',
                        child: Text('Sinh viên (Student)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedAccountType = val);
                      }
                    },
                  ),
                ),
              ],
              if (mode != AccountFlowMode.changePassword) ...[
                _field(
                  _email,
                  'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
              if (mode == AccountFlowMode.verifyEmail ||
                  mode == AccountFlowMode.resetPassword)
                _field(_otp, 'Mã OTP', keyboardType: TextInputType.number),
              if (mode == AccountFlowMode.changePassword)
                _field(_currentPassword, 'Mật khẩu hiện tại', secret: true),
              if (mode == AccountFlowMode.register ||
                  mode == AccountFlowMode.resetPassword ||
                  mode == AccountFlowMode.changePassword)
                _field(
                  _password,
                  mode == AccountFlowMode.register
                      ? 'Mật khẩu'
                      : 'Mật khẩu mới',
                  secret: true,
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy ? const CircularProgressIndicator() : Text(_title),
              ),
              if (mode == AccountFlowMode.forgotPassword) ...[
                const SizedBox(height: 8),
                const Text(
                  'Nhập email, sau đó dùng mã OTP nhận được để đặt mật khẩu mới.',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool secret = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: secret,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty) return '$label không được để trống';
          if (label == 'Email' && !text.contains('@'))
            return 'Email không hợp lệ';
          if ((label.contains('Mật khẩu')) && text.length < 6)
            return 'Mật khẩu cần ít nhất 6 ký tự';
          return null;
        },
      ),
    );
  }
}
