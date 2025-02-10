import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:connect_force_app/app/common/styles/app_styles.dart';
import 'package:connect_force_app/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:connect_force_app/app/layers/data/models/debouncer_model.dart';
import 'package:connect_force_app/app/layers/presenter/logged_in/screens/clientes/clientes_cadastro_screen.dart';
import 'package:connect_force_app/navigation.dart';

class ClientesListaScreen extends StatefulWidget {
  final bool? isFromPedido;
  const ClientesListaScreen({super.key, this.isFromPedido = false});

  static const String route = "clientes_lista_screen";

  @override
  State<ClientesListaScreen> createState() => _ClientesListaScreenState();
}

class _ClientesListaScreenState extends State<ClientesListaScreen> {
  Databasepadrao banco = Databasepadrao.instance;
  Debouncer debouncer = Debouncer(milliseconds: 500);
  AppStyles appStyles = AppStyles();

  late Future<void> future;
  List listaCliente = [];
  List listaFiltrada = [];

  TextEditingController searchController = TextEditingController();

  Future<void> initScreen() async {
    listaCliente = await banco.dataReturnCliente();
    print(jsonEncode(listaCliente.first));
    setState(() {
      listaFiltrada = List.from(listaCliente);
      listaFiltrada.sort((a, b) => a["NOMECLI"].toString().compareTo(b["NOMECLI"].toString()));
    });
  }

  void filterClientes(String query) {
    listaFiltrada = listaCliente.where((cliente) {
      final nome = cliente["NOMECLI"].toString().toLowerCase();
      final cpf = cliente["CPF"].toString();
      // final flag = cliente["FLAGNAOVENDER"];
      return nome.contains(query.toLowerCase()) || cpf.contains(query); // || flag.contains('Y');
    }).toList();
    listaFiltrada.sort((a, b) => a["NOMECLI"].toString().compareTo(b["NOMECLI"].toString()));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    future = initScreen();
    searchController.addListener(() {
      debouncer.run(() {
        filterClientes(searchController.text);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Scaffold(
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text("Lista de Clientes"),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(45),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Pesquisar por nome ou CPF",
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.black),
                              onPressed: () {
                                searchController.clear();
                                filterClientes('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            body: ListView.builder(
              itemCount: listaFiltrada.length,
              itemBuilder: (BuildContext context, int index) {
                var item = listaFiltrada[index];
                return InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Escolha a ação para ${item['NOMECLI']}!'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [],
                          ),
                          actions: [
                            TextButton(
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: appStyles.primaryColor,
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            if (!widget.isFromPedido!) ...[
                              // TextButton(
                              //   child: Text(
                              //     'Ver Detalhes',
                              //     style: TextStyle(
                              //       color: appStyles.primaryColor,
                              //     ),
                              //   ),
                              //   onPressed: () {
                              //     Navigator.of(context).pop();
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (_) => ClientesCadastroScreen(cliente: item),
                              //       ),
                              //     );
                              //   },
                              // ),
                              TextButton(
                                child: Text(
                                  'Visualizar',
                                  style: TextStyle(
                                    color: appStyles.primaryColor,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ClientesCadastroScreen(cliente: item),
                                    ),
                                  );
                                },
                              ),
                            ],
                            if (widget.isFromPedido!) ...[
                              TextButton(
                                child: Text(
                                  'Selecionar',
                                  style: TextStyle(
                                    color: appStyles.primaryColor,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(item);
                                  Navigator.of(context).pop(item);
                                },
                              ),
                            ],
                          ],
                        );
                      },
                    );
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(
                        item['NOMECLI'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Endereço: ${item['ENDERECO']} - ${item['BAIRRO']} - ${item['CIDADE']} - ${item['ESTADO']} - ${item['CEP']}"),
                          Text("Telefone: ${item['TELEFONE']}"),
                          Text("Documento: ${item['CPF']}"),
                          if (item['FLAGNAOVENDER'] == 'Y') ...[
                            const SizedBox(height: 5),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              child: const Text(
                                'Não Vender',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                var result = await push(context, ClientesCadastroScreen());
                if (result != null) {
                  future = initScreen();
                }
              },
              label: const Text('Novo Cliente'),
              icon: const Icon(Icons.add),
            ),
          );
        });
  }
}
