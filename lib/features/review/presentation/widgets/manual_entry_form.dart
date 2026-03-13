import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../scan/domain/entities/receipt_item.dart';

class ManualEntryForm extends StatefulWidget {
  final Function(ReceiptItem) onAdd;

  const ManualEntryForm({super.key, required this.onAdd});

  @override
  State<ManualEntryForm> createState() => _ManualEntryFormState();
}

class _ManualEntryFormState extends State<ManualEntryForm> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  void _submit() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text) ?? 0.0;
    
    if (name.isNotEmpty && price > 0) {
      widget.onAdd(ReceiptItem(id: const Uuid().v4(), name: name, price: price));
      _nameController.clear();
      _priceController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Item name...'),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: '\$ Price'),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primaryLight, size: 36),
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
