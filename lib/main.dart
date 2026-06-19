import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:premio/core/router.dart';
import 'package:premio/core/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:premio/core/providers/shared_prefs_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Инициализация Firebase с сгенерированными опциями
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase успешно инициализирован.');
  } catch (e) {
    debugPrint('Предупреждение: Firebase не инициализирован (проект еще не настроен): $e');
    debugPrint('Вы можете продолжать тестирование с использованием Dev Mock кнопок на экране входа.');
  }

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Premio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Автоматическое переключение тем
      routerConfig: router,
    );
  }
}
