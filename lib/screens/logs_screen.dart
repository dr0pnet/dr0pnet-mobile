import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LogsScreen extends StatefulWidget {
  @override
  _LogsScreenState createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  String logs = '';
  bool isLoading = true;

  void fetchLogs() async {
    try {
      final result = await ApiService.fetchTrapLog(); // ✅ Corrected method name
      setState(() {
        logs = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        logs = 'Error loading logs: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLogs();
    Timer.periodic(Duration(seconds: 10), (timer) => fetchLogs()); // ✅ 10s refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Text(
                logs,
                style: TextStyle(
                    color: Colors.greenAccent, fontFamily: 'monospace'),
              ),
            ),
    );
  }
}
