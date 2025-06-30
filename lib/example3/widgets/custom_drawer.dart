import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite_assignment/example3/screens/fetch_data_screen.dart';
import 'package:sqlite_assignment/example3/screens/home_screen.dart';
import 'package:sqlite_assignment/example3/screens/login_screen.dart';
import '../screens/personal_details_screen.dart';

class CustomDrawer extends StatelessWidget {
  final String role;

  const CustomDrawer({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[600]!, Colors.blue[800]!],
          ),
        ),
        child: Column(
          children: [
            // Header
            SizedBox(
              height: 220,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.transparent),
                margin: EdgeInsets.zero,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.blue[600],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Menu
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      _buildDrawerItem(
                        context,
                        icon: Icons.home,
                        title: 'Home',
                        subtitle: 'Go to main screen',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                      ),

                      SizedBox(height: 8),
                      _buildDrawerItem(
                        context,
                        icon: Icons.person_add,
                        title: 'Add Data',
                        subtitle: 'Enter new user details',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PersonalDetailsScreen(role: role)),
                          );
                        },
                        disabled: role != 'Operator',
                      ),
                      // All roles can view
                      SizedBox(height: 8),
                      _buildDrawerItem(
                        context,
                        icon: Icons.visibility,
                        title: 'View Data',
                        subtitle: 'See existing data',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FetchDataScreen(role: role)),
                          );
                        },
                      ),

                      SizedBox(height: 8),
                      _buildDrawerItem(
                        context,
                        icon: Icons.edit,
                        title: 'Edit Data',
                        subtitle: 'Update existing information',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FetchDataScreen(role: role)),
                          );
                        },
                        disabled: !(role == 'Supervisor' || role == 'Manager'),
                      ),

                      SizedBox(height: 8),
                      _buildDrawerItem(
                        context,
                        icon: Icons.delete,
                        title: 'Delete Data',
                        subtitle: 'Remove existing record',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FetchDataScreen(role: role)),
                          );
                        },
                        disabled: role != 'Manager',
                      ),

                      // Logout (for all)
                      SizedBox(height: 8),
                      _buildDrawerItem(
                        context,
                        icon: Icons.logout,
                        title: 'Logout',
                        subtitle: 'Sign out of app',
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences
                              .getInstance();
                          await prefs.clear();

                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool disabled = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: disabled ? Colors.grey[200] : Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
              icon, color: disabled ? Colors.grey : Colors.blue[600], size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: disabled ? Colors.grey : Colors.grey[800],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
              color: disabled ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14,
            color: disabled ? Colors.grey[300] : Colors.grey[400]),
        onTap: disabled ? null : onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
    );
  }
}
