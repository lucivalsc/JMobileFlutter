import 'package:brasil_fields/brasil_fields.dart';
import 'package:connect_force_app/app/common/utils/functions.dart';
import 'package:connect_force_app/app/common/widgets/text_field_date.dart';
import 'package:connect_force_app/app/common/widgets/text_field_dropdown.dart';
import 'package:connect_force_app/app/common/widgets/text_field_widget.dart';
import 'package:connect_force_app/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:connect_force_app/app/layers/presenter/logged_in/screens/pedidos/pedidos_impressao_screen.dart';
import 'package:connect_force_app/app/layers/presenter/providers/data_provider.dart';
import 'package:connect_force_app/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PedidosFecharScreen extends StatefulWidget {
  final Map cliente;
  final List listaProdutos;
  final Map? oldPedido;
  const PedidosFecharScreen({
    super.key,
    required this.cliente,
    required this.listaProdutos,
    this.oldPedido,
  });

  @override
  State<PedidosFecharScreen> createState() => _PedidosFecharScreenState();
}

class _PedidosFecharScreenState extends State<PedidosFecharScreen> {
  final Databasepadrao banco = Databasepadrao.instance;
  late DataProvider dataProvider;
  late Future<void> future;
  // Controladores
  TextEditingController descontoContoller = TextEditingController(text: '0');
  TextEditingController valorEntradaContoller = TextEditingController(text: '0');
  TextEditingController inicioVencimentoContoller =
      TextEditingController(text: DateFormat('dd/MM/yyyy').format(DateTime.now().add(Duration(days: 30))));
  TextEditingController numeroParcelasContoller = TextEditingController(text: '1 parcela');
  TextEditingController observacaoContoller = TextEditingController();
  Map usuario = {};
  // Variáveis de estado
  Map selectedTipoPedido = {'id': 1, 'text': 'Pedido'};
  Map selectedNumeroParcela = {'id': 1, 'text': '1 parcela'};
  List<Map<String, dynamic>> parcelas = [];

  // Listas de opções
  final List<Map<String, dynamic>> tipoPedido = [
    {'id': 1, 'text': 'Pedido'},
    {'id': 2, 'text': 'Condicional'},
  ];

  final List<Map<String, dynamic>> numeroParcela = List.generate(24, (index) {
    return {
      'id': index + 1,
      'text': index + 1 == 1 ? '1 parcela' : '${index + 1} parcelas',
    };
  });

  Future<void> preecherVariaveis() async {
    if (widget.oldPedido != null) {
      inicioVencimentoContoller.text = widget.oldPedido!['INICIO_VENCIMENTO'] ??
          DateFormat('dd/MM/yyyy').format(DateTime.now().add(Duration(days: 30)));
      descontoContoller.text = widget.oldPedido!['DESCONTO'].toString();
      valorEntradaContoller.text = widget.oldPedido!['VALORENTRADA'].toString();
      observacaoContoller.text = widget.oldPedido!['OBSPEDIDO'] ?? '';
      selectedTipoPedido = tipoPedido.firstWhere(
        (element) => element['id'] == (widget.oldPedido!['TIPO_PEDIDO'] == 'P' ? 2 : 1),
      );
      // selectedNumeroParcela = numeroParcela.firstWhere(
      //   (element) => element['id'] == widget.oldPedido!['PRAZOPAGTO'].toInt(),
      // );
    }
  }

  // Método para gerar as parcelas
  void gerarParcelas() {
    parcelas.clear();
    double valorTotalComDesconto = getValorComDescontoEentrada();
    int numeroParcelas = selectedNumeroParcela['id'] ?? 1;
    DateTime dataVencimento = formatarData(inicioVencimentoContoller.text);

    if (numeroParcelas > 0) {
      double valorParcela = valorTotalComDesconto / numeroParcelas;

      for (int i = 0; i < numeroParcelas; i++) {
        parcelas.add({
          'parcela': '${i + 1}/$numeroParcelas',
          'dataVencimento': dataVencimento.add(Duration(days: 30 * i)).toString().split(' ')[0],
          'valor': valorParcela.toStringAsFixed(2),
        });
      }
    }

    setState(() {});
  }

