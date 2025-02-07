import 'package:flutter/material.dart';
import 'package:jmobileflutter/app/common/styles/app_styles.dart';
import 'package:jmobileflutter/app/common/widgets/app_widgets.dart';
import 'package:jmobileflutter/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:jmobileflutter/app/layers/data/models/debouncer_model.dart';

class ProdutosListaScreen extends StatefulWidget {
  final bool isFromPedido;
  const ProdutosListaScreen({super.key, this.isFromPedido = false});
  static const String route = "produtos_lista_screen";
  @override
  State<ProdutosListaScreen> createState() => ProdutosListaScreenState();
}

class ProdutosListaScreenState extends State<ProdutosListaScreen> {
  Databasepadrao banco = Databasepadrao.instance;
  Debouncer debouncer = Debouncer(milliseconds: 500);
  AppWidgets appWidgets = AppWidgets();
  AppStyles appStyles = AppStyles();
  late Future<void> future;
  List listaProdutos = [];
  List listaFiltrada = [];
  TextEditingController searchController = TextEditingController();

  Future<void> initScreen() async {
    listaProdutos = await banco.dataReturn("produtos");
    setState(() {
      listaFiltrada = List.from(listaProdutos);
      listaFiltrada.sort((a, b) => a["NOMEPROD"].toString().compareTo(b["NOMEPROD"].toString()));
    });
  }

  void filterProdutos(String query) {
    listaFiltrada = listaProdutos.where((produto) {
      final nome = produto["NOMEPROD"].toString().toLowerCase();
      final codigo = produto["CODIGO"].toString();
      return nome.contains(query.toLowerCase()) || codigo.contains(query);
    }).toList();
    listaFiltrada.sort((a, b) => a["NOMEPROD"].toString().compareTo(b["NOMEPROD"].toString()));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    future = initScreen();
    searchController.addListener(() {
      debouncer.run(() {
        filterProdutos(searchController.text);
      });
    });
  }

  void _openProductDetails(BuildContext context, Map<String, dynamic> item) {
    int quantidade = 1;
    double valorTotal = item['PRECO'] * quantidade;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['NOMEPROD'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Valor Unitário:"),
                      Text("R\$ ${item['PRECO'].toStringAsFixed(2)}"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Quantidade:"),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (quantidade > 1) {
                                setStateBottomSheet(() {
                                  quantidade--;
                                  valorTotal = item['PRECO'] * quantidade;
                                });
                              }
                            },
                          ),
                          Text("$quantidade"),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setStateBottomSheet(() {
                                quantidade++;
                                valorTotal = item['PRECO'] * quantidade;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          TextEditingController quantidadeController =
                              TextEditingController(text: quantidade.toString());
                          return AlertDialog(
                            title: const Text("Alterar Quantidade"),
                            content: TextField(
                              controller: quantidadeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "Quantidade"),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancelar"),
                              ),
                              TextButton(
                                onPressed: () {
                                  int novaQuantidade = int.tryParse(quantidadeController.text) ?? 1;
                                  setStateBottomSheet(() {
                                    quantidade = novaQuantidade;
                                    valorTotal = item['PRECO'] * quantidade;
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text("Aceitar"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Valor Total:"),
                        Text("R\$ ${valorTotal.toStringAsFixed(2)}"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      print(item);
                      Navigator.pop(context);
                      Navigator.pop(
                        context,
                        {
                          ...item,
                          "QUANTIDADE": quantidade,
                          "VALOR_TOTAL": valorTotal,
                        },
                      );
                    },
                    child: const Text("Adicionar"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
            title: const Text("Lista de Produtos"),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(45),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Pesquisar por nome ou código",
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
                              filterProdutos('');
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
              return Card(
                child: ListTile(
                  onTap: () {
                    if (widget.isFromPedido) {
                      _openProductDetails(context, item as Map<String, dynamic>);
                    } else {
                      Navigator.pop(context, item as Map);
                    }
                  },
                  title: Text(
                    item['NOMEPROD'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text("Código: ${item['CODIGO']}")],
                  ),
                  trailing: Text(
                    "R\$ ${item['PRECO'].toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: appStyles.primaryColor,
                      fontSize: 18,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
