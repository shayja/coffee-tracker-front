// coffee_tracker/lib/features/coffee_tracker/presentation/widgets/coffee_log_list.dart
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/kv_type.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_bloc.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_event.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/widgets/coffee_entry_data.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/widgets/show_coffee_entry_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CoffeeLogList extends StatelessWidget {
  final List<CoffeeTrackerEntry> entries;
  final List<KvType> coffeeTypes;
  final List<KvType> sizes;

  const CoffeeLogList({
    super.key,
    required this.entries,
    required this.coffeeTypes,
    required this.sizes,
  });

  String? _getNameForKey(List<KvType> options, int? key) {
    if (key == null) return null;
    final match = options.cast<KvType?>().firstWhere(
      (element) => element?.key == key,
      orElse: () => null,
    );
    return match?.value;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final timeStr = DateFormat('HH:mm').format(entry.timestamp.toLocal());
        final coffeeTypeName = _getNameForKey(coffeeTypes, entry.coffeeType);
        final sizeName = _getNameForKey(sizes, entry.size);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              Icons.local_cafe,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              entry.notes?.isNotEmpty == true ? entry.notes! : '',
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // subtitle: Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Text(timeStr, style: Theme.of(context).textTheme.bodySmall),
            //     const SizedBox(height: 6),
            //     SizedBox(
            //       height: 10, // fixed height to avoid vertical growth
            //       child: SingleChildScrollView(
            //         scrollDirection: Axis.horizontal,
            //         child: Row(
            //           children: [
            //             if (coffeeTypeName != null)
            //               _buildLabelChip(
            //                 context,
            //                 coffeeTypeName,
            //                 Theme.of(context).colorScheme.primary,
            //               ),
            //             if (coffeeTypeName != null && sizeName != null)
            //               const SizedBox(width: 8),
            //             if (sizeName != null)
            //               _buildLabelChip(
            //                 context,
            //                 sizeName,
            //                 Theme.of(context).colorScheme.secondary,
            //               ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit entry',
                  onPressed: () async {
                    await showCoffeeEntryDialog(
                      context: context,
                      coffeeTypes: coffeeTypes,
                      sizes: sizes,
                      entry: CoffeeEntryData(
                        dateTime: entry.timestamp,
                        description: entry.notes ?? '',
                        coffeeTypeKey: entry.coffeeType,
                        sizeKey: entry.size,
                      ),
                      onConfirm:
                          (newDesc, newTimestamp, newCoffeeType, newSize) {
                            final updatedEntry = entry.copyWith(
                              notes: newDesc,
                              timestamp: newTimestamp,
                              coffeeType: newCoffeeType,
                              size: newSize,
                            );
                            context.read<CoffeeTrackerBloc>().add(
                              EditCoffeeEntry(
                                oldEntry: entry,
                                newEntry: updatedEntry,
                              ),
                            );
                          },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete entry',
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Entry'),
                        content: const Text(
                          'Are you sure you want to delete this coffee entry?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (context.mounted && confirmed == true) {
                      context.read<CoffeeTrackerBloc>().add(
                        DeleteCoffeeEntry(entry: entry),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coffee entry deleted')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabelChip(BuildContext context, String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color.withOpacity(0.15),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}
