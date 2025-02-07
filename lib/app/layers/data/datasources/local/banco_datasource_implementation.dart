import 'dart:async';
import 'dart:io';
import 'package:jmobileflutter/app/common/script_sql.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

const String databaseName = 'bd';
const int databaseVersion = 1;

class Databasepadrao {
  Databasepadrao._privateConstructor();
  static final Databasepadrao instance = Databasepadrao._privateConstructor();
  static Database? _database;

  Future<Database?> get db async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, databaseName);
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Add the onUpgrade callback
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(ScriptSql.createTableClientes);
    await db.execute(ScriptSql.createTableProdutos);
    await db.execute(ScriptSql.createTableContas);
    await db.execute(ScriptSql.createTableMobileCliente);
    await db.execute(ScriptSql.createTableMobileContatos);
    await db.execute(ScriptSql.createTableMobileItemPedido);
    await db.execute(ScriptSql.createTableMobileParcelas);
    await db.execute(ScriptSql.createTableMobilePedido);
    await db.execute(ScriptSql.createTableRelMobRecebida);
  }

  // Handle database upgrades
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < databaseVersion) {
      // await db.execute(ScriptSql.sqlInCloudProdPedVendaConsulta);
    }
  }

  Future<void> dataInsert(String tabela, List lista) async {
    Database? dbPadrao = await db;
    final batch = dbPadrao!.batch();
    for (var item in lista) {
      batch.insert(tabela, item);
    }

    await batch.commit();
  }

  Future<int> updateFromJson(String tabela, Map<String, dynamic> json) async {
    // Verifica se o JSON contém as chaves esperadas
    if (!json.containsKey('dados') || !json.containsKey('filter')) {
      throw ArgumentError('O JSON deve conter as chaves "dados" e "filter".');
    }

    // Obtém as partes relevantes do JSON
    Map<String, dynamic> dados = json['dados'];
    Map<String, dynamic> filter = json['filter'];

    // Monta a cláusula WHERE e os argumentos dinâmicos
    String whereClause = filter.keys.map((key) => "$key = ?").join(' AND ');
    List<dynamic> whereArgs = filter.values.toList();

    // Conecta ao banco de dados
    Database? dbPadrao = await db;

    // Realiza o update
    return await dbPadrao!.update(
      tabela,
      dados,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  Future<List<Map>> dataReturn(String tabela) async {
    Database? dbPadrao = await db;
    List<Map> listMap = await dbPadrao!.query(tabela);
    return listMap;
  }

  Future deleteAll(String tabela) async {
    Database? dbPadrao = await db;
    await dbPadrao!.delete(tabela);
  }

  Future<int> deleteId(String tabela, coluna, id) async {
    Database? dbPadrao = await db;
    return await dbPadrao!.delete(
      tabela,
      where: "$coluna = ?",
      whereArgs: [id],
    );
  }

  Future<List<Map>> filterReturn(String tabela, String coluna, id, {String? colunaExcluida}) async {
    Database? dbPadrao = await db;

    // Obter todas as colunas da tabela
    List<Map<String, dynamic>> colunasInfo = await dbPadrao!.rawQuery('PRAGMA table_info($tabela)');
    List<String> colunas = colunasInfo.map((coluna) => coluna['name'] as String).toList();

    // Remover a coluna especificada, se houver
    if (colunaExcluida != null) {
      colunas.remove(colunaExcluida);
    }

    List<Map> listMap = await dbPadrao.query(
      tabela,
      columns: colunas,
      where: '$coluna = ?',
      whereArgs: [id],
    );
    return listMap;
  }

  Future close() async {
    Database? dbPadrao = await db;
    dbPadrao!.close();
  }
}
