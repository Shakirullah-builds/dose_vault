import 'package:dose_tracker/core/constants/app_colors.dart';
import 'package:dose_tracker/core/models/medication.dart';
import 'package:dose_tracker/core/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryTile extends StatelessWidget {
  final DoseLog log;
  final Medication? medication;
  final VoidCallback onDelete;
  const HistoryTile({
    required this.log,
    this.medication,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isTaken = log.status == 'taken';
    final name = medication?.name ?? 'Unknown';
    final timeStr = log.actionTime != null
        ? DateFormat('h:mm a').format(log.actionTime!)
        : '';

    return Dismissible(
      key: ValueKey('history_${log.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: AppColors.missed),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.undo, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          //borderRadius: BorderRadius.circular(14),
          //border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              //padding: ,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isTaken
                    ? AppColors.taken.withValues(alpha: 0.12)
                    : AppColors.missed.withValues(alpha: 0.1),
                // borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isTaken
                    ? Icons.check_circle_outline
                    : Icons.remove_circle_outline,
                color: isTaken ? AppColors.taken : AppColors.skippedText,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    name,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  if (medication != null)
                    CustomText(
                      '${medication!.dosage.truncateToDouble() == medication!.dosage ? medication!.dosage.toInt() : medication!.dosage}${medication!.unit}',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  isTaken ? 'Taken' : 'Skipped',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isTaken ? AppColors.taken : AppColors.skippedText,
                ),
                if (timeStr.isNotEmpty)
                  CustomText(
                    timeStr,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
