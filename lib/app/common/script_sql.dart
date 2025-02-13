// class ScriptSql {
//   static String createTableClientes = '''
//                                         CREATE TABLE CLIENTES (
//                                             NOMECARACTERISTICAPESSOA TEXT,
//                                             CODCLI	TEXT,
//                                             CODIGO	TEXT,
//                                             CODEMPRESA	TEXT,
//                                             NOMECLI	TEXT,
//                                             ENDERECO	TEXT,
//                                             BAIRRO	TEXT,
//                                             CIDADE	TEXT,
//                                             ESTADO	TEXT,
//                                             CEP	TEXT,
//                                             TELEFONE	TEXT,
//                                             CPF	TEXT,
//                                             LIMITECRED	TEXT,
//                                             IDENTIDADE	TEXT,
//                                             DATNASC	TEXT,
//                                             FILIACAO	TEXT,
//                                             PROFISSAO	TEXT,
//                                             FOTO	TEXT,
//                                             OBS	TEXT,
//                                             CONJFANTASIA	TEXT,
//                                             LAST_CHANGE	TEXT,
//                                             ULTPAG	TEXT,
//                                             NUMEROLOGRADOURO	TEXT,
//                                             COMPLEMENTOLOGRADOURO    TEXT,
//                                             DIAVENCIMENTO	TEXT,
//                                             FLAGNAOVENDER	TEXT
//                                         );
// ''';

//   static String createTableProdutos = '''
//                                               CREATE TABLE PRODUTOS (
//                                                   CODPROD     TEXT,
//                                                   CODIGO      TEXT,
//                                                   NOMEPROD    TEXT,
//                                                   DATREAJ     TEXT,
//                                                   ESTATU      TEXT,
//                                                   PRECO	TEXT,
//                                                   LAST_CHANGE TEXT
//                                               );
// ''';

//   static String createTableContas = '''
//                                         CREATE TABLE CONTAS (
//                                             CODCLI	TEXT,
//                                             NUMDOC	TEXT,
//                                             DEVEDOR	TEXT,
//                                             ENDERECO	TEXT,
//                                             NUMEROLOGRADOURO TEXT,
//                                             TELEFONE	TEXT,
//                                             VALOR	TEXT,
//                                             DATENTR	TEXT,
//                                             DATVENC	TEXT,
//                                             PARCELA	TEXT,
//                                             FLAGPAGO	TEXT,
//                                             DATPAG	TEXT,
//                                             RECEBIDO	TEXT,
//                                             CODCR	TEXT,
//                                             SALDO	TEXT,
//                                             DIAS_ATRASO      TEXT,
//                                             PEDIDO	TEXT,
//                                             CODIGO	TEXT,
//                                             GUID	TEXT,
//                                             TIPOPAGAMENTO    TEXT,
//                                             LATITUDE	TEXT	DEFAULT (0),
//                                             LONGITUDE	TEXT	DEFAULT (0),
//                                             PDOT	TEXT,
//                                             SEQ	INTEGER	PRIMARY KEY AUTOINCREMENT
//                                         );
// ''';

//   static String createTableMobileCliente = '''
//                                           CREATE TABLE MOBILE_CLIENTE (
//                                               IDUSUARIO	TEXT,
//                                               CODCLI	INTEGER	PRIMARY KEY AUTOINCREMENT,
//                                               CODIGO	TEXT,
//                                               NOMECLI	TEXT,
//                                               ENDERECO	TEXT,
//                                               BAIRRO	TEXT,
//                                               CIDADE	TEXT,
//                                               ESTADO	TEXT,
//                                               CEP	TEXT,
//                                               TELEFONE	TEXT,
//                                               CPF	TEXT,
//                                               LIMITECRED	TEXT,
//                                               IDENTIDADE	TEXT,
//                                               DATNASC	TEXT,
//                                               FILIACAO	TEXT,
//                                               PROFISSAO	TEXT,
//                                               DATCAD	TEXT,
//                                               FOTO	TEXT,
//                                               OBS	TEXT,
//                                               CONJFANTASIA	TEXT,
//                                               LAST_CHANGE	TEXT,
//                                               LATITUDE	TEXT	DEFAULT (0),
//                                               LONGITUDE	TEXT	DEFAULT (0),
//                                               PDOT	TEXT,
//                                               NUMEROLOGRADOURO      TEXT,
//                                               COMPLEMENTOLOGRADOURO TEXT,
//                                               DIAVENCIMENTO	TEXT,
//                                               FLAGNAOVENDER	TEXT
//                                           );
// ''';

