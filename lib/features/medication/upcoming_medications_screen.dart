import 'package:dose_vault/core/constants/app_colors.dart';
import 'package:dose_vault/core/models/medication.dart';
import 'package:dose_vault/core/providers/medication_provider.dart';
import 'package:dose_vault/core/services/notification_service.dart';
import 'package:dose_vault/core/services/supabase_sync_service.dart';
import 'package:dose_vault/core/widgets/custom_elevated_button.dart';
import 'package:dose_vault/core/widgets/custom_empty_state.dart';
import 'package:dose_vault/core/widgets/custom_text.dart';
import 'package:dose_vault/core/widgets/custom_text_field.dart';
import 'package:dose_vault/core/widgets/top_toast.dart';
import 'package:dose_vault/features/widgets/upcoming_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full screen view displaying all upcoming scheduled medications
/// with a search bar for quickly finding specific medications.
class UpcomingMedicationsScreen extends ConsumerStatefulWidget {
  const UpcomingMedicationsScreen({super.key});

  @override
  ConsumerState<UpcomingMedicationsScreen> createState() =>
      _UpcomingMedicationsScreenState();
}

class _UpcomingMedicationsScreenState
    extends ConsumerState<UpcomingMedicationsScreen> {
  String _searchQuery = '';

  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medications = ref.watch(medicationListProvider);
    final doseLogs = ref.watch(doseLogListProvider);
    final isSyncing = ref.watch(isInitialSyncingProvider);

    final now = DateTime.now();

    // ── THE LOGICAL DAY FIX (3:00 AM Rollover) ──
    final isLateNight = now.hour < 3;
    final logicalDate = isLateNight
        ? now.subtract(const Duration(days: 1))
        : now;

    // Define the exact 24-hour window: 3:00 AM to 3:00 AM next day
    final logicalStart = DateTime(
      logicalDate.year,
      logicalDate.month,
      logicalDate.day,
      3,
      0,
    );
    final logicalEnd = logicalStart.add(const Duration(hours: 24));

    // ONLY grab logs that happened during this logical 24-hour shift
    final currentLogs = doseLogs.where((l) {
      final time = l.actionTime ?? l.date;
      return time.isAfter(logicalStart.subtract(const Duration(seconds: 1))) &&
          time.isBefore(logicalEnd);
    }).toList();

    final upcoming = <Medication>[];

    for (final med in medications) {
      final hasLog = currentLogs.any((l) => l.medicationId == med.id);
      if (!hasLog) {
        upcoming.add(med);
      }
    }

    upcoming.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    // ── APPLY SEARCH FILTER ──
    final filteredUpcoming = _searchQuery.isEmpty
        ? upcoming
        : upcoming
              .where(
                (med) => med.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()),
              )
              .toList();

    final hasAnyUpcoming = upcoming.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.scaffoldBg,
        centerTitle: true,
        title: const CustomText(
          'Upcoming Schedule',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── SEARCH BAR (only when there are upcoming meds) ──
            if (hasAnyUpcoming) _buildSearchBar(),

            Expanded(
              child: filteredUpcoming.isEmpty
                  ? (isSyncing
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              CustomText('Restoring data...'),
                            ],
                          ),
                        )
                      : hasAnyUpcoming
                          // Search returned no matches
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 56,
                                    color: AppColors.textHint.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const CustomText(
                                    'No matching medications',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(height: 4),
                                  const CustomText(
                                    'Try a different search term.',
                                    fontSize: 13,
                                    color: AppColors.textHint,
                                  ),
                                ],
                              ),
                            )
                          // Genuinely no upcoming meds
                          : CustomEmptyState(
                              title: 'All caught up! 🎉',
                              subtitle:
                                  "You've taken or skipped all scheduled medications for today.",
                              icon: Icons.check_circle_outline,
                              actionButton: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: CustomElevatedButton(
                                  label: 'Go Home',
                                  borderRadius: 30,
                                  onPressed: () =>
                                      Navigator.of(context).pop(),
                                ),
                              ),
                            ))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: filteredUpcoming.length,
                      itemBuilder: (context, index) {
                        final med = filteredUpcoming[index];
                        return UpcomingCard(
                          medication: med,
                          onDelete: () {
                            ref
                                .read(medicationListProvider.notifier)
                                .removeMedication(med.id);
                            ref
                                .read(notificationServiceProvider)
                                .cancelReminder(med.id);

                            TopToast.showWithUndo(
                              context,
                              message: 'Medication deleted.',
                              onUndo: () async {
                                await ref
                                    .read(medicationListProvider.notifier)
                                    .addMedication(med);
                                await ref
                                    .read(notificationServiceProvider)
                                    .scheduleDoseReminder(med);
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SEARCH BAR ──
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: CustomTextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) => setState(() => _searchQuery = value.trim()),
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        hintText: 'Search by medication name...',
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textHint,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary,
          size: 22,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _searchFocusNode.unfocus();
                  setState(() => _searchQuery = '');
                },
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: AppColors.cardBg,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
