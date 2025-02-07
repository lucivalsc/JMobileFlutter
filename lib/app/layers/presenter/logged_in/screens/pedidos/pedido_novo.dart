// import 'package:jmobileflutter/app/common/comum.dart';
// import 'package:jmobileflutter/app/common/padrao.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:intl/intl.dart';
// import 'package:uuid/uuid.dart';

// import 'package:jmobileflutter/app/layers/data/datasources/local/banco_controller.dart';
// import 'package:jmobileflutter/app/common/theme/cores.dart';
// import 'package:jmobileflutter/app/common/theme/my_app_bar.dart';
// import 'package:jmobileflutter/app/common/theme/texto_formatado_lista.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/cadastro/clientes/clientes.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/cadastro/condicao_pagamento/condicao_pagamento.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/comercial/pedidos/pedido_comum.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/comercial/pedidos/pedido_produtos.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/comercial/pedidos/pedido_store.dart';

// class PedidoNovo extends StatefulWidget {
//   final String? guidOld;
//   final String? cnpjOld;
//   final String? codigoCondicaoOld;
//   const PedidoNovo({
//     super.key,
//     this.guidOld,
//     this.cnpjOld,
//     this.codigoCondicaoOld,
//   });

//   @override
//   State<PedidoNovo> createState() => _PedidoNovoState();
// }

// class _PedidoNovoState extends State<PedidoNovo> {
//   Databasepadrao banco = Databasepadrao.instance;
//   NumberFormat formatacao = NumberFormat.simpleCurrency(locale: 'pt_BR');
//   var uuid = const Uuid();
//   PedidoStore store = PedidoStore();
//   PedidoComum pedidoComum = PedidoComum();
//   Comum comum = Comum();
//   final msgControllerValorVerba = TextEditingController();

//   gerarGuid() async {
//     if (widget.guidOld == null) {
//       //Gera uma guid nova e passa o valor para guid na store
//       store.uuGuidAtual(uuid.v1());
//     } else {
//       store.guid = widget.guidOld;
//       await store.listaPedidosVerba(widget.guidOld);
//       await store.listarPedidosItens(widget.guidOld);
//       await store.retornarCliente(widget.cnpjOld);
//       if (widget.codigoCondicaoOld != null) await store.retornarCondicaoPg(widget.codigoCondicaoOld);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     gerarGuid();
//     store.retornarVerba(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     double padLeft = 7.0;
//     double padRight = 7.0;
//     double padTop = 0.1;
//     double padBottom = 0.1;

