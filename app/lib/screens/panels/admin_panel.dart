import 'package:flutter/material.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../home_screen.dart';

const kPrimaryDarkColor = Color(0xFF1B263B);
const kSecondaryDarkColor = Color(0xFF0D1B2A);
const kCardColor = Color(0xFF283244);
const kAccentColor = Color(0xFF00BFFF);

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final roleController = TextEditingController();

  final List<Map<String, String>> violations = [
    {"user": "User X", "time": "19:11:39", "violation": "Wire Cut"},
    {"user": "Admin Y", "time": "19:11:32", "violation": "Voltage Drop"},
    {"user": "Admin Y", "time": "19:11:25", "violation": "Power Failure"},
    {"user": "Farmer A", "time": "19:11:18", "violation": "Power Failure"},
    {"user": "Guard B", "time": "19:11:12", "violation": "Wire Cut"},
  ];

  List<Map<String, String>> addedUsers = [];

  void _addUser() {
    if (nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        roleController.text.isNotEmpty) {
      final newUser = {
        "user": nameController.text,
        "email": emailController.text,
        "role": roleController.text,
      };
      setState(() {
        addedUsers.add(newUser);
      });
      nameController.clear();
      emailController.clear();
      roleController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${newUser['user']} added successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields to add a user.")),
      );
    }
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.12)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAccentColor.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kAccentColor.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }

  Widget _buildAddUserCard(BuildContext context) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Add User",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kAccentColor,
            ),
          ),
          const SizedBox(height: 20),
          CustomTextField(controller: nameController, label: "Name"),
          const SizedBox(height: 16),
          CustomTextField(controller: emailController, label: "Email"),
          const SizedBox(height: 16),
          CustomTextField(controller: roleController, label: "Role"),
          const SizedBox(height: 24),
          CustomButton(text: "Add User", onPressed: _addUser, color: const Color(0xFF1B263B))  
        ]
      ),
    );
  }

  Widget _buildViolationsCard() {
    final combinedList = [
      ...addedUsers.reversed.map((user) => {
            'user': user['user']!,
            'time': 'Just now',
            'violation': 'New User'
          }),
      ...violations
    ];

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "User Violations",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kAccentColor,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: kPrimaryDarkColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
              child: Row(
                children: const [
                  Expanded(flex: 3, child: Text("User", style: TextStyle(fontWeight: FontWeight.bold, color: kAccentColor))),
                  Expanded(flex: 2, child: Text("Time", style: TextStyle(fontWeight: FontWeight.bold, color: kAccentColor))),
                  Expanded(flex: 4, child: Text("Violation", style: TextStyle(fontWeight: FontWeight.bold, color: kAccentColor))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: combinedList.length,
            itemBuilder: (context, index) {
              final row = combinedList[index];
              final bgColor = index % 2 == 0
                  ? Colors.white.withOpacity(0.03)
                  : Colors.white.withOpacity(0.05);
              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(row['user']!, style: const TextStyle(color: Colors.white))),
                    Expanded(flex: 2, child: Text(row['time']!, style: const TextStyle(color: Colors.white70))),
                    Expanded(flex: 4, child: Text(row['violation']!, style: const TextStyle(color: Colors.white70))),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSecondaryDarkColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Admin Panel",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildAddUserCard(context)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildViolationsCard()),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildAddUserCard(context),
                    const SizedBox(height: 20),
                    _buildViolationsCard(),
                  ],
                );
              }
            }),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 10,
                  shadowColor: Colors.redAccent.withOpacity(0.7),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text("Logout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
