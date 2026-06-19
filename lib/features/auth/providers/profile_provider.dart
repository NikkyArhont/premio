import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  final String name;
  final String address;

  ProfileState({this.name = '', this.address = ''});

  ProfileState copyWith({String? name, String? address}) {
    return ProfileState(
      name: name ?? this.name,
      address: address ?? this.address,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return ProfileState();
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateAddress(String address) {
    state = state.copyWith(address: address);
  }
  
  void saveProfile(String name, String address) {
    state = state.copyWith(name: name, address: address);
    // TODO: Connect this to SharedPreferences or Firebase later.
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});