//     return WillPopScope(
//       onWillPop: () => pedidoComum.requestPop(context, store),
//       child: SafeArea(
//         child: Observer(
//           builder: (_) => Scaffold(
//             backgroundColor: Cores.corBarraStatus,
//             body: Column(
//               children: [
//                 const Cabecalho(),
//                 const MyAppBar(texto: 'Novo Pedido'),
//                 Divider(color: Cores.corPadrao),
//                 InkWell(
//                   child: Padding(
//                     padding: EdgeInsets.fromLTRB(padLeft, padTop, padRight, padBottom),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               TextoFormatadoLista(
//                                 titulo: 'Razão Social:',
//                                 texto: store.razaoSocial,
//                               ),
//                               TextoFormatadoLista(
//                                 titulo: 'CNPJ/CPF:',
//                                 texto: inMostraLogo ? store.cnpj : '',
//                               ),
//                             ],
//                           ),
//                         ),
//                         const Center(
//                           child: Icon(Icons.search),
//                         )
//                       ],
//                     ),
//                   ),
//                   onTap: () async {
//                     var retorno = await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const Clientes(retorno: true),
//                       ),
//                     );
//                     if (retorno != null) {
//                       store.clientes = retorno;
//                       store.razaoSocial = store.clientes.PESSOADESCRICAO!;
//                       store.cnpj = store.clientes.CNPJCPF!;
//                       if (store.clientes.CODIGOCONDICAO != null) store.retornarCondicao();
//                     }
//                   },
//                 ),
//                 Divider(color: Cores.corPadrao),
//                 InkWell(
//                   child: Padding(
//                     padding: EdgeInsets.fromLTRB(padLeft, padTop, padRight, padBottom),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: TextoFormatadoLista(
//                             titulo: 'Condição de pagamento:',
//                             texto: store.listaPrazoPagamentoAtiva!,
//                           ),
//                         ),
//                         const Center(
//                           child: Icon(Icons.search),
//                         )
//                       ],
//                     ),
//                   ),
//                   onTap: () async {
//                     var retorno = await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const CondicaoPagamento(retorno: true),
//                       ),
//                     );
//                     if (retorno != null) {
//                       store.condicao = retorno;
//                       store.listaPrazoPagamentoAtiva = store.condicao.DESCRICAO!;
//                     }
//                   },
//                 ),
//                 Divider(color: Cores.corPadrao),
//                 Container(
//                   margin: const EdgeInsets.all(1),
//                   padding: const EdgeInsets.all(2),
//                   color: Colors.black12,
//                   child: Padding(
//                     padding: EdgeInsets.fromLTRB(padLeft, padTop, padRight, padBottom),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         Flexible(
//                           child: TextoFormatadoLista(
//                             titulo: 'Verba',
//                             texto: formatacao.format(double.parse(store.valorVerba.toString())),
//                           ),
//                         ),
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
//                 Divider(color: Cores.corPadrao),
//                 store.pedidositens.isNotEmpty
//                     ? Expanded(
//                         child: ListView.builder(
//                           itemCount: store.pedidositens.length,
//                           itemBuilder: (BuildContext context, int index) {
//                             var item = store.pedidositens[index];
//                             return ListTile(
//                               title: Text(item.DESCRICAOCOMPLETA!),
//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                                 children: [
//                                   Text(item.CODIGOEAN!),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Flexible(
//                                         child: Text(
//                                           'Qtde: ${formatacao.format(double.parse(item.QUANTIDADE!)).replaceAll('R\$', '')}',
//                                         ),
//                                       ),
//                                       Flexible(
//                                         child: Text(
//                                           'Valor: ${formatacao.format(
//                                             double.parse(item.VALORTOTAL!),
//                                           )}',
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Text(
//                                     'Valor unit.: ${formatacao.format(
//                                       double.parse(
//                                         item.VALORUNITARIO!.toString(),
//                                       ),
//                                     )}',
//                                   ),
//                                 ],
//                               ),
//                               onTap: () {
//                                 store.quantidade = double.parse(item.QUANTIDADE!);
//                                 store.valorProduto = double.parse(item.VALORUNITARIO!);
//                                 store.calcular();
//                                 pedidoComum.showModalNovoAtualizar(
//                                   context,
//                                   item,
//                                   index,
//                                   store,
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       )
//                     : Container(),
//               ],
//             ),
//             floatingActionButton: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 FloatingActionButton(
//                   heroTag: 1,
//                   onPressed: () async {
//                     comum.addObservacao(store.observacao, context);
//                   },
//                   child: const Icon(Icons.note_add),
//                 ),
//                 const SizedBox(height: 15),
//                 FloatingActionButton(
//                   heroTag: 2,
//                   onPressed: () async {
//                     await salvar();
//                   },
//                   child: const Icon(Icons.save),
//                 ),
//                 const SizedBox(height: 15),
//                 FloatingActionButton(
//                   heroTag: 3,
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => PedidosProdutos(
//                           carrinho: store,
//                         ),
//                       ),
//                     );
//                   },
//                   child: const Icon(Icons.shopping_basket),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   salvar() async {
//     if (store.razaoSocial != '') {
//       if (store.listaPrazoPagamentoAtiva != '') {
//         if (store.pedidositens.isNotEmpty) {
//           if (widget.guidOld != null) {
//             //TODO: Voltar aki
//             ///Deletar pedido e produtos do pedido
//             await banco.deletar('PEDVENDA', 'GUID', widget.guidOld);
//             await banco.deletar('PRODPEDVENDA', 'GUID', widget.guidOld);
//             await banco.deletar('VERBA', 'GUID_PEDIDO', widget.guidOld);
//           }
//           await store.calcularValorTotal();
//           await store.calcularValorVerba();
//           await store.inserirPedido();
//           await store.salvarPedido();
//           await store.salvarVerbaCalculada();
//           store.valorVerbaPedidoAtual = 0;
//           Navigator.pop(context);
//         } else {
//           pedidoComum.mensagem(
//             context,
//             'A lista de produtos não pode estar vazia.',
//           );
//         }
//       } else {
//         pedidoComum.mensagem(context, 'Escolha uma condição de pagamento.');
//       }
//     } else {
//       pedidoComum.mensagem(context, 'Escolha um cliente.');
//     }
//   }
// }
