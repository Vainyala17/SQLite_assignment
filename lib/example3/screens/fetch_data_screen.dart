import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqlite_assignment/example3/screens/personal_details_screen.dart';
import 'dart:io';

import '../../example3/db/database_helper.dart';
import '../model/user_model.dart';
import '../widgets/custom_menu.dart';

class FetchDataScreen extends StatefulWidget {
  @override
  _FetchDataScreenState createState() => _FetchDataScreenState();
}

class _FetchDataScreenState extends State<FetchDataScreen> {
  List<UserModel> _userData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() => _isLoading = true);
      final users = await DatabaseHelper.instance.getAllUsers();
      setState(() {
        _userData = users;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar('Error fetching data: $e', isError: true);
      setState(() => _isLoading = false);
    }
  }
  void _refreshPage() {
    _fetchData(); // Just reload the data
    _showSnackBar('Page refreshed successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fetch Data',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          CustomMenu(
            context: context,
            onRefresh: _refreshPage,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: _isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 3),
              SizedBox(height: 16),
              Text(
                'Loading data...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        )
            : _userData.isEmpty
            ? _buildEmptyState()
            : _buildDataList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PersonalDetailsScreen(),
            ),
          ).then((result) {
            if (result == true) {
              _fetchData();
            }
          });
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New User',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'No Data Found',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Add some personal details first',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonalDetailsScreen(),
                ),
              ).then((result) {
                if (result == true) {
                  _fetchData();
                }
              });
            },
            icon: Icon(Icons.add),
            label: Text('Add First User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataList() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _userData.length,
        itemBuilder: (context, index) {
          final user = _userData[index];
          return _buildUserCard(user, index);
        },
      ),
    );
  }

  Widget _buildUserCard(UserModel user, int index) {
    final userData = user.data();

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profile Image
                if (userData['photoPath'] != null && File(userData['photoPath']).existsSync())
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: FileImage(File(userData['photoPath'])),
                  )
                else
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.person, size: 35, color: Colors.blue[600]),
                  ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData['name'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        userData['mobile'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  iconSize: 28,
                  onSelected: (value) {
                    if (value == 'edit') {
                      _navigateToEditScreen(user);
                    } else if (value == 'delete') {
                      _showDeleteDialog(user);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 24, color: Colors.blue),
                          SizedBox(width: 12),
                          Text('Edit', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 24, color: Colors.red),
                          SizedBox(width: 12),
                          Text(
                            'Delete',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Divider(thickness: 1.5, height: 24),

            _buildInfoRow(Icons.email, 'Email', userData['email'] ?? 'N/A'),
            _buildInfoRow(Icons.home, 'Address', userData['address'] ?? 'N/A'),
            _buildInfoRow(Icons.person, 'Gender', userData['gender'] ?? 'N/A'),
            _buildInfoRow(
              Icons.favorite,
              'Marital Status',
              userData['maritalStatus'] ?? 'Not Specified',
            ),
            _buildInfoRow(Icons.location_on, 'State', userData['state'] ?? 'N/A'),
            _buildInfoRow(
              Icons.school,
              'Education',
              userData['educationalQualification'] ?? 'N/A',
            ),

            if (userData['educationalQualification'] == 'Graduate' &&
                userData['subjects'] != null) ...[
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.book, size: 20, color: Colors.grey[600]),
                  SizedBox(width: 12),
                  Text(
                    'Subjects: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${userData['subjects']['subject1'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 15)),
                        Text('${userData['subjects']['subject2'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 15)),
                        Text('${userData['subjects']['subject3'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            if (userData['educationalQualification'] == 'Post Graduate' &&
                userData['subject'] != null) ...[
              _buildInfoRow(
                Icons.book,
                'Subject',
                userData['subject'] ?? 'N/A',
              ),
            ],

            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                SizedBox(width: 8),
                Text(
                  'Added: ${_formatTimestamp(userData['timestamp'])}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigate to PersonalDetailsScreen for editing
  void _navigateToEditScreen(UserModel user) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PersonalDetailsScreen(editUser: user),
        ),
      );

      // Refresh data if user was updated
      if (result == true) {
        _fetchData();
      }
    } catch (e) {
      _showSnackBar('Error navigating to edit screen: $e', isError: true);
    }
  }

  void _showDeleteDialog(UserModel user) {
    final userData = user.data();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Delete User',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this user?',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (userData['photoPath'] != null && File(userData['photoPath']).existsSync())
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: FileImage(File(userData['photoPath'])),
                          )
                        else
                          CircleAvatar(
                            radius: 20,
                            child: Icon(Icons.person, size: 20),
                          ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['name'] ?? 'N/A',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              Text(
                                userData['mobile'] ?? 'N/A',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Email: ${userData['email'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This action cannot be undone.',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser(user);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Delete', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(UserModel user) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Deleting user...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Delete photo file if exists
      if (user.photoPath != null) {
        try {
          final photoFile = File(user.photoPath!);
          if (photoFile.existsSync()) {
            await photoFile.delete();
          }
        } catch (e) {
          print('Error deleting photo file: $e');
        }
      }

      // Delete user from database
      await DatabaseHelper.instance.deleteUser(user.id!);

      // Close loading dialog
      Navigator.of(context).pop();

      _showSnackBar('User deleted successfully!');
      _fetchData(); // Refresh the list
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      _showSnackBar('Error deleting user: $e', isError: true);
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      DateTime dateTime;
      if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return 'Unknown';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}