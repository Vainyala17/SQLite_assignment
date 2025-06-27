import 'package:flutter/material.dart';

import '../widgets/custom_drawer.dart';
import '../widgets/custom_menu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // You can add state variables here later if needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Details App'),
        centerTitle: true,
        actions: [
          CustomMenu(
            context: context,
            onRefresh: _refreshPage, // ✅ calling refresh
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 80,
                color: Colors.blue[600],
              ),
              SizedBox(height: 20),
              Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Use the drawer menu to navigate',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshPage() {
    setState(() {
      // Add logic to refresh or reload anything here if needed
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Page refreshed successfully!')),
    );
  }
}
