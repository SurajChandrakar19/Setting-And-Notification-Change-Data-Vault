import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart'; // For specific colors if not themed
import 'login_screen.dart'; // For logout navigation
import 'privacy_policy_screen.dart';
import 'help_support_screen.dart';
import 'account_details_screen.dart';
import 'account_settings_screen.dart';
import '../providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsTabScreen extends StatefulWidget {
  const SettingsTabScreen({super.key});

  @override
  State<SettingsTabScreen> createState() => _SettingsTabScreenState();
}

class _SettingsTabScreenState extends State<SettingsTabScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 20),
          // User Profile Summary Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: accentLighterBlue,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: whiteColor,
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Name',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'user.email@example.com',
                      style: TextStyle(fontSize: 14, color: subtleTextColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 40),

          // Settings Options
          _buildSettingsItem(
            context,
            icon: Icons.account_circle_outlined,
            title: 'Account Details',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountDetailsScreen(),
                ),
              );
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Account Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountSettingsScreen(),
                ),
              );
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
              return ListTile(
                leading: const Icon(
                  Icons.dark_mode_outlined,
                  color: primaryDarkBlue,
                ),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (bool value) async {
                    await themeProvider.toggleTheme(value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value ? 'Dark mode enabled' : 'Dark mode disabled',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  activeThumbColor: accentLighterBlue,
                ),
                onTap: () async {
                  final newValue = !isDarkMode;
                  await themeProvider.toggleTheme(newValue);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newValue ? 'Dark mode enabled' : 'Dark mode disabled',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpSupportScreen()),
              );
            },
          ),
          const Divider(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
              ),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: whiteColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryDarkBlue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: subtleTextColor),
      onTap: onTap,
    );
  }
}
