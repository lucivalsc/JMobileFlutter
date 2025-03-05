import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> checkIfHeroIconExists(String path) async {
  try {
    await rootBundle.load(path);
    return path;
  } catch (e) {
    return null;
  }
}

String extractMonthAndYear(String fullDate) {
  // Assume que a data está no formato 'dd/mm/yyyy'
  // Se estiver em um formato diferente, ajuste conforme necessário
  List<String> dateParts = fullDate.split('/');
  if (dateParts.length == 3) {
    int day = int.tryParse(dateParts[0]) ?? 0;
    int month = int.tryParse(dateParts[1]) ?? 0;
    int year = int.tryParse(dateParts[2]) ?? 0;

    if (day >= 1 && day <= 31 && month >= 1 && month <= 12 && year != 0) {
      // Retorna o formato 'MM/yyyy'
      return '$month/${year.toString().padLeft(4, '0')}';
    }
  }

  // Retorna a data completa se houver algum problema com o formato
  return fullDate;
}

String formatCurrency(double? number, {String? symbol = 'R\$'}) {
  return NumberFormat.currency(locale: "pt_BR", symbol: symbol).format(number ?? 0.00);
}

String formatter(DateTime? date) {
  if (date != null) {
    return DateFormat('dd/MM/yyyy').format(date);
  } else {
    return '';
  }
}

String formatDatetime(String? date) =>
    date != null ? DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.parse(date).toLocal()) : '--';

String formatDate(String? date, {bool? showTime = false}) {
  return date != null
      ? DateFormat('dd/MM/yyyy ${showTime == true ? 'HH:mm:ss' : ''}').format(DateTime.parse(date).toLocal())
      : '-';
}

String formatTime(String? date, {bool? showTime = false}) {
  return date != null ? DateFormat('HH:mm:ss').format(DateTime.parse(date).toLocal()) : '-';
}

String formatDateTimeDivider(String? date) {
  return date != null ? DateFormat('dd/MM/yyyy - HH:mm:ss').format(DateTime.parse(date)) : '-';
}

DateTime formatarData(String data) {
  // Assume que a data está no formato 'dd/mm/yyyy'
  List<String> dateParts = data.split('/');
  if (dateParts.length == 3) {
    int day = int.tryParse(dateParts[0]) ?? 1;
    int month = int.tryParse(dateParts[1]) ?? 1;
    int year = int.tryParse(dateParts[2]) ?? 2000;

    // Retorna um objeto DateTime
    return DateTime(year, month, day);
  }

  // Retorna a data atual se houver algum problema com o formato
  return DateTime.now();
}

String capitalize(String string) {
  string = string.trim();
  final exceptions = ["do", "dos", "da", "das", "de"];
  final fullUpperCase = ['ltda', 'cia', 'go', 'km'];
  if (string == '') {
    return '-';
  } else if (string.split(' ').length > 1) {
    return string
        .toLowerCase()
        .split(" ")
        .map((sub) {
          if (sub == '') {
            return sub;
          } else if (fullUpperCase.contains(sub)) {
            return sub.toUpperCase();
          } else if (!exceptions.contains(sub)) {
            return sub[0].toUpperCase() + sub.substring(1);
          } else {
            return sub;
          }
        })
        .toList()
        .join(" ");
  } else {
    return string.substring(0, 1).toUpperCase() + string.substring(1);
  }
}

Future<void> startHiveStuff() async {
  await getApplicationDocumentsDirectory().then((directory) => Hive.init(directory.path));
}

Widget base64ToImage(String base64Image) {
  try {
    Uint8List bytes = base64Decode(base64Image);
    return Image.memory(
      bytes,
      // fit: BoxFit.fill,
    );
  } catch (e) {
    // Trata o erro aqui, por exemplo, retornando um ícone de imagem padrão
    return const Icon(Icons.image);
  }
}

// Map<dynamic, dynamic> reorganizeData(Map<String, dynamic> jsonData, String key) {
//   List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(jsonData['data']);

//   if (key == 'total') {
//     dataList.sort((a, b) => a[key].compareTo(b[key]));
//   }

//   if (key == 'vencimento' || key == 'movimento') {
//     // Convertendo as strings de data para objetos DateTime
//     for (var data in dataList) {
//       // Verificando se a data está no formato "dd/MM/yyyy"
//       RegExp datePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$');
//       if (datePattern.hasMatch(data[key])) {
//         List<String> dateParts = data[key].split('/');
//         int day = int.parse(dateParts[0]);
//         int month = int.parse(dateParts[1]);
//         int year = int.parse(dateParts[2]);
//         data[key] = DateTime(year, month, day);
//       } else {
//         throw FormatException('Formato de data inválido: ${data[key]}');
//       }
//     }

//     // Ordenando os dados com base nas datas
//     dataList.sort((a, b) => b[key].compareTo(a[key]));
//   }

//   jsonData['data'] = dataList;
//   return jsonData;
// }

Map<dynamic, dynamic> reorganizeData(Map<String, dynamic> jsonData, key) {
  List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(jsonData['data']);
  if (key == 'total') {
    dataList.sort((a, b) => a[key].compareTo(b[key]));
  }

  jsonData['data'] = dataList;
  return jsonData;
}

double calcularPercentual(double valorLiquido, double valorBruto) {
  // Verifica se o valor bruto é zero para evitar divisão por zero
  if (valorBruto == 0) {
    // Retorna 0 se o valor bruto for zero
    return 0;
  }
  // Calcula o percentual dividindo o valor líquido pelo valor bruto e multiplicando por 100
  return (valorLiquido / valorBruto) * 100;
}

