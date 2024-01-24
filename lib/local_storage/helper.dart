import 'package:contact_app/api/user_model.dart';
import 'package:contact_app/local_storage/mycontact.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart'; //import these

class DBHelper {
  //initialize the SQLite database and create database
  static Future<Database> initDB() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, 'mycontact.db'); 
    return await openDatabase(path,
        version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  // upgrade logic for future versions if needed
  static void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');
    if (oldVersion < 3) {
      print('Performing schema update for version 2');
      const sql = 'ALTER TABLE mycontact ADD COLUMN avatar TEXT';
      await db.execute(sql);
    }
    print('Upgrade complete');
  }

  //create table
  static Future _onCreate(Database db, int version) async {
    const sql = '''CREATE TABLE mycontact(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      first_name TEXT,
      last_name TEXT,
      email TEXT,
      avatar TEXT, 
      isFavorite TEXT
    )''';
  await db.execute(sql);
}

// Save the contacts from remote to local storage
  static Future<void> createContactsFromRemote(List<UserModel> users) async {
    Database db = await DBHelper.initDB();
    List<Mycontact> contacts = users
        .map((user) => Mycontact(
              firstName: user.firstName,
              lastName: user.lastName,
              email: user.email,
              avatar: user.avatar,
            ))
        .toList();    
    for (Mycontact contact in contacts) {
      await db.insert('mycontact', contact.toJson());
    }
  }

  //build create function (insert data in mycontact table)
  static Future<int> createContacts(Mycontact mycontact) async {
    Database db = await DBHelper.initDB();    
    try {
      return await db.insert('mycontact', mycontact.toJson());
    } catch (e) {
      print('Error inserting data: $e');
      return -1; // Return -1 to indicate an error
    }
  }

  //build read function
  static Future<List<Mycontact>> readContacts() async {
    Database db = await DBHelper.initDB();
    var mycontact = await db.query('mycontact', orderBy: 'id');
    //if empty, then return empty []
    List<Mycontact> contactList = mycontact.isNotEmpty
        ? mycontact.map((details) => Mycontact.fromJson(details)).toList()
        : [];
    return contactList;
  }

  //build update function
  static Future<int> updateContacts(Mycontact mycontact) async {
    Database db = await DBHelper.initDB();
    //update the existing mycontact according to its id
    return await db.update('mycontact', mycontact.toJson(),
        where: 'id = ?', whereArgs: [mycontact.id]);
  }

  //build delete function
  static Future<int> deleteContacts(int id) async {
    Database db = await DBHelper.initDB();
    //delete existing mycontact according to its id
    return await db.delete('mycontact', where: 'id = ?', whereArgs: [id]);
  }

  // update the isFavorite field for the specified contact ID
  static Future<int> updateContactFavoriteStatus(int id, String isFavorite) async {
    Database db = await DBHelper.initDB();
    return await db.update(
      'mycontact',
      {'isFavorite': isFavorite},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
