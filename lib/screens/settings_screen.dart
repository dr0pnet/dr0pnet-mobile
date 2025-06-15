import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _autoRefreshEnabled = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('baseUrl') ?? '';
    final savedRefresh = prefs.getBool('autoRefresh') ?? true;

    setState(() {
      _controller.text = savedUrl;
      _autoRefreshEnabled = savedRefresh;
    });

    ApiService.setAutoRefresh(savedRefresh);
    ApiService.setBaseUrl(savedUrl);
  }

  void saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final url = _controller.text.trim();

    if (url.isEmpty || !url.startsWith("http")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter a valid URL")),
      );
      return;
    }

    try {
      await prefs.setString('baseUrl', url);
      await prefs.setBool('autoRefresh', _autoRefreshEnabled);
      ApiService.setBaseUrl(url);
      ApiService.setAutoRefresh(_autoRefreshEnabled);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Settings saved successfully")),
      );
    } catch (e) {
      print("Error saving settings: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.lightBlue.shade900,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Honeypot URL",
                hintText: "http://192.168.x.x:5050",
                hintStyle: TextStyle(color: Colors.grey),
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Text(
                  "Auto-Refresh Every 10s",
                  style: TextStyle(color: Colors.white),
                ),
                Spacer(),
                Switch(
                  value: _autoRefreshEnabled,
                  activeColor: Colors.lightBlue,
                  onChanged: (value) {
                    setState(() {
                      _autoRefreshEnabled = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: saveSettings,
              child: Text("Save"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
