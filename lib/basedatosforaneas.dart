import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'persona.dart';
import 'cita.dart';

class DB {
  static Future<Database> _conectarDB() async {

    Future onConfigure(Database db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    }

    return openDatabase(
      join(await getDatabasesPath(), 'ejercicio2.db'),
      version: 1,
      onConfigure: onConfigure, // Añadimos la configuración
      onCreate: (db, version) async {
        // Corregido: CREATE TABLE en lugar de CREATE TABLA
        await db.execute(
            "CREATE TABLE PERSONA(IDPERSONA INTEGER PRIMARY KEY AUTOINCREMENT, NOMBRE TEXT NOT NULL, TELEFONO TEXT)");

        // Corregido: CREATE TABLE
        await db.execute(
            "CREATE TABLE CITA(IDCITA INTEGER PRIMARY KEY AUTOINCREMENT, LUGAR TEXT, FECHA TEXT, HORA TEXT, ANOTACIONES TEXT, "
                "IDPERSONA INTEGER NOT NULL, " // Es buena práctica que la FK no sea nula
                "FOREIGN KEY(IDPERSONA) REFERENCES PERSONA(IDPERSONA) ON DELETE CASCADE ON UPDATE CASCADE)");
      },
    );
  }


  static Future<int> insertarPersona(Persona p) async {
    Database db = await _conectarDB();

    return db.insert('PERSONA', p.toJson());
  }

  static Future<List<Persona>> mostrarPersonas() async {
    Database db = await _conectarDB();
    final List<Map<String, dynamic>> maps = await db.query('PERSONA');

    return List.generate(maps.length, (i) {
      return Persona.fromMap(maps[i]);
    });
  }

  static Future<int> actualizarPersona(Persona p) async {
    Database db = await _conectarDB();
    return db.update(
      'PERSONA',
      p.toJson(),
      where: 'IDPERSONA = ?',
      whereArgs: [p.idPersona],
    );
  }

  static Future<int> eliminarPersona(int id) async {
    Database db = await _conectarDB();
    return db.delete(
      'PERSONA',
      where: 'IDPERSONA = ?',
      whereArgs: [id],
    );

  }

  static Future<int> insertarCita(Cita c) async {
    Database db = await _conectarDB();
    return db.insert('CITA', c.toJson());
  }

  static Future<List<Map<String, dynamic>>> mostrarCitasConNombre() async {
    Database db = await _conectarDB();
    String sql = "SELECT C.*, P.NOMBRE FROM CITA C "
        "INNER JOIN PERSONA P ON C.IDPERSONA = P.IDPERSONA";
    return db.rawQuery(sql);
  }
  static Future<int> actualizarCita(Cita c) async {
    Database db = await _conectarDB();
    return db.update(
      'CITA',
      c.toJson(),
      where: 'IDCITA = ?',
      whereArgs: [c.idCita],
    );
  }

  static Future<int> eliminarCita(int id) async {
    Database db = await _conectarDB();
    return db.delete(
      'CITA',
      where: 'IDCITA = ?',
      whereArgs: [id],
    );
  }
}