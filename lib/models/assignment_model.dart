import 'package:boomerang_app/assignment.dart';
import 'package:boomerang_app/db_utils.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class AssignmentModel
{
  Future getAllAssignments() async
  {
    final db = await DBUtils.init(); //start database
    final List maps = await db.query('assignments');
    List<Assignment> assignments = [];

    for (int i = 0; i < maps.length; i++)
    {
      assignments.add(Assignment.fromMap(maps[i]));
    }

    return assignments;
  }
  Future<int> insertAssn(Assignment assignment) async
  {
    final db = await DBUtils.init();
    return db.insert('assignments', assignment.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateAssn(Assignment assignment) async
  {
    final db = await DBUtils.init();
    return db.update('assignments', assignment.toMap(), where: 'id = ?', whereArgs: [assignment.id]);
  }

  Future<int> deleteAssnById(int id) async
  {
    final db = await DBUtils.init();
    return db.delete('assignments', where: "id = ?", whereArgs: [id]);

  }
}