import 'package:dose_tracker/core/constants/app_colors.dart';
import 'package:dose_tracker/core/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Header extends StatelessWidget {
  final double adherence;
  final int takenCount;
  final int totalCount;
  const Header({
    required this.adherence,
    required this.takenCount,
    required this.totalCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      'Today',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    CustomText(
                      DateFormat('EEEE, MMM d').format(now),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: CircularPercentIndicator(
                radius: 70,
                lineWidth: 10,
                percent: adherence.clamp(0.0, 1.0),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      '${(adherence * 100).round()}%',
                      fontSize: 33,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    const CustomText(
                      'ADHERENCE',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ],
                ),
                progressColor: AppColors.primaryDark,
                backgroundColor: AppColors.ringTrack,
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 800,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: CustomText(
                '$takenCount of $totalCount medications taken',
                fontSize: 15,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
