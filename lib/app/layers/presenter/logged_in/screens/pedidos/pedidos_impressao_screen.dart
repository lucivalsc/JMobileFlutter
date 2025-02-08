// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// class PedidosImpressaoScreen extends StatefulWidget {
//   const PedidosImpressaoScreen({super.key});

//   @override
//   PedidosImpressaoScreenState createState() => PedidosImpressaoScreenState();
// }

// class PedidosImpressaoScreenState extends State<PedidosImpressaoScreen> {
//   BluetoothConnection? _connection;
//   bool _isConnected = false;

//   // Função para conectar ao dispositivo Bluetooth
//   Future<void> _connectBluetooth() async {
//     try {
//       final BluetoothDevice? selectedDevice = await FlutterBluetoothSerial.instance.getBondedDevices().then((devices) {
//         // Use `firstWhereOrNull` from the `collection` package to handle nullable results
//         return devices.firstWhere((device) => device.name == "SuaImpressora");
//       });

//       if (selectedDevice != null) {
//         _connection = await BluetoothConnection.toAddress(selectedDevice.address);
//         setState(() {
//           _isConnected = true;
//         });
//         print("Conectado ao dispositivo Bluetooth");
//       } else {
//         print("Nenhum dispositivo Bluetooth encontrado");
//       }
//     } catch (e) {
//       print("Erro ao conectar ao Bluetooth: $e");
//     }
//   }

//   // Função para imprimir via Bluetooth
//   void _printViaBluetooth(String text) {
//     if (_connection != null && _isConnected) {
//       _connection!.output.add(Uint8List.fromList(text.codeUnits));
//       _connection!.output.allSent.then((_) {
//         print("Impressão enviada com sucesso");
//       }).catchError((e) {
//         print("Erro ao enviar impressão: $e");
//       });
//     } else {
//       print("Bluetooth não conectado");
//     }
//   }

//   // Função para simular ImprimirPedido
//   Future<void> _imprimirPedido(String codigoPedido) async {
//     final database = openDatabase(
//       join(await getDatabasesPath(), 'app_database.db'),
//       onCreate: (db, version) {
//         return db.execute(
//           "CREATE TABLE IF NOT EXISTS pedidos(id TEXT PRIMARY KEY, nomeCliente TEXT, valorTotal REAL)",
//         );
//       },
//       version: 1,
//     );

//     final db = await database;
//     final List<Map<String, dynamic>> result = await db.query(
//       'pedidos',
//       where: 'id = ?',
//       whereArgs: [codigoPedido],
//     );

//     if (result.isNotEmpty) {
//       final pedido = result.first;
//       String textoPedidosImpressao = """
// PRE-VENDA MOBILE
// DT IMP.: ${DateTime.now()}
// CLIENTE: ${pedido['nomeCliente']}
// VALOR TOTAL: R\$ ${pedido['valorTotal'].toStringAsFixed(2)}
// """;
//       _printViaBluetooth(textoPedidosImpressao);
//     } else {
//       print("Pedido não encontrado");
//     }
//   }

//   // Função para simular ImprimirRecebimentoMobile
//   Future<void> _imprimirRecebimentoMobile() async {
//     // Lógica similar à função acima, adaptando para recebimentos
//     String textoPedidosImpressao = """
// --- CLIENTES RECEBIDOS ---
// USUARIO: UsuarioLogado
// PERIODO: 01/01/2023 - 31/01/2023
// TOTAL GERAL: R\$ 1000.00
// """;
//     _printViaBluetooth(textoPedidosImpressao);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Impressão via Bluetooth"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _connectBluetooth,
//               child: Text(_isConnected ? "Conectado" : "Conectar Bluetooth"),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _imprimirPedido("12345"),
//               child: Text("Imprimir Pedido"),
//             ),
//             ElevatedButton(
//               onPressed: _imprimirRecebimentoMobile,
//               child: Text("Imprimir Recebimento"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
