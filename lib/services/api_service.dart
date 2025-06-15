import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String baseUrl = ""; // User must set this in Settings

  static bool autoRefreshEnabled = true;
  static Timer? _timer;

  static void setBaseUrl(String url) {
    baseUrl = url;
  }

  static void setAutoRefresh(bool enabled) {
    autoRefreshEnabled = enabled;
    if (!enabled) stopAutoRefresh();
  }

  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString('baseUrl') ?? baseUrl;
    autoRefreshEnabled = prefs.getBool('autoRefresh') ?? true;
  }

  static void startAutoRefresh(Function callback) {
    stopAutoRefresh();
    if (autoRefreshEnabled) {
      _timer = Timer.periodic(Duration(seconds: 10), (_) => callback());
    }
  }

  static void stopAutoRefresh() {
    _timer?.cancel();
  }

  static Future<List<Map<String, dynamic>>> fetchTrapStatus() async {
    final res = await http.get(Uri.parse('$baseUrl/api/trap_status'));
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(res.body));
    }
    return [];
  }

  static Future<String> fetchTrapLog() async {
    final res = await http.get(Uri.parse('$baseUrl/api/trap_log'));
    if (res.statusCode == 200) {
      return res.body;
    }
    return 'Unable to fetch log data.';
  }

static Future<List<Map<String, dynamic>>> fetchAlerts() async {
  final res = await http.get(Uri.parse('$baseUrl/api/alerts'));
  if (res.statusCode == 200) {
    final List<dynamic> data = json.decode(res.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList(); // ✅ This line
  }
  return [];
}




}
