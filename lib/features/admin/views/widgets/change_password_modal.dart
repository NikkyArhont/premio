import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:premio/features/auth/providers/auth_provider.dart';

class ChangePasswordModal extends ConsumerStatefulWidget {
  const ChangePasswordModal({super.key});

  @override
  ConsumerState<ChangePasswordModal> createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends ConsumerState<ChangePasswordModal> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureRepeat = true;

  bool _isLoading = false;
  String? _oldPasswordError;
  String? _newPasswordError;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, TextEditingController controller, bool obscureText, VoidCallback toggleObscure, {String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: ShapeDecoration(
            color: const Color(0x26CCC3BA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 16),
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: const TextStyle(color: Color(0xFF93959E), fontSize: 12),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF93959E),
                  size: 18,
                ),
                onPressed: toggleObscure,
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              errorText,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 573,
        padding: const EdgeInsets.all(24),
        decoration: ShapeDecoration(
          color: const Color(0xFFEEEEEE),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFF71717A),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 48,
              offset: Offset(0, 32),
              spreadRadius: -8,
            ),
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 14,
              offset: Offset(0, 0),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Сменить пароль',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildTextField(
              'Существующий пароль',
              _oldPasswordController,
              _obscureOld,
              () => setState(() => _obscureOld = !_obscureOld),
              errorText: _oldPasswordError,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Новый пароль',
              _newPasswordController,
              _obscureNew,
              () => setState(() => _obscureNew = !_obscureNew),
              errorText: _newPasswordError,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Повторите пароль',
              _repeatPasswordController,
              _obscureRepeat,
              () => setState(() => _obscureRepeat = !_obscureRepeat),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        color: const Color(0x19FAF9F4),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0x7F006A36),
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text(
                        'Отмена',
                        style: TextStyle(
                          color: Color(0xFF006A36),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _isLoading ? null : () async {
                      final oldPassword = _oldPasswordController.text;
                      final newPassword = _newPasswordController.text;
                      final repeatPassword = _repeatPasswordController.text;

                      setState(() {
                        _oldPasswordError = null;
                        _newPasswordError = null;
                      });

                      if (oldPassword.isEmpty) {
                        setState(() => _oldPasswordError = 'Введите текущий пароль');
                        return;
                      }
                      if (newPassword.isEmpty) {
                        setState(() => _newPasswordError = 'Введите новый пароль');
                        return;
                      }
                      if (newPassword != repeatPassword) {
                        setState(() => _newPasswordError = 'Пароли не совпадают');
                        return;
                      }

                      setState(() => _isLoading = true);
                      final error = await ref.read(authProvider.notifier).changePassword(oldPassword, newPassword);
                      if (!mounted) return;
                      setState(() => _isLoading = false);

                      if (error != null) {
                        if (error.contains('текущий') || error.contains('wrong-password') || error.contains('invalid-credential')) {
                          setState(() => _oldPasswordError = error);
                        } else {
                          setState(() => _newPasswordError = error);
                        }
                      } else {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Пароль успешно изменен!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        color: _isLoading ? const Color(0xFF199C5B).withOpacity(0.5) : const Color(0xFF199C5B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text(
                            'Сохранить',
                            style: TextStyle(
                              color: Color(0xFFFAF9F4),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
