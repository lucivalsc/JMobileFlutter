import 'package:flutter/material.dart';
import 'package:jmobileflutter/app/common/styles/app_styles.dart';
import 'package:jmobileflutter/app/common/widgets/app_widgets.dart';
import 'package:jmobileflutter/app/layers/presenter/logged_in/screens/clientes/clientes_lista_screen.dart';
import 'package:jmobileflutter/app/layers/presenter/logged_in/screens/produtos/produtos_lista_screen.dart';
import 'package:jmobileflutter/navigation.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  AppWidgets appWidgets = AppWidgets();
  AppStyles appStyles = AppStyles();
  Map cliente = {'NOMECLI': '', 'CPF': '', 'TELEFONE': ''};
  List<Map<String, dynamic>> listaProdutos = [];

  // Método para calcular o valor total
  double getValorTotal() {
    return listaProdutos.fold(0, (sum, item) => sum + (item['VALOR_TOTAL'] ?? 0));
  }

  // Método para calcular a quantidade total de itens
  int getQuantidadeTotal() {
    return listaProdutos.fold(0, (sum, item) {
      final quantidade = item['QUANTIDADE'];
      return sum + (quantidade is int ? quantidade : 0);
    });
  }

  // Método para adicionar ou atualizar produtos
  void adicionarOuAtualizarProduto(Map<String, dynamic> novoProduto) {
    bool existe = false;

    for (var produto in listaProdutos) {
      if (produto['CODIGO'] == novoProduto['CODIGO']) {
        setState(() {
          produto['QUANTIDADE'] += novoProduto['QUANTIDADE'];
          produto['VALOR_TOTAL'] += novoProduto['VALOR_TOTAL'];
        });
        existe = true;
        break;
      }
    }

    if (!existe) {
      setState(() {
        listaProdutos.add(novoProduto);
      });
    }
  }

  // Método para excluir um produto
  void excluirProduto(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Produto"),
        content: const Text("Deseja realmente excluir este produto?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                listaProdutos.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  // Método para abrir o modal de edição de produto
  void _openProductDetails(BuildContext context, int index) {
    var item = listaProdutos[index];
    int quantidade = item['QUANTIDADE'];
    double valorTotal = item['VALOR_TOTAL'];

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
                      setState(() {
                        item['QUANTIDADE'] = quantidade;
                        item['VALOR_TOTAL'] = valorTotal;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("Salvar Alterações"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Método para validar antes de sair
  Future<bool> _onWillPop() async {
    if (cliente['NOMECLI'].isNotEmpty || listaProdutos.isNotEmpty) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Sair sem salvar"),
              content: const Text("Você tem produtos ou cliente selecionado. Deseja realmente sair sem salvar?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false); // Não sai
                  },
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true); // Sai
                  },
                  child: const Text("Sair"),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true; // Sai normalmente se não houver dados
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Novo Pedido'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(45),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () async {
                  var retorno = await push(context, ClientesListaScreen(isFromPedido: true));
                  if (retorno != null) {
                    setState(() {
                      cliente = retorno;
                    });
                  }
                },
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Razão Social: ${cliente['NOMECLI']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              'CPF: ${cliente['CPF']}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.search),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 50,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Valor Total: R\$ ${getValorTotal().toStringAsFixed(2)}'),
                      Text('Qtde Itens: ${getQuantidadeTotal()}'),
                    ],
                  ),
                ],
              ),
            ),
            if (listaProdutos.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                  itemCount: listaProdutos.length,
                  itemBuilder: (BuildContext context, int index) {
                    var item = listaProdutos[index];
                    return ListTile(
                      onTap: () => _openProductDetails(context, index),
                      title: Text(
                        item['NOMEPROD'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Código: ${item['CODIGO']}"),
                              Text("Quantidade: ${item['QUANTIDADE']}"),
                            ],
                          ),
                          Text(
                            "R\$ ${item['VALOR_TOTAL'].toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: appStyles.primaryColor,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => excluirProduto(index),
                      ),
                    );
                  },
                ),
              ),
            if (listaProdutos.isEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_shopping_cart, size: 60, color: Colors.grey),
                    Text(
                      "Nenhum produto\n adicionado",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'obs',
              onPressed: () {},
              child: const Icon(Icons.note_add),
            ),
            const SizedBox(height: 15),
            FloatingActionButton(
              heroTag: 'produto',
              onPressed: () async {
                var retorno = await push(context, ProdutosListaScreen(isFromPedido: true));
                if (retorno == null) return;
                adicionarOuAtualizarProduto(retorno);
              },
              child: const Icon(Icons.add_shopping_cart),
            ),
            const SizedBox(height: 55),
          ],
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.all(8.0),
          child: appWidgets.buildPrimaryButton(
            () {
              if (cliente['NOMECLI'].isEmpty || listaProdutos.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Selecione um cliente e adicione produtos antes de salvar."),
                  ),
                );
                return;
              }
              // Lógica para salvar o pedido
              print("Pedido salvo:");
              print("Cliente: $cliente");
              print("Produtos: $listaProdutos");
            },
            label: 'FECHAR PEDIDO',
            enable: cliente['NOMECLI'].isNotEmpty && listaProdutos.isNotEmpty,
            processing: false,
            buttonColor: appStyles.primaryColor,
          ),
        ),
      ),
    );
  }
}
