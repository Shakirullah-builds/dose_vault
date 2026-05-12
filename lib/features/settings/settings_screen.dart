import 'package:flutter/material.dart';
import 'package:dose_tracker/core/widgets/custom_text.dart';
import 'package:dose_tracker/core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        title: const CustomText(
          'Settings',
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
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: CustomText(
              'Preferences',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          ListTile(
            title: const CustomText(
              'Notifications',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            subtitle: const CustomText(
              'Pause all medication reminders',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            trailing: Switch(
              value: _notificationsEnabled,
              activeColor: AppColors.primary,
              onChanged: (val) {
                setState(() {
                  _notificationsEnabled = val;
                });
              },
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: CustomText(
              'Legal',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          ListTile(
            title: const CustomText(
              'Privacy Policy',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            trailing: const Icon(Icons.open_in_new, color: AppColors.textSecondary),
            onTap: () {},
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: CustomText(
              'Danger Zone',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          ListTile(
            title: const CustomText(
              'Wipe My Data',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const CustomText(
                    'Are you sure?',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  content: const CustomText(
                    'This will permanently delete all your medication data from this device and the cloud.',
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const CustomText(
                        'Cancel',
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement Supabase wipe and sign out
                        Navigator.of(context).pop();
                      },
                      child: const CustomText(
                        'Wipe Data',
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          const Center(
            child: CustomText(
              'DoseTrack v1.0.0',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
