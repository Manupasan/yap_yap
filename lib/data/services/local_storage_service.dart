// lib/data/services/local_storage_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chat_session_local.dart';
import '../models/message_local.dart';

class LocalStorageService {
  static Database? _database;
  static const String _databaseName = 'yap_yap.db';
  static const int _databaseVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create chat_sessions table
    await db.execute('''
      CREATE TABLE chat_sessions (
        session_id TEXT PRIMARY KEY,
        other_user_name TEXT NOT NULL,
        last_message TEXT,
        last_activity INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create messages table
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        text TEXT NOT NULL,
        sender_id TEXT NOT NULL,
        is_me INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (session_id) REFERENCES chat_sessions (session_id) ON DELETE CASCADE
      )
    ''');
  }

  // Chat session methods
  Future<void> saveChatSession(ChatSessionLocal session) async {
    final db = await database;

    // Check if session already exists
    final existing = await db.query(
      'chat_sessions',
      where: 'session_id = ?',
      whereArgs: [session.sessionId],
    );

    if (existing.isNotEmpty) {
      // Update existing session
      await db.update(
        'chat_sessions',
        session.toMap(),
        where: 'session_id = ?',
        whereArgs: [session.sessionId],
      );
    } else {
      // Insert new session
      await db.insert(
        'chat_sessions',
        session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<ChatSessionLocal>> getAllChatSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chat_sessions',
      orderBy: 'last_activity DESC',
    );

    return List.generate(maps.length, (i) {
      return ChatSessionLocal.fromMap(maps[i]);
    });
  }

  Future<void> updateChatSession(String sessionId, {
    String? otherUserName,
    String? lastMessage,
    int? lastActivity,
  }) async {
    final db = await database;
    Map<String, dynamic> updates = {};

    if (otherUserName != null) updates['other_user_name'] = otherUserName;
    if (lastMessage != null) updates['last_message'] = lastMessage;
    if (lastActivity != null) updates['last_activity'] = lastActivity;

    if (updates.isNotEmpty) {
      await db.update(
        'chat_sessions',
        updates,
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );
    }
  }

  Future<void> deleteChatSession(String sessionId) async {
    final db = await database;
    await db.delete(
      'chat_sessions',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  // Message methods
  Future<void> saveMessage(MessageLocal message) async {
    final db = await database;
    await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MessageLocal>> getMessagesForSession(String sessionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );

    return List.generate(maps.length, (i) {
      return MessageLocal.fromMap(maps[i]);
    });
  }

  Future<void> deleteMessagesForSession(String sessionId) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }
}