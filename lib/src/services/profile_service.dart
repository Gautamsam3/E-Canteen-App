import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ProfileService {
  final _client = Supabase.instance.client;

  Future<Profile?> fetchCurrentProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    print('Fetching profile for userId: $userId');
    final dataList = await _client.from('profiles').select().eq('id', userId);
    print('Profile fetch result: $dataList');
    if (dataList is List && dataList.isNotEmpty) {
      return Profile.fromMap(dataList.first);
    }
    return null;
  }

  Future<void> updateProfile({
    required String fullName,
    required String avatarUrl,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');
    await _client
        .from('profiles')
        .update({'full_name': fullName, 'avatar_url': avatarUrl})
        .eq('id', userId);
  }
}
