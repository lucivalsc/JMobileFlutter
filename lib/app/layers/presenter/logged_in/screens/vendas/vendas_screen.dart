import 'package:flutter/material.dart';

class VendasScreen extends StatefulWidget {
  final VoidCallback onPressed;

  const VendasScreen({Key? key, required this.onPressed}) : super(key: key);

  @override
  State<VendasScreen> createState() => _VendasScreenState();
}

class _VendasScreenState extends State<VendasScreen> {
  List<Map<String, dynamic>> pedidosMock = [];
  late Future<void> future;

  Future<void> initScreen() async {
    // Mock de pedidos
    pedidosMock = [
      {
        'id': 1,
        'cliente': 'João Silva',
        'qtdePecas': 10,
        'valorFaturado': 'R\$ 500,00',
        'fabrica': 'TORQ',
        'status': 'Concluído',
      },
      {
        'id': 2,
        'cliente': 'Maria Oliveira',
        'qtdePecas': 20,
        'valorFaturado': 'R\$ 1.200,00',
        'fabrica': 'Willtec',
        'status': 'Pendente',
      },
      {
        'id': 3,
        'cliente': 'Carlos Souza',
        'qtdePecas': 15,
        'valorFaturado': 'R\$ 750,00',
        'fabrica': 'Bastos',
        'status': 'Em andamento',
      },
    ];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    future = initScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Pesquisar",
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              itemCount: pedidosMock.length,
              itemBuilder: (BuildContext context, int index) {
                var pedido = pedidosMock[index];
                return InkWell(
                  onTap: () {
                    // Aqui você pode definir o que acontece ao clicar no pedido
                    // Por exemplo, navegar para uma tela de detalhes
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(
                        'Cliente: ${pedido['cliente']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantidade de Peças: ${pedido['qtdePecas']}'),
                          Text('Valor Faturado: ${pedido['valorFaturado']}'),
                          Text('Fábrica: ${pedido['fabrica']}'),
                          Text('Status: ${pedido['status']}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
