import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/user_MGT.dart';
import 'package:flutter_application_1/pages/violation_logs.dart';
import 'package:flutter_application_1/pages/reffered_CNL.dart';

const List<Map<String, dynamic>> cases = [
  {
    'priority': 'High',
    'status': 'Scheduled Hearing',
    'name': 'John Doe',
    'id': '20230001',
    'violation': 'Cheating',
    'details': 'Caught cheating during midterm exams. Evidence submitted.',
    'referred': '2024-06-01',
  },
  {
    'priority': 'Medium',
    'status': 'Under Review',
    'name': 'Jane Smith',
    'id': '20230002',
    'violation': 'Plagiarism',
    'details': 'Plagiarized assignment. Awaiting further investigation.',
    'referred': '2024-06-03',
  },
  {
    'priority': 'Low',
    'status': 'Pending',
    'name': 'Alice Johnson',
    'id': '20230003',
    'violation': 'Disruptive Behavior',
    'details': 'Disrupted class repeatedly. Awaiting decision.',
    'referred': '2024-06-05',
  },
];

class SummaryReportsPage extends StatefulWidget {
  const SummaryReportsPage({super.key});

  @override
  State<SummaryReportsPage> createState() => _SummaryReportsPageState();
}

class _SummaryReportsPageState extends State<SummaryReportsPage> {
  Map<String, int> getViolationDistribution() {
    final Map<String, int> counts = {};
    for (var c in cases) {
      String violation = c['violation'] as String;
      // Normalize if needed (e.g., collapse similar labels)
      if (violation.toLowerCase().contains('disruptive')) {
        violation = 'Disruptive Behavior';
      }
      counts[violation] = (counts[violation] ?? 0) + 1;
    }
    return counts;
  }

  int countByStatus(String statusMatch) {
    return cases
        .where((c) => (c['status'] as String).contains(statusMatch))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final distribution = getViolationDistribution();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary of Reports'),
        backgroundColor: const Color.fromARGB(255, 182, 175, 175),
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          Row(
            children: [
              const Text(
                'ADMIN',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(width: 16),
              const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 253, 250, 250),
                child: Icon(Icons.person, color: Colors.black),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.grey[200],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 70.0,
                        maxWidth: 70.0,
                      ),
                      child: Image.asset('images/logos.png'),
                    ),
                    const Text(
                      "CMU_SASO DRMS",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'GENERAL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Dashboard'),
                tileColor: Colors.grey[300],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Dashboard()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('Violation Logs'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViolationLogsPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.pie_chart),
                title: const Text('Summary of Reports'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SummaryReportsPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark),
                title: const Text('Referred to Council'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RefferedCnl()),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'ADMINISTRATION',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('User management'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserMgt()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 30.0),
                    SizedBox(
                      width: 400,
                      height: 200,
                      child: buildSummaryCard(
                        "Total Cases",
                        cases.length.toString(),
                        "Active Referrals",
                        Icons.cases_outlined,
                        const Color.fromARGB(255, 240, 48, 48),
                      ),
                    ),
                    const SizedBox(width: 30.0),
                    SizedBox(
                      width: 400,
                      height: 200,
                      child: buildSummaryCard(
                        "Under Review",
                        countByStatus('Under Review').toString(),
                        "Being Evaluated",
                        Icons.reviews,
                        const Color.fromARGB(255, 52, 96, 241),
                      ),
                    ),
                    const SizedBox(width: 30.0),
                    SizedBox(
                      width: 400,
                      height: 200,
                      child: buildSummaryCard(
                        "Scheduled",
                        countByStatus('Scheduled Hearing').toString(),
                        "Hearings Set",
                        Icons.schedule,
                        const Color.fromARGB(255, 13, 200, 224),
                      ),
                    ),
                    const SizedBox(width: 30.0),
                    SizedBox(
                      width: 400,
                      height: 200,
                      child: buildSummaryCard(
                        "Pending",
                        countByStatus('Pending').toString(),
                        "Awaiting Decision",
                        Icons.pending,
                        const Color.fromARGB(255, 232, 235, 19),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 350,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 500,
                      child: ViolationPieChartCard(distribution: distribution),
                    ),
                    const SizedBox(width: 32),
                    SizedBox(width: 500, child: WeeklyViolationChartCard()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildSummaryCard(
  String title,
  String value,
  String subtitle,
  IconData icon,
  Color color,
) {
  return Container(
    width: 300,
    height: 180,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 36),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.black54)),
      ],
    ),
  );
}

class ViolationPieChartCard extends StatelessWidget {
  final Map<String, int> distribution;

  const ViolationPieChartCard({super.key, required this.distribution});

  static const Map<String, Color> colorMap = {
    'Cheating': Colors.red,
    'Plagiarism': Colors.blue,
    'Disruptive Behavior': Colors.green,
  };

  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold<int>(0, (prev, e) => prev + e);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Violation Types Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: _buildSections(total),
                  centerSpaceRadius: 30,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(enabled: true),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: distribution.entries.map((e) {
                final label = e.key;
                final count = e.value;
                final percentage = total > 0
                    ? (count / total * 100).toStringAsFixed(1)
                    : '0';
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colorMap[label] ?? Colors.grey,
                        shape: BoxShape.rectangle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('$label: $count ($percentage%)'),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(int total) {
    if (total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          title: 'No data',
          color: Colors.grey.shade300,
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ];
    }

    return distribution.entries.map((entry) {
      final label = entry.key;
      final count = entry.value.toDouble();
      final color = colorMap[label] ?? Colors.grey;
      return PieChartSectionData(
        color: color,
        value: count,
        title: '${((count / total) * 100).toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

class WeeklyViolationChartCard extends StatelessWidget {
  const WeeklyViolationChartCard({super.key});

  Map<String, int> _countViolationsByWeekday() {
    final Map<String, int> counts = {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };

    for (final c in cases) {
      final dateStr = c['referred'] as String;
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        final weekday = _weekdayLabel(date.weekday);
        counts[weekday] = (counts[weekday] ?? 0) + 1;
      }
    }

    return counts;
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _countViolationsByWeekday();
    final barGroups = <BarChartGroupData>[];

    int x = 0;
    for (final day in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
      final count = data[day]!;
      barGroups.add(
        BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: Colors.blue,
              width: 18,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      x++;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Violation Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: (data.values.reduce((a, b) => a > b ? a : b) + 1)
                      .toDouble(),
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              days[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