//   static String createTableMobileContatos = '''
//                                           CREATE TABLE MOBILE_CONTATOS (
//                                               IDUSUARIO   TEXT,
//                                               CODCTC      TEXT,
//                                               CODCLI      TEXT,
//                                               NOME	TEXT,
//                                               TELEFONE    TEXT,
//                                               EMAIL	TEXT,
//                                               SETOR	TEXT,
//                                               LAST_CHANGE TEXT
//                                           );
// ''';

//   static String createTableMobileItemPedido = '''
//                                             CREATE TABLE MOBILE_ITEMPEDIDO (
//                                                 IDITEMPEDIDO    INTEGER      PRIMARY KEY AUTOINCREMENT,
//                                                 IDUSUARIO	TEXT,
//                                                 IDITEMPEDIDOERP TEXT,
//                                                 IDPEDIDO	TEXT,
//                                                 IDPRODUTO	TEXT,
//                                                 QTDE	TEXT,
//                                                 VALORUNITARIO   TEXT,
//                                                 VALORTOTAL      TEXT,
//                                                 DATAHORAMOBILE  TEXT
//                                             );
// ''';

//   static String createTableMobileParcelas = '''
//                                               CREATE TABLE MOBILE_PARCELAS (
//                                                   IDPARCELAS INTEGER	PRIMARY KEY AUTOINCREMENT,
//                                                   DTINICIAL  TEXT,
//                                                   GUID	TEXT,
//                                                   DATA	TEXT,
//                                                   VALORTOTAL TEXT,
//                                                   PARCELA    TEXT,
//                                                   NRPARCELA  TEXT,
//                                                   VALOR      TEXT,
//                                                   SITUACAO   TEXT	DEFAULT A,
//                                                   CODCLI     TEXT,
//                                                   DTPAGO     TEXT,
//                                                   VALORPAGO  TEXT,
//                                                   OBSERVACAO TEXT,
//                                                   IDPEDIDO   TEXT
//                                               );
// ''';

//   static String createTableMobilePedido = '''
//                                               CREATE TABLE MOBILE_PEDIDO (
//                                                   IDPEDIDO	INTEGER	PRIMARY KEY AUTOINCREMENT,
//                                                   IDPEDIDOERP	TEXT,
//                                                   IDEMPRESA	TEXT,
//                                                   IDUSUARIO	TEXT,
//                                                   IDCLIENTE	TEXT,
//                                                   PRAZOPAGTO	TEXT,
//                                                   DATAMOBILE	TEXT,
//                                                   INICIO_VENCIMENTO TEXT,
//                                                   OBSPEDIDO	TEXT,
//                                                   VALOR	TEXT,
//                                                   DESCONTO	TEXT,
//                                                   VALORTOTAL	TEXT,
//                                                   VALORENTRADA      TEXT,
//                                                   STATUSPEDIDOERP   TEXT,
//                                                   CLI_NOME	TEXT,
//                                                   CLI_CPF	TEXT,
//                                                   DATAHORA	TEXT,
//                                                   CLIENTENOVO	TEXT,
//                                                   COUNT_ITEMPEDIDO  TEXT,
//                                                   TIPOPEDIDO	TEXT  DEFAULT P,
//                                                   LATITUDE	TEXT	DEFAULT (0),
//                                                   LONGITUDE	TEXT	DEFAULT (0)
//                                               );
// ''';

//   static String createTableRelMobRecebida = '''
//                                               CREATE TABLE REL_MOB_RECEBIDA (
//                                                   CODIGO  TEXT,
//                                                   NOMECLI TEXT,
//                                                   NUMDOC  TEXT,
//                                                   CODCR   TEXT,
//                                                   CODUSER TEXT,
//                                                   DATA    TEXT,
//                                                   VALOR   TEXT,
//                                                   TIPO    TEXT,
//                                                   CODCLI  TEXT,
//                                                   GUID    TEXT
//                                               );
// ''';
// }

