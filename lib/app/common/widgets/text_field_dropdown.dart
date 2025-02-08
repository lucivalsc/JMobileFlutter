import 'package:flutter/material.dart';

class TextFieldDropdown extends StatefulWidget {
  final String id;
  final String label;
  final String value;
  final List items; // Garantindo tipagem dos itens
  final String? initialValue; // Valor inicial como String
  final Function(Map<String, dynamic>) onItemSelected;
  final double? height;

  const TextFieldDropdown({
    super.key,
    required this.id,
    required this.label,
    required this.value,
    required this.items,
    required this.onItemSelected,
    this.initialValue,
    this.height = 45,
  });

  @override
  State<TextFieldDropdown> createState() => _TextFieldDropdownState();
}

class _TextFieldDropdownState extends State<TextFieldDropdown> {
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    // Configura o valor inicial, se existir
    if (widget.initialValue != null) {
      _selectedId = int.tryParse(widget.initialValue!);
    }
  }

  @override
  void didUpdateWidget(covariant TextFieldDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualiza o estado caso o valor inicial ou os itens mudem
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _selectedId = widget.initialValue != null ? int.tryParse(widget.initialValue!) : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        const SizedBox(height: 2),
        SizedBox(
          height: widget.height,
          child: DropdownMenu<int>(
            hintText: 'Selecione um(a) ${widget.label.toLowerCase()}',
            initialSelection: _selectedId, // Valor inicial para o menu
            dropdownMenuEntries: widget.items.map((item) {
              final int itemId = int.tryParse(item[widget.id].toString()) ?? -1;
              return DropdownMenuEntry<int>(
                value: itemId,
                label: item[widget.value].toString(),
              );
            }).toList(),
            onSelected: (selectedId) {
              if (selectedId != null) {
                setState(() {
                  _selectedId = selectedId;
                });
                final selectedItem = widget.items.firstWhere(
                  (item) => (int.tryParse(item[widget.id].toString()) ?? -1) == selectedId,
                );
                widget.onItemSelected({
                  widget.id: selectedItem[widget.id],
                  widget.value: selectedItem[widget.value],
                });
              }
            },
            trailingIcon: const Icon(
              Icons.arrow_drop_down,
              size: 16,
            ),
            // enableFilter: true,
            // requestFocusOnTap: true,
            expandedInsets: const EdgeInsets.all(0),
            menuHeight: 300,
          ),
        ),
      ],
    );
  }
}
