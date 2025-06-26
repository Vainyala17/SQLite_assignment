import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
      version: 1,
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
    FOREIGN KEY (address_id) REFERENCES users(id) ON DELETE CASCADE)
''');

  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades if needed in the future
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
        conflictAlgorithm: ConflictAlgorithm.replace, // or fail
      );
    } catch (e) {
      throw Exception('Failed to insert address: ${e.toString()}');
    }
  }

  Future<int> updateAddress(int userId, String address) async {
    final db = await database;
    try {
      int count = await db.update(
        'address',
        {'address': address},
        where: 'address_id = ?',
        whereArgs: [userId],
      );
      // If no rows were updated, throw a manual exception
      if (count == 0) {
        throw Exception('No address found with address_id = $userId');
      }
      return count;
    } catch (e, stacktrace) {
      // Print full error details in debug console
      print('Update Error: $e');
      print('Stacktrace: $stacktrace');

      // Now this message will be shown wherever you catch it (like in Snackbar)
      throw Exception('Failed to update address: ${e.toString()}');
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


  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    try {
      final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
      if (result.isNotEmpty) {
        return UserModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user: ${e.toString()}');
    }
  }

  Future<UserModel?> getUserByMobile(String mobile) async {
    final db = await database;
    try {
      final result = await db.query('users', where: 'mobile = ?', whereArgs: [mobile]);
      if (result.isNotEmpty) {
        return UserModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user by mobile: ${e.toString()}');
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

  Future queryAllRows() async {

  }
}