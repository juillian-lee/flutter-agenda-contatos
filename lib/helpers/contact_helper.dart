
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {


  static final ContactHelper _instance = ContactHelper.internal();


  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;


  Future<Database> get db async {

    if(_db != null) {
      return _db;
    }

    _db = await initDB();
    return _db;

  }

  Future<Database> initDB() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contacts.db");

    return openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
        "CREATE TABLE $contactTable("
              "$idColumn INTEGER PRIMARY KEY, "
              "$nameColumn TEXT, "
              "$emailColumn TEXT, "
              "$phoneColumn TEXT, "
              "$imgColumn TEXT"
            ")"
      );
    });
  }


  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }


  Future<Contact> get(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable, columns: [
      idColumn, nameColumn, phoneColumn, emailColumn, imgColumn
    ], where: "$idColumn = ?", whereArgs: [id]);

    return maps.length > 0 ? Contact.fromMap(maps.first) : null;
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }


  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(),
      where: "$idColumn = ? ",
      whereArgs: [contact.id]
    );
  }

  Future<List<Contact>> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for(Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = await db;
    return dbContact.close();
  }
}

class Contact {

  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };

    if(id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return "Contato(id: $id, nome: $name, email: $email, phone: $phone, img: $img)";
  }

}