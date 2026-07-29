import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:premio/core/models/user_profile.dart';
import 'package:premio/features/auth/providers/auth_provider.dart';
import 'package:premio/features/auth/views/login_screen.dart';
import 'package:premio/features/admin/views/admin_dashboard.dart';
import 'package:premio/features/client/views/client_home.dart';
import 'package:premio/features/staff/views/staff_dashboard.dart';
import 'package:premio/features/auth/views/splash_screen.dart';
import 'package:premio/features/auth/views/permission_screen.dart';
import 'package:premio/features/auth/views/success_screen.dart';
import 'package:premio/features/auth/views/profile_setup_screen.dart';
import 'package:premio/features/auth/views/onboarding_screen.dart';
import 'package:premio/features/auth/views/admin_login_screen.dart';
import 'package:premio/features/auth/views/admin_register_screen.dart';
import 'package:premio/core/providers/shared_prefs_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

bool get _isAdminInterface => 
    defaultTargetPlatform == TargetPlatform.macOS || 
    defaultTargetPlatform == TargetPlatform.windows || 
    defaultTargetPlatform == TargetPlatform.linux;

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  _RouterNotifier(this._ref) {
    _ref.listen(authProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final loggedIn = authState.user != null;
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/admin-login' || state.matchedLocation == '/admin-register';

      final isSplash = state.matchedLocation == '/splash';
      if (isSplash) return null;

      final hasSeenOnboarding = ref.read(onboardingSeenProvider);
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (!hasSeenOnboarding && !_isAdminInterface) {
        return isOnboarding ? null : '/onboarding';
      }

      final isPermission = state.matchedLocation == '/permission';
      final isSuccess = state.matchedLocation == '/success';
      final isProfileSetup = state.matchedLocation == '/profile-setup';

      if (!loggedIn) {
        if (isLoggingIn || isPermission || isSuccess || isProfileSetup || isOnboarding) {
          // if (_isAdminInterface && state.matchedLocation == '/login') return '/admin-login';
          if (!_isAdminInterface && (state.matchedLocation == '/admin-login' || state.matchedLocation == '/admin-register')) return '/login';
          return null;
        }
        return _isAdminInterface ? '/admin-login' : '/login';
      }

      // User is logged in, redirect from login to their default screen if they try to access login
      if (isLoggingIn) {
        switch (authState.user!.role) {
          case UserRole.admin:
            return '/admin';
          case UserRole.staff:
            return '/staff';
          case UserRole.client:
            return '/client';
        }
      }

      // Role check for specific pathways
      final isAccessingAdmin = state.matchedLocation.startsWith('/admin');
      final isAccessingStaff = state.matchedLocation.startsWith('/staff');
      final isAccessingClient = state.matchedLocation.startsWith('/client');

      if (isAccessingAdmin && authState.user!.role != UserRole.admin) {
        return _getHomeRoute(authState.user!.role);
      }
      if (isAccessingStaff && authState.user!.role != UserRole.staff && authState.user!.role != UserRole.admin) {
        return _getHomeRoute(authState.user!.role);
      }
      if (isAccessingClient && authState.user!.role != UserRole.client) {
        return _getHomeRoute(authState.user!.role);
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin-register',
        builder: (context, state) => const AdminRegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/permission',
        builder: (context, state) => const PermissionScreen(),
      ),
      GoRoute(
        path: '/success',
        builder: (context, state) => const SuccessScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/staff',
        builder: (context, state) => const StaffDashboard(),
      ),
      GoRoute(
        path: '/client',
        builder: (context, state) => const ClientHome(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Страница не найдена: ${state.error}'),
      ),
    ),
  );
});

String _getHomeRoute(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return '/admin';
    case UserRole.staff:
      return '/staff';
    case UserRole.client:
      return '/client';
  }
}
