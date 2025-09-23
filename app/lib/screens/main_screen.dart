// ================= screens/main_screen.dart =================
import 'package:flutter/material.dart';
import 'package:ignite_fence/screens/notification/admin_notifications_page.dart';
import 'package:ignite_fence/screens/notification/user_notifications_page.dart';
import 'package:ignite_fence/screens/panels/webcam.dart';
import 'package:ignite_fence/screens/violation_reports_page.dart';
import 'package:ignite_fence/screens/panels/readings.dart';
import 'panels/admin_panel.dart';
import 'panels/user_panel.dart';
import 'settings_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  final String role; // "admin" or "user"
  final VoidCallback toggleTheme;

  const MainScreen({
    super.key,
    required this.role,
    required this.toggleTheme,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // ---------------------- Drawer Item Model ----------------------
  final List<_DrawerItem> drawerItems = [
    _DrawerItem(icon: Icons.home, title: "Dashboard"),
    _DrawerItem(icon: Icons.report_problem, title: "Violations"),
    _DrawerItem(icon: Icons.bolt, title: "Readings"),
    _DrawerItem(icon: Icons.notifications, title: "Notifications"),
    _DrawerItem(icon: Icons.camera, title: "Live Feed"),
    _DrawerItem(icon: Icons.settings, title: "Settings"),
  ];

  @override
  Widget build(BuildContext context) {
    // ---------------------- Admin ----------------------
    final adminPages = <Widget>[
      const AdminDashboard(),
      const AdminNotificationsPage(),
      SettingsPage(toggleTheme: widget.toggleTheme),
    ];

    final adminItems = const <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
      BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
    ];

    // ---------------------- User ----------------------
    final userPages = <Widget>[
      UserDashboard(),
      const ViolationReportPage(),
      const DeviceReadingsPage(),
      const ViolationNotificationsPage(), // <-- just normal page
      const LiveFeedPage(), // <-- just normal LiveFeedPage
      SettingsPage(toggleTheme: widget.toggleTheme),
    ];

    // ---------------------- Role-based Scaffold ----------------------
    if (widget.role == "admin") {
      return Scaffold(
        body: Center(child: adminPages[_selectedIndex]),
        bottomNavigationBar: BottomNavigationBar(
          items: adminItems,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.cyan,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: const Color(0xFF1B263B),
        ),
      );
    } else {
      // User with Drawer
      return Scaffold(
        appBar: AppBar(
          title: Text(drawerItems[_selectedIndex].title),
          backgroundColor: const Color(0xFF1B263B),
          foregroundColor: Colors.white,
        ),
        drawer: Drawer(
          backgroundColor: const Color(0xFF0D1B2A),
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B263B), Color(0xFF0D1B2A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.cyan,
                      child: const Icon(Icons.person, color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Hello, User!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: drawerItems.length,
                  itemBuilder: (context, index) {
                    bool selected = _selectedIndex == index;
                    return ListTile(
                      leading: Icon(drawerItems[index].icon,
                          color: selected ? Colors.cyan : Colors.white),
                      title: Text(
                        drawerItems[index].title,
                        style: TextStyle(
                          color: selected ? Colors.cyan : Colors.white,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                          Navigator.pop(context); // close drawer
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        body: userPages[_selectedIndex],
      );
    }
  }
}

// ---------------------- Drawer Item Model ----------------------
class _DrawerItem {
  final IconData icon;
  final String title;

  const _DrawerItem({required this.icon, required this.title});
}
