import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:premio/features/auth/providers/auth_provider.dart';
import 'package:premio/core/models/user_profile.dart';

class AdminRegisterScreen extends ConsumerStatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  ConsumerState<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends ConsumerState<AdminRegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  String? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1400),
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: ShapeDecoration(
                color: const Color(0xFFFAF9F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
              child: Center(
                child: Container(
                  width: 580,
                  padding: const EdgeInsets.all(40),
                  decoration: ShapeDecoration(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Логотип
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Image.asset(
                          'assets/logo.png', 
                          height: 60, 
                          errorBuilder: (context, error, stackTrace) => const SizedBox(height: 60),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Регистрация',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Создайте учетную запись для доступа к панели',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF717171),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_localError != null || authState.errorMessage != null) ...[
                        Text(
                          _localError ?? authState.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        const SizedBox(height: 16),
                      ],
                      
                      // Email
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                      ),
                      const SizedBox(height: 16),
                      
                      // Пароль
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Пароль',
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                      
                      // Подтверждение пароля
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Подтвердите пароль',
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),
                      
                      // Кнопка Зарегистрироваться
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : () {
                            final email = _emailController.text.trim();
                            final password = _passwordController.text;
                            final confirmPassword = _confirmPasswordController.text;
                            
                            if (password != confirmPassword) {
                              setState(() {
                                _localError = 'Пароли не совпадают';
                              });
                              return;
                            } else {
                              setState(() {
                                _localError = null;
                              });
                            }

                            if (email.isNotEmpty && password.isNotEmpty) {
                              ref.read(authProvider.notifier).signUp(email, password, 'Администратор', UserRole.admin);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006A36), // Используем зеленый акцентный цвет
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            elevation: 0,
                          ),
                          child: authState.isLoading 
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text(
                                  'Зарегистрироваться',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Уже есть аккаунт? Войти
                      TextButton(
                        onPressed: () {
                          context.go('/admin-login');
                        },
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Уже есть аккаунт? ',
                                style: TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: 'Войти',
                                style: TextStyle(
                                  color: Color(0xFF006A36),
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Соглашения
                      const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Регистрируясь, вы соглашаетесь с ',
                              style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
                            ),
                            TextSpan(
                              text: 'Условиями использования',
                              style: TextStyle(
                                color: Color(0xFF006A36),
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(
                              text: '\nи ',
                              style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
                            ),
                            TextSpan(
                              text: 'Политикой конфиденциальности',
                              style: TextStyle(
                                color: Color(0xFF006A36),
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(
                              text: '.',
                              style: TextStyle(color: Color(0xFF006A36), fontSize: 14),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
  }) {
    return Container(
      decoration: ShapeDecoration(
        color: const Color(0x26CCC3BA),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        style: const TextStyle(color: Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF93959E),
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF93959E),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
