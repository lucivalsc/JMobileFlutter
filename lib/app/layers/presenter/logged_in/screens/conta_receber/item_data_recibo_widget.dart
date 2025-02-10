import 'package:flutter/material.dart';
import 'package:connect_force_app/app/common/styles/app_styles.dart';

class ItemDataReciboWidget extends StatelessWidget {
  final dynamic pedido;
  final Function()? onTap;
  final bool? isDevedor;

  const ItemDataReciboWidget({
    super.key,
    required this.pedido,
    this.onTap,
    this.isDevedor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: isDevedor != null && isDevedor!
          ? Text(
              pedido['DEVEDOR'] ?? 'Cliente não informado',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          // Valor total formatado
          Text(
            "Total: R\$ ${double.tryParse(pedido['VALOR'].toString())?.toStringAsFixed(2) ?? '0.00'}",
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Número do documento (Pedido)
          Text(
            "Pedido: ${pedido['NUMDOC'] ?? 'Não informado'}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          // Data de vencimento formatada
          Text(
            "Data Vencimento: ${pedido['DATVENC'] ?? 'Não informada'}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          // Endereço completo
          Text(
            "Endereço: ${pedido['ENDERECO'] ?? 'Não informado'} - ${pedido['NUMEROLOGRADOURO'] ?? 'S/N'} - ${pedido['TELEFONE'] ?? 'Não informado'}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: pedido['FLAGPAGO'] == 'S' ? AppStyles().primaryColor : Colors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  pedido['FLAGPAGO'] == 'S' ? 'Recebido' : 'Não Recebido',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }
}
