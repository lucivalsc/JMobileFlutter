// import 'package:jmobileflutter/app/layers/data/datasources/local/banco_controller.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/comercial/pedidos/pedido_store.dart';
// import 'package:intl/intl.dart';
// import 'imports.dart'; // Importe seus módulos necessários

// // Função fictícia para obter dados da filial[' Substitua'] pelo seu método real.
// Future<Map> getFilialByCodigo(String codigo) async {
//   Databasepadrao banco = Databasepadrao.instance;
//   // Aqui você deve implementar a lógica para obter a filial do banco de dados
//   // Exemplo fictício de retorno
//   var value = await banco.retornarFiltrado('FILIAL', 'CODIGOFILIAL', codigo);
//   Map pedidos = value[0];
//   return {
//     "CODIGOFILIAL": pedidos['CODIGOFILIAL'] ?? '',
//     "NOME": pedidos['NOME'] ?? '',
//     "FANTASIA": pedidos['FANTASIA'] ?? '',
//     "CNPJ": pedidos['CNPJ'] ?? '',
//     "INSCRICAO": pedidos['INSCRICAO'] ?? '',
//     "ENDERECO": pedidos['ENDERECO'] ?? '',
//     "CEP": pedidos['CEP'] ?? '',
//     "CIDADE": pedidos['CIDADE'] ?? '',
//     "BAIRRO": pedidos['BAIRRO'] ?? '',
//     "ESTADO": pedidos['ESTADO'] ?? '',
//     "TELEFONE": pedidos['TELEFONE'] ?? '',
//     "CODIGOMUNICIPIO": pedidos['CODIGOMUNICIPIO'] ?? '',
//     "NUMERO": pedidos['NUMERO'] ?? '',
//     "REFERENCIA": pedidos['REFERENCIA'] ?? '',
//     "FAX": pedidos['FAX'] ?? '',
//     "EMAIL": pedidos['EMAIL'] ?? '',
//     "SITE": pedidos['SITE'] ?? '',
//     "CNAE": pedidos['CNAE'] ?? '',
//     // O campo LOGO foi omitido, pois é um BLOB e requer manipulação específica.
//   };
// }

// Future<List<int>> getTicket(PedidoStore store) async {
//   List<int> bytes = [];
//   CapabilityProfile profile = await CapabilityProfile.load();
//   final generator = Generator(PaperSize.mm80, profile);

//   // Inicializa formatadores
//   final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
//   final numberFormat = NumberFormat.decimalPattern('pt_BR');

//   // Obtém dados da filial
//   // final filial = await getFilialByCodigo(store.codigofilial);
//   final filial = await getFilialByCodigo(store.pedido.CODIGOFILIAL!);

//   // Cabeçalho
//   // bytes += generator.text(
//   //   "APP jmobileflutter",
//   //   styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size2, width: PosTextSize.size2),
//   //   linesAfter: 1,
//   // );

//   // Dados da filial
//   bytes += generator.text(
//     "${filial['NOME']}",
//     styles: const PosStyles(align: PosAlign.center, bold: true),
//   );

//   bytes += generator.text(
//     'CNPJ: ${filial['CNPJ']}',
//     styles: const PosStyles(align: PosAlign.center),
//   );

//   bytes += generator.text(
//     '${filial['ENDERECO']}, ${filial['CIDADE']} - ${filial['ESTADO']}',
//     styles: const PosStyles(align: PosAlign.center),
//   );

//   bytes += generator.text(
//     'Telefone: ${filial['TELEFONE']}',
//     styles: const PosStyles(align: PosAlign.center),
//   );

//   bytes += generator.hr();

//   // Dados do comprador
//   bytes += generator.text(
//     store.razaoSocial!,
//     styles: const PosStyles(align: PosAlign.center, bold: true),
//   );

//   bytes += generator.text(
//     'CNPJ/CPF: ${store.cnpj}',
//     styles: const PosStyles(align: PosAlign.center),
//   );

//   bytes += generator.text(
//     '${store.clientes.ENDERECORUA}, ${store.clientes.ENDERECONUMERO}, ${store.clientes.ENDERECOCEP}, ${store.clientes.ENDERECOCIDADE} - ${store.clientes.ENDERECOESTADO}',
//     styles: const PosStyles(align: PosAlign.center),
//   );