class ScriptSql {
  static String createTableClientes = '''
                                        CREATE TABLE CLIENTES (
                                            NOMECARACTERISTICAPESSOA VARCHAR (60),
                                            CODCLI	VARCHAR (20),
                                            CODIGO	VARCHAR (20),
                                            CODEMPRESA	VARCHAR (60),
                                            NOMECLI	VARCHAR (50),
                                            ENDERECO	VARCHAR (60),
                                            BAIRRO	VARCHAR (60),
                                            CIDADE	VARCHAR (60),
                                            ESTADO	VARCHAR (2),
                                            CEP	VARCHAR (15),
                                            TELEFONE	VARCHAR (45),
                                            CPF	VARCHAR (14),
                                            LIMITECRED	REAL (15, 4),
                                            IDENTIDADE	VARCHAR (17),
                                            DATNASC	DATETIME,
                                            FILIACAO	VARCHAR (60),
                                            PROFISSAO	VARCHAR (60),
                                            FOTO	VARCHAR (255),
                                            OBS	VARCHAR (255),
                                            CONJFANTASIA	VARCHAR (255),
                                            LAST_CHANGE	DATETIME,
                                            ULTPAG	DATETIME,
                                            NUMEROLOGRADOURO	VARCHAR (10),
                                            COMPLEMENTOLOGRADOURO    VARCHAR (255),
                                            DIAVENCIMENTO	INTEGER,
                                            FLAGNAOVENDER	CHAR (1)
                                        );
''';

  static String createTableProdutos = '''
                                              CREATE TABLE PRODUTOS (
                                                  CODPROD     VARCHAR (20),
                                                  CODIGO      VARCHAR (20),
                                                  NOMEPROD    VARCHAR (50),
                                                  DATREAJ     DATE,
                                                  ESTATU      REAL (15, 4),
                                                  PRECO	REAL (15, 4),
                                                  LAST_CHANGE DATETIME
                                              );
''';

  static String createTableContas = '''
                                        CREATE TABLE CONTAS (
                                            CODCLI	VARCHAR (20),
                                            NUMDOC	VARCHAR (20),
                                            DEVEDOR	VARCHAR (60),
                                            ENDERECO	VARCHAR (255),
                                            NUMEROLOGRADOURO VARCHAR (10),
                                            TELEFONE	VARCHAR (45),
                                            VALOR	DOUBLE,
                                            DATENTR	DATE,
                                            DATVENC	DATE,
                                            PARCELA	VARCHAR (20),
                                            FLAGPAGO	CHAR (1),
                                            DATPAG	DATETIME,
                                            RECEBIDO	DOUBLE,
                                            CODCR	VARCHAR (20),
                                            SALDO	DOUBLE,
                                            DIAS_ATRASO      INTEGER,
                                            PEDIDO	VARCHAR (20),
                                            CODIGO	VARCHAR (20),
                                            GUID	VARCHAR (100),
                                            TIPOPAGAMENTO    VARCHAR (20),
                                            LATITUDE	DOUBLE,
                                            LONGITUDE	DOUBLE,
                                            PDOT	DOUBLE,
                                            SEQ	INTEGER	PRIMARY KEY AUTOINCREMENT
                                        );
''';

  static String createTableMobileCliente = '''
                                          CREATE TABLE MOBILE_CLIENTE (
                                              IDUSUARIO	VARCHAR (20),
                                              CODCLI	INTEGER	PRIMARY KEY AUTOINCREMENT,
                                              CODIGO	VARCHAR (10),
                                              NOMECLI	VARCHAR (50),
                                              ENDERECO	VARCHAR (55),
                                              BAIRRO	VARCHAR (30),
                                              CIDADE	VARCHAR (40),
                                              ESTADO	VARCHAR (2),
                                              CEP	VARCHAR (8),
                                              TELEFONE	VARCHAR (45),
                                              CPF	VARCHAR (14),
                                              LIMITECRED	REAL (15, 4),
                                              IDENTIDADE	VARCHAR (16),
                                              DATNASC	DATETIME,
                                              FILIACAO	VARCHAR (60),
                                              PROFISSAO	VARCHAR (30),
                                              DATCAD	DATETIME,
                                              FOTO	VARCHAR (255),
                                              OBS	VARCHAR (255),
                                              CONJFANTASIA	VARCHAR (255),
                                              LAST_CHANGE	DATETIME,
                                              LATITUDE	REAL,
                                              LONGITUDE	REAL,
                                              PDOT	REAL,
                                              NUMEROLOGRADOURO      VARCHAR (10),
                                              COMPLEMENTOLOGRADOURO VARCHAR (50),
                                              DIAVENCIMENTO	INTEGER,
                                              FLAGNAOVENDER	CHAR (1)
                                          );
''';

