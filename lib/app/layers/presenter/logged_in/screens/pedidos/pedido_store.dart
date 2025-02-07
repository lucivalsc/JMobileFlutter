// import 'dart:convert';
// import 'package:jmobileflutter/app/common/utils/functions.dart';
// import 'package:jmobileflutter/app/common/padrao.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/sincronizar/verba/verba_model.dart';
// import 'package:http/http.dart' as http;
// import 'package:jmobileflutter/app/layers/data/datasources/local/banco_controller.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/comercial/pedidos/pedido_item_model.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/comercial/pedidos/pedido_model.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/sincronizar/clientes/clientes_model.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/sincronizar/condicao_pagamento/condicao_pagamento_model.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/sincronizar/produtos/produtos_model.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mobx/mobx.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// part 'pedidos/pedido_store.g.dart';

// class PedidoStore = _PedidoStoreBase with _$PedidoStore;

// abstract class _PedidoStoreBase with Store {
//   //NumberFormat formatacao = NumberFormat.simpleCurrency(locale: 'pt_BR');
//   Databasepadrao banco = Databasepadrao.instance;

//   ObservableList<List<ProdutosModel>> listaProdutos = ObservableList<List<ProdutosModel>>();

//   final pesquisar = TextEditingController();
//   final observacao = TextEditingController();
//   final descontoPercentual = TextEditingController();
//   final descontoValor = TextEditingController();

//   @observable
//   int indiceItemSelecionado = 0;

//   @observable
//   String mensagem = '';

//   @observable
//   String submensagem = '';

//   @observable
//   TextEditingController tecQuantidadeProduto = TextEditingController();

//   @observable
//   TextEditingController tecPrecoProduto = TextEditingController();

//   @observable
//   SingingCharacter? character = SingingCharacter.abertos;

//   @observable
//   TextEditingController tecQtdeItem = TextEditingController();

//   @observable
//   ClientesModel clientes = ClientesModel();

//   @observable
//   CondicaoPagamentoModel condicao = CondicaoPagamentoModel();

//   @observable
//   String? guid = '';

//   @action
//   uuGuidAtual(String value) => guid = value;

//   @observable
//   bool inLoading = true;

//   @action
//   iniciarLoading() => inLoading = !inLoading;

//   @observable
//   String? listaPrazoPagamentoAtiva = '';

//   @observable
//   String? razaoSocial = '';

//   @observable
//   String? cnpj = '';

//   @observable
//   String? limite = '';

//   @observable
//   double quantidade = 1;

//   @observable
//   double valorTotal = 0;

//   @observable
//   double valorProduto = 0;

//   @observable
//   double valorDesconto = 0;

//   @observable
//   double valorDescontoPerc = 0;

//   @observable
//   double valorTotalOld = 0;

//   @action
//   calcularDesconto() async {
//     // valorDesconto = double.tryParse(descontoValor.text) ?? 0;
//     // valorDescontoPerc = double.tryParse(descontoPercentual.text) ?? 0;
//     // valorTotalOld =
//     //     await (valorTotal - valorDesconto) * (valorDescontoPerc / 100);
//   }

//   @action
//   somar() {
//     quantidade++;
//     calcular();
//   }

//   @action
//   diminuir() {
//     if (quantidade > 1) quantidade--;
//     calcular();
//   }

//   @action
//   calcular() {
//     valorTotal = (valorProduto * quantidade);
//     valorTotalOld = (valorProduto * quantidade);
//     calcularValorTotal();
//   }

//   @observable
//   double valorTotalItens = 0;

//   @action
//   calcularValorTotal() {
//     valorTotalItens = 0;
//     for (var i = 0; i < pedidositens.length; i++) {
//       valorTotalItens = valorTotalItens + double.parse(pedidositens[i].VALORTOTAL!);
//     }
//   }

//   //Waldir - 23/02/2023
//   @action
//   calcularValorVerba() {
//     double verbaAtual = valorVerba + (valorVerbaExtorno * (-1));

//     for (var i = 0; i < verbaPedidoitens.length; i++) {
//       if (verbaPedidoitens[i].VALORVERBA! < 0) {
//         verbaAtual = verbaAtual + verbaPedidoitens[i].VALORVERBA!;
//       }
//     }

//     //TODO: Se der ruim voltar aki
//     valorVerba = verbaAtual;
//     valorVerbaExtorno = 0;
//   }

//   ObservableList<List<Map>> listaMapPedidos = ObservableList<List<Map>>();

//   @action
//   listaPedidos(String status, String pesquisa) async {
//     listaMapPedidos.clear();
//     await banco.listaPedidos(status, pesquisa).then(
//           (value) => listaMapPedidos.add(value),
//         );
//   }

