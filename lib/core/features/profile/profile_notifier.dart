import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/model/profile_model.dart';
import 'profile_state.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this._client) : super(ProfileState.initial());

  Future<void>init()async{
    await loadPersistedProfileIfAny();
  }

  final SupabaseClient _client;

  static const String _profilePrefsKey = 'user_profile';

  /// Clear profile from memory + persistence
  Future<void> clearProfile() async {
    state = ProfileState.initial();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profilePrefsKey);
    debugPrint("Profile cleared from memory and persistent storage");
  }

  /// Get profile from API, save to persistence
  Future<bool> getProfile(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single()
          .timeout(const Duration(seconds: 10));

      final profile = Profile.fromMap(response);

      state = state.copyWith(
        profile: profile,
        isLoading: false,
        error: null,
      );

      await _saveProfileToPrefs(profile);
      return true;
    } on TimeoutException {
      _setError("The request timed out. Please check your internet connection.");
    } on SocketException {
      _setError("No internet connection. Please connect and try again.");
    } catch (e) {
      _setError("Failed to fetch profile: ${e.toString()}");
    }

    return false;
  }

  /// Insert profile, save to persistence
  Future<bool> insertProfile(Profile profile, String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      debugPrint(profile.toMap(userId).toString());
      await _client.from('profiles').insert(profile.toMap(userId));
      state = state.copyWith(
        profile: profile,
        isLoading: false,
        error: null,
      );

      await _saveProfileToPrefs(profile.copyWith(id: userId));
      return true;

    } catch (e) {
      _setError("Failed to insert profile: ${e.toString()}");
      return false;
    }
  }

  /// Update profile, save to persistence
  Future<bool> updateProfile(Profile updatedProfile, String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _client
          .from('profiles')
          .update(updatedProfile.toMap(userId))
          .eq('id', userId);

      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        error: null,
      );

      await _saveProfileToPrefs(updatedProfile);
      return true;

    } catch (e) {
      _setError("Failed to update profile: ${e.toString()}");
      return false;
    }
  }

  /// Load persisted profile, if available
  Future<void> loadPersistedProfileIfAny() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_profilePrefsKey);

    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        final profile = Profile.fromMap(map);
        state = state.copyWith(profile: profile);
        debugPrint("Profile loaded from persistent storage");

      } catch (e) {
        debugPrint("Failed to load persisted profile: $e");
        await clearProfile(); // remove corrupted data
      }
    }
  }

  /// Helper: Save profile JSON string to SharedPreferences
  Future<void> _saveProfileToPrefs(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profilePrefsKey, jsonEncode(profile.toMap(profile.id!)));
    state = state.copyWith(profile: profile);
    debugPrint("Profile saved to persistent storage");
  }

  /// Helper: save profile from outside class:
  Future<void> cachedToPersist(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profilePrefsKey, jsonEncode(profile.toMap(profile.id!)));
    state = state.copyWith(profile: profile);
    debugPrint("cached profile saved to persistent storage");
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Helper for setting error state
  void _setError(String message) {
    state = state.copyWith(isLoading: false, error: message);
    debugPrint(message);
  }

  /// Debug: Check and print the stored profile value
  Future<void> debugPrintStoredProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_profilePrefsKey);

    if (jsonStr == null) {
      debugPrint("📦 No stored profile found in SharedPreferences.");
      return;
    }

    debugPrint("📦 Raw stored profile JSON: $jsonStr");

    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final profile = Profile.fromMap(map);
      debugPrint("✅ Decoded stored profile: ${profile.toString()}");
    } catch (e) {
      debugPrint("❌ Failed to decode stored profile: $e");
    }
  }
}