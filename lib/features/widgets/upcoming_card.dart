import 'package:dose_vault/core/constants/app_colors.dart';
import 'package:dose_vault/core/models/medication.dart';
import 'package:dose_vault/core/providers/medication_provider.dart';
import 'package:dose_vault/core/utils/medication_utils.dart';
import 'package:dose_vault/core/widgets/custom_text.dart';
import 'package:dose_vault/core/widgets/pill_chip.dart';
import 'package:dose_vault/features/widgets/action_button.dart';
import 'package:dose_vault/features/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dose_vault/features/medication/add_medication_screen.dart';

/// A provider that emits the current time every 5 seconds.
/// This allows the cards to dynamically update their state (Pending -> Actionable)
/// exactly when the time arrives, without the user needing to refresh the screen.
final timeTickProvider = StreamProvider.autoDispose<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 5), (_) => DateTime.now());
});

/// Premium Bento Box upcoming medication card.
///
/// If the scheduled time has passed, the action buttons are replaced
/// with an "Overdue" pill chip so the user sees it at a glance.
class UpcomingCard extends ConsumerWidget {
  final Medication medication;
  final VoidCallback onDelete;
  const UpcomingCard({
    required this.medication,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the time ticker to force a rebuild every 5 seconds
    final now = ref.watch(timeTickProvider).value ?? DateTime.now();
    
    // Strip milliseconds/microseconds to ensure exact minute comparisons
    final cleanNow = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    
    DateTime scheduledTime = medication.scheduledDateTime;

    // ── 1. THE CINDERELLA FIX (Logical Day) ──
    // Pull late-night PM pills back to "Yesterday"
    if (cleanNow.hour < 3 && scheduledTime.hour > 12) {
      scheduledTime = scheduledTime.subtract(const Duration(days: 1));
    }

    // ── 2. THE TIME TRAVEL FIX (Creation Boundary) ──
    // If the calculated time happened BEFORE the user even created this medication profile,
    // they cannot be overdue for it. We must push it forward to its first real occurrence.
    // We strip seconds to prevent false positives (e.g. creating at 10:30:05 for 10:30:00).
    final cleanCreatedAt = DateTime(
      medication.createdAt.year,
      medication.createdAt.month,
      medication.createdAt.day,
      medication.createdAt.hour,
      medication.createdAt.minute,
    );
    if (scheduledTime.isBefore(cleanCreatedAt)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // STATE 1: Pending (Time hasn't arrived yet)
    final isPending = scheduledTime.isAfter(cleanNow);

    // STATE 3: Overdue (15 minutes late)
    final isOverdue = scheduledTime.isBefore(
      cleanNow.subtract(const Duration(minutes: 15)),
    );

    return Dismissible(
      key: ValueKey('upcoming_${medication.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.missed,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: premiumCardDecoration,
        child: Column(
          children: [
            // ── Top row: icon + title + time ──
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.12),
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
                          Flexible(
                            child: CustomText(
                              medication.name,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            style: ButtonStyle(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(
                              Icons.more_vert,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () => _showMoreOptions(context, ref),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: CustomText(
                              dosageLabel(medication),
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PillChip(
                            label: fmt(medication.scheduledTime),
                            leadingIcon: Icons.access_time,
                            fontSize: 12,
                            textColor: AppColors.textPrimary.withValues(
                              alpha: 0.8,
                            ),
                          ),
                          if (isPending) ...[
                            const SizedBox(width: 8),
                            PillChip(
                              label: 'Pending',
                              leadingIcon: Icons.hourglass_empty,
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              // statusColor: AppColors.primary,
                              // iconColor: AppColors.primary,
                            ),
                          ],
                          if (!isPending && isOverdue) ...[
                            const SizedBox(width: 8),
                            const PillChip(
                              label: 'Overdue',
                              leadingIcon: Icons.access_time_rounded,
                              backgroundColor: Color(0xFFFFF3E0),
                              textColor: AppColors.warning,
                              iconColor: AppColors.warning,
                              // statusColor: AppColors.warning,
                              // iconColor: AppColors.warning,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── BOTTOM SECTION: The 4-State Machine ──

            // If it's NOT pending, the time has arrived. Show the action buttons!
            if (!isPending) ...[
              const SizedBox(height: 14),
              // The buttons ALWAYS appear as long as it's not Pending
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
                    child: ActionButton('Taken', false, () {
                      HapticFeedback.mediumImpact();
                      ref
                          .read(doseLogListProvider.notifier)
                          .logDose(
                            medicationId: medication.id,
                            status: 'taken',
                          );
                    }),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final cleanNow = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    
    DateTime scheduledTime = medication.scheduledDateTime;

    if (cleanNow.hour < 3 && scheduledTime.hour > 12) {
      scheduledTime = scheduledTime.subtract(const Duration(days: 1));
    }
    
    final cleanCreatedAt = DateTime(
      medication.createdAt.year,
      medication.createdAt.month,
      medication.createdAt.day,
      medication.createdAt.hour,
      medication.createdAt.minute,
    );
    
    if (scheduledTime.isBefore(cleanCreatedAt)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final isPending = scheduledTime.isAfter(cleanNow);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          if (isPending)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
                ref
                    .read(doseLogListProvider.notifier)
                    .logDose(medicationId: medication.id, status: 'taken');
              },
              child: CustomText(
                'Take Early',
                fontSize: 20,
                color: AppColors.primary,
                //fontWeight: FontWeight.bold,
              ),
              //child: const Text('Take Early'),
            ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddMedicationScreen(medication: medication),
                ),
              );
            },
            child: CustomText(
              'Edit Medication',
              fontSize: 20,
              color: AppColors.primary,
              //fontWeight: FontWeight.bold,
            ),
            //child: const Text('Edit Medication'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: CustomText(
              'Delete Medication',
              fontSize: 20,
              color: Colors.red,
              //fontWeight: FontWeight.bold,
            ),
            //child: const Text('Delete Medication'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: CustomText(
            'Cancel',
            fontSize: 20,
            color: Colors.red,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
