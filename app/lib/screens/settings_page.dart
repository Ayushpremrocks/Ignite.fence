// ================= screens/settings_page.dart =================
import 'package:flutter/material.dart';

// Import the custom color definitions from main.dart
import '../main.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const SettingsPage({super.key, required this.toggleTheme});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Define a map to hold the notification preferences
  Map<String, bool> notificationPreferences = {
    'Email': true,
    'Push Notifications': true,
    'Sounds': false,
    'Vibrations': true,
  };

  void _onSavePreferences() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notification preferences saved!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = Theme.of(context).brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;

    return Scaffold(
      // Set the background color to match the dark theme
      backgroundColor: kSecondaryDarkColor,
      appBar: AppBar(
        title: const Text("Settings"),
        // Set the app bar color to match the dark theme
        backgroundColor: kPrimaryDarkColor,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Dark Theme"),
            value: currentThemeMode == ThemeMode.dark,
            onChanged: (bool value) {
              widget.toggleTheme();
            },
            secondary: const Icon(Icons.nightlight_round, color: kAccentColor),
            activeColor: kAccentColor,
          ),
          const Divider(color: Colors.white24),

          // ** Notification Preferences Section **
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Notification Preferences",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kAccentColor,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text("Email Notifications"),
            value: notificationPreferences['Email']!,
            onChanged: (bool value) {
              setState(() {
                notificationPreferences['Email'] = value;
              });
            },
            // Style the switch and text for the dark theme
            activeColor: kAccentColor,
          ),
          SwitchListTile(
            title: const Text("Push Notifications"),
            value: notificationPreferences['Push Notifications']!,
            onChanged: (bool value) {
              setState(() {
                notificationPreferences['Push Notifications'] = value;
              });
            },
            activeColor: kAccentColor,
          ),
          SwitchListTile(
            title: const Text("Sounds"),
            value: notificationPreferences['Sounds']!,
            onChanged: (bool value) {
              setState(() {
                notificationPreferences['Sounds'] = value;
              });
            },
            activeColor: kAccentColor,
          ),
          SwitchListTile(
            title: const Text("Vibrations"),
            value: notificationPreferences['Vibrations']!,
            onChanged: (bool value) {
              setState(() {
                notificationPreferences['Vibrations'] = value;
              });
            },
            activeColor: kAccentColor,
          ),
          const Divider(color: Colors.white24),

          // ** Other Settings (Language, etc.) **
          ListTile(
            title: const Text("Language"),
            subtitle: const Text("English"),
            leading: const Icon(Icons.language, color: kAccentColor),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Language settings")),
              );
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            title: const Text("Notifications"),
            subtitle: const Text("Manage your notifications"),
            leading: const Icon(Icons.notifications, color: kAccentColor),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Notification settings")),
              );
            },
          ),
          const Divider(color: Colors.white24),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccentColor,
            foregroundColor: Colors.white,
          ),
          onPressed: _onSavePreferences,
          child: const Text("Save Preferences"),
        ),
      ),
    );
  }
}