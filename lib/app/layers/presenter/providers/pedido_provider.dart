import 'package:flutter/material.dart';

class PedidoProvider extends ChangeNotifier {
  List listaPedidos = [];

  addListaPedidos(Map item) {
    listaPedidos.add(item);
    notifyListeners();
  }

  removeItem(int index) {
    listaPedidos.removeAt(index);
    notifyListeners();
  }
}
