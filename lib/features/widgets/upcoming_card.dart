import 'package:dose_tracker/core/constants/app_colors.dart';
import 'package:dose_tracker/core/models/medication.dart';
import 'package:dose_tracker/core/providers/medication_provider.dart';
import 'package:dose_tracker/core/utils/medication_utils.dart';
import 'package:dose_tracker/core/widgets/custom_text.dart';
import 'package:dose_tracker/features/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpcomingCard extends ConsumerWidget {
  final Medication medication;
  final VoidCallback onDelete;
  const UpcomingCard({required this.medication, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('upcoming_${medication.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(color: AppColors.missed),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          //borderRadius: BorderRadius.circular(16),
          //border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.iconBg,
                  ),
                  child: const Icon(
                    Icons.medication_rounded,
                    color: AppColors.primaryDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            medication.name,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          CustomText(
                            fmt(medication.scheduledTime),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ],
                      ),
                      CustomText(
                        dosageLabel(medication),
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ActionButton(
                    'Skipped',
                    true,
                    () => ref
                        .read(doseLogListProvider.notifier)
                        .logDose(
                          medicationId: medication.id,
                          status: 'skipped',
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ActionButton(
                    'Taken',
                    false,
                    () => ref
                        .read(doseLogListProvider.notifier)
                        .logDose(medicationId: medication.id, status: 'taken'),
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