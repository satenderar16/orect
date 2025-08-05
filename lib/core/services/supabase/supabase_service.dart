import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
   final SupabaseClient client = Supabase.instance.client;


  Future<List<Map<String, dynamic>>> fetchData(String table) async {
    final response = await client.from(table).select();
    return List<Map<String, dynamic>>.from(response);
  }

  // Example: insert data into a table
  Future<void> insertData(String table, Map<String, dynamic> data) async {
    await client.from(table).insert(data);
  }

  //also add function but we are using this class only for client:


  Session? get currentSession => client.auth.currentSession;
  User? get currentUser => client.auth.currentUser;
}
