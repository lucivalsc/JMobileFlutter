import 'package:flutter/material.dart';
import 'package:jmobileflutter/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:jmobileflutter/app/layers/data/models/debouncer_model.dart';
import 'package:jmobileflutter/app/layers/presenter/logged_in/screens/clientes/clientes_cadastro_screen.dart';
import 'package:jmobileflutter/app/layers/presenter/logged_in/screens/vendas/vendas_registro_screen.dart';

class ClientesListaScreen extends StatefulWidget {
  final bool isFromPedido;
  const ClientesListaScreen({super.key, this.isFromPedido = false});

  static const String route = "clientes_lista_screen";

  @override
  State<ClientesListaScreen> createState() => _ClientesListaScreenState();
}

class _ClientesListaScreenState extends State<ClientesListaScreen> {
  Databasepadrao banco = Databasepadrao.instance;
  Debouncer debouncer = Debouncer(milliseconds: 500);

  late Future<void> future;
  List listaCliente = [];
  List listaFiltrada = [];

  TextEditingController searchController = TextEditingController();

  Future<void> initScreen() async {
    listaCliente = await banco.dataReturn("clientes");
    setState(() {
      listaFiltrada = List.from(listaCliente);
      listaFiltrada.sort((a, b) => a["NOMECLI"].toString().compareTo(b["NOMECLI"].toString()));
    });
  }

  void filterClientes(String query) {
    listaFiltrada = listaCliente.where((cliente) {
      final nome = cliente["NOMECLI"].toString().toLowerCase();
      final cpf = cliente["CPF"].toString();
      return nome.contains(query.toLowerCase()) || cpf.contains(query);
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
                            children: [
                              if (!widget.isFromPedido) ...[
                                TextButton(
                                  child: const Text('Registrar Venda'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => VendasRegistroScreen(cliente: item),
                                      ),
                                    );
                                  },
                                ),
                                TextButton(
                                  child: const Text('Editar'),
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
                              if (widget.isFromPedido) ...[
                                TextButton(
                                  child: const Text('Selecionar'),
                                  onPressed: () {
                                    Navigator.of(context).pop(item);
                                    Navigator.of(context).pop(item);
                                  },
                                ),
                              ],
                              TextButton(
                                child: const Text('Cancelar'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ClientesCadastroScreen(),
                  ),
                );
              },
              label: const Text('Novo Cliente'),
              icon: const Icon(Icons.add),
            ),
          );
        });
  }
}
