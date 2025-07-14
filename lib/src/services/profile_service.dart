import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ProfileService {
  final _client = Supabase.instance.client;

  Future<Profile?> fetchCurrentProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final data = await _client.from('profiles').select().eq('id', userId).single();
    return Profile.fromMap(data);
  }
} 