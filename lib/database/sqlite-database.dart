import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:notesapp/Utils/date_formatter.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:notesapp/exceptions/exceptions.dart';

class NotesService {
  Database? _db;

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController =
        StreamController<List<DatabaseNote>>.broadcast(onListen: (() {
      _notesStreamController.sink.add(_notes);
    }));
  }
  factory NotesService() => _shared;

  List<DatabaseNote> _notes = [];
  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allnotes => _notesStreamController.stream;

  Future<void> _cachedNotes() async {
    final allnotes = await getAllNotes();
    _notes = allnotes;
    _notesStreamController.add(_notes);
  }

  Future<DatabaseUser> getOrCreateUser(
      {required String email, required String name}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(name: name, email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Database getdatabaseorthrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> openDbase() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createNoteTable);
      await _cachedNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }

  Future<void> ensureDBisOpen() async {
    try {
      await openDbase();
    } on DatabaseAlreadyOpenException {
      //
    }
  }

  Future<void> closeDbase() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> deleteUser({required String email}) async {
    await ensureDBisOpen();
    final db = getdatabaseorthrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseUser> createUser(
      {required String name, required String email}) async {
    await ensureDBisOpen();
    final db = getdatabaseorthrow();

    //CHECK IF USER ALREADY EXISTS
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
      nameColumn: name.replaceFirst(name[0], name[0].toUpperCase())
    });
    return DatabaseUser(id: userId, name: name, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await ensureDBisOpen();
    final db = getdatabaseorthrow();

    //ensure user exists
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      final user = DatabaseUser.fromRow(results.first);
      return user;
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await ensureDBisOpen();
    final db = getdatabaseorthrow();

    // check if owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    // create the note
    final noteId = await db.insert(
      noteTable,
      {useridColumn: owner.id, bodyColumn: '', titleColumn: ''},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    final newnote = DatabaseNote(
        id: noteId, userid: owner.id, body: '', title: '', lastUpdated: '');
    _notes.add(newnote);
    _notesStreamController.add(_notes);
    return newnote;
  }

  Future<void> deleteNote({required int id}) async {
    await ensureDBisOpen();
    final db = getdatabaseorthrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteAllNotes() async {
    await ensureDBisOpen();
    final db = getdatabaseorthrow();
    final numberOfDeletions = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await ensureDBisOpen();
    final db = getdatabaseorthrow();
    final results = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final retrievednote = DatabaseNote.fromRow(results.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(retrievednote);
      _notesStreamController.add(_notes);
      return retrievednote;
    }
  }

  Future<List<DatabaseNote>> getAllNotes() async {
    await ensureDBisOpen();
    final db = getdatabaseorthrow();
    final results = await db.query(noteTable);
    final notes = results.map((e) => DatabaseNote.fromRow(e));
    return notes.toList();
  }

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note,
      String? newBody,
      String? newTitle,
      int? id}) async {
    await ensureDBisOpen();
    final db = getdatabaseorthrow();
    await getNote(id: note.id);
    final updatesCount = await db.update(
      noteTable,
      {
        titleColumn: newTitle,
        bodyColumn: newBody,
        lastUpdatedColumn: dateFormatter(DateTime.now()),
      },
    );
    if (updatesCount == 0) {
      throw CouldNotUpdateNote;
    } else {
      final updatednote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatednote.id);
      _notes.add(updatednote);
      _notesStreamController.add(_notes);

      return updatednote;
    }
  }
}

//constants
const idColumn = 'id';
const nameColumn = 'name';
const emailColumn = 'email';
const useridColumn = 'user_id';
const titleColumn = 'title';
const bodyColumn = 'body';
const lastUpdatedColumn = 'last_updated';
const dbName = 'mynotesapp.db';
const userTable = 'user';
const noteTable = 'note';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL UNIQUE,
	"name"	TEXT NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);''';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"title"	TEXT,
	"body"	TEXT,
  "last_updated" TEXT,
	FOREIGN KEY("user_id") REFERENCES "user"("id"),
	PRIMARY KEY("id" AUTOINCREMENT)
);
);''';

@immutable
class DatabaseUser {
  final int id;
  final String name;
  final String email;

  const DatabaseUser(
      {required this.id, required this.name, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        name = map[nameColumn] as String,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID =  $id, name = $name, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userid;
  final String title;
  final String body;
  final String lastUpdated;

  DatabaseNote({
    required this.id,
    required this.userid,
    required this.title,
    required this.body,
    required this.lastUpdated,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userid = map[useridColumn] as int,
        title = map[titleColumn] as String,
        body = map[bodyColumn] as String,
        lastUpdated = dateFormatter(DateTime.now());

  @override
  String toString() =>
      'Note, ID =  $id, userid = $userid, title = $title, body = $body, last updated = $lastUpdated';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
