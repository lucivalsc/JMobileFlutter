import 'package:flutter/material.dart';

class VendasRegistroScreen extends StatefulWidget {
  final Map cliente;

  const VendasRegistroScreen({Key? key, required this.cliente}) : super(key: key);

  @override
  State<VendasRegistroScreen> createState() => _VendasRegistroScreenState();
}

class _VendasRegistroScreenState extends State<VendasRegistroScreen> {
  final TextEditingController _qtdePecasController = TextEditingController();
  final TextEditingController _valorFaturadoController = TextEditingController();
  final TextEditingController _itensNaoCadastradosController = TextEditingController();

  String? _fabricaSelecionada;
  Map<String, dynamic>? _preListaSelecionada;

  final List<Map<String, dynamic>> _preLista = [
    {'id': 1, 'descricao': 'Item 1'},
    {'id': 2, 'descricao': 'Item 2'},
    {'id': 3, 'descricao': 'Item 3'},
    {'id': 4, 'descricao': 'Item 4'},
  ];

  final List<String> _fabricas = ['TORQ', 'Willtec', 'Bastos', 'Perfect'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Venda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nome do cliente
              Text(
                'Cliente: ${widget.cliente['name']}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Campo de quantidade de peças
              TextField(
                controller: _qtdePecasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade de Peças',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Campo de valor faturado
              TextField(
                controller: _valorFaturadoController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor Faturado',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Campo de itens não cadastrados
              TextField(
                controller: _itensNaoCadastradosController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Itens Não Cadastrados',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Dropdown para selecionar a fábrica
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Fábrica',
                  border: OutlineInputBorder(),
                ),
                items: _fabricas.map((fabrica) => DropdownMenuItem(value: fabrica, child: Text(fabrica))).toList(),
                value: _fabricaSelecionada,
                onChanged: (value) {
                  setState(() {
                    _fabricaSelecionada = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Dropdown para selecionar item da pré-lista
              DropdownButtonFormField<Map<String, dynamic>>(
                decoration: const InputDecoration(
                  labelText: 'Pré-Lista',
                  border: OutlineInputBorder(),
                ),
                items: _preLista
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item['descricao']),
                        ))
                    .toList(),
                value: _preListaSelecionada,
                onChanged: (value) {
                  setState(() {
                    _preListaSelecionada = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Botão para salvar
              ElevatedButton(
                onPressed: _salvarVenda,
                child: const Text('Salvar Venda'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _salvarVenda() {
    final qtdePecas = _qtdePecasController.text;
    final valorFaturado = _valorFaturadoController.text;
    final itensNaoCadastrados = _itensNaoCadastradosController.text;

    if (qtdePecas.isEmpty || valorFaturado.isEmpty || _fabricaSelecionada == null || _preListaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios!'),
        ),
      );
      return;
    }

    final venda = {
      'cliente': widget.cliente,
      'qtdePecas': int.parse(qtdePecas),
      'valorFaturado': double.parse(valorFaturado),
      'itensNaoCadastrados': itensNaoCadastrados,
      'fabricaSelecionada': _fabricaSelecionada,
      'preListaSelecionada': _preListaSelecionada,
    };

    // Aqui você pode enviar os dados para a API ou fazer outro processamento
    print('Venda salva: $venda');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Venda registrada com sucesso!'),
      ),
    );

    // Limpar os campos após salvar
    _qtdePecasController.clear();
    _valorFaturadoController.clear();
    _itensNaoCadastradosController.clear();
    setState(() {
      _fabricaSelecionada = null;
      _preListaSelecionada = null;
    });
  }

  @override
  void dispose() {
    _qtdePecasController.dispose();
    _valorFaturadoController.dispose();
    _itensNaoCadastradosController.dispose();
    super.dispose();
  }
}
