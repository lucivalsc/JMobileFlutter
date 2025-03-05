import 'package:connect_force_app/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:connect_force_app/app/layers/presenter/providers/data_provider.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class RelatoriosRecebidasScreen extends StatefulWidget {
  final String periodoInicial;
  final String periodoFinal;

  const RelatoriosRecebidasScreen({
    super.key,
    required this.periodoInicial,
    required this.periodoFinal,
  });

  @override
  RelatoriosRecebidasScreenState createState() => RelatoriosRecebidasScreenState();
}

class RelatoriosRecebidasScreenState extends State<RelatoriosRecebidasScreen> {
  final Databasepadrao banco = Databasepadrao.instance;
  late DataProvider dataProvider;
  late Future<void> future;
  List recibos = [];
  Map totais = {};
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

    var value = await dataProvider.datasResponse(
      context,
      route: 'RecebimentoMobile?CodUser=002&DtInicial=01/01/2000&DtFinal=01/02/2025',
    );
    await banco.deleteAll('REL_MOB_RECEBIDA');
    await banco.dataInsertLista('REL_MOB_RECEBIDA', (value as List)[0]);
    print(value);

    final dadosRecibos = await banco.relatoriosRecebidas();
    final dadosTotais = await banco.relatoriosRecebidasFull();
    setState(() {
      recibos = dadosRecibos;
      totais = dadosTotais[0];
    });
    getBluetoothDevices();
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
    bytes += generator.text('Relatorio de Recibos', styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Periodo: ${widget.periodoInicial} - ${widget.periodoFinal}');
    bytes += generator.text('Usuario: ${usuario['NOME']}');
    bytes += generator.text('--- CLIENTES RECEBIDOS ---', styles: PosStyles(align: PosAlign.center));
    bytes += generator.feed(1);

    // Lista de recibos
    for (var recibo in recibos) {
      bytes += generator.text('Codigo: ${recibo["CODIGO"]}');
      bytes += generator.text('Cliente: ${recibo["NOMECLI"]}');
      bytes += generator.text('Doc: ${recibo["NUMDOC"]} - Tipo: ${recibo["TIPO"]} - Valor: R\$ ${recibo["VALOR"]}');
      bytes += generator.feed(1);
    }

    // Totais
    bytes += generator.text('--- TOTAIS ---', styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('Qtde Recebimentos: ${totais["QTDE"] ?? 0}');
    bytes += generator.text('Total Dinheiro: R\$ ${totais["DINHEIRO"]?.toStringAsFixed(2) ?? '0.00'}');
    bytes += generator.text('Total PIX: R\$ ${totais["PIX"]?.toStringAsFixed(2) ?? '0.00'}');
    bytes += generator.text('Total Cartao: R\$ ${totais["CARTAO"]?.toStringAsFixed(2) ?? '0.00'}');
    bytes += generator.text('Total Deposito: R\$ ${totais["DEP"]?.toStringAsFixed(2) ?? '0.00'}');
    bytes += generator.text('Total Outros: R\$ ${totais["OUTROS"]?.toStringAsFixed(2) ?? '0.00'}');
    bytes += generator.text('Total Geral: R\$ ${totais["TOTAL"]?.toStringAsFixed(2) ?? '0.00'}');
    bytes += generator.feed(2);
    bytes += generator.text('Visto Gerencia', styles: PosStyles(align: PosAlign.center));
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
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Relatório de Recibos"),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text("--- CLIENTES RECEBIDOS ---", style: Theme.of(context).textTheme.titleLarge),
                        Text("USUÁRIO: ${usuario['NOME']}"),
                        Text("PERÍODO: ${widget.periodoInicial} - ${widget.periodoFinal}"),
                      ],
                    ),
                  ],
                ),
                const Divider(),

                // Cabeçalho
                Row(
                  children: [
                    Expanded(child: Text("CÓDIGO", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text("CLIENTE", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                      flex: 2,
                      child: Text("DOC - TIPO - VALOR", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const Divider(),

                // Lista de recibos
                for (var recibo in recibos)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recibo["CODIGO"] ?? ''),
                      Text(recibo["NOMECLI"] ?? ''),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${recibo["NUMDOC"]}', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${recibo["TIPO"]}', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${recibo["VALOR"]}', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(),
                    ],
                  ),

                // Totais
                const SizedBox(height: 20),
                Text("QTDE DE RECEBIMENTOS: ${totais["QTDE"] ?? 0}"),
                Text("TOTAL DINHEIRO:     R\$ ${totais["DINHEIRO"]?.toStringAsFixed(2) ?? '0.00'}"),
                Text("TOTAL PIX:          R\$ ${totais["PIX"]?.toStringAsFixed(2) ?? '0.00'}"),
                Text("TOTAL CARTÃO:       R\$ ${totais["CARTAO"]?.toStringAsFixed(2) ?? '0.00'}"),
                Text("TOTAL DEPÓSITO:     R\$ ${totais["DEP"]?.toStringAsFixed(2) ?? '0.00'}"),
                Text("TOTAL OUTROS:       R\$ ${totais["OUTROS"]?.toStringAsFixed(2) ?? '0.00'}"),
                Text("TOTAL GERAL:        R\$ ${totais["TOTAL"]?.toStringAsFixed(2) ?? '0.00'}"),
                const Divider(),
                const Text("VISTO GERÊNCIA", textAlign: TextAlign.center),
              ],
            ),
          );
        },
      ),
    );
  }
}
