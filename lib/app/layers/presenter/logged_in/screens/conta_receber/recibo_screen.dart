import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:connect_force_app/app/common/widgets/text_field_dropdown.dart';
import 'package:connect_force_app/app/layers/presenter/logged_in/screens/conta_receber/item_data_recibo_widget.dart';
import 'package:provider/provider.dart';
import 'package:connect_force_app/app/common/styles/app_styles.dart';
import 'package:connect_force_app/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:connect_force_app/app/layers/presenter/providers/data_provider.dart';

class ReciboScreen extends StatefulWidget {
  final Map cliente;
  const ReciboScreen({
    super.key,
    required this.cliente,
  });

  static const String route = "recibo_screen";

  @override
  State<ReciboScreen> createState() => _ReciboScreenState();
}

class _ReciboScreenState extends State<ReciboScreen> {
  final Databasepadrao banco = Databasepadrao.instance;
  late DataProvider dataProvider;
  late Future<void> future;
  final appStyles = AppStyles();
  List listaReceber = [];
  List listaFiltrada = [];
  final TextEditingController searchController = TextEditingController();

  // Variáveis de estado para filtros
  Map<String, dynamic>? selectedTipoPedido;

  @override
  void initState() {
    super.initState();
    future = initScreen();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> initScreen({String flag = 'S'}) async {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    listaReceber = await banco.listarRecibo(codCli: widget.cliente['CODCLI'].toString(), flag: flag);
    listaFiltrada = listaReceber;

    setState(() {});
  }

  String? formaPagamentoSelecionada = 'Dinheiro';

  void abrirModalDetalhes(BuildContext context, Map<String, dynamic> pedido) {
    // Controladores para os campos do formulário
    final TextEditingController valorPagoController = TextEditingController(
      text: double.tryParse(pedido['VALOR'].toString())?.toStringAsFixed(2) ?? '0.00',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite controle de rolagem
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets, // Ajusta o modal ao teclado
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Garante que o modal ocupe apenas o espaço necessário
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exibição dos detalhes do pedido
                  ItemDataReciboWidget(pedido: pedido),

                  const SizedBox(height: 20),

                  // Campo para digitar o valor pago
                  TextField(
                    controller: valorPagoController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Valor Pago",
                      border: OutlineInputBorder(),
                      prefix: Text("R\$ "),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Título para as formas de pagamento
                  const Text(
                    "Forma de Pagamento",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  // Formas de pagamento organizadas em duas colunas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Coluna 1
                      Expanded(
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: const Text("Dinheiro"),
                              value: "Dinheiro",
                              groupValue: formaPagamentoSelecionada,
                              onChanged: (value) {
                                setState(() {
                                  formaPagamentoSelecionada = value;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text("Cartão"),
                              value: "Cartão",
                              groupValue: formaPagamentoSelecionada,
                              onChanged: (value) {
                                setState(() {
                                  formaPagamentoSelecionada = value;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text("Outros"),
                              value: "Outros",
                              groupValue: formaPagamentoSelecionada,
                              onChanged: (value) {
                                setState(() {
                                  formaPagamentoSelecionada = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      // Coluna 2
                      Expanded(
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: const Text("Pix"),
                              value: "Pix",
                              groupValue: formaPagamentoSelecionada,
                              onChanged: (value) {
                                setState(() {
                                  formaPagamentoSelecionada = value;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text("Depósito"),
                              value: "Depósito",
                              groupValue: formaPagamentoSelecionada,
                              onChanged: (value) {
                                setState(() {
                                  formaPagamentoSelecionada = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Botão "Receber"
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formaPagamentoSelecionada == null || valorPagoController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Preencha todos os campos!")),
                            );
                            return;
                          }

                          // Aqui você pode processar o pagamento
                          final valorPago = double.tryParse(valorPagoController.text);

                          final sucesso = await banco.registrarRecibo(
                            recibo: pedido,
                            valorRecebido: valorPago.toString(),
                            tipoPagamento: formaPagamentoSelecionada!,
                            latitude: double.tryParse(dataProvider.longitudeController.text) ?? 0.0,
                            longitude: double.tryParse(dataProvider.latitudeController.text) ?? 0.0,
                            idUsuario: pedido['CODIGO'],
                          );

                          if (sucesso) {
                            // Fecha o modal após o processamento
                            Navigator.pop(context);
                            future = initScreen();
                          } else {
                            print("Falha ao registrar recibo.");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text("Receber"),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5), // Espaçamento adicional para evitar cortes
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Recibo"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Text(
                    widget.cliente['DEVEDOR'] ?? 'Cliente não informado',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Código do cliente
                  Text(
                    "Código: ${widget.cliente['CODIGO'] ?? 'Não informado'}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Flexible(
                          child: TextFieldDropdown(
                            label: 'Situação',
                            value: 'text',
                            id: 'id',
                            items: dataProvider.tipoPedido,
                            onItemSelected: (selectedItem) {
                              setState(() {
                                selectedTipoPedido = selectedItem;
                                final flag = selectedItem['id'] == 1 ? 'N' : 'S';
                                future = initScreen(flag: flag);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (listaFiltrada.isEmpty) {
              return const Center(
                child: Text(
                  "Nenhuma parcela encontrada.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: listaFiltrada.length,
                    itemBuilder: (context, index) {
                      final pedido = listaFiltrada[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ItemDataReciboWidget(
                          pedido: pedido,
                          onTap: () => abrirModalDetalhes(context, pedido),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
