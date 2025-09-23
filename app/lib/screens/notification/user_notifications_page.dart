// ================= screens/notification/user_notifications_page.dart =================
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class Violation {
  final String id;
  final String deviceId;
  final String voltage;
  final String current;
  final String power;
  final String createdAt;
  final String piezo;
  final String isAlert;
  final String abnormal;

  Violation({
    required this.id,
    required this.deviceId,
    required this.voltage,
    required this.current,
    required this.power,
    required this.createdAt,
    required this.piezo,
    required this.isAlert,
    required this.abnormal,
  });

  factory Violation.fromJson(Map<String, dynamic> json) {
    return Violation(
      id: json['id'].toString(),
      deviceId: json['device_id'].toString(),
      voltage: json['voltage'].toString(),
      current: json['current'].toString(),
      power: json['power'].toString(),
      createdAt: json['created_at'].toString(),
      piezo: json['piezo'].toString(),
      isAlert: json['is_alert'].toString(),
      abnormal: json['abnormal']?.toString() ?? "0",
    );
  }
}

class ViolationNotificationsPage extends StatefulWidget {
  const ViolationNotificationsPage({super.key});

  @override
  State<ViolationNotificationsPage> createState() =>
      _ViolationNotificationsPageState();
}

class _ViolationNotificationsPageState
    extends State<ViolationNotificationsPage> {
  static const Color kBackground = Color(0xFF071733);
  static const Color kCard = Color(0xFF0F344F);
  static const Color kAccent = Color(0xFF00BFFF);
  static const Color kAlert = Colors.redAccent;
  static const Color kWhite = Colors.white;

  late Future<List<Violation>> futureViolations;
  List<String> previousAlertIds = [];
  List<File> snapshots = [];

  @override
  void initState() {
    super.initState();
    _refreshViolations();
  }

  Future<void> _refreshViolations() async {
    try {
      final newViolations = await fetchViolations();

      final newAlertIds = newViolations
          .where((v) => v.isAlert == "1" || v.abnormal == "1")
          .map((v) => v.id)
          .toList();

      final newlyAddedAlerts =
          newAlertIds.where((id) => !previousAlertIds.contains(id)).toList();

      previousAlertIds = newAlertIds;

      setState(() {
        futureViolations = Future.value(newViolations);
      });

      // Trigger snapshot for new alerts
      if (newlyAddedAlerts.isNotEmpty) {
        bool success = await _captureIpWebcamImage();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? "Screenshot taken" : "Screenshot failed"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching violations: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<List<Violation>> fetchViolations() async {
    final response = await http.post(
      Uri.parse("https://ecomlancers.com/Sih_Api/fetch_data"),
      body: {"device_id": "1"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);
      if (jsonBody['code'] == 200) {
        final List<dynamic> dataList = json.decode(jsonBody['data']);
        return dataList.map((e) => Violation.fromJson(e)).toList();
      } else {
        throw Exception('API returned code ${jsonBody['code']}');
      } 
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  // Future<bool> _captureIpWebcamImage() async {
  //   try {
  //     final url = 'http://10.46.121.80:8080/photo.jpg'; // Replace with your phone IP
  //     final response = await http.get(Uri.parse(url));

  //     if (response.statusCode == 200) {
  //       final dir = await getTemporaryDirectory();
  //       final file = File(
  //           '${dir.path}/snapshot_${DateTime.now().millisecondsSinceEpoch}.jpg');
  //       await file.writeAsBytes(response.bodyBytes);
  //       snapshots.add(file); // add to list
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Error capturing image: $e');
  //     return false;
  //   }
  // }

  Future<bool> _captureIpWebcamImage() async {
  try {

    final url = 'http://10.46.121.80:8080/photo.jpg'; // Replace with your phone IP
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final snapshotsDir = Directory('${directory.path}/ViolationSnapshots');

      if (!await snapshotsDir.exists()) {
        await snapshotsDir.create(recursive: true);
      }

      final file = File('${snapshotsDir.path}/snapshot_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(response.bodyBytes);
      snapshots.add(file); // Add to in-app list
      print('Saved to internal storage: ${file.path}');
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print('Error capturing image: $e');
    return false;
  }
}


  void _openGallery() {
    if (snapshots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No snapshots available"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar:
              AppBar(title: const Text("Snapshots"), backgroundColor: kCard),
          backgroundColor: kBackground,
          body: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: snapshots.length,
            itemBuilder: (context, index) {
              return Image.file(snapshots[index], fit: BoxFit.cover);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Alerts'),
        centerTitle: true,
        backgroundColor: kCard,
        foregroundColor: kWhite,
      ),
      body: FutureBuilder<List<Violation>>(
        future: futureViolations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: kAccent));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No alerts',
                style: TextStyle(color: kWhite.withOpacity(0.75), fontSize: 16),
              ),
            );
          }

          final violations = snapshot.data!;
          final alerts =
              violations.where((v) => v.isAlert == "1" || v.abnormal == "1").toList();

          return Stack(
            children: [
              RefreshIndicator(
                color: kAccent,
                backgroundColor: kCard,
                onRefresh: _refreshViolations,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final v = alerts[index];
                    return _alertCard(v, index + 1);
                  },
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                  onPressed: _openGallery,
                  icon: const Icon(Icons.photo),
                  label: const Text("Snapshots"),
                  backgroundColor: kAccent,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _alertCard(Violation v, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: v.isAlert == "1" ? kAlert : kAccent, width: 5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alert #$index',
            style: TextStyle(
              color: v.isAlert == "1" ? kAlert : kAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Device: ${v.deviceId}  •  Voltage: ${v.voltage} V  •  Current: ${v.current} A',
            style: TextStyle(color: kWhite.withOpacity(0.85)),
          ),
          const SizedBox(height: 4),
          Text(
            'Power: ${v.power} W  •  Piezo: ${v.piezo}',
            style: TextStyle(color: kWhite.withOpacity(0.85)),
          ),
          const SizedBox(height: 6),
          Text(
            'Time: ${v.createdAt}',
            style: TextStyle(color: kWhite.withOpacity(0.6), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
