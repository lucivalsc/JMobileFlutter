import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ClientesCadastroScreen extends StatefulWidget {
  final Map? cliente;
  const ClientesCadastroScreen({super.key, this.cliente});

  @override
  State<ClientesCadastroScreen> createState() => _ClientesCadastroScreenState();
}

class _ClientesCadastroScreenState extends State<ClientesCadastroScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _fornecedorController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();
  final TextEditingController _concorrenteController = TextEditingController();
  final TextEditingController _especialidadeOutraController = TextEditingController();

  String? _especialidadeCliente;
  String? _servicosOficina;

  List<String> especialidades = ['Retífica', 'Auto Center', 'Outra'];
  List<String> servicos = ['Suspensão', 'Motor', 'Mecânica em geral', 'Elétrica', 'Outras especialidades'];

  Position? _currentPosition;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.cliente != null) {
      _nomeController.text = widget.cliente!['name'] ?? '';
      _latitudeController.text = widget.cliente!['location']?['latitude']?.toString() ?? '';
      _longitudeController.text = widget.cliente!['location']?['longitude']?.toString() ?? '';
      _enderecoController.text = widget.cliente!['address'] ?? '';
      _telefoneController.text = widget.cliente!['phone'] ?? '';
      _documentoController.text = widget.cliente!['document'] ?? '';
    }
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('O serviço de localização está desativado.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permissão de localização negada.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissão de localização negada permanentemente.')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
    });
  }

  void _salvarCliente() {
    if (_formKey.currentState!.validate()) {
      if (_currentPosition == null ||
          _latitudeController.text != _currentPosition!.latitude.toString() ||
          _longitudeController.text != _currentPosition!.longitude.toString()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Você está fora da localização do cliente!')),
        );
        return;
      }

      final cliente = {
        "name": _nomeController.text,
        "location": {
          "latitude": double.tryParse(_latitudeController.text) ?? 0.0,
          "longitude": double.tryParse(_longitudeController.text) ?? 0.0,
        },
        "address": _enderecoController.text,
        "phone": _telefoneController.text,
        "document": _documentoController.text,
        "fornecedor": _fornecedorController.text,
        "observacoes": _observacoesController.text,
        "concorrente": _concorrenteController.text,
        "especialidadeCliente": _especialidadeCliente,
        "servicosOficina": _servicosOficina,
        "especialidadeOutra": _especialidadeCliente == 'Outra' ? _especialidadeOutraController.text : null,
      };

      if (widget.cliente != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cliente atualizado: ${cliente['name']}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cliente cadastrado: ${cliente['name']}')),
        );
      }

      Navigator.pop(context, cliente);
    }
  }

  void _excluirCliente() {
    if (widget.cliente != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cliente ${widget.cliente!['name']} excluído')),
      );
      Navigator.pop(context, null); // Retorna para a tela anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cliente != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Cliente' : 'Cadastro de Cliente'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Informações Básicas'),
            Tab(text: 'Especialidade e Serviços'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(labelText: 'Nome'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'O nome é obrigatório.';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _latitudeController,
                          decoration: const InputDecoration(labelText: 'Latitude'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'A latitude é obrigatória.';
                            }
                            if (double.tryParse(value) == null) {
                              return 'A latitude deve ser um número válido.';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _longitudeController,
                          decoration: const InputDecoration(labelText: 'Longitude'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'A longitude é obrigatória.';
                            }
                            if (double.tryParse(value) == null) {
                              return 'A longitude deve ser um número válido.';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _enderecoController,
                          decoration: const InputDecoration(labelText: 'Endereço'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'O endereço é obrigatório.';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _telefoneController,
                          decoration: const InputDecoration(labelText: 'Telefone'),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'O telefone é obrigatório.';
                            }
                            if (!RegExp(r'^\(\d{2}\)\s?\d{4,5}-\d{4}$').hasMatch(value)) {
                              return 'Insira um telefone válido. Ex: (11) 98765-4321';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _documentoController,
                          decoration: const InputDecoration(labelText: 'Documento'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'O documento é obrigatório.';
                            }
                            if (!RegExp(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$').hasMatch(value)) {
                              return 'Insira um CPF válido. Ex: 123.456.789-10';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _fornecedorController,
                          decoration: const InputDecoration(labelText: 'Principal Fornecedor'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'O fornecedor é obrigatório.';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _observacoesController,
                          decoration: const InputDecoration(labelText: 'Observações'),
                        ),
                        TextFormField(
                          controller: _concorrenteController,
                          decoration: const InputDecoration(labelText: 'Ações do Concorrente'),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _especialidadeCliente,
                          decoration: const InputDecoration(labelText: 'Especialidade'),
                          items: especialidades.map((especialidade) {
                            return DropdownMenuItem<String>(
                              value: especialidade,
                              child: Text(especialidade),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _especialidadeCliente = value;
                            });
                          },
                        ),
                        if (_especialidadeCliente == 'Outra') ...[
                          TextFormField(
                            controller: _especialidadeOutraController,
                            decoration: const InputDecoration(labelText: 'Especifique a Especialidade'),
                          ),
                        ],
                        DropdownButtonFormField<String>(
                          value: _servicosOficina,
                          decoration: const InputDecoration(labelText: 'Serviços da Oficina'),
                          items: servicos.map((servico) {
                            return DropdownMenuItem<String>(
                              value: servico,
                              child: Text(servico),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _servicosOficina = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _salvarCliente,
          child: Text(isEditing ? 'Atualizar Cliente' : 'Cadastrar Cliente'),
        ),
      ),
    );
  }
}
