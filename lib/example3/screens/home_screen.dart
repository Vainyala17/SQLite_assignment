import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_drawer.dart';
import '../widgets/custom_menu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userMobile = '';
  String userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userMobile = prefs.getString('user_mobile') ?? 'Unknown';
      userRole = prefs.getString('user_role') ?? 'Unknown';
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Details App'),
        centerTitle: true,
        actions: [
          CustomMenu(
            context: context,
            onRefresh: _refreshPage,
          ),
        ],
      ),
      drawer: CustomDrawer(role: userRole), // ✅ Pass role to drawer
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade200, Colors.white],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_emotions, size: 80, color: Colors.orange),
                SizedBox(height: 20),
                Text(
                  '🎉 Congratulations!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Welcome to the Personal Details App',
                  style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('📱 Mobile Number:', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                        SizedBox(height: 4),
                        Text(userMobile, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 12),
                        Text('🔐 Role:', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                        SizedBox(height: 4),
                        Text(userRole, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Use the drawer menu to explore features.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _refreshPage() {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Page refreshed successfully!')),
    );
  }
}