  static String createTableMobileContatos = '''
                                          CREATE TABLE MOBILE_CONTATOS (
                                              IDUSUARIO   VARCHAR (20),
                                              CODCTC      VARCHAR (9),
                                              CODCLI      VARCHAR (8),
                                              NOME	VARCHAR (50),
                                              TELEFONE    VARCHAR (45),
                                              EMAIL	VARCHAR (100),
                                              SETOR	VARCHAR (30),
                                              LAST_CHANGE DATETIME
                                          );
''';

  static String createTableMobileItemPedido = '''
                                            CREATE TABLE MOBILE_ITEMPEDIDO (
                                                IDITEMPEDIDO    INTEGER      PRIMARY KEY AUTOINCREMENT,
                                                IDUSUARIO	VARCHAR (20),
                                                IDITEMPEDIDOERP VARCHAR (20),
                                                IDPEDIDO	INTEGER,
                                                IDPRODUTO	VARCHAR (20),
                                                QTDE	REAL (10, 4),
                                                VALORUNITARIO   REAL (10, 4),
                                                VALORTOTAL      REAL (10, 4),
                                                DATAHORAMOBILE  DATETIME
                                            );
''';

  static String createTableMobileParcelas = '''
                                              CREATE TABLE MOBILE_PARCELAS (
                                                  IDPARCELAS INTEGER	PRIMARY KEY AUTOINCREMENT,
                                                  DTINICIAL  DATE,
                                                  GUID	VARCHAR (255),
                                                  DATA	DATE,
                                                  VALORTOTAL DOUBLE,
                                                  PARCELA    VARCHAR (20),
                                                  NRPARCELA  INTEGER,
                                                  VALOR      DOUBLE,
                                                  SITUACAO   TEXT	DEFAULT A,
                                                  CODCLI     INTEGER,
                                                  DTPAGO     DATE,
                                                  VALORPAGO  DOUBLE,
                                                  OBSERVACAO VARCHAR (255),
                                                  IDPEDIDO   INTEGER
                                              );
''';

  static String createTableMobilePedido = '''
                                              CREATE TABLE MOBILE_PEDIDO (
                                                  IDPEDIDO	INTEGER	PRIMARY KEY AUTOINCREMENT,
                                                  IDPEDIDOERP	VARCHAR (10),
                                                  IDEMPRESA	VARCHAR (20),
                                                  IDUSUARIO	VARCHAR (20),
                                                  IDCLIENTE	VARCHAR (20),
                                                  PRAZOPAGTO	VARCHAR (20),
                                                  DATAMOBILE	DATE,
                                                  INICIO_VENCIMENTO DATE,
                                                  OBSPEDIDO	VARCHAR (255),
                                                  VALOR	REAL (15, 4),
                                                  DESCONTO	REAL (15, 4),
                                                  VALORTOTAL	REAL (15, 4),
                                                  VALORENTRADA      REAL (15, 4),
                                                  STATUSPEDIDOERP   VARCHAR (20),
                                                  CLI_NOME	VARCHAR (255),
                                                  CLI_CPF	VARCHAR (50),
                                                  DATAHORA	DATETIME,
                                                  CLIENTENOVO	CHAR (1),
                                                  COUNT_ITEMPEDIDO  INTEGER,
                                                  TIPOPEDIDO	CHAR (1)      DEFAULT P,
                                                  LATITUDE	DOUBLE	DEFAULT (0),
                                                  LONGITUDE	DOUBLE	DEFAULT (0)
                                              );
''';

  static String createTableRelMobRecebida = '''
                                              CREATE TABLE REL_MOB_RECEBIDA (
                                                  CODIGO  VARCHAR (20),
                                                  NOMECLI VARCHAR (100),
                                                  NUMDOC  VARCHAR (20),
                                                  CODCR   VARCHAR (20),
                                                  CODUSER VARCHAR (20),
                                                  DATA    DATETIME,
                                                  VALOR   DOUBLE,
                                                  TIPO    VARCHAR (20),
                                                  CODCLI  VARCHAR (20),
                                                  GUID    VARCHAR (200)
                                              );
''';
}
