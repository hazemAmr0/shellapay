import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../scan/domain/entities/receipt_item.dart';
import '../bloc/review_bloc.dart';
import '../widgets/editable_item_card.dart';
import '../widgets/manual_entry_form.dart';
import '../widgets/tax_service_input.dart';

class ReviewPage extends StatelessWidget {
  final List<ReceiptItem> extractedItems;

  const ReviewPage({super.key, required this.extractedItems});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReviewBloc>()..add(InitializeReview(extractedItems)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Review Items')),
        body: BlocConsumer<ReviewBloc, ReviewState>(
          listener: (context, state) {
            if (state.isConfirmed) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Items confirmed! Ready for Split Phase.'), 
                  backgroundColor: AppColors.success
                ),
              );
              Future.delayed(const Duration(seconds: 1), () => context.go('/'));
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ManualEntryForm(
                      onAdd: (item) => context.read<ReviewBloc>().add(AddItemEvent(item)),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return EditableItemCard(
                            item: item,
                            onEdit: (updated) => context.read<ReviewBloc>().add(EditItemEvent(updated)),
                            onDelete: () => context.read<ReviewBloc>().add(RemoveItemEvent(item.id)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    TaxServiceInput(
                      initialTax: state.tax,
                      initialService: state.service,
                      onTaxChanged: (val) => context.read<ReviewBloc>().add(UpdateTaxEvent(val)),
                      onServiceChanged: (val) => context.read<ReviewBloc>().add(UpdateServiceEvent(val)),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Subtotal: \$${state.subtotal.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textSecondary)),
                              Text('Total: \$${state.total.toStringAsFixed(2)}', 
                                style: const TextStyle(color: AppColors.secondary, fontSize: 20, fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: state.items.isEmpty 
                                ? null 
                                : () => context.read<ReviewBloc>().add(ConfirmReviewEvent()),
                            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
