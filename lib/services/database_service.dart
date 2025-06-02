import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contato.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'contacts.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE contacts('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'name TEXT, '
              'phone TEXT, '
              'synced INTEGER DEFAULT 0, '
              'isDeleted INTEGER DEFAULT 0'
              ')',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertContact(Contact contact) async {
    final db = await database;
    await db.insert('contacts', contact.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Contact>> getUnsyncedContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'isDeleted = 0 AND synced = 0',
    );
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }

  static Future<void> markAsSynced(int id) async {
    final db = await database;
    await db.update(
      'contacts',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
