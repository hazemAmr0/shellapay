import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TaxServiceInput extends StatelessWidget {
  final double initialTax;
  final double initialService;
  final Function(double) onTaxChanged;
  final Function(double) onServiceChanged;

  const TaxServiceInput({
    super.key,
    required this.initialTax,
    required this.initialService,
    required this.onTaxChanged,
    required this.onServiceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Additional Charges (distributed proportionally)', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: initialTax > 0 ? initialTax.toStringAsFixed(2) : '',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Tax Amount', prefixText: '\$'),
                    onChanged: (val) => onTaxChanged(double.tryParse(val) ?? 0.0),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: initialService > 0 ? initialService.toStringAsFixed(2) : '',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Service/Tip', prefixText: '\$'),
                    onChanged: (val) => onServiceChanged(double.tryParse(val) ?? 0.0),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
