import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:savaio/others.dart';
import 'package:savaio/others.dart';

void main() {
  group('Analisa Page API Tests', () {
    late SupabaseClient client;
    const testEmail = 'test1@savaio.com';
    const testPassword = 'password123';

    setUpAll(() async {
      // Load environment variables
      await dotenv.load(fileName: ".env");

      // Initialize Supabase for testing
      await Supabase.initialize(
        url: ApiConfig.supabaseUrl,
        anonKey: ApiConfig.supabaseAnonKey,
      );
      
      client = Supabase.instance.client;
      sl.setup();
    });

    test('Login and Fetch Analysis Snapshot', () async {
      // 1. Sign in
      final response = await client.auth.signInWithPassword(
        email: testEmail,
        password: testPassword,
      );
      
      expect(response.user, isNotNull);
      expect(response.user!.email, testEmail);

      final userId = response.user!.id;
      final currentMonth = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

      // 2. Call the optimized RPC
      final result = await client.rpc('get_analysis_snapshot', params: {
        'p_user_id': userId,
        'p_month': currentMonth,
      });

      // 3. Verify the structure and data
      expect(result, isNotNull);
      expect(result['month'], currentMonth);
      expect(result, contains('total_expense'));
      expect(result, contains('target_amount'));
      expect(result, contains('category_breakdown'));
      expect(result, contains('daily_trend'));
      expect(result, contains('monthly_trend'));

      print('--- Analysis Snapshot Test Success ---');
      print('Month: ${result['month']}');
      print('Total Expense: ${result['total_expense']}');
      print('Categories Found: ${(result['category_breakdown'] as List).length}');
      print('--------------------------------------');
    });
  });
}