//   @action
//   listarPedidos(guid, {String tabela = 'PEDVENDA'}) async {
//     pedido = PedidoModel();
//     await banco.retornarFiltrado(tabela, 'GUID', guid).then(
//           (value) => pedido = PedidoModel.fromJson(value[0]),
//         );
//   }

//   ObservableList<PedidoItemModel> pedidositens = ObservableList<PedidoItemModel>();
//   @action
//   listarPedidosItens(guid, {String tabela = 'PRODPEDVENDA'}) async {
//     pedidositens.clear();
//     var lista = await banco.listaPedidosItens(guid, tabela: tabela);
//     for (var item in lista) {
//       pedidositens.add(PedidoItemModel.fromJson(item));
//     }
//     calcularValorTotal();
//   }

//   @observable
//   double valorVerbaExtorno = 0;

//   removerLinhaVerbaPedidoItens(int indexListaPedidosItem) {
//     bool encontrou = false;
//     PedidoItemModel item;
//     VerbaModel? verba;
//     int i;

//     print(verbaPedidoitens.length);

//     if (indexListaPedidosItem >= 0) {
//       item = pedidositens[indexListaPedidosItem];

//       for (i = 0; i < verbaPedidoitens.length; i++) {
//         verba = verbaPedidoitens[i];

//         if (verba.GUIDPRODPEDVENDA == item.GUIDPRODPEDVENDA) {
//           encontrou = true;
//           break;
//         }
//       }

//       if ((encontrou) && (verba != null)) {
//         print(i);
//         print(item.DESCRICAOCOMPLETA);
//         print(item.GUID);
//         print(item.GUIDPRODPEDVENDA);
//         print(item.CODIGOEAN);
//         print(verba.GUIDPEDIDO);
//         print(verba.GUIDPRODPEDVENDA);

//         verbaPedidoitens.removeAt(i);
//       }
//     }
//   }

//   ObservableList<VerbaModel> verbaPedidoitens = ObservableList<VerbaModel>();
//   @action
//   listaPedidosVerba(guid) async {
//     VerbaModel verbaModel;

//     verbaPedidoitens.clear();
//     dynamic lista = await banco.listaPedidosVerba(guid);

//     for (var item in lista) {
//       verbaModel = VerbaModel.fromJson(item);
//       verbaPedidoitens.add(verbaModel);

//       if (verbaModel.OPERACAO == '-') {
//         valorVerbaExtorno = valorVerbaExtorno + (verbaModel.VALORVERBA ?? 0);
//       }
//     }
//   }

//   @action
//   retornarCliente(String? pesquisar) async {
//     var lista = await banco.retornarClientes(pesquisar);
//     if (lista.isNotEmpty) {
//       razaoSocial = lista[0].PESSOADESCRICAO;
//       cnpj = lista[0].CNPJCPF;
//       clientes = lista[0];
//       // retornarCondicao();
//     }
//   }

//   @action
//   retornarCondicaoPg(codigo) async {
//     var lista = await banco.condicaoPg(codigo);
//     if (lista.isNotEmpty) {
//       listaPrazoPagamentoAtiva = lista[0]['DESCRICAO']!;
//       condicao.DESCRICAO = lista[0]['DESCRICAO'];
//       condicao.CODIGOCONDICAO = lista[0]['CODIGOCONDICAO'];
//       condicao.FORA = lista[0]['FORA'];
//       condicao.QTDPARCELAS = lista[0]['QTDPARCELAS'];
//       condicao.DIASEMISSAO = lista[0]['DIASEMISSAO'];
//       condicao.DIASINTERVALO = lista[0]['DIASINTERVALO'];
//     }
//   }

//   @observable
//   PedidoModel pedido = PedidoModel();

//   @action
//   salvarPedido() async {
//     if (pedido.GUID != null) {
//       await banco.inserir('PEDVENDA', pedido);
//     }
//     if (pedidositens.isNotEmpty) {
//       for (var m in pedidositens) {
//         await banco.inserir('PRODPEDVENDA', m);
//       }
//     }
//     if (verbaPedidoitens.isNotEmpty) {
//       for (var m in verbaPedidoitens) {
//         await banco.inserir('VERBA', m);
//       }
//     }
//   }

//   //Waldir - 23/02/2023
//   @action
//   salvarVerbaCalculada() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String tipoUsuario = prefs.getString('TipoUsuario').toString();
//     int codUsuario = int.parse(prefs.getString('CodUsuario').toString());
//     String codLoja = prefs.getString('CodLoja').toString();

//     if (tipoUsuario == 'Vendedor') {
//       var verbaCalculada = VerbaModel();

