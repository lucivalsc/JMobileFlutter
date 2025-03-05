import 'package:connect_force_app/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:connect_force_app/app/layers/presenter/providers/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class RelatoriosCondiScreen extends StatefulWidget {
  final String tipoPedido;
  final String periodoInicial;
  final String periodoFinal;

  const RelatoriosCondiScreen({
    super.key,
    required this.tipoPedido,
    required this.periodoInicial,
    required this.periodoFinal,
  });

  @override
  RelatoriosCondiScreenState createState() => RelatoriosCondiScreenState();
}

class RelatoriosCondiScreenState extends State<RelatoriosCondiScreen> {
  final Databasepadrao banco = Databasepadrao.instance;
  late DataProvider dataProvider;
  late Future<void> future;
  List recibos = [];
  Map usuario = {};
  double valorTotal = 0;
  double desconto = 0;
  double entrada = 0;

  List availableDevices = [];
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
    var value = await dataProvider.datasResponse(
      context,
      route:
          'RelatorioCodiVenda?IdUsuario=000201&DataInicial=${widget.periodoInicial}&DataFinal=${widget.periodoFinal}&TipoPedido=${widget.tipoPedido}',
    );
    if (value.isNotEmpty) {
      recibos = (value as List)[0];
      // Calcula totais apenas para pedidos ('P')
      if (widget.tipoPedido == 'P') {
        valorTotal = recibos.fold(0, (sum, recibo) => sum + (recibo['VALOR'] ?? 0));
        desconto = recibos.fold(0, (sum, recibo) => sum + (recibo['DESCONTO'] ?? 0));
        entrada = recibos.fold(0, (sum, recibo) => sum + (recibo['VALORENTRADA'] ?? 0));
      }
    }
    setState(() {});
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

  Future<void> getBluetoothDevices() async {
    await requestPermissions();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        availableDevices = results.map((result) => result.device).toList();
      });
    });
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
    bytes += generator.text(
      "RELATORIO ${widget.tipoPedido == 'C' ? 'CONDI' : 'VENDAS MOBILE'}",
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text("VENDEDOR: ${usuario['NOME'] ?? 'N/A'}");
    bytes += generator.text("PERIODO: ${widget.periodoInicial} - ${widget.periodoFinal}");
    bytes += generator.feed(1);

    // Lista de recibos
    for (var recibo in recibos) {
      bytes += generator.text("${recibo['CODIGO']} - ${recibo['NOME']}", styles: PosStyles(bold: true));
      bytes += generator.text("Pedido: ${recibo['IDPEDIDO']} - Data: ${recibo['DATAMOBILE']}");
      if (widget.tipoPedido == 'P') {
        bytes += generator.text(
            "Valor: R\$ ${recibo['VALOR'].toStringAsFixed(2)} | Desconto: R\$ ${recibo['DESCONTO'].toStringAsFixed(2)} | Entrada: R\$ ${recibo['VALORENTRADA'].toStringAsFixed(2)}");
      }
      bytes += generator.feed(1);
    }

    // Totais
    bytes += generator.text("--- TOTAIS ---", styles: PosStyles(align: PosAlign.center));
    if (widget.tipoPedido == 'C') {
      bytes += generator.text("QTDE DE CONDI: ${recibos.length}");
    } else {
      bytes += generator.text("QTDE DE VENDAS: ${recibos.length}");
      bytes += generator.text("TOTAL VENDAS: R\$ ${valorTotal.toStringAsFixed(2)}");
      bytes += generator.text("TOTAL DESCONTO: R\$ ${desconto.toStringAsFixed(2)}");
      bytes += generator.text("TOTAL ENTRADA: R\$ ${entrada.toStringAsFixed(2)}");
    }
    bytes += generator.feed(2);
    bytes += generator.text("VISTO GERENCIA", styles: PosStyles(align: PosAlign.center));
    bytes += generator.cut();

    // Dividir os dados em pacotes menores
    const int maxPacketSize = 182; // Tamanho máximo permitido
    for (int i = 0; i < bytes.length; i += maxPacketSize) {
      List<int> packet = bytes.sublist(i, i + maxPacketSize > bytes.length ? bytes.length : i + maxPacketSize);
      await characteristic!.write(packet, withoutResponse: true);
      await Future.delayed(const Duration(milliseconds: 100)); // Adicionar um pequeno atraso
    }
  }

  void _showDeviceSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
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
                  ElevatedButton(
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
                    child: Text('Imprimir'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Relatório"),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () {
              getBluetoothDevices();
              _showDeviceSelectionModal(context);
            },
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "RELATÓRIO ${widget.tipoPedido == 'C' ? 'CONDI' : 'VENDAS MOBILE'}",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text("VENDEDOR: ${usuario['NOME'] ?? 'N/A'}"),
                      Text("PERÍODO: ${widget.periodoInicial} - ${widget.periodoFinal}"),
                    ],
                  ),
                  const Divider(),
                  for (var recibo in recibos)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${recibo['CODIGO'].toString()} - ${recibo['NOME']}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Pedido: ${recibo['IDPEDIDO']} - Data: ${recibo['DATAMOBILE']}"),
                        if (widget.tipoPedido == 'P')
                          Text(
                              "Valor: R\$ ${recibo['VALOR'].toStringAsFixed(2)} | Desconto: R\$ ${recibo['DESCONTO'].toStringAsFixed(2)} | Entrada: R\$ ${recibo['VALORENTRADA'].toStringAsFixed(2)}"),
                        const Divider(),
                      ],
                    ),
                  const SizedBox(height: 20),
                  if (widget.tipoPedido == 'C') Text("QTDE DE CONDI: ${recibos.length}"),
                  if (widget.tipoPedido == 'P') ...[
                    Text("QTDE DE VENDAS: ${recibos.length}"),
                    Text("TOTAL VENDAS: R\$ ${valorTotal.toStringAsFixed(2)}"),
                    Text("TOTAL DESCONTO: R\$ ${desconto.toStringAsFixed(2)}"),
                    Text("TOTAL ENTRADA: R\$ ${entrada.toStringAsFixed(2)}"),
                  ],
                ],
              ),
            );
          }),
    );
  }
}
