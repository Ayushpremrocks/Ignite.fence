// ================= main.dart =================
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

// GlobalKey to manage theme switching
final GlobalKey<_IgniteFenceAppState> igniteFenceAppKey =
    GlobalKey<_IgniteFenceAppState>();

// Theme colors
const kPrimaryDarkColor = Color(0xFF1B263B);
const kSecondaryDarkColor = Color(0xFF0D1B2A);
const kCardColor = Color(0xFF283244);
const kAccentColor = Color(0xFF00BFFF);


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(IgniteFenceApp(key: igniteFenceAppKey)); // ❌ ERROR
}

class IgniteFenceApp extends StatefulWidget {
  const IgniteFenceApp({super.key});

  @override
  State<IgniteFenceApp> createState() => _IgniteFenceAppState();
}

class _IgniteFenceAppState extends State<IgniteFenceApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ignite Fence',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        cardColor: const Color(0xFF283244),
        primaryColor: kAccentColor,
      ),
      themeMode: _themeMode,
      // ✅ Launcher page = HomeScreen
      home: const HomeScreen(),
    );
  }
}
