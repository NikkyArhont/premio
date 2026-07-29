import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:premio/features/auth/providers/auth_provider.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/logo.png', 
                              height: 60, 
                              errorBuilder: (context, error, stackTrace) => const SizedBox(height: 60),
                            ),
                            const Text('v1.0.9', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Вход администратора',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Доступ к административной панели разрешен только уполномоченным сотрудникам',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF717171),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (authState.errorMessage != null) ...[
                        Text(
                          authState.errorMessage!,
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
                      const SizedBox(height: 24),
                      
                      // Кнопка продолжить
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : () {
                            final email = _emailController.text.trim();
                            final password = _passwordController.text;
                            if (email.isNotEmpty && password.isNotEmpty) {
                              ref.read(authProvider.notifier).signIn(email, password);
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
                                  'Продолжить',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Забыли пароль
                      TextButton(
                        onPressed: () {},
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Забыли пароль? ',
                                style: TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: 'Восстановить пароль',
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
                      const SizedBox(height: 16),
                      
                      // Нет аккаунта? Зарегистрироваться
                      TextButton(
                        onPressed: () {
                          context.go('/admin-register');
                        },
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Нет аккаунта? ',
                                style: TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: 'Зарегистрироваться',
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
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: const Text(
                          'ВРЕМЕННО: Перейти в мобильную версию',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Соглашения
                      const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Продолжая, вы соглашаетесь с ',
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
