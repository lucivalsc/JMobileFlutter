import 'package:connect_force_app/app/common/widgets/elevated_button_widget.dart';
import 'package:connect_force_app/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:connect_force_app/app/layers/presenter/providers/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class PedidosImpressaoScreen extends StatefulWidget {
  final Map pedido;
  const PedidosImpressaoScreen({super.key, required this.pedido});

  @override
  State<PedidosImpressaoScreen> createState() => _PedidosImpressaoScreenState();
}

class _PedidosImpressaoScreenState extends State<PedidosImpressaoScreen> {
  final Databasepadrao banco = Databasepadrao.instance;
  late DataProvider dataProvider;
  late Future<void> future;
  List listaPedido = [];
  Map usuario = {};

  List<BluetoothDevice> availableDevices = [];
  BluetoothDevice? selectedDevice;
  BluetoothCharacteristic? characteristic;

  @override
  void initState() {
    super.initState();
    future = initScreen();
  }

  @override
  void dispose() {
    // Parar o escaneamento do Bluetooth, se estiver ativo
    FlutterBluePlus.stopScan();

    // Desconectar do dispositivo Bluetooth, se conectado
    if (selectedDevice != null) {
      selectedDevice!.disconnect();
    }

    super.dispose();
  }

  Future<void> initScreen() async {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    usuario = await dataProvider.loadDataToSend(uri: 'login');
    listaPedido = await banco.imprimirPedido(widget.pedido['IDPEDIDO'].toString());

    getBluetoothDevices();
    setState(() {});
  }

