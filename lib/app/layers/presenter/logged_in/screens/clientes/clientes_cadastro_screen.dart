import 'package:flutter/material.dart';
import 'package:jmobileflutter/app/common/styles/app_styles.dart';
import 'package:jmobileflutter/app/common/utils/functions.dart';
import 'package:jmobileflutter/app/common/widgets/elevated_button_widget.dart';
import 'package:jmobileflutter/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/data_provider.dart';
import 'package:provider/provider.dart';

class ClientesCadastroScreen extends StatefulWidget {
  final Map? cliente;
  const ClientesCadastroScreen({super.key, this.cliente});

  @override
  State<ClientesCadastroScreen> createState() => _ClientesCadastroScreenState();
}

class _ClientesCadastroScreenState extends State<ClientesCadastroScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final Databasepadrao banco = Databasepadrao.instance;

  // Cliente
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataNascController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _diaVencimentoController = TextEditingController();
  bool naoVender = false; // FLAGNAOVENDER como Checkbox
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _profissaoController = TextEditingController();

  // Documentos
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _identidadeController = TextEditingController();
  final TextEditingController _localTrabalhoController = TextEditingController();
  final TextEditingController _limiteCreditoController = TextEditingController();

  // Endereço
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _numeroLogradouroController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _complementoLogradouroController = TextEditingController();

  // Cônjuge
  final TextEditingController _conjugeController = TextEditingController();
  final TextEditingController _telefoneConjugeController = TextEditingController();

  // Filiação
  final TextEditingController _filiacaoMaeController = TextEditingController();
  final TextEditingController _telefoneMaeController = TextEditingController();
  final TextEditingController _filiacaoPaiController = TextEditingController();
  final TextEditingController _telefonePaiController = TextEditingController();
  final TextEditingController _obsController = TextEditingController();

  late TabController _tabController;
  late bool isEditing;

  late DataProvider dataProvider;
  late Future<void> future;
  final appStyles = AppStyles();

  @override
  void dispose() {
    _tabController.dispose();
    _nomeController.dispose();
    _dataNascController.dispose();
    _cpfController.dispose();
    _identidadeController.dispose();
    _localTrabalhoController.dispose();
    _limiteCreditoController.dispose();
    _cepController.dispose();
    _numeroLogradouroController.dispose();
    _enderecoController.dispose();
    _estadoController.dispose();
    _cidadeController.dispose();
    _bairroController.dispose();
    _complementoLogradouroController.dispose();
    _conjugeController.dispose();
    _telefoneConjugeController.dispose();
    _filiacaoMaeController.dispose();
    _telefoneMaeController.dispose();
    _filiacaoPaiController.dispose();
    _telefonePaiController.dispose();
    _obsController.dispose();

    super.dispose();
  }

  Map usuario = {};
  Future<void> initScreen({String flag = 'S'}) async {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    usuario = await dataProvider.loadDataToSend(uri: 'login');
    var usuarioView = await dataProvider.datasResponse(
      context,
      route: 'ClienteDetalhe?Codigo=${widget.cliente!['CODIGO'].toString()}',
    );

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    future = initScreen();
    _tabController = TabController(length: 5, vsync: this);
    isEditing = widget.cliente != null;

    if (isEditing) {
      _nomeController.text = widget.cliente!['NOMECLI'] ?? '';
      _codigoController.text = widget.cliente!['CODCLI'].toString() ?? '';
      _enderecoController.text = widget.cliente!['ENDERECO'] ?? '';
      _bairroController.text = widget.cliente!['BAIRRO'] ?? '';
      _cidadeController.text = widget.cliente!['CIDADE'] ?? '';
      _estadoController.text = widget.cliente!['ESTADO'] ?? '';
      _cepController.text = widget.cliente!['CEP'] ?? '';
      _telefoneController.text = widget.cliente!['TELEFONE'] ?? '';
      _cpfController.text = widget.cliente!['CPF'] ?? '';
      _limiteCreditoController.text = widget.cliente!['LIMITECRED']?.toString() ?? '';
      _identidadeController.text = widget.cliente!['IDENTIDADE'] ?? '';
      _dataNascController.text = widget.cliente!['DATNASC'] ?? '';
      _filiacaoMaeController.text = widget.cliente!['FILIACAO'] ?? '';
      _profissaoController.text = widget.cliente!['PROFISSAO'] ?? '';
      _obsController.text = widget.cliente!['OBS'] ?? '';
      _numeroLogradouroController.text = widget.cliente!['NUMEROLOGRADOURO'] ?? '';
      _complementoLogradouroController.text = widget.cliente!['COMPLEMENTOLOGRADOURO'] ?? '';
      _diaVencimentoController.text = widget.cliente!['DIAVENCIMENTO']?.toString() ?? '';
      naoVender = widget.cliente!['FLAGNAOVENDER'] == 'S'; // Checkbox
    }
  }

  void _salvarCliente() async {
    // if (_formKey.currentState!.validate()) {
    var cliente = {
      "IDUSUARIO": usuario['IDUSUARIO'],
      "NOMECLI": _nomeController.text,
      "CODCLI": _codigoController.text,
      "ENDERECO": _enderecoController.text,
      "BAIRRO": _bairroController.text,
      "CIDADE": _cidadeController.text,
      "ESTADO": _estadoController.text,
      "CEP": _cepController.text,
      "TELEFONE": _telefoneController.text,
      "CPF": _cpfController.text,
      "LIMITECRED": double.tryParse(_limiteCreditoController.text) ?? 0.0,
      "IDENTIDADE": _identidadeController.text,
      "DATNASC": _dataNascController.text,
      "FILIACAO": _filiacaoMaeController.text,
      "PROFISSAO": _profissaoController.text,
      "OBS": _obsController.text,
      "NUMEROLOGRADOURO": _numeroLogradouroController.text,
      "COMPLEMENTOLOGRADOURO": _complementoLogradouroController.text,
      "DIAVENCIMENTO": int.tryParse(_diaVencimentoController.text),
      "FLAGNAOVENDER": naoVender ? 'S' : 'N', // Checkbox
      "LATITUDE": dataProvider.latitudeController.text,
      "LONGITUDE": dataProvider.longitudeController.text,
    };
    final contatos = [
      {
        "IDUSUARIO": usuario['IDUSUARIO'],
        "NOME": _conjugeController.text,
        "TELEFONE": _telefoneConjugeController.text,
        "EMAIL": "",
        "SETOR": "E", // Cônjuge
      },
      {
        "IDUSUARIO": usuario['IDUSUARIO'],
        "NOME": _filiacaoMaeController.text,
        "TELEFONE": _telefoneMaeController.text,
        "EMAIL": "",
        "SETOR": "M", // Mãe
      },
      {
        "IDUSUARIO": usuario['IDUSUARIO'],
        "NOME": _filiacaoPaiController.text,
        "TELEFONE": _telefonePaiController.text,
        "EMAIL": "",
        "SETOR": "P", // Pai
      },
    ];
    try {
      await banco.gravarCliente(cliente: cliente, contatos: contatos);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cliente cadastrado com sucesso!')),
      );
      Navigator.pop(context, cliente);
      print('Cliente e contatos gravados com sucesso!');
    } catch (e) {
      print('Erro ao gravar cliente: $e');
    }
    // }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    String? Function(String?)? customValidator,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: isEditing,
      decoration: InputDecoration(labelText: label),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Campo obrigatório';
              }
              if (customValidator != null) {
                return customValidator(value);
              }
              return null;
            }
          : customValidator,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Visualizar Cliente' : 'Cadastro de Cliente'),
        bottom: TabBar(
          labelColor: Colors.white,
          isScrollable: true,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cliente'),
            Tab(text: 'Documentos'),
            Tab(text: 'Endereço'),
            Tab(text: 'Cônjuge'),
            Tab(text: 'Filiação'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba 1: Cliente
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildTextField(label: 'Nome do Cliente', controller: _nomeController, isRequired: true),
                  // _buildTextField(label: 'Código do Cliente', controller: _codigoController, isRequired: true),
                  _buildTextField(
                    label: 'Data de Nascimento',
                    controller: _dataNascController,
                    isRequired: true,
                    customValidator: (value) {
                      if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value ?? '')) {
                        return 'Formato inválido (DD/MM/AAAA)';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(label: 'Telefone', controller: _telefoneController, isRequired: true),
                  _buildTextField(label: 'Profissão', controller: _profissaoController),
                  _buildTextField(label: 'Dia Vencimento', controller: _diaVencimentoController),
                  Row(
                    children: [
                      Checkbox(
                        value: naoVender,
                        onChanged: isEditing
                            ? null
                            : (value) {
                                setState(() {
                                  naoVender = value ?? false;
                                });
                              },
                      ),
                      const Text('Não Vender'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Aba 2: Documentos
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildTextField(
                  label: 'CPF',
                  controller: _cpfController,
                  isRequired: true,
                  customValidator: (value) {
                    if (!RegExp(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$').hasMatch(value ?? '')) {
                      return 'CPF inválido (XXX.XXX.XXX-XX)';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'Identidade',
                  controller: _identidadeController,
                  isRequired: true,
                ),
                _buildTextField(label: 'Limite de Crédito', controller: _limiteCreditoController),
                _buildTextField(label: 'Local de Trabalho', controller: _localTrabalhoController),
              ],
            ),
          ),
          // Aba 3: Endereço
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildTextField(
                  label: 'CEP',
                  controller: _cepController,
                  isRequired: true,
                  onChanged: (p0) async {
                    try {
                      // Consulta o endereço pelo CEP
                      if (p0.toString().length <= 7) return;
                      Map<String, dynamic> endereco = await buscarEnderecoPorCep(p0);

                      // Preenche os controladores com os dados retornados
                      _enderecoController.text = endereco['logradouro'] ?? '';
                      _complementoLogradouroController.text = endereco['complemento'] ?? '';
                      _bairroController.text = endereco['bairro'] ?? '';
                      _cidadeController.text = endereco['localidade'] ?? '';
                      _estadoController.text = endereco['uf'] ?? '';

                      print('Endereço preenchido com sucesso!'); // Log para depuração
                    } catch (e) {
                      print('Erro ao preencher endereço: $e');
                      rethrow; // Relança a exceção para tratamento externo, se necessário
                    }
                  },
                ),
                _buildTextField(label: 'Endereço', controller: _enderecoController, isRequired: true),
                _buildTextField(label: 'Número Logradouro', controller: _numeroLogradouroController, isRequired: true),
                _buildTextField(label: 'Complemento Logradouro', controller: _complementoLogradouroController),
                _buildTextField(label: 'Bairro', controller: _bairroController, isRequired: true),
                _buildTextField(label: 'Cidade', controller: _cidadeController, isRequired: true),
                _buildTextField(label: 'Estado', controller: _estadoController, isRequired: true),
              ],
            ),
          ),
          // Aba 4: Cônjuge
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildTextField(label: 'Nome do Cônjuge', controller: _conjugeController),
                _buildTextField(label: 'Telefone do Cônjuge', controller: _telefoneConjugeController),
              ],
            ),
          ),
          // Aba 5: Filiação
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildTextField(label: 'Nome da Mãe', controller: _filiacaoMaeController, isRequired: true),
                _buildTextField(label: 'Telefone da Mãe', controller: _telefoneMaeController),
                _buildTextField(label: 'Nome do Pai', controller: _filiacaoPaiController),
                _buildTextField(label: 'Telefone do Pai', controller: _telefonePaiController),
                _buildTextField(label: 'Observações', controller: _obsController),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isEditing
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButtonWidget(
                onPressed: _salvarCliente,
                label: 'Cadastrar Cliente',
              ),
            ),
    );
  }
}
