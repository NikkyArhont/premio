import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

class OnboardingSeenNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool('has_seen_onboarding') ?? false;
  }

  void complete() {
    state = true;
  }
}

final onboardingSeenProvider = NotifierProvider<OnboardingSeenNotifier, bool>(() {
  return OnboardingSeenNotifier();
});
