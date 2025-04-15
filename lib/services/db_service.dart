import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/container_model.dart';

class DBService {
  // Singleton pattern
  DBService._privateConstructor();
  static final DBService instance = DBService._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'container_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE containers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        containerNumber TEXT NOT NULL,
        type TEXT NOT NULL,
        typeCode TEXT,
        height TEXT,
        isoCode TEXT,
        warnings TEXT,
        timestamp TEXT NOT NULL,
        imagePath TEXT
      )
    ''');
  }

  // Konteyner ekle
  Future<int> addContainer(ContainerModel container) async {
    Database db = await database;
    return await db.insert('containers', container.toMap());
  }

  // Tüm konteynerleri getir
  Future<List<ContainerModel>> getAllContainers() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('containers', orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) {
      return ContainerModel.fromMap(maps[i]);
    });
  }

  // Gelen konteynerleri getir
  Future<List<ContainerModel>> getIncomingContainers() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'containers',
      where: 'type = ?',
      whereArgs: ['incoming'],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) {
      return ContainerModel.fromMap(maps[i]);
    });
  }

  // Giden konteynerleri getir
  Future<List<ContainerModel>> getOutgoingContainers() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'containers',
      where: 'type = ?',
      whereArgs: ['outgoing'],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) {
      return ContainerModel.fromMap(maps[i]);
    });
  }

  // Konteyner güncelle
  Future<int> updateContainer(ContainerModel container) async {
    Database db = await database;
    return await db.update(
      'containers',
      container.toMap(),
      where: 'id = ?',
      whereArgs: [container.id],
    );
  }

  // Konteyner sil
  Future<int> deleteContainer(int id) async {
    Database db = await database;
    return await db.delete(
      'containers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Konteyner numarasına göre ara
  Future<List<ContainerModel>> searchContainers(String query) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'containers',
      where: 'containerNumber LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) {
      return ContainerModel.fromMap(maps[i]);
    });
  }
} 