//       verbaCalculada.CODIGOFILIAL = codLoja;
//       verbaCalculada.CODIGOVENDEDOR = codUsuario;
//       verbaCalculada.DATAOPERACAO = DateFormat.yMd().format(DateTime.now());
//       verbaCalculada.HORAOPERACAO = DateFormat.Hms().format(DateTime.now());
//       verbaCalculada.TIPOMOVIMENTO = 'VC'; //Verba calculada
//       verbaCalculada.VALORVERBA = valorVerba;

//       valorVerbaExtorno = 0;

//       await banco.inserir('VERBA', verbaCalculada);
//     }
//   }

//   @action
//   inserirPedido() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String codLoja = prefs.getString('CodLoja').toString();
//     pedido = PedidoModel();
//     pedido.DATAEMISSAO = DateFormat.yMd().format(DateTime.now());
//     pedido.SERIE = 'A';
//     pedido.TIPOPEDIDO = 'A';
//     pedido.DATAINCLUSAO = DateFormat.yMd().format(DateTime.now());
//     pedido.CODIGOCONDICAO = condicao.CODIGOCONDICAO;
//     pedido.CNPJCPF = clientes.CNPJCPF;
//     pedido.CODIGOVENDEDOR = prefs.getString('CodUsuario') ?? '-1';
//     pedido.CODIGOTABELA = clientes.CODIGOTABELAPRECO;
//     pedido.CARGA = '0';
//     pedido.STATUS = 'AB';
//     pedido.GUID = guid;
//     pedido.PERCENTUALDESCONTO = valorDescontoPerc.toString();
//     pedido.TOTALDESCONTO = valorDesconto.toString();
//     pedido.VALORTOTAL = valorTotalItens.toString();
//     pedido.OBSERVACAO = observacao.text;
//     pedido.CODIGOFILIAL = codLoja;
//   }

//   @action
//   retornar(String? pesquisar) async {
//     listaProdutos.clear();
//     await banco.retornarProdutos(pesquisar).then((value) => listaProdutos.add(value));
//   }

//   @action
//   retornarCondicao() async {
//     var resultado = await banco.retornarFiltrado(
//       'CONDICAOPGTO',
//       'CODIGOCONDICAO',
//       clientes.CODIGOCONDICAO!,
//     );
//     if (resultado.isNotEmpty && resultado[0].isNotEmpty) {
//       listaPrazoPagamentoAtiva = resultado[0]['DESCRICAO'];
//       condicao.DESCRICAO = resultado[0]['DESCRICAO'];
//       condicao.CODIGOCONDICAO = resultado[0]['CODIGOCONDICAO'];
//     }
//   }

//   List<dynamic> ProdPedVenda = [];
//   List<dynamic> PedVenda = [];
//   List<dynamic> Verba = [];

//   @action
//   listarRegistros(String guid) async {
//     PedVenda = await banco.retornarFiltrado('PEDVENDA', 'GUID', guid, colunaExcluida: 'IN_CLOUD');
//     ProdPedVenda = await banco.retornarFiltrado('PRODPEDVENDA', 'GUID', guid, colunaExcluida: 'IN_CLOUD');
//     Verba = await banco.retornarFiltrado('VERBA', 'GUID_PEDIDO', guid);
//   }

//   @action
//   enviarRegistros(String guid) async {
//     if (PedVenda.isNotEmpty) {
//       var url = Uri.parse('${await baseUrl()}pedidoVenda');

//       var body = jsonEncode({
//         "PedVenda": PedVenda,
//         "ProdPedVenda": ProdPedVenda,
//         "Verba": Verba,
//       });

//       final http.Response response = await http.post(
//         url,
//         headers: {'authorization': await basicAuth()},
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         banco.atualizarValor('PEDVENDA', 'GUID', guid, 'CO');
//       }
//     } else {
//       mensagem = 'Não existem itens para serem enviados.';
//     }
//   }

//   @observable
//   double msgValorVerba = 0;

//   @action
//   trocarMsgValorVerba(double value) => msgValorVerba = value;

//   @observable
//   double valorVerba = 0; //Esse valorVerba é exibido na tela de Novo Pedido

//   @observable
//   double valorVerbaPedidoAtual = 0;

//   //Waldir - 23/02/2023
//   @action
//   retornarVerba(BuildContext? context) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String tipoUsuario = prefs.getString('TipoUsuario').toString();
//     String codUsuario = prefs.getString('CodUsuario').toString();

//     if (tipoUsuario == 'Vendedor') {
//       valorVerba = double.parse(await banco.retornaVerba(codUsuario));
//     } else {
//       valorVerba = 0;
//     }
//   }
// }
