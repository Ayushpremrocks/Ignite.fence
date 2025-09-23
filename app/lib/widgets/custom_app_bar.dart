//
// // We'll create a custom AppBar to match the navigation bar from the image
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../screens/home_screen.dart';
// import '../screens/login_screen.dart';
// // ================= screens/login_screen.dart =================
// // (imports and other classes remain the same)
//
// // We'll create a custom AppBar to match the navigation bar from the image
// class CustomAppBar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//       color: kPrimaryDarkColor,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text(
//             "Ignite.Fence",
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           // Wrap the Row of buttons in an Expanded widget
//           Expanded(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
//               children: [
//                 TextButton.icon(
//                   onPressed: () {
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(builder: (_) => const HomeScreen()),
//                           (Route<dynamic> route) => false,
//                     );
//                   },
//                   icon: const Icon(Icons.home, color: Colors.white),
//                   label: const Text(
//                     "Home",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton.icon(
//                   onPressed: () {},
//                   icon: const Icon(Icons.admin_panel_settings, color: Colors.black),
//                   label: const Text(
//                     "Admin Panel",
//                     style: TextStyle(color: Colors.black),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: kAccentColor,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 TextButton.icon(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const UserLoginScreen()),
//                     );
//                   },
//                   icon: const Icon(Icons.person, color: Colors.white),
//                   label: const Text(
//                     "User Panel",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }