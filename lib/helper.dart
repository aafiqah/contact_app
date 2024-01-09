import 'package:contact_app/mycontact.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart'; //import these

class DBHelper {
  //this is to initialize the SQLite database
  //Database is from sqflite package
  //as well as getDatabasesPath()
  static Future<Database> initDB() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, 'mycontact.db');
    //this is to create database
    return await openDatabase(path, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  static void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');
    if (oldVersion < 3) {
      print('Performing schema update for version 3');
      const sql = 'ALTER TABLE mycontact ADD COLUMN profileImage TEXT';
      await db.execute(sql);
    }
    // Add more upgrade logic for future versions if needed
    print('Upgrade complete');
  }



  //build _onCreate function
  static Future _onCreate(Database db, int version) async {
    //this is to create table into database
    //and the command is same as SQL statement
    //you must use ''' and ''', for open and close
    const sql = '''CREATE TABLE mycontact(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      firstname TEXT,
      lastname TEXT,
      fullname TEXT,
      email TEXT,
      profileImage TEXT, 
      isFavorite INTEGER
    )''';
    //sqflite is only support num, string, and unit8List format
    //please refer to package doc for more details
    await db.execute(sql);
  }

  //build create function (insert)
  static Future<int> createContacts(Mycontact mycontact) async {
    Database db = await DBHelper.initDB();
    //create mycontact using insert()
    //return await db.insert('mycontact', mycontact.toJson());
    try {
      // create mycontact using insert()
      return await db.insert('mycontact', mycontact.toJson());
    } catch (e) {
      print('Error inserting data: $e');
      return -1; // Return -1 to indicate an error
    }
  }

  //build read function
  static Future<List<Mycontact>> readContacts() async {
    Database db = await DBHelper.initDB();
    var mycontact = await db.query('mycontact', orderBy: 'fullname');
    //this is to list out the mycontact list from database
    //if empty, then return empty []
    List<Mycontact> contactList = mycontact.isNotEmpty
        ? mycontact.map((details) => Mycontact.fromJson(details)).toList()
        : [];
    return contactList;
  }

  //build update function
  static Future<int> updateContacts(Mycontact mycontact) async {
    Database db = await DBHelper.initDB();
    //update the existing mycontact
    //according to its id
    return await db.update('mycontact', mycontact.toJson(),
        where: 'id = ?', whereArgs: [mycontact.id]);
  }

  //build delete function
  static Future<int> deleteContacts(int id) async {
    Database db = await DBHelper.initDB();
    //delete existing mycontact
    //according to its id
    return await db.delete('mycontact', where: 'id = ?', whereArgs: [id]);
  }
}