  Future<void> getBluetoothDevices() async {
    await requestPermissions();
    FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        availableDevices = results.map((result) => result.device).toList();
      });
    });
  }

  Future<void> requestPermissions() async {
    try {
      if (await Permission.bluetooth.isGranted &&
          await Permission.bluetoothScan.isGranted &&
          await Permission.bluetoothConnect.isGranted) {
        return;
      }

      await [Permission.bluetooth, Permission.bluetoothScan, Permission.bluetoothConnect].request();
    } catch (e) {
      debugPrint('Erro ao solicitar permissões: $e');
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic char in service.characteristics) {
        if (char.properties.write) {
          characteristic = char;
          break;
        }
      }
    }
    setState(() {
      selectedDevice = device;
    });
  }

  Future<void> printTicket() async {
    if (selectedDevice == null || characteristic == null) {
      debugPrint('Nenhum dispositivo selecionado ou característica não encontrada.');
      return;
    }

    final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());
    List<int> bytes = [];

    // Cabeçalho
    bytes += generator.text('Recibo de Venda', styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Data Impressão: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    bytes += generator.text('Data Venda: ${listaPedido[0]['DATAHORA']}');
    bytes += generator.text('Número de Venda: ${listaPedido[0]['IDPEDIDO']}');
    bytes += generator.text('Vendedor: ${usuario['NOME']}');
    bytes += generator.text('Latitude: ${listaPedido[0]['LATITUDE']}');
    bytes += generator.text('Longitude: ${listaPedido[0]['LONGITUDE']}');
    bytes += generator.text('Cliente: ${listaPedido[0]['CODIGORELATORIO']}');
    bytes += generator.text('${listaPedido[0]['NOMECLIENTE']}');
    bytes += generator.text('--- Produtos ---');

    // Produtos
    for (var item in listaPedido) {
      bytes += generator.text('Código Produto: ${item['CODIGOPRODUTO']}');
      bytes += generator.text('Descrição: ${item['NOMEPROD']}');
      bytes += generator.text('Quantidade: ${item['QTDE']} X Valor Unitário: R\$ ${item['VALORUNITARIO']}');
      bytes += generator.text('Total: R\$ ${item['VALORTOTAL']}');
    }

    // Totais
    bytes += generator.text('Total Produtos: ${listaPedido[0]['TOTALPRODUTOS']}');
    bytes += generator.text('Valor Total: R\$ ${listaPedido[0]['VALOR']}');
    bytes += generator.text('Desconto: R\$ ${listaPedido[0]['DESCONTO']}');
    bytes += generator.text('Entrada: R\$ ${listaPedido[0]['VALORENTRADA']}');
    bytes += generator
        .text('Valor Parcelado: R\$ ${listaPedido[0]['VALORTOTALCALC'] / int.parse(listaPedido[0]['PRAZOPAGTO'])}');
    bytes += generator.text('Prazo Pagamento: ${listaPedido[0]['PRAZOPAGTO']}');
    bytes += generator.text('1º Vencimento: ${listaPedido[0]['INICIO_VENCIMENTO']}');

    bytes += generator.feed(2);
    bytes += generator.cut();

    // Dividir os dados em pacotes menores
    const int maxPacketSize = 182; // Tamanho máximo permitido
    for (int i = 0; i < bytes.length; i += maxPacketSize) {
      List<int> packet = bytes.sublist(i, i + maxPacketSize > bytes.length ? bytes.length : i + maxPacketSize);
      await characteristic!.write(packet, withoutResponse: true);
      await Future.delayed(Duration(milliseconds: 100)); // Adicionar um pequeno atraso entre os pacotes
    }
  }

  void _showDeviceSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Selecione um dispositivo Bluetooth',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: availableDevices.length,
                    itemBuilder: (context, index) {
                      final device = availableDevices[index];
                      return ListTile(
                        title: Text(device.name ?? 'Dispositivo desconhecido'),
                        subtitle: Text(device.id.toString()),
                        trailing: selectedDevice?.id == device.id ? Icon(Icons.check, color: Colors.green) : null,
                        onTap: () {
                          setState(() {
                            selectedDevice = device;
                          });
                        },
                      );
                    },
                  ),
                ),
                ElevatedButtonWidget(
                  onPressed: () async {
                    if (selectedDevice != null) {
                      await connectToDevice(selectedDevice!);
                      await printTicket();
                      Navigator.pop(context); // Fechar o modal após a impressão
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selecione um dispositivo para imprimir.')),
                      );
                    }
                  },
                  label: 'Imprimir',
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recibo'),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () => _showDeviceSelectionModal(context),
          ),
        ],
      ),
      body: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: SafeArea(child: const Center(child: CircularProgressIndicator())));
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Cabeçalho
                  Center(
                    child: Text(
                      'Recibo de Venda',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  Text('Data Impressão: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}'),
                  SizedBox(height: 8),
                  Text('Data Venda: ${listaPedido[0]['DATAHORA']}'),
                  SizedBox(height: 8),
                  Text('Número de Venda: ${listaPedido[0]['IDPEDIDO']}'),
                  SizedBox(height: 8),
                  Text('Vendedor: ${usuario['NOME']}'),
                  SizedBox(height: 8),
                  Text('Latitude: ${listaPedido[0]['LATITUDE']}'),
                  SizedBox(height: 8),
                  Text('Longitude: ${listaPedido[0]['LONGITUDE']}'),
                  SizedBox(height: 16),
                  Divider(),

                  // Informações do Cliente
                  Text('Cliente: ${listaPedido[0]['CODIGORELATORIO']}'),
                  Text('${listaPedido[0]['NOMECLIENTE']}'),
                  SizedBox(height: 16),

                  // Produtos
                  Text('--- Produtos ---'),
                  SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: listaPedido.length,
                    itemBuilder: (context, index) {
                      var item = listaPedido[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            // Alinhando título à esquerda e valor à direita
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Código Produto:'),
                                Text(item['CODIGOPRODUTO'] ?? ''),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Descrição:'),
                                Expanded(child: Text(item['NOMEPROD'] ?? '')),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Quantidade:'),
                                Text('${item['QTDE']} X Valor Unitário: R\$ ${item['VALORUNITARIO']}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total:'),
                                Text('R\$ ${item['VALORTOTAL']}'),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  Divider(),

                  // Totais
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Produtos:'),
                      Text('${listaPedido[0]['TOTALPRODUTOS']}'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Valor Total:'),
                      Text('R\$ ${listaPedido[0]['VALOR']}'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Desconto:'),
                      Text('R\$ ${listaPedido[0]['DESCONTO']}'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Entrada:'),
                      Text('R\$ ${listaPedido[0]['VALORENTRADA']}'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Valor Parcelado:'),
                      Text('R\$ ${listaPedido[0]['VALORTOTALCALC'] / int.parse(listaPedido[0]['PRAZOPAGTO'])}'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Prazo Pagamento:'),
                      Text('${listaPedido[0]['PRAZOPAGTO']}'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1º Vencimento:'),
                      Text('${listaPedido[0]['INICIO_VENCIMENTO']}'),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }
}
