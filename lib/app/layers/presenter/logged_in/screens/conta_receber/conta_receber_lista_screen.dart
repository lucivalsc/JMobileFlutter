import 'package:flutter/material.dart';
import 'package:connect_force_app/app/common/styles/app_styles.dart';
import 'package:connect_force_app/app/common/widgets/text_field_dropdown.dart';
import 'package:connect_force_app/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:connect_force_app/app/layers/presenter/logged_in/screens/conta_receber/item_data_view_widget.dart';
import 'package:connect_force_app/app/layers/presenter/logged_in/screens/conta_receber/recibo_screen.dart';
import 'package:connect_force_app/app/layers/presenter/providers/data_provider.dart';
import 'package:connect_force_app/navigation.dart';
import 'package:provider/provider.dart';

class ContaReceberListaScreen extends StatefulWidget {
  const ContaReceberListaScreen({super.key});

  static const String route = "conta_receber_lista_screen";

  @override
  State<ContaReceberListaScreen> createState() => _ContaReceberListaScreenState();
}

class _ContaReceberListaScreenState extends State<ContaReceberListaScreen> {
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
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> initScreen() async {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    listaReceber = await banco.listarReceber();
    applyFilters(); // Aplica os filtros iniciais
  }

  // Função centralizada para aplicar filtros
  void applyFilters({
    String? flag,
    String? query,
  }) {
    setState(() {
      listaFiltrada = listaReceber.where((item) {
        bool matchesFlag = true;
        bool matchesQuery = true;

        // Filtrar por flag (tipo de pedido)
        if (flag != null) {
          matchesFlag = item['FLAGPAGO'] == flag;
        }

        // Filtrar por pesquisa (nome ou CPF)
        if (query != null && query.isNotEmpty) {
          final nome = item["DEVEDOR"].toString().toLowerCase();
          final cpf = item["CPF"].toString().toLowerCase();
          matchesQuery = nome.contains(query.toLowerCase()) || cpf.contains(query.toLowerCase());
        }

        return matchesFlag && matchesQuery;
      }).toList();

      // Ordenar a lista filtrada pelo nome
      listaFiltrada.sort((a, b) => a["DEVEDOR"].toString().compareTo(b["DEVEDOR"].toString()));
    });
  }

  // Função para lidar com mudanças no campo de pesquisa
  void _onSearchChanged() {
    final query = searchController.text.trim();
    final flag = selectedTipoPedido?['id'] == 2 ? 'N' : 'S';
    applyFilters(flag: flag, query: query);
  }

  // Função para abrir modal de detalhes
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
              ItemDataViewWidget(pedido: pedido),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    push(context, ReciboScreen(cliente: pedido));
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: const Text("Listar Parcelas"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("A Receber"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(130.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Pesquisar por nome",
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
                                applyFilters(flag: selectedTipoPedido?['id'] == 2 ? 'N' : 'S', query: '');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Flexible(
                          child: TextFieldDropdown(
                            label: 'Tipo de Pedido',
                            value: 'text',
                            id: 'id',
                            items: dataProvider.tipoPedido,
                            onItemSelected: (selectedItem) {
                              setState(() {
                                selectedTipoPedido = selectedItem;
                                final flag = selectedItem['id'] == 2 ? 'N' : 'S';
                                applyFilters(flag: flag, query: searchController.text.trim());
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
              return const Center(child: Text("Nenhum pedido encontrado."));
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
                        child: ItemDataViewWidget(
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