  // Métodos para cálculos
  double getValorTotal() {
    return widget.listaProdutos.fold(0, (sum, item) => sum + (item['VALOR_TOTAL'] ?? 0));
  }

  int getQuantidadeTotal() {
    return widget.listaProdutos.fold(0, (sum, item) {
      final quantidade = item['QUANTIDADE'];
      return sum + (quantidade is int ? quantidade : 0);
    });
  }

  String getValorSemVirgula(String valor) {
    return valor.replaceAll('.', '').replaceAll(',', '.');
  }

  double getValorComDescontoEentrada() {
    double valorTotal = getValorTotal();
    double desconto = double.tryParse(getValorSemVirgula(descontoContoller.text)) ?? 0;
    double entrada = double.tryParse(getValorSemVirgula(valorEntradaContoller.text)) ?? 0;
    return valorTotal - desconto - entrada;
  }

  // Método para formatar o valor com duas casas decimais
  void formatarValor(TextEditingController controller) {
    String text = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isEmpty) {
      controller.text = '';
      return;
    }
    double value = double.parse(text) / 100;
    controller.text = value.toStringAsFixed(2);
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
  }

  // Método para fechar o pedido
  Future<void> fecharPedido() async {
    try {
      // Verifica se está editando um pedido existente
      if (widget.oldPedido != null) {
        await banco.deleteId('MOBILE_ITEMPEDIDO', 'IDPEDIDO', widget.oldPedido!['IDPEDIDO'].toString());
        await banco.deleteId('MOBILE_PEDIDO', 'IDPEDIDO', widget.oldPedido!['IDPEDIDO'].toString());
      }

      // Verifica se o cliente é novo
      final clienteNovo = await banco.cliente(widget.cliente['CODCLI'].toString());

      // final isClienteNovo = clienteNovo.isNotEmpty ? '1' : '0';
      final isClienteNovo = clienteNovo != null ? '1' : '0';

      // Insere o pedido na tabela MOBILE_PEDIDO
      final idPedido = await banco.dataInsertClient(
        'MOBILE_PEDIDO',
        {
          // 'IDPEDIDO': '', // Novo campo
          'IDPEDIDOERP': '0', // Já existia
          'IDEMPRESA': usuario['CODEMPRESA'],
          'IDUSUARIO': usuario['CODIGO'],
          'IDCLIENTE': widget.cliente['CODCLI'].toString().padLeft(8, '0'),
          'PRAZOPAGTO': selectedNumeroParcela['id'].toString(),
          // 'DATAMOBILE': DateFormat('yyyy-MM-dd').format(DateTime.now()), // Novo campo
          'INICIO_VENCIMENTO': DateFormat('yyyy-MM-dd').format(formatarData(inicioVencimentoContoller.text)),
          'OBSPEDIDO': observacaoContoller.text.isNotEmpty ? observacaoContoller.text : ' ',
          'VALOR': double.tryParse(getValorSemVirgula(descontoContoller.text)) ?? 0,
          'DESCONTO': double.tryParse(getValorSemVirgula(descontoContoller.text)) ?? 0,
          'VALORTOTAL': getValorComDescontoEentrada(),
          'VALORENTRADA': double.tryParse(getValorSemVirgula(valorEntradaContoller.text)) ?? 0,
          'STATUSPEDIDOERP': '0', // Novo campo
          'CLI_NOME': widget.cliente['NOMECLI'],
          'CLI_CPF': widget.cliente['CPF'],
          'DATAHORA': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()), // Formata a data atual
          'CLIENTENOVO': isClienteNovo,
          'COUNT_ITEMPEDIDO': widget.listaProdutos.length,
          'TIPOPEDIDO': selectedTipoPedido['id'] == 1 ? 'P' : 'C',
          'LATITUDE': dataProvider.latitudeController.text.isEmpty ? '0' : dataProvider.latitudeController.text,
          'LONGITUDE': dataProvider.longitudeController.text.isEmpty ? '0' : dataProvider.longitudeController.text,
        },
      );

      // Insere os itens do pedido na tabela MOBILE_ITEMPEDIDO
      for (var produto in widget.listaProdutos) {
        await banco.dataInsertLista(
          'MOBILE_ITEMPEDIDO',
          [
            {
              // 'IDITEMPEDIDO': '', // Novo campo
              'IDUSUARIO': usuario['CODIGO'],
              'IDITEMPEDIDOERP': '0',
              'IDPEDIDO': idPedido,
              'IDPRODUTO': produto['CODPROD'],
              'QTDE': produto['QUANTIDADE'],
              'VALORUNITARIO': produto['PRECO'],
              'VALORTOTAL': produto['VALOR_TOTAL'],
              // 'DATAHORAMOBILE': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
            }
          ],
        );
      }

      // Limpa os campos após fechar o pedido
      limparCampos();

      // Exibe feedback para o usuário
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Pedido Fechado'),
            content: Text('Deseja imprimir este pedido?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  push(context, PedidosImpressaoScreen(idPedido: idPedido));
                },
                child: Text('Sim'),
              ),
              TextButton(
                onPressed: () {
                  // Navega para a tela de lista de pedidos
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Não'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  // Método para limpar os campos
  void limparCampos() {
    descontoContoller.clear();
    valorEntradaContoller.clear();
    inicioVencimentoContoller.clear();
    numeroParcelasContoller.clear();
    observacaoContoller.clear();
    setState(() {
      selectedTipoPedido = {};
      selectedNumeroParcela = {};
      parcelas.clear();
    });
  }

  Future<void> initScreen() async {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    usuario = await dataProvider.loadDataToSend(uri: 'login');
    await preecherVariaveis();
    gerarParcelas();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    future = initScreen();
    // Adicionar listeners para atualizar as parcelas quando os campos mudarem
    // descontoContoller.addListener(() {
    //   formatarValor(descontoContoller);
    //   gerarParcelas();
    // });
    // valorEntradaContoller.addListener(() {
    //   formatarValor(valorEntradaContoller);
    //   gerarParcelas();
    // });
    // inicioVencimentoContoller.addListener(gerarParcelas);
  }

  @override
  void dispose() {
    descontoContoller.dispose();
    valorEntradaContoller.dispose();
    inicioVencimentoContoller.dispose();
    numeroParcelasContoller.dispose();
    observacaoContoller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fechar Pedido"),
      ),
      body: ListView(
        children: [
          Container(
            height: 70,
            width: double.infinity,
            color: Colors.grey.shade300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Valor Total: R\$ ${getValorTotal().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Valor Final: R\$ ${getValorComDescontoEentrada().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Qtde Itens: ${getQuantidadeTotal()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      child: TextFieldWidget(
                        label: 'Desconto',
                        controller: descontoContoller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CentavosInputFormatter(casasDecimais: 2),
                        ],
                        onChanged: (value) => gerarParcelas(),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: TextFieldWidget(
                        label: 'Valor Entrada',
                        controller: valorEntradaContoller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CentavosInputFormatter(casasDecimais: 2),
                        ],
                        onChanged: (value) => gerarParcelas(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(
                      child: TextFieldDate(
                        label: 'Início do Vencimento',
                        controller: inicioVencimentoContoller,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: TextFieldDropdown(
                        label: 'Número de Parcelas',
                        value: 'text',
                        id: 'id',
                        items: numeroParcela,
                        initialValue: selectedNumeroParcela['id'].toString(),
                        onItemSelected: (selectedItem) {
                          setState(() {
                            selectedNumeroParcela = selectedItem;
                            gerarParcelas();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(
                      child: TextFieldDropdown(
                        label: 'Tipo de Pedido',
                        value: 'text',
                        id: 'id',
                        items: tipoPedido,
                        initialValue: selectedTipoPedido['id'].toString(),
                        onItemSelected: (selectedItem) {
                          setState(() {
                            selectedTipoPedido = selectedItem;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(
                      child: TextFieldWidget(
                        label: 'Observação',
                        controller: observacaoContoller,
                        height: 100,
                        maxLines: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Lista de parcelas
                if (parcelas.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Parcelas:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ...parcelas.map((parcela) {
                        return ListTile(
                          title: Text('Parcela ${parcela['parcela']}'),
                          subtitle: Text('Vencimento: ${formatDate(parcela['dataVencimento'])}'),
                          trailing: Text(
                            'R\$ ${parcela['valor']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "btnSalvar",
        label: const Text("Fechar Pedido"),
        onPressed: fecharPedido,
      ),
    );
  }
}
