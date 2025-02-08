import 'dart:async';
import 'dart:io';
import 'package:jmobileflutter/app/common/script_sql.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

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

  Future<void> dataInsertMap(String tabela, List lista) async {
    Database? dbPadrao = await db;
    final batch = dbPadrao!.batch();
    for (var item in lista) {
      batch.insert(tabela, item);
    }

    await batch.commit();
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

  Future<List<Map>> dataReturnCliente() async {
    Database? dbPadrao = await db;
    List<Map> listMap = await dbPadrao!.rawQuery('''
                                                SELECT 
                                                    CAST(CODCLI AS INTEGER) CODCLI, 
                                                    CODIGO, 
                                                    NOMECLI, 
                                                    ENDERECO, 
                                                    BAIRRO, 
                                                    CIDADE, 
                                                    ESTADO, 
                                                    CEP, 
                                                    TELEFONE, 
                                                    CPF, 
                                                    LIMITECRED, 
                                                    IDENTIDADE, 
                                                    DATNASC, 
                                                    FILIACAO, 
                                                    PROFISSAO, 
                                                    FOTO, 
                                                    OBS, 
                                                    CONJFANTASIA, 
                                                    LAST_CHANGE, 
                                                    NUMEROLOGRADOURO, 
                                                    '0' ERP, 
                                                    FLAGNAOVENDER
                                                FROM CLIENTES
                                                UNION ALL
                                                SELECT 
                                                    CAST(CODCLI AS INTEGER) CODCLI, 
                                                    CODCLI CODIGO, 
                                                    NOMECLI, 
                                                    ENDERECO, 
                                                    BAIRRO, 
                                                    CIDADE, 
                                                    ESTADO, 
                                                    CEP, 
                                                    TELEFONE, 
                                                    CPF, 
                                                    LIMITECRED, 
                                                    IDENTIDADE, 
                                                    DATNASC, 
                                                    FILIACAO, 
                                                    PROFISSAO, 
                                                    FOTO, 
                                                    OBS, 
                                                    CONJFANTASIA, 
                                                    LAST_CHANGE, 
                                                    NUMEROLOGRADOURO, 
                                                    '1' ERP, 
                                                    FLAGNAOVENDER
                                                FROM 
                                                    MOBILE_CLIENTE
                                                ORDER BY 
                                                    CODIGO DESC
                                                ''');
    if (listMap.isEmpty) {
      return [];
    }
    return listMap;
  }

  Future<Map?> cliente(String codCli) async {
    Database? dbPadrao = await db;
    List<Map> listMap = await dbPadrao!.query(
      'MOBILE_CLIENTE',
      where: 'CODCLI = ?',
      whereArgs: [codCli],
    );
    if (listMap.isEmpty) {
      return null;
    }
    return listMap.first;
  }

  // Método para executar a consulta personalizada
  Future<List<Map>> listarPedidos() async {
    final db = await this.db;

    const sql = '''
      SELECT COALESCE(MP.CLI_NOME, C.NOMECLI) AS NOMECLI, MP.*,
      CASE WHEN MP.TIPOPEDIDO = 'P' THEN 'Pedido' ELSE 'Condicional' END AS TIPO
      FROM MOBILE_PEDIDO MP
      LEFT JOIN CLIENTES C ON C.CODCLI = MP.IDCLIENTE
      ORDER BY MP.IDPEDIDO DESC
    ''';

    return await db!.rawQuery(sql);
  }

  Future<List<Map>> listarReceber({
    String flag = 'N',
    String pesquisar = '',
  }) async {
    final db = await this.db;
    String sql = '''
                    SELECT DISTINCT 
                        'Pedido: ' || C.PEDIDO AS Titulo,
                        C.CODCLI,
                        C.CODIGO,
                        C.DEVEDOR,
                        C.ENDERECO,
                        C.TELEFONE,
                        C.NUMEROLOGRADOURO,
                        C.FLAGPAGO,
                        printf("%.2f", SUM(C.VALOR)) AS VALOR
                    FROM CONTAS C
                    LEFT JOIN CLIENTES CL ON C.CODCLI = CL.CODCLI
                    WHERE FLAGPAGO = '$flag'
                    AND UPPER(C.DEVEDOR || CL.CODIGO) LIKE UPPER('%$pesquisar%')
                    GROUP BY 
                        'Pedido: ' || C.PEDIDO,
                        C.CODCLI,
                        C.CODIGO,
                        C.DEVEDOR,
                        C.ENDERECO,
                        C.TELEFONE,
                        C.NUMEROLOGRADOURO,
                        C.FLAGPAGO;
                        ''';
    return await db!.rawQuery(sql);
  }

  Future<List<Map>> listarRecibo({
    String flag = 'S',
    String codCli = '',
  }) async {
    final db = await this.db;
    String sql = '''
                      SELECT DISTINCT *
                      FROM CONTAS
                      WHERE CODCLI = '$codCli'
                        AND FLAGPAGO <> '$flag'
                      ORDER BY DATVENC;                    
                        ''';
    return await db!.rawQuery(sql);
  }

  // Se AFlag = 'N', substitua WHERE FLAGPAGO = :AFlag por WHERE FLAGPAGO <> 'S'.
// Função para registrar o recibo
  Future<bool> registrarRecibo({
    required Map<String, dynamic> recibo,
    required String valorRecebido,
    required String tipoPagamento,
    required double latitude,
    required double longitude,
    required String idUsuario,
  }) async {
    Database? dbPadrao = await db;
    var uuid = const Uuid();
    try {
      // Validar se o valor recebido foi informado
      if (valorRecebido.isEmpty) {
        throw Exception('Valor recebido não pode ser vazio.');
      }

      // Calcular o saldo restante
      final valorOriginal = double.tryParse(recibo['VALOR'].toString()) ?? 0.0;
      final valorRecebidoAtual = double.tryParse(valorRecebido) ?? 0.0;
      final saldoRestante = valorOriginal - valorRecebidoAtual;

      // Atualizar o registro na tabela CONTAS
      await dbPadrao!.transaction((txn) async {
        // Atualizar os dados do recibo existente
        await txn.rawUpdate(
          '''
          UPDATE CONTAS 
          SET FLAGPAGO = ?, DATPAG = ?, GUID = ?, TIPOPAGAMENTO = ?, RECEBIDO = ?, LATITUDE = ?, LONGITUDE = ?, SALDO = ?, CODIGO = ?
          WHERE SEQ = ? AND CODCR = ?
          ''',
          [
            'S', // FLAGPAGO
            DateTime.now().toIso8601String(), // DATPAG
            uuid.v1(), // GUID
            tipoPagamento, // TIPOPAGAMENTO
            valorRecebidoAtual, // RECEBIDO
            latitude.toString(), // LATITUDE
            longitude.toString(), // LONGITUDE
            saldoRestante, // SALDO
            idUsuario, // CODIGO
            recibo['SEQ'], // SEQ
            recibo['CODCR'], // CODCR
          ],
        );

        // Se houver saldo restante, inserir um novo registro
        if (saldoRestante > 0) {
          await txn.rawInsert(
            '''
            INSERT INTO CONTAS (
              CODCLI, CODIGO, NUMDOC, DEVEDOR, ENDERECO, NUMEROLOGRADOURO, TELEFONE, VALOR, DATENTR, DATVENC, PARCELA, RECEBIDO, CODCR, SALDO, FLAGPAGO, DIAS_ATRASO
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''',
            [
              recibo['CODCLI'], // CODCLI
              recibo['CODIGO'], // CODIGO
              recibo['NUMDOC'], // NUMDOC
              recibo['DEVEDOR'], // DEVEDOR
              recibo['ENDERECO'], // ENDERECO
              recibo['NUMEROLOGRADOURO'], // NUMEROLOGRADOURO
              recibo['TELEFONE'], // TELEFONE
              saldoRestante, // VALOR
              recibo['DATENTR'], // DATENTR
              recibo['DATVENC'], // DATVENC
              recibo['PARCELA'], // PARCELA
              0.0, // RECEBIDO
              recibo['CODCR'], // CODCR
              saldoRestante, // SALDO
              'P', // FLAGPAGO
              recibo['DIAS_ATRASO'], // DIAS_ATRASO
            ],
          );
        }
      });

      return true; // Sucesso
    } catch (e) {
      print('Erro ao registrar recibo: $e');
      return false; // Falha
    }
  }

  // Função para gravar o cliente e seus contatos
  Future<void> gravarCliente({
    required Map<String, dynamic> cliente,
    required List<Map<String, dynamic>> contatos,
  }) async {
    Database? dbPadrao = await db;
    try {
      // Iniciar transação para garantir consistência dos dados
      await dbPadrao!.transaction((txn) async {
        // Gerar o próximo código do cliente
        final codigoCliente = await _gerarProximoCodigoCliente(txn);

        // Inserir o cliente na tabela MOBILE_CLIENTE
        await txn.insert(
          'MOBILE_CLIENTE',
          {
            "IDUSUARIO": cliente['IDUSUARIO'],
            "CODCLI": codigoCliente,
            "NOMECLI": cliente['NOMECLI'],
            "DATNASC": cliente['DATNASC'],
            "TELEFONE": cliente['TELEFONE'],
            "CPF": cliente['CPF'],
            "IDENTIDADE": cliente['IDENTIDADE'],
            "PROFISSAO": cliente['PROFISSAO'],
            "DATCAD": DateTime.now().toIso8601String(),
            "LIMITECRED": cliente['LIMITECRED'],
            "CEP": cliente['CEP'],
            "ENDERECO": cliente['ENDERECO'],
            "BAIRRO": cliente['BAIRRO'],
            "NUMEROLOGRADOURO": cliente['NUMEROLOGRADOURO'],
            "CIDADE": cliente['CIDADE'],
            "ESTADO": cliente['ESTADO'],
            "OBS": cliente['OBS'],
            "COMPLEMENTOLOGRADOURO": cliente['COMPLEMENTOLOGRADOURO'],
            "DIAVENCIMENTO": cliente['DIAVENCIMENTO'],
            "FLAGNAOVENDER": cliente['FLAGNAOVENDER'],
            "LATITUDE": cliente['LATITUDE'],
            "LONGITUDE": cliente['LONGITUDE'],
          },
        );

        // Inserir os contatos na tabela MOBILE_CONTATOS
        for (var contato in contatos) {
          await txn.insert(
            'MOBILE_CONTATOS',
            {
              "IDUSUARIO": cliente['IDUSUARIO'],
              "CODCLI": codigoCliente,
              "NOME": contato['NOME'],
              "TELEFONE": contato['TELEFONE'],
              "EMAIL": contato['EMAIL'] ?? '',
              "SETOR": contato['SETOR'],
            },
          );
        }
      });

      print('Cliente e contatos gravados com sucesso!');
    } catch (e) {
      print('Erro ao gravar cliente: $e');
      throw Exception('Falha ao gravar cliente.');
    }
  }

  // Função para gerar o próximo código do cliente
  Future<String> _gerarProximoCodigoCliente(Transaction txn) async {
    final result = await txn.rawQuery('SELECT MAX(CODCLI) AS CODIGO FROM MOBILE_CLIENTE');
    final maxCodigo = result.first['CODIGO'] as int? ?? 0;
    return (maxCodigo + 1).toString();
  }

  Future<int> dataInsertClient(String tabela, Map<String, dynamic> item) async {
    Database? dbPadrao = await db;
    return await dbPadrao!.insert(tabela, item);
  }

  Future<List<Map<String, Object?>>> dataReturnFull(String sql) async {
    Database? dbPadrao = await db;
    return await dbPadrao!.rawQuery(sql);
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
