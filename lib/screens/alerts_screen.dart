import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AlertsScreen extends StatefulWidget {
  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<dynamic> alerts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAlerts();
    Timer.periodic(Duration(seconds: 10), (_) => fetchAlerts());
  }

 void fetchAlerts() async {
  try {
    final result = await ApiService.fetchAlerts();
    print("Fetched alerts: $result"); // ✅ Add this line here

    setState(() {
      alerts = result;
      isLoading = false;
    });
  } catch (e) {
    print("Error fetching alerts: $e");
    setState(() {
      alerts = [
        {"timestamp": "Error", "message": "Failed to load alerts: $e"}
      ];
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return Card(
                  color: Colors.lightBlue[900],
                  child: ListTile(
                    title: Text(
                      alert["message"] ?? "",
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      alert["timestamp"] ?? "",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