//   bytes += generator.text(
//     'Telefone: ${store.clientes.TELCOMERCIAL1}',
//     styles: const PosStyles(align: PosAlign.center),
//   );

//   bytes += generator.hr();

//   bytes += generator.text('PEDIDO', styles: const PosStyles(align: PosAlign.center, bold: true));

//   bytes += generator.hr();

//   // Cabeçalho da Tabela
//   bytes += generator.row(
//     [
//       PosColumn(
//         text: 'Codigo',
//         width: 2,
//         styles: const PosStyles(align: PosAlign.left, bold: true),
//       ),
//       PosColumn(
//         text: 'Item',
//         width: 4, // Ajuste para caber corretamente no papel mm80
//         styles: const PosStyles(align: PosAlign.left, bold: true),
//       ),
//       PosColumn(
//         text: 'Preco',
//         width: 2,
//         styles: const PosStyles(align: PosAlign.right, bold: true),
//       ),
//       PosColumn(
//         text: 'Qtde',
//         width: 2,
//         styles: const PosStyles(align: PosAlign.right, bold: true),
//       ),
//       PosColumn(
//         text: 'Total',
//         width: 2,
//         styles: const PosStyles(align: PosAlign.right, bold: true),
//       ),
//     ],
//   );

//   // Itens da Tabela
//   for (int i = 0; i < store.pedidositens.length; i++) {
//     var item = store.pedidositens[i];

//     // Primeira linha: No, Código e Item
//     bytes += generator.row(
//       [
//         PosColumn(
//           text: item.CODIGOEAN.toString(),
//           width: 5, // Ajustado para caber corretamente
//           styles: const PosStyles(align: PosAlign.left),
//         ),
//         PosColumn(
//           text: item.DESCRICAOCOMPLETA.toString(),
//           width: 7, // Ajustado para caber corretamente
//           styles: const PosStyles(align: PosAlign.left),
//         ),
//       ],
//     );

//     // Segunda linha: Preço, Qtde e Total
//     bytes += generator.row(
//       [
//         PosColumn(
//           text: currencyFormat.format(double.parse(item.VALORUNITARIO!)),
//           width: 4,
//           styles: const PosStyles(align: PosAlign.right),
//         ),
//         PosColumn(
//           text: numberFormat.format(double.parse(item.QUANTIDADE!)),
//           width: 4,
//           styles: const PosStyles(align: PosAlign.right),
//         ),
//         PosColumn(
//           text: currencyFormat.format(double.parse(item.VALORTOTAL!)),
//           width: 4,
//           styles: const PosStyles(align: PosAlign.right),
//         ),
//       ],
//     );
//   }

//   bytes += generator.hr(ch: '-', linesAfter: 1);

//   // Totalizadores
//   bytes += generator.text(
//     'Valor Total: ${currencyFormat.format(store.valorTotalItens)}',
//     styles: const PosStyles(align: PosAlign.right),
//   );
//   bytes += generator.text(
//     'Qtde Itens: ${numberFormat.format(store.pedidositens.length)}',
//     styles: const PosStyles(align: PosAlign.right),
//   );

//   bytes += generator.text(
//     'Forma de Pagamento: ${store.condicao.DESCRICAO}',
//     styles: const PosStyles(align: PosAlign.right),
//   );

//   bytes += generator.hr(ch: '-', linesAfter: 1);

//   bytes += generator.text(
//     'Obs.: ${store.pedido.OBSERVACAO}',
//     styles: const PosStyles(align: PosAlign.center),
//   );

//   bytes += generator.hr(ch: '-', linesAfter: 1);
//   // Rodapé
//   bytes += generator.text('Obrigado pela preferencia!', styles: const PosStyles(align: PosAlign.center, bold: true));

//   bytes += generator.text(
//     DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
//     styles: const PosStyles(align: PosAlign.center),
//   );

//   // bytes += generator.text(
//   //   'Nota: As mercadorias uma vez vendidas nao serao devolvidas ou trocadas.',
//   //   styles: const PosStyles(align: PosAlign.center),
//   // );

//   bytes += generator.cut();

//   return bytes;
// }
