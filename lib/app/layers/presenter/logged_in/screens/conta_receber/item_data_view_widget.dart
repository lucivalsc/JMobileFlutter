import 'package:flutter/material.dart';
import 'package:jmobileflutter/app/common/utils/functions.dart';

class ItemDataViewWidget extends StatelessWidget {
  final dynamic pedido;
  final Function()? onTap;
  const ItemDataViewWidget({
    super.key,
    required this.pedido,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        pedido['DEVEDOR'] ?? 'Cliente não informado',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Text(
            "Total: R\$ ${double.parse(pedido['VALOR'].toString()).toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Código: ${pedido['CODIGO']}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            "Pedido: ${pedido['Titulo']}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          // Text(
          //   "Data Vencimento: ${pedido['DATVENC']}",
          //   style: const TextStyle(
          //     fontSize: 14,
          //     color: Colors.grey,
          //   ),
          // ),
          Text(
            "Endereço: ${pedido['ENDERECO']} - ${pedido['NUMEROLOGRADOURO']} - ${pedido['TELEFONE']}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }
}
