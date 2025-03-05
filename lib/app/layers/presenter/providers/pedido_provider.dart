import 'dart:io';

import 'package:connect_force_app/app/common/utils/functions.dart';
import 'package:connect_force_app/app/common/widgets/elevated_button_widget.dart';
import 'package:connect_force_app/app/layers/presenter/providers/data_provider.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class PedidoProvider extends ChangeNotifier {
  List listaPedidos = [];
  List listaPedido = [];
  Map usuario = {};

  List<BluetoothDevice> availableDevices = [];
  BluetoothDevice? selectedDevice;
  BluetoothCharacteristic? characteristic;

  addListaPedidos(Map item) {
    listaPedidos.add(item);
    notifyListeners();
  }

  removeItem(int index) {
    listaPedidos.removeAt(index);
    notifyListeners();
  }

  disconnectBluetooth() async {
    FlutterBluePlus.stopScan();
    if (selectedDevice != null) {
      await selectedDevice?.disconnect();
      selectedDevice = null;
      characteristic = null;
    }
  }

  Future<void> printTicket(DataProvider dataProvider) async {
    if (selectedDevice == null || characteristic == null) {
      debugPrint('Nenhum dispositivo selecionado ou característica não encontrada.');
      return;
    }

    final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());
    List<int> bytes = [];

    bytes += generator.text('Recibo de Venda', styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Data Impressao: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    bytes += generator.text('Data Venda: ${formatDatetime(listaPedido[0]['DATAHORA'])}');
    bytes += generator.text('Numero de Venda: ${listaPedido[0]['IDPEDIDO']}');
    bytes += generator.text('Vendedor: ${usuario['NOME']}');
    bytes += generator.text('Latitude: ${dataProvider.latitudeController.text}');
    bytes += generator.text('Longitude: ${dataProvider.longitudeController.text}');
    bytes += generator.text('Cliente: ${listaPedido[0]['CODIGORELATORIO']}');
    bytes += generator.text('${listaPedido[0]['NOMECLIENTE']}');

    bytes += generator.text('--- Produtos ---', styles: PosStyles(align: PosAlign.center, bold: true));

    for (var item in listaPedido) {
      bytes += generator.text('Codigo Produto: ${item['CODIGOPRODUTO']}');
      bytes += generator.text('Descricao: ${item['NOMEPROD']}');
      bytes += generator
          .text('Quantidade: ${formatCurrency(item['QTDE'], symbol: '')} X  ${formatCurrency(item['VALORUNITARIO'])}');
      bytes += generator.text('Total: ${formatCurrency(item['VALORTOTAL'])}');
    }

    bytes += generator.text('Total Produtos: ${formatCurrency(listaPedido[0]['TOTALPRODUTOS'], symbol: '')}');
    bytes += generator.text('Valor Total: R\$ ${formatCurrency(listaPedido[0]['VALOR'])}');
    bytes += generator.text('Desconto: R\$ ${formatCurrency(listaPedido[0]['DESCONTO'])}');
    bytes += generator.text('Entrada: R\$ ${formatCurrency(listaPedido[0]['VALORENTRADA'])}');
    bytes += generator.text(
        'Valor Parcelado: R\$ ${formatCurrency(listaPedido[0]['VALORTOTALCALC'] / int.parse(listaPedido[0]['PRAZOPAGTO']))}');
    bytes += generator.text('Prazo Pagamento: ${listaPedido[0]['PRAZOPAGTO']}');
    bytes += generator.text('Vencimento: ${formatDate(listaPedido[0]['INICIO_VENCIMENTO'])}');

    bytes += generator.feed(2);
    bytes += generator.cut();

    const int maxPacketSize = 182;
    for (int i = 0; i < bytes.length; i += maxPacketSize) {
      List<int> packet = bytes.sublist(i, i + maxPacketSize > bytes.length ? bytes.length : i + maxPacketSize);
      await characteristic!.write(packet, withoutResponse: true);
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  Future<void> generateAndOpenPdf(DataProvider dataProvider) async {
    final pdf = pw.Document();

    // Definir a largura do PDF para 58mm (58 * 2.83 = ~164 pontos)
    const double pdfWidth = 164; // Largura aproximada para 58mm
    const double fontSize = 9; // Tamanho da fonte para ficar semelhante ao ticket

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pdfWidth, double.infinity, marginAll: 0), // Sem margens
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              pw.Text('Recibo de Venda',
                  style: pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold, font: pw.Font.courier())),
              pw.SizedBox(height: 5),
              pw.Text('Data Impressao: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
              pw.Text('Data Venda: ${formatDatetime(listaPedido[0]['DATAHORA'])}',
                  style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
              pw.Text('Numero de Venda: ${listaPedido[0]['IDPEDIDO']}',
                  style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
              pw.Text('Vendedor: ${usuario['NOME']}', style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
              pw.Text('Latitude: ${dataProvider.currentPosition!.latitude}',
                  style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
              pw.Text('Longitude: ${listaPedido[0]['LONGITUDE']}',
                  style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
              pw.Text('Cliente: ${listaPedido[0]['CODIGORELATORIO']}',
                  style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
              pw.Text('${listaPedido[0]['NOMECLIENTE']}',
                  style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
              pw.SizedBox(height: 5),
              pw.Text('--- Produtos ---',
                  style: pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold, font: pw.Font.courier())),

              // Produtos
              for (var item in listaPedido)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Codigo Produto: ${item['CODIGOPRODUTO']}',
                        style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
                    pw.Text('Descricao: ${item['NOMEPROD']}',
                        style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
                    pw.Text('Quantidade: ${item['QTDE']} X Valor Unitário: R\$ ${item['VALORUNITARIO']}',
                        style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
                    pw.Text('Total: R\$ ${item['VALORTOTAL']}',
                        style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
                    pw.SizedBox(height: 5),
                  ],
                ),

              // Totais
              pw.Text('Total Produtos: ${listaPedido[0]['TOTALPRODUTOS']}',
                  style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
              pw.Text('Valor Total: R\$ ${listaPedido[0]['VALOR']}',
                  style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
              pw.Text('Desconto: R\$ ${listaPedido[0]['DESCONTO']}',
                  style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
              pw.Text('Entrada: R\$ ${listaPedido[0]['VALORENTRADA']}',
                  style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
              pw.Text(
                  'Valor Parcelado: R\$ ${listaPedido[0]['VALORTOTALCALC'] / int.parse(listaPedido[0]['PRAZOPAGTO'])}',
                  style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
              pw.Text('Prazo Pagamento: ${listaPedido[0]['PRAZOPAGTO']}',
                  style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
              pw.Text('1º Vencimento: ${formatDate(listaPedido[0]['INICIO_VENCIMENTO'])}',
                  style: pw.TextStyle(fontSize: fontSize, font: pw.Font.courier())),
            ],
          );
        },
      ),
    );

    // Salvar o PDF em um arquivo temporário
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/recibo.pdf");
    await file.writeAsBytes(await pdf.save());

    // Abrir o arquivo PDF
    OpenFile.open(file.path);
  }

  Future<void> getBluetoothDevices() async {
    await requestPermissions();
    FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      availableDevices = results.map((result) => result.device).toList();
      notifyListeners();
    }).onDone(
      () {
        FlutterBluePlus.stopScan();
      },
    );
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

    selectedDevice = device;
    notifyListeners();
  }

  void showDeviceSelectionModal(BuildContext context, DataProvider dataProvider) {
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
                        title: Text(device.advName),
                        subtitle: Text(device.mtuNow.toString()),
                        trailing: selectedDevice?.mtuNow == device.mtuNow
                            ? Icon(
                                Icons.check,
                                color: Colors.green,
                              )
                            : null,
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
                      await printTicket(dataProvider);
                      Navigator.pop(context);
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
}
