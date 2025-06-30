import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../model/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_data.db');

    return await openDatabase(
      path,
      version: 2, // Increased version for schema update
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  mobile TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL,
  gender TEXT NOT NULL,
  maritalStatus TEXT,
  state TEXT NOT NULL,
  educationalQualification TEXT NOT NULL,
  subject1 TEXT,
  subject2 TEXT,
  subject3 TEXT,
  pgSubject TEXT,
  photoPath TEXT,
  timestamp TEXT NOT NULL
)
''');


    await db.execute('''
    CREATE TABLE IF NOT EXISTS address (
      address_id INTEGER PRIMARY KEY,
      address TEXT NOT NULL,
      FOREIGN KEY (address_id) REFERENCES users(id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS login (
    mobile TEXT PRIMARY KEY,
    password TEXT NOT NULL,
    token TEXT,
    role TEXT
  )
''');

  }


  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS login');
      await db.execute('''
  CREATE TABLE IF NOT EXISTS login (
    mobile TEXT PRIMARY KEY,
    password TEXT NOT NULL,
    token TEXT,
    role TEXT
  )
''');

    }
  }


  // Hash password for security
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
  // Generate simple token
  String _generateToken() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  // Register new user
  // Register new user
  Future<Map<String, dynamic>> registerUser(String mobile, String password, String? selectedRole) async {
    final db = await database;
    try {
      final existingUser = await getUserByMobile(mobile);
      if (existingUser != null) {
        return {'success': false, 'message': 'Mobile number already registered'};
      }

      String hashedPassword = _hashPassword(password);
      String token = _generateToken();

      await db.insert('login', {
        'mobile': mobile,
        'password': hashedPassword,
        'token': token,
        'role': selectedRole ?? 'Operator', // default fallback role
      });

      return {
        'success': true,
        'message': 'Registration successful',
        'token': token,
        'mobile': mobile,
        'role': selectedRole,
      };
    } catch (e) {
      return {'success': false, 'message': 'Registration failed: ${e.toString()}'};
    }
  }

  // Login user
  // Login user
  Future<Map<String, dynamic>> loginUser(String mobile, String password) async {
    final db = await database;
    try {
      String hashedPassword = _hashPassword(password);

      final result = await db.query(
        'login',
        where: 'mobile = ? AND password = ?',
        whereArgs: [mobile, hashedPassword],
        limit: 1,
      );

      if (result.isNotEmpty) {
        String newToken = _generateToken();
        await db.update(
          'login',
          {'token': newToken},
          where: 'mobile = ?',
          whereArgs: [mobile],
        );

        final user = await getUserByMobile(mobile);
        final role = result.first['role'] ?? 'Operator';

        return {
          'success': true,
          'message': 'Login successful',
          'token': newToken,
          'user': user,
          'role': role,
        };
      } else {
        return {'success': false, 'message': 'Mobile number and Password do not match'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Login failed: ${e.toString()}'};
    }
  }

  // Verify token
  Future<UserModel?> getUserByToken(String token) async {
    final db = await database;
    try {
      final result = await db.rawQuery('''
      SELECT users.*
      FROM users
      JOIN login ON users.mobile = login.mobile
      WHERE login.token = ?
    ''', [token]);

      if (result.isNotEmpty) {
        return UserModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update password
  Future<bool> updatePassword(String mobile, String oldPassword, String newPassword) async {
    final db = await database;
    try {
      String hashedOldPassword = _hashPassword(oldPassword);
      String hashedNewPassword = _hashPassword(newPassword);

      // Verify old password
      final result = await db.query(
        'login',
        where: 'mobile = ? AND password = ?',
        whereArgs: [mobile, hashedOldPassword],
      );

      if (result.isNotEmpty) {
        await db.update(
          'login',
          {'password': hashedNewPassword},
          where: 'mobile = ?',
          whereArgs: [mobile],
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Logout user (clear token)
  Future<bool> logoutUser(String token) async {
    final db = await database;
    try {
      await db.update(
        'login',
        {'token': null},
        where: 'token = ?',
        whereArgs: [token],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    try {
      return await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.fail);
    } catch (e) {
      throw Exception('Failed to insert user: ${e.toString()}');
    }
  }

  Future<int> insertAddress(int userId, String address) async {
    final db = await database;
    try {
      return await db.insert(
        'address',
        {
          'address_id': userId,
          'address': address,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert address: ${e.toString()}');
    }
  }

  Future<int> deleteAddress(int userId) async {
    final db = await database;
    try {
      return await db.delete('address', where: 'address_id = ?', whereArgs: [userId]);
    } catch (e) {
      throw Exception('Failed to delete address: ${e.toString()}');
    }
  }

  // ✅ CORRECTED: Fixed getAllUsers method to handle address properly
  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    try {
      final result = await db.rawQuery('''
      SELECT 
        users.*, 
        address.address 
      FROM users
      LEFT JOIN address ON users.id = address.address_id
      ORDER BY users.id DESC
    ''');

      return result.map((map) => UserModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: ${e.toString()}');
    }
  }

// ✅ CORRECTED: Fixed getUserById to include address
  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    try {
      final result = await db.rawQuery('''
      SELECT 
        users.*, 
        address.address 
      FROM users
      LEFT JOIN address ON users.id = address.address_id
      WHERE users.id = ?
    ''', [id]);

      if (result.isNotEmpty) {
        return UserModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user: ${e.toString()}');
    }
  }

// ✅ CORRECTED: Fixed getUserByMobile to include address
  Future<UserModel?> getUserByMobile(String mobile) async {
    final db = await database;
    try {
      final result = await db.rawQuery('''
      SELECT 
        users.*, 
        address.address 
      FROM users
      LEFT JOIN address ON users.id = address.address_id
      WHERE users.mobile = ?
    ''', [mobile]);

      if (result.isNotEmpty) {
        return UserModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user by mobile: ${e.toString()}');
    }
  }

// ✅ CORRECTED: Improved updateAddress method with better error handling
  Future<int> updateAddress(int userId, String address) async {
    final db = await database;
    try {
      // First, try to update existing address
      int count = await db.update(
        'address',
        {'address': address},
        where: 'address_id = ?',
        whereArgs: [userId],
      );

      // If no rows were updated, insert new address
      if (count == 0) {
        await db.insert(
          'address',
          {
            'address_id': userId,
            'address': address,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        return 1; // Return 1 to indicate success
      }

      return count;
    } catch (e) {
      print('Update Address Error: $e');
      throw Exception('Failed to update address: ${e.toString()}');
    }
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    try {
      return await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    try {
      return await db.delete('users', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  Future<bool> isMobileExists(String mobile, {int? excludeId}) async {
    final db = await database;
    try {
      String whereClause = 'mobile = ?';
      List<dynamic> whereArgs = [mobile];

      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }

      final result = await db.query('users', where: whereClause, whereArgs: whereArgs);
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_data.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // Add this method to your DatabaseHelper class

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    final db = await database;
    try {
      return await db.query('users');
    } catch (e) {
      throw Exception('Failed to query all rows: ${e.toString()}');
    }
  }
}