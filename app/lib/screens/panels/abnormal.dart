import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeviceReportPage extends StatefulWidget {
  const DeviceReportPage({super.key});

  @override
  State<DeviceReportPage> createState() => _DeviceReportPageState();
}

class _DeviceReportPageState extends State<DeviceReportPage> {
  List readings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReadings();
  }

  Future<void> fetchReadings() async {
    try {
      final response = await http.get(Uri.parse('YOUR_API_URL'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          readings = jsonDecode(data['data']);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching API: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final abnormalReadings =
        readings.where((r) => r['abnormal'] == "1" || r['is_alert'] == "1").toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        title: const Text(
          "Device Report",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF112D4E),
        centerTitle: true,
        elevation: 6,
        shadowColor: Colors.cyan.withOpacity(0.3),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _summaryCard("Total Readings", readings.length.toString()),
                      _summaryCard("Abnormal Readings", abnormalReadings.length.toString()),
                      _summaryCard(
                          "Device ID", readings.isNotEmpty ? readings[0]['device_id'] : "-"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Abnormal readings table
                  Text(
                    "Abnormal / Alert Readings",
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.cyanAccent.withOpacity(0.3),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                            Colors.cyanAccent.withOpacity(0.2)),
                        columns: const [
                          DataColumn(label: Text("Time", style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text("Voltage", style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text("Current", style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text("Power", style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text("Piezo", style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text("Alert", style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text("Abnormal", style: TextStyle(color: Colors.white))),
                        ],
                        rows: abnormalReadings.map((r) {
                          return DataRow(
                            cells: [
                              DataCell(Text(r['created_at'], style: const TextStyle(color: Colors.white))),
                              DataCell(Text(r['voltage'], style: const TextStyle(color: Colors.white))),
                              DataCell(Text(r['current'], style: const TextStyle(color: Colors.white))),
                              DataCell(Text(r['power'], style: const TextStyle(color: Colors.white))),
                              DataCell(Text(r['piezo'], style: const TextStyle(color: Colors.white))),
                              DataCell(Text(r['is_alert'] == "1" ? "Yes" : "No",
                                  style: TextStyle(
                                      color: r['is_alert'] == "1"
                                          ? Colors.redAccent
                                          : Colors.white))),
                              DataCell(Text(r['abnormal'] == "1" ? "Yes" : "No",
                                  style: TextStyle(
                                      color: r['abnormal'] == "1"
                                          ? Colors.redAccent
                                          : Colors.white))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Summary card widget
  Widget _summaryCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF112D4E), Color(0xFF003B5C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
