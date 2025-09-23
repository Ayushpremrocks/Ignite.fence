// lib/screens/device_readings.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeviceReading {
  final String id;
  final String deviceId;
  final String voltage;
  final String current;
  final String power;
  final String createdAt;

  DeviceReading({
    required this.id,
    required this.deviceId,
    required this.voltage,
    required this.current,
    required this.power,
    required this.createdAt,
  });

  factory DeviceReading.fromJson(Map<String, dynamic> json) {
    return DeviceReading(
      id: json['id'].toString(),
      deviceId: json['device_id'].toString(),
      voltage: json['voltage'].toString(),
      current: json['current'].toString(),
      power: json['power'].toString(),
      createdAt: json['created_at'].toString(),
    );
  }
}

class DeviceReadingsPage extends StatefulWidget {
  const DeviceReadingsPage({super.key});

  @override
  State<DeviceReadingsPage> createState() => _DeviceReadingsPageState();
}

class _DeviceReadingsPageState extends State<DeviceReadingsPage> {
  static const Color kBackground = Color(0xFF071733);
  static const Color kPrimary = Color(0xFF0D2640);
  static const Color kCard = Color(0xFF0F344F);
  static const Color kAccent = Color(0xFF00BFFF);
  static const Color kWhite = Colors.white;

  late Future<List<DeviceReading>> futureReadings;

  @override
  void initState() {
    super.initState();
    _refreshReadings();
  }

  Future<void> _refreshReadings() async {
    setState(() {
      futureReadings = fetchReadings();
    });
  }

  Future<List<DeviceReading>> fetchReadings() async {
    final response = await http.post(
      Uri.parse("https://ecomlancers.com/Sih_Api/fetch_data"),
      body: {"device_id": "1"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);
      if (jsonBody['code'] == 200) {
        final List<dynamic> dataList = json.decode(jsonBody['data']);
        final readings = dataList.map((e) => DeviceReading.fromJson(e)).toList();
        return readings;
      } else {
        throw Exception('API returned code ${jsonBody['code']}');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  double _averagePower(List<DeviceReading> list) {
    if (list.isEmpty) return 0;
    double sum = 0;
    for (var r in list) {
      sum += double.tryParse(r.power) ?? 0;
    }
    return sum / list.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Device Readings'),
        centerTitle: true,
        elevation: 6,
        backgroundColor: kPrimary,
        foregroundColor: kWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
      ),
      body: FutureBuilder<List<DeviceReading>>(
        future: futureReadings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kAccent));
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
                'No readings available',
                style: TextStyle(color: kWhite.withOpacity(0.75), fontSize: 16),
              ),
            );
          }

          final readings = snapshot.data!;
          final latest = readings.first;
          final avgPower = _averagePower(readings);

          return RefreshIndicator(
            color: kAccent,
            backgroundColor: kPrimary,
            onRefresh: _refreshReadings,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary Row
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kAccent.withOpacity(0.6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _statTile(
                          label: 'Latest (W)',
                          value: (double.tryParse(latest.power) ?? 0).toStringAsFixed(1),
                          accent: kAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statTile(
                          label: 'Average (W)',
                          value: avgPower.toStringAsFixed(1),
                          accent: kAccent.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Text(
                    'Recent Readings',
                    style: TextStyle(
                      color: kWhite.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Reading cards with index (no time)
                ...readings.asMap().entries.map((entry) {
                  int idx = entry.key + 1;
                  DeviceReading r = entry.value;
                  return _readingCard(r, idx);
                }).toList(),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statTile({
    required String label,
    required String value,
    required Color accent,
    bool isSmall = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 14, horizontal: 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.8), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: kWhite.withOpacity(0.8), fontSize: isSmall ? 12 : 13)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: kWhite, fontSize: isSmall ? 14 : 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _readingCard(DeviceReading reading, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: kAccent, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 6)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: kAccent.withOpacity(0.15),
          child: Text(
            '#$index',
            style: TextStyle(color: kAccent, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          'V: ${reading.voltage} V   •   I: ${reading.current} A',
          style: TextStyle(color: kWhite, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Power: ${reading.power} W',
          style: TextStyle(color: kWhite.withOpacity(0.8)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: kAccent.withOpacity(0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            (double.tryParse(reading.power) ?? 0).toStringAsFixed(0),
            style: TextStyle(color: kAccent, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
