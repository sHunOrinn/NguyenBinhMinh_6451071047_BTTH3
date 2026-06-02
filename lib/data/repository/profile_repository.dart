import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../models/profile_model.dart';
import '../services/sqlite/app_database.dart';

class ProfileRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  // CREATE
  Future<int> createProfile(ProfileModel profile) async {
    final Database db = await _appDatabase.database;

    debugPrint('CRUD LOG: CREATE profile id = ${profile.id}');

    return db.insert(
      'profile_info',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ ONE
  Future<ProfileModel> getProfile() async {
    final Database db = await _appDatabase.database;

    debugPrint('CRUD LOG: READ profile id = 1');

    final List<Map<String, dynamic>> result = await db.query(
      'profile_info',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isEmpty) {
      final ProfileModel defaultProfile = ProfileModel(
        id: 1,
        fullName: 'Nguyễn Bình Minh',
        studentId: '6451071047',
        email: '6451071047@st.utc2.edu.vn',
        aboutMe: '',
        workExperience: '',
        education: '',
        skill: '',
        language: '',
        appreciation: '',
        resume: 'My_CV.pdf',
      );

      await createProfile(defaultProfile);

      return defaultProfile;
    }

    return ProfileModel.fromMap(result.first);
  }

  // READ ALL
  Future<List<ProfileModel>> getAllProfiles() async {
    final Database db = await _appDatabase.database;

    debugPrint('CRUD LOG: READ ALL profiles');

    final List<Map<String, dynamic>> result = await db.query(
      'profile_info',
      orderBy: 'id DESC',
    );

    return result.map((map) => ProfileModel.fromMap(map)).toList();
  }

  // UPDATE FULL PROFILE
  Future<int> updateProfile(ProfileModel profile) async {
    final Database db = await _appDatabase.database;

    debugPrint('CRUD LOG: UPDATE profile id = ${profile.id}');

    return db.update(
      'profile_info',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  // UPDATE ONE SECTION
  Future<int> updateProfileSection({
    required String columnName,
    required String value,
  }) async {
    final Database db = await _appDatabase.database;

    debugPrint('CRUD LOG: UPDATE section $columnName = $value');

    return db.update(
      'profile_info',
      {
        columnName: value,
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // DELETE ONE SECTION, dùng để xóa nội dung About me, Skill, Resume...
  Future<int> deleteProfileSection({
    required String columnName,
  }) async {
    final Database db = await _appDatabase.database;

    debugPrint('CRUD LOG: DELETE/CLEAR section $columnName');

    return db.update(
      'profile_info',
      {
        columnName: '',
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // DELETE PROFILE
  Future<int> deleteProfile({
    required int id,
  }) async {
    final Database db = await _appDatabase.database;

    debugPrint('CRUD LOG: DELETE profile id = $id');

    return db.delete(
      'profile_info',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}