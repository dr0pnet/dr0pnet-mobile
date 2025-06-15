import 'dart:async';
import 'package:flutter/material.dart';
import 'settings_screen.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String terminalOutput = '';
  List<dynamic> traps = [];

  @override
  void initState() {
    super.initState();
    fetchTrapStatus();
    Timer.periodic(Duration(seconds: 10), (_) => fetchTrapStatus());
  }

  void fetchTrapStatus() async {
    try {
      final trapData = await ApiService.fetchTrapStatus();
      final logData = await ApiService.fetchTrapLog();
      setState(() {
        traps = trapData;
        terminalOutput = logData;
      });
    } catch (e) {
      print("Error fetching trap status: $e");
    }
  }

  @override
  void dispose() {
    ApiService.stopAutoRefresh();
    super.dispose();
  }

  void openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
    fetchTrapStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('dr0pnet Dashboard'),
        backgroundColor: Colors.lightBlue.shade900,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: openSettings,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trap Modules:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: traps.length,
                itemBuilder: (context, index) {
                  var trap = traps[index];
                  String last = trap['last_triggered'];
                  bool wasRecentlyTriggered = false;

                  if (last != "Never") {
                    try {
                      final dt = DateFormat("yyyy-MM-dd HH:mm:ss").parse(last);
                      final diff = DateTime.now().difference(dt);
                      if (diff.inMinutes < 10) {
                        wasRecentlyTriggered = true;
                      }
                    } catch (e) {
                      print("Date parse error: $e");
                    }
                  }

                  return ListTile(
                    title: Text(trap['name'], style: TextStyle(color: Colors.white)),
                    subtitle: Text("Last Triggered: $last", style: TextStyle(color: Colors.white70)),
                    trailing: Icon(
                      wasRecentlyTriggered ? Icons.close : Icons.check,
                      color: wasRecentlyTriggered ? Colors.red : Colors.greenAccent,
                    ),
                  );
                },
              ),
            ),
            Divider(color: Colors.greenAccent),
            Text('Live Terminal Feed:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.black87,
                padding: EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: Text(terminalOutput, style: TextStyle(fontFamily: 'monospace', color: Colors.greenAccent)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
