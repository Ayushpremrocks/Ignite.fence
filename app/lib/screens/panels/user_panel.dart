// ================= panels/user_panel.dart =================
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  List<double> powers = [];
  bool isLoading = true;

  // Color palette
  static const Color kBackground = Color(0xFF071733);
  static const Color kCard = Color(0xFF0F344F);
  static const Color kAccent = Color(0xFF00BFFF);
  static const Color kWhite = Colors.white;

  @override
  void initState() {
    super.initState();
    _fetchAndSetReadings();
  }

  Future<void> _fetchAndSetReadings() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse("https://ecomlancers.com/Sih_Api/fetch_data");
      final response = await http.post(url, body: {"device_id": "1"});

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse["code"] == 200) {
          final List<dynamic> decodedData = json.decode(jsonResponse["data"]);

          setState(() {
            powers = decodedData
                .take(30)
                .map((e) => double.tryParse(e["power"]) ?? 0)
                .toList();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching readings: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text("Live Power Graph"),
        backgroundColor: kCard,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: kAccent))
          : RefreshIndicator(
              onRefresh: _fetchAndSetReadings,
              color: kAccent,
              backgroundColor: kCard,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ---------- Header / Summary ----------
                  Card(
                    color: kCard,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            "Latest 30 Power Readings",
                            style: TextStyle(
                                color: kAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),                         const SizedBox(height: 6),
                          Text(
                            "Swipe down to refresh and get the latest readings",
                            style: TextStyle(
                                color: kWhite.withOpacity(0.7), fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Max: ${powers.isEmpty ? 0 : powers.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)} W",
                            style: TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Min: ${powers.isEmpty ? 0 : powers.reduce((a, b) => a < b ? a : b).toStringAsFixed(1)} W",
                            style: TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------- Graph ----------
                  Card(
                    color: kCard,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 300,
                        child: LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: powers.isEmpty
                                ? 100
                                : powers.reduce((a, b) => a > b ? a : b) * 1.2,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 20,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: kWhite.withOpacity(0.2),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  interval: 50,
                                  getTitlesWidget: (val, meta) => Text(
                                    val.toInt().toString(),
                                    style: TextStyle(
                                        color: kWhite.withOpacity(0.6),
                                        fontSize: 10),
                                  ),
                                ),
                              ),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                  color: kWhite.withOpacity(0.2), width: 1),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: powers.asMap().entries
                                    .map((e) => FlSpot(
                                        e.key.toDouble(), e.value))
                                    .toList(),
                                isCurved: true,
                                gradient: LinearGradient(
                                  colors: [kAccent, Colors.cyanAccent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      kAccent.withOpacity(0.3),
                                      Colors.cyanAccent.withOpacity(0.1)
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                            ],
                            // ---------- Touch interaction ----------
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(  
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    return LineTooltipItem(
                                      '${spot.y.toStringAsFixed(2)} W',
                                      const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    );
                                  }).toList();
                                },
                              ),
                              handleBuiltInTouches: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
