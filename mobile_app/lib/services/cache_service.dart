import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';

class CacheService {
  /// Fetch from Supabase; on failure, fall back to cached JSON.
    static Future<List<Map<String, dynamic>>> fetchList(
    String table, {
    String? orderBy,
    bool ascending = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cache_$table';

    try {
      final dynamic query = orderBy == null
          ? SupabaseService.client.from(table).select()
          : SupabaseService.client
              .from(table)
              .select()
              .order(orderBy, ascending: ascending);

      final data = await query;
      final list = List<Map<String, dynamic>>.from(data);
      await prefs.setString(cacheKey, jsonEncode(list));
      return list;
    } catch (_) {
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        final decoded = jsonDecode(cached) as List;
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    }
  }

  static Future<bool> isOffline() async {
    try {
      await SupabaseService.client.from('careers').select('id').limit(1);
      return false;
    } catch (_) {
      return true;
    }
  }
}