BoxDecoration getIndicatorColor(int index) {
  // Define a cor do indicador com base no índice da guia ativa
  switch (index) {
    case 0:
      return BoxDecoration(
        borderRadius: BorderRadius.circular(2.0),
        color: Colors.blue,
      );
    case 1:
      return BoxDecoration(
        borderRadius: BorderRadius.circular(2.0),
        color: Colors.red,
      );
    case 2:
      return BoxDecoration(
        borderRadius: BorderRadius.circular(2.0),
        color: Colors.blue,
      );
    default:
      return BoxDecoration(
        borderRadius: BorderRadius.circular(2.0),
        color: Colors.transparent,
      ); // Se o índice estiver fora do intervalo, retorna transparente
  }
}

List<Color> colorList = [
  // Colors.white,
  Colors.blue,
  Colors.blue,
  Colors.orange,
  Colors.red,
];

List<Color> myColorList = [
  Colors.purple,
  Colors.teal,
  Colors.amber,
  Colors.indigo,
  Colors.pink,
  Colors.cyan,
  Colors.lime,
  Colors.deepPurple,
  Colors.lightBlue,
  Colors.deepOrange,
  Colors.yellow,
  Colors.brown,
  Colors.grey,
  Colors.blueAccent,
  Colors.blueAccent,
  Colors.orangeAccent,
  Colors.redAccent,
  Colors.purpleAccent,
  Colors.tealAccent,
  Colors.amberAccent,
  Colors.indigoAccent,
  Colors.pinkAccent,
  Colors.cyanAccent,
  Colors.limeAccent,
  Colors.deepPurpleAccent,
  Colors.lightBlueAccent,
  Colors.deepOrangeAccent,
  Colors.yellowAccent,
  Colors.brown,
  Colors.grey,
  Colors.blue[900]!,
  Colors.blue[900]!,
  Colors.orange[900]!,
  Colors.red[900]!,
  Colors.purple[900]!,
  Colors.teal[900]!,
  Colors.amber[900]!,
  Colors.indigo[900]!,
  Colors.pink[900]!,
  Colors.cyan[900]!,
  Colors.lime[900]!,
  Colors.deepPurple[900]!,
  Colors.lightBlue[900]!,
  Colors.deepOrange[900]!,
  Colors.yellow[900]!,
  Colors.brown[900]!,
  const Color.fromARGB(255, 35, 35, 109),
  const Color.fromRGBO(0, 128, 0, 1),
  const Color.fromRGBO(255, 165, 0, 1),
  const Color.fromRGBO(255, 0, 0, 1),
  const Color.fromRGBO(128, 0, 128, 1),
  const Color.fromRGBO(0, 128, 128, 1),
  const Color.fromRGBO(255, 191, 0, 1),
  const Color.fromRGBO(75, 0, 130, 1),
  const Color.fromRGBO(255, 105, 180, 1),
  const Color.fromRGBO(0, 255, 255, 1),
  const Color.fromRGBO(50, 205, 50, 1),
  const Color.fromRGBO(138, 43, 226, 1),
  const Color.fromRGBO(173, 216, 230, 1),
  const Color.fromRGBO(255, 140, 0, 1),
  const Color.fromRGBO(255, 255, 0, 1),
  const Color.fromRGBO(165, 42, 42, 1),
  const Color.fromRGBO(128, 128, 128, 1),
  const Color.fromRGBO(0, 0, 139, 1),
  const Color.fromRGBO(0, 128, 0, 1),
  const Color.fromRGBO(255, 69, 0, 1),
  const Color.fromRGBO(0, 128, 128, 1),
  const Color.fromARGB(255, 27, 27, 163),
  const Color.fromRGBO(0, 128, 0, 1),
  const Color.fromARGB(255, 88, 25, 1),
  const Color.fromRGBO(0, 128, 128, 1),
];

Color getColorFromList(int index, List<Color> colorList) {
  if (colorList.isEmpty) {
    // Retorna uma cor padrão caso a lista esteja vazia
    return Colors.grey;
  }

  final int colorIndex = index % colorList.length;
  return colorList[colorIndex];
}

// Função para buscar o endereço pelo CEP usando a API ViaCEP
Future<Map<String, dynamic>> buscarEnderecoPorCep(String cep) async {
  final url = 'https://viacep.com.br/ws/$cep/json/';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // Decodifica o JSON retornado pela API
    Map<String, dynamic> data = json.decode(response.body);

    // Verifica se a API retornou um erro (ex.: CEP inválido)
    if (data.containsKey('erro')) {
      throw Exception('CEP não encontrado.');
    }

    return data;
  } else {
    throw Exception('Erro ao consultar o CEP. Status code: ${response.statusCode}');
  }
}

String formatJson(Map<String, dynamic> data) {
  final buffer = StringBuffer('{');

  data.forEach((key, value) {
    if (key == 'entity' || key == 'in_insert' || key == 'new_id' || key == 'select') {
      buffer.write('"$key": ${_formatValue(value)}, ');
    } else {
      buffer.write('$key: ${_formatValue(value)}, ');
    }
  });

  if (buffer.length > 1) {
    buffer.write('}');
  }

  return buffer.toString().replaceAll(', }', '}'); // Remove a última vírgula extra
}

String _formatValue(dynamic value) {
  if (value is String) {
    return '"$value"';
  } else if (value is bool) {
    return value ? '"true"' : '"false"';
  } else if (value is List) {
    return '[${value.map((e) => _formatValue(e)).join(', ')}]';
  } else if (value is Map<String, dynamic>) {
    return formatJson(value);
  }
  return value.toString();
}
