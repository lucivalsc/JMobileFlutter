// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/comercial/pedidos/pedido_store.dart';
// import 'package:bluetooth_thermal_printer_plus/bluetooth_thermal_printer_plus.dart';

// import 'imports.dart';

// class ComumPrint {
//   solicitarPermissao() async {
//     if (await Permission.bluetooth.isGranted &&
//         await Permission.bluetoothScan.isGranted &&
//         await Permission.bluetoothConnect.isGranted) {
//       // Permissões já concedidas
//       return;
//     }

//     // Solicitar permissões
//     await [Permission.bluetooth, Permission.bluetoothScan, Permission.bluetoothConnect].request();
//   }

//   bool connected = false;
//   String titulo = '';
//   List availableBluetoothDevices = [];

//   Future<void> getBluetooth() async {
//     final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
//     debugPrint("Print $bluetooths");
//     availableBluetoothDevices = bluetooths!;
//   }

//   Future<bool> setConnect(String mac) async {
//     if (connected) {
//       await BluetoothThermalPrinter.disconnect();
//     }
//     var result = await BluetoothThermalPrinter.connect(mac);
//     if (result == "true") {
//       return connected = true;
//     } else {
//       return connected = false;
//     }
//   }

//   Future<void> printTicket(PedidoStore store) async {
//     var isConnected = await BluetoothThermalPrinter.connectionStatus;
//     if (isConnected == "true") {
//       List<int> bytes = await getTicket(store);
//       final result = await BluetoothThermalPrinter.writeBytes(bytes);
//       debugPrint("Print $result");
//     } else {
//       //Hadnle Not Connected Senario
//     }
//   }

//   Future<void> printGraphics() async {
//     var isConnected = await BluetoothThermalPrinter.connectionStatus;
//     if (isConnected == "true") {
//       List<int> bytes = await getGraphicsTicket();
//       final result = await BluetoothThermalPrinter.writeBytes(bytes);
//       debugPrint("Print $result");
//     } else {
//       //Hadnle Not Connected Senario
//     }
//   }

//   Future<List<int>> getGraphicsTicket() async {
//     List<int> bytes = [];

//     CapabilityProfile profile = await CapabilityProfile.load();
//     final generator = Generator(PaperSize.mm58, profile);

//     // Print QR Code using native function
//     bytes += generator.qrcode('example.com');

//     bytes += generator.hr();

//     // Print Barcode using native function
//     final List<dynamic> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4, 'wwww.google.com'];
//     bytes += generator.barcode(Barcode.upcA(barData));

//     bytes += generator.cut();

//     return bytes;
//   }
// }
