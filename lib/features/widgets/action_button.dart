import 'package:dose_tracker/core/constants/app_colors.dart';
import 'package:dose_tracker/core/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final bool isSkip;
  final VoidCallback onTap;
  const ActionButton(this.label, this.isSkip, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSkip
          ? AppColors.skipped
          : AppColors.taken.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isSkip) ...[
                const Icon(Icons.check, size: 18, color: AppColors.taken),
                const SizedBox(width: 6),
              ],
              CustomText(
                label,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSkip ? AppColors.skippedText : AppColors.taken,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
