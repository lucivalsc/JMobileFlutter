// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/observacao/observacao_screen.dart';
// import 'package:jmobileflutter/navigation.dart';
// import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:intl/intl.dart';
// import 'package:uuid/uuid.dart';

// import 'package:jmobileflutter/app/layers/data/datasources/local/banco_controller.dart';
// import 'package:jmobileflutter/app/common/padrao.dart';
// import 'package:jmobileflutter/app/common/theme/cores.dart';
// import 'package:jmobileflutter/app/common/theme/my_app_bar.dart';
// import 'package:jmobileflutter/app/common/theme/texto_formatado_lista.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/comercial/pedidos/impressao/imports.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/comercial/pedidos/impressao/impressao_configuracao.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/comercial/pedidos/pedido_comum.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/comercial/pedidos/pedido_store.dart';

// class ImpressaoPadrao extends StatefulWidget {
//   final String? guidOld;
//   final String? cnpjOld;
//   final String? codigoCondicaoOld;
//   final String tabela;
//   final String tabelaItens;
//   const ImpressaoPadrao({
//     super.key,
//     this.guidOld,
//     this.cnpjOld,
//     this.codigoCondicaoOld,
//     required this.tabela,
//     required this.tabelaItens,
//   });

//   @override
//   State<ImpressaoPadrao> createState() => _ImpressaoPadraoState();
// }

// class _ImpressaoPadraoState extends State<ImpressaoPadrao> {
//   Databasepadrao banco = Databasepadrao.instance;
//   NumberFormat formatacao = NumberFormat.simpleCurrency(locale: 'pt_BR');
//   var uuid = const Uuid();
//   PedidoStore store = PedidoStore();
//   PedidoComum pedidoComum = PedidoComum();
//   ComumPrint comumPrint = ComumPrint();

//   gerarGuid() async {
//     if (widget.guidOld == null) {
//       store.uuGuidAtual(uuid.v1());
//     } else {
//       store.guid = widget.guidOld;
//       await store.listarPedidos(widget.guidOld, tabela: widget.tabela);
//       await store.listarPedidosItens(widget.guidOld, tabela: widget.tabelaItens);
//       await store.retornarCliente(widget.cnpjOld);
//       if (widget.codigoCondicaoOld != null) await store.retornarCondicaoPg(widget.codigoCondicaoOld);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     gerarGuid();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Observer(
//         builder: (_) => Scaffold(
//           appBar: AppBar(
//             backgroundColor: Colors.transparent,
//             flexibleSpace: const Cabecalho(),
//             toolbarHeight: 0,
//             title: const SizedBox(),
//             automaticallyImplyLeading: false,
//             bottom: const PreferredSize(
//               preferredSize: Size(0, 100),
//               child: Column(
//                 children: [
//                   MyAppBar(texto: 'Impressão'),
//                 ],
//               ),
//             ),
//           ),
//           body: Container(
//             color: Cores.corBarraStatus,
//             child: ListView(
//               children: [
//                 Divider(color: Cores.corPadrao),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text('ID do pedido: ${store.guid!}'),
//                 ),
//                 Divider(color: Cores.corPadrao),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 10, right: 10),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             TextoFormatadoLista(
//                               titulo: 'Razão Social:',
//                               texto: store.razaoSocial,
//                             ),
//                             TextoFormatadoLista(
//                               titulo: 'CNPJ/CPF:',
//                               texto: inMostraLogo ? store.cnpj : '',
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Divider(color: Cores.corPadrao),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 10, right: 10),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextoFormatadoLista(
//                           titulo: 'Condição de pagamento:',
//                           texto: store.listaPrazoPagamentoAtiva!,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Divider(color: Cores.corPadrao),
//                 InkWell(
//                   onTap: () async {
//                     var value = await pushNamed(context, ObservacaoScreen.route, arguments: [store.pedido]);
//                     if (value != null) {
//                       store.pedido.OBSERVACAO = value;
//                       setState(() {});
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 10, right: 10),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: TextoFormatadoLista(
//                             titulo: 'Observação:',
//                             texto: store.pedido.OBSERVACAO,
//                           ),
//                         ),
//                         CircleAvatar(
//                           backgroundColor: Cores.corPadrao,
//                           child: const Icon(
//                             Icons.edit,
//                             color: Colors.white,
//                             // size: 15,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Divider(color: Cores.corPadrao),
//                 Container(
//                   margin: const EdgeInsets.all(5),
//                   padding: const EdgeInsets.all(5),
//                   color: Colors.black12,
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 10, right: 10),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Flexible(
//                           child: TextoFormatadoLista(
//                             titulo: 'Valor Total',
//                             texto: formatacao.format(double.parse(store.valorTotalItens.toString())),
//                           ),
//                         ),
//                         Flexible(
//                           child: TextoFormatadoLista(
//                             textAlign: TextAlign.end,
//                             titulo: 'Qtde Itens',
//                             texto: store.pedidositens.length.toString(),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const Divider(),
//                 ListView.builder(
//                   physics: const NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   itemCount: store.pedidositens.isEmpty ? 0 : store.pedidositens.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     var item = store.pedidositens[index];
//                     return ListTile(
//                       title: Text(item.DESCRICAOCOMPLETA!),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           Text(item.CODIGOEAN!),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Flexible(
//                                 child: Text(
//                                   'Qtde: ${formatacao.format(
//                                         double.parse(item.QUANTIDADE!),
//                                       ).replaceAll('R\$', '')}',
//                                 ),
//                               ),
//                               Flexible(
//                                 child: Text(
//                                   'Valor: ${formatacao.format(
//                                     double.parse(item.VALORTOTAL!),
//                                   )}',
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             'Valor unit.: ${formatacao.format(
//                               double.parse(
//                                 item.VALORUNITARIO!.toString(),
//                               ),
//                             )}',
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//           floatingActionButton: FloatingActionButton(
//             onPressed: () async {
//               comumPrint.connected ? await comumPrint.printTicket(store) : null;
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => ImpressaoConfiguracaoScreen(store: store),
//                 ),
//               );
//             },
//             child: const Icon(Icons.print),
//           ),
//         ),
//       ),
//     );
//   }
// }
