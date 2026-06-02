import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._privateConstructor();

  static final AppDatabase instance = AppDatabase._privateConstructor();

  static Database? _database;

  static const String databaseName = 'jobspot.db';
  static const int databaseVersion = 2;

  Future<Database> get database async {
    if (_database != null) {
      debugPrint('SQLite LOG: Database đã mở rồi');
      return _database!;
    }

    debugPrint('SQLite LOG: Đang mở database...');
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String databasePath = await getDatabasesPath();
    final String path = join(databasePath, databaseName);

    debugPrint('SQLite LOG: Path = $path');

    return openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) {
        debugPrint('SQLite LOG: Mở database thành công');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint('SQLite LOG: Tạo bảng profile_info');

    await db.execute('''
      CREATE TABLE profile_info (
        id INTEGER PRIMARY KEY,
        fullName TEXT NOT NULL,
        studentId TEXT NOT NULL,
        email TEXT NOT NULL,
        aboutMe TEXT,
        workExperience TEXT,
        education TEXT,
        skill TEXT,
        language TEXT,
        appreciation TEXT,
        resume TEXT
      )
    ''');

    await db.insert(
      'profile_info',
      {
        'id': 1,
        'fullName': 'Nguyễn Bình Minh',
        'studentId': '6451071047',
        'email': '6451071047@st.utc2.edu.vn',
        'aboutMe': '',
        'workExperience': '',
        'education': '',
        'skill': '',
        'language': '',
        'appreciation': '',
        'resume': 'My_CV.pdf',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('SQLite LOG: Tạo database và dữ liệu mặc định thành công');
  }

  Future<void> _onUpgrade(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    debugPrint('SQLite LOG: Upgrade từ version $oldVersion lên $newVersion');

    if (oldVersion < 2) {
      await db.execute('ALTER TABLE profile_info ADD COLUMN resume TEXT');
      debugPrint('SQLite LOG: Đã thêm cột resume');
    }
  }
}