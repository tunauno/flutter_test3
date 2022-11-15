import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void init_sql() async {
  final database = openDatabase(
    join(await getDatabasesPath(), 'usersetting_database.db'),

    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE usersettings(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)",
      );
    },

    version: 1,
  );

  //定義插入方法
  Future<void> insert_usersetting(Usersetting usersetting) async {

    final Database db = await database;

    await db.insert(
      'usersettings',
      usersetting.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //查詢資料
  Future<List<Usersetting>> usersettings() async {

    final Database db = await database;


    final List<Map<String, dynamic>> maps = await db.query('usersettings');

    return List.generate(maps.length, (i) {
      return Usersetting(
        id: maps[i]['id'],
        name: maps[i]['name'],
        age: maps[i]['age'],
      );
    });
  }

  //更新資料
  Future<void> update_usersetting(Usersetting usersetting) async {

    final db = await database;

    await db.update(
      'usersettings',
      usersetting.toMap(),

      where: "id = ?",

      whereArgs: [usersetting.id],
    );
  }

  //刪除資料
  Future<void> delete_usersetting(int id) async {

    final db = await database;


    await db.delete(
      'usersettings',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  var fido = Usersetting(
    id: 0,
    name: 'Fido',
    age: 35,
  );

  await insert_usersetting(fido);

  print(await usersettings());

  fido = Usersetting(
    id: fido.id,
    name: fido.name,
    age: fido.age + 7,
  );
  await update_usersetting(fido);

  print(await usersettings());

  await delete_usersetting(fido.id);

  print(await usersettings());
}

class Usersetting {
  final int id;
  final String name;
  final int age;

  Usersetting({required this.id, required this.name, required this.age});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }

  @override
  String toString() {
    return 'Usersetting{id: $id, name: $name, age: $age}';
  }
}