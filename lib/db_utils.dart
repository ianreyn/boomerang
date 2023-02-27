import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBUtils{
  static Future init() async{
    //set up the database
    var database = openDatabase(
      path.join(await getDatabasesPath(), 'assignments_manager.db'),
      onCreate: (db, version){
        db.execute(
            'CREATE TABLE assignments(id INTEGER PRIMARY KEY, title TEXT, date TEXT, plan TEXT, account TEXT)'
        );
      },
      version: 1,
    );

    print("Created DB $database");
    return database;
  }
}