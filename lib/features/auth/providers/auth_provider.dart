import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:premio/core/models/user_profile.dart';

class AuthState {
  final UserProfile? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    UserProfile? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  fb.FirebaseAuth? _auth;
  FirebaseFirestore? _db;

  @override
  AuthState build() {
    try {
      // Initialize services
      _auth = fb.FirebaseAuth.instance;
      _db = FirebaseFirestore.instance;
      
      // Set up Firebase auth changes listener
      _init();
    } catch (e) {
      debugPrint('Firebase Auth/Firestore instances could not be loaded: $e');
    }
    
    return AuthState();
  }

  void _init() {
    try {
      _auth?.authStateChanges().listen((fb.User? firebaseUser) async {
        if (firebaseUser == null) {
          state = AuthState(user: null);
        } else {
          await _loadUserProfile(firebaseUser.uid, firebaseUser.email ?? '');
        }
      });
    } catch (e) {
      debugPrint('Firebase Auth initialization caught (Mock Dev Mode Active): $e');
    }
  }

  Future<void> _loadUserProfile(String uid, String email) async {
    try {
      final doc = await _db?.collection('users').doc(uid).get();
      if (doc != null && doc.exists && doc.data() != null) {
        state = AuthState(user: UserProfile.fromMap(doc.data()!, uid));
      } else {
        final isAdminInterface = defaultTargetPlatform == TargetPlatform.macOS || 
                                 defaultTargetPlatform == TargetPlatform.windows || 
                                 defaultTargetPlatform == TargetPlatform.linux;
        final role = isAdminInterface ? UserRole.admin : UserRole.client;
        final newUser = UserProfile(
          id: uid,
          name: email.split('@').first,
          email: email,
          role: role,
        );
        
        // Попытка сохранить профиль, если его еще нет (самовосстановление)
        try {
          await _db?.collection('users').doc(uid).set(newUser.toMap());
        } catch (_) {}

        state = AuthState(user: newUser);
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      final isAdminInterface = defaultTargetPlatform == TargetPlatform.macOS || 
                               defaultTargetPlatform == TargetPlatform.windows || 
                               defaultTargetPlatform == TargetPlatform.linux;
      final role = isAdminInterface ? UserRole.admin : UserRole.client;
      state = AuthState(
        user: UserProfile(
          id: uid,
          name: email.split('@').first,
          email: email,
          role: role,
        ),
      );
    }
  }

  // Mock login for developer testing
  void loginMock(String name, UserRole role) {
    state = AuthState(
      user: UserProfile(
        id: 'mock_uid_${role.name}',
        name: name,
        email: '${name.toLowerCase()}@example.com',
        role: role,
      ),
    );
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true);
    if (_auth == null) {
      state = AuthState(errorMessage: 'Firebase не настроен. Настройте Firebase или используйте Mock вход.', isLoading: false);
      return;
    }
    try {
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
    } on fb.FirebaseAuthException catch (e) {
      state = AuthState(errorMessage: e.message, isLoading: false);
    } catch (e) {
      state = AuthState(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> signUp(String email, String password, String name, UserRole role) async {
    state = state.copyWith(isLoading: true);
    if (_auth == null) {
      state = AuthState(errorMessage: 'Firebase не настроен. Настройте Firebase или используйте Mock вход.', isLoading: false);
      return;
    }
    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        final profile = UserProfile(
          id: credential.user!.uid,
          name: name,
          email: email,
          role: role,
        );
        await _db?.collection('users').doc(credential.user!.uid).set(profile.toMap());
        state = AuthState(user: profile);
      }
    } on fb.FirebaseAuthException catch (e) {
      state = AuthState(errorMessage: e.message, isLoading: false);
    } catch (e) {
      state = AuthState(errorMessage: e.toString(), isLoading: false);
    }
  }
  void devLogin(UserRole role) {
    state = AuthState(user: UserProfile(id: 'dev-user', name: 'Dev User', email: 'dev@test.com', role: role));
  }

  Future<String?> changePassword(String oldPassword, String newPassword) async {
    final user = _auth?.currentUser;
    if (user == null || user.email == null) {
      return 'Пользователь не авторизован';
    }
    
    try {
      final credential = fb.EmailAuthProvider.credential(email: user.email!, password: oldPassword);
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return null; // Success
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Неверный текущий пароль';
      } else if (e.code == 'weak-password') {
        return 'Новый пароль слишком простой';
      }
      return e.message ?? 'Ошибка при смене пароля';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth?.signOut();
    } catch (e) {
      state = AuthState(user: null);
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
