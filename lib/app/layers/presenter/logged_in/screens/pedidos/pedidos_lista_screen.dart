import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:connect_force_app/app/common/styles/app_styles.dart';
import 'package:connect_force_app/app/common/utils/functions.dart';
import 'package:connect_force_app/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:connect_force_app/app/layers/presenter/logged_in/screens/pedidos/pedidos_impressao_screen.dart';
import 'package:connect_force_app/app/layers/presenter/logged_in/screens/pedidos/pedidos_novo_screen.dart';
import 'package:connect_force_app/app/layers/presenter/providers/data_provider.dart';
import 'package:connect_force_app/navigation.dart';
import 'package:provider/provider.dart';

class PedidosListaScreen extends StatefulWidget {
  const PedidosListaScreen({super.key});

  static const String route = "pedidos_lista_screen";

  @override
  State<PedidosListaScreen> createState() => _PedidosListaScreenState();
}

class _PedidosListaScreenState extends State<PedidosListaScreen> {
  final Databasepadrao banco = Databasepadrao.instance;
  bool isScreenLocked = false;
  late DataProvider dataProvider;
  late Future<void> future;
  final appStyles = AppStyles();
  List listaPedidos = [];
  List listaFiltrada = [];
  final TextEditingController _filtroController = TextEditingController();

  // Variáveis para filtros
  String filtroNome = '';
  String filtroTipo = '';
  String filtroIdPedido = '';
  double? filtroValorMin;
  double? filtroValorMax;

  Future<void> initScreen() async {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    listaPedidos = await banco.listarPedidos();
    // print(jsonEncode(listaPedidos.first));
    listaFiltrada = listaPedidos; // Inicialmente, a lista filtrada é igual à lista completa
    setState(() {});
  }

  void filtrarPedidos() {
    setState(() {
      listaFiltrada = listaPedidos.where((pedido) {
        final nomeCliente = pedido['NOMECLI']?.toString().toLowerCase() ?? '';
        final tipoPedido = pedido['TIPO']?.toString().toLowerCase() ?? '';
        final idPedido = pedido['IDPEDIDO']?.toString() ?? '';
        final valorTotal = pedido['VALORTOTAL'] as double? ?? 0.0;

        // Aplicar filtros
        bool matchesNome = nomeCliente.contains(filtroNome.toLowerCase());
        bool matchesTipo = tipoPedido.contains(filtroTipo.toLowerCase());
        bool matchesId = idPedido.contains(filtroIdPedido);
        bool matchesValor = true;

        if (filtroValorMin != null && filtroValorMax != null) {
          matchesValor = valorTotal >= filtroValorMin! && valorTotal <= filtroValorMax!;
        } else if (filtroValorMin != null) {
          matchesValor = valorTotal >= filtroValorMin!;
        } else if (filtroValorMax != null) {
          matchesValor = valorTotal <= filtroValorMax!;
        }

        return matchesNome && matchesTipo && matchesId && matchesValor;
      }).toList();
    });
  }

  void abrirModalDetalhes(BuildContext context, Map<String, dynamic> pedido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Detalhes do Pedido",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Valor Total: R\$ ${pedido['VALORTOTAL']?.toStringAsFixed(2) ?? '0.00'}",
                style: const TextStyle(
                  fontSize: 15,
                  // color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Cliente: ${pedido['NOMECLI'] ?? 'Não informado'}"),
              Text("ID Pedido: ${pedido['IDPEDIDO']}"),
              Text("Tipo: ${pedido['TIPO']}"),
              Text("Data: ${formatDate(pedido['DATAHORA'])}"),
              if (pedido['TIPOPEDIDO'] == 'C') ...[
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Função para impressão
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text("Editar"),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Função para impressão
                    Navigator.pop(context);
                    // push(context, PedidosImpressaoScreen());
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: const Text("Imprimir"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void abrirDialogFiltros(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Filtrar Pedidos"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Nome do Cliente"),
                  onChanged: (value) {
                    filtroNome = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Tipo (Pedido/Condicional)"),
                  onChanged: (value) {
                    filtroTipo = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "ID do Pedido"),
                  onChanged: (value) {
                    filtroIdPedido = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Valor Mínimo"),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    filtroValorMin = double.tryParse(value);
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Valor Máximo"),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    filtroValorMax = double.tryParse(value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                filtrarPedidos();
                Navigator.of(context).pop();
              },
              child: const Text("Aplicar Filtros"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    future = initScreen();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lista de Pedidos"),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                abrirDialogFiltros(context);
              },
            ),
          ],
        ),
        body: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (listaFiltrada.isEmpty) {
              return const Center(
                child: Text("Nenhum pedido encontrado."),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: listaFiltrada.length,
              itemBuilder: (context, index) {
                final pedido = listaFiltrada[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      pedido['NOMECLI'] ?? 'Cliente não informado',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          "Total: R\$ ${pedido['VALORTOTAL']?.toStringAsFixed(2) ?? '0.00'}",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "ID Pedido: ${pedido['IDPEDIDO']}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "Tipo: ${pedido['TIPO']}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "Data: ${formatDate(pedido['DATAHORA'])}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      abrirModalDetalhes(context, pedido);
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: const Text("Novo Pedido"),
          onPressed: () async {
            await push(context, const PedidosNovoScreen());
            future = initScreen();
          },
        ),
      ),
    );
  }
}
