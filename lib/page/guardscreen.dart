import 'package:flutter/material.dart';

class Guardscreen extends StatelessWidget {
  const Guardscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CMU - Guard DRMS'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.3,
                children: const [
                  DashboardCard(
                    title: "Today's\nViolation",
                    value: "12",
                    subtitle: "5 More Yesterday",
                    icon: Icons.report,
                  ),
                  DashboardCard(
                    title: "Pending\nReports",
                    value: "3",
                    subtitle: "Needs Review",
                    icon: Icons.pending_actions,
                  ),
                  DashboardCard(
                    title: "This Week",
                    value: "20",
                    subtitle: "",
                    icon: Icons.date_range,
                  ),
                  DashboardCard(
                    title: "Daily Average",
                    value: "8",
                    subtitle: "",
                    icon: Icons.bar_chart,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Quick Action",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  ActionButton(
                    icon: Icons.qr_code_scanner,
                    label: "Scan Student ID",
                  ),
                  const SizedBox(height: 10),
                  ActionButton(icon: Icons.list, label: "View All Violation"),
                ],
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recent Violation",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 10),

              Column(
                children: const [
                  ViolationItem(
                    name: "Coco Cruz",
                    type: "Dress code",
                    offense: "First Offense",
                    color: Colors.yellow,
                  ),
                  ViolationItem(
                    name: "Joy Martin",
                    type: "Late Entry",
                    offense: "First Offense",
                    color: Colors.yellow,
                  ),
                  ViolationItem(
                    name: "Nika Luna",
                    type: "ID",
                    offense: "First Offense",
                    color: Colors.yellow,
                  ),
                  ViolationItem(
                    name: "Justine Kim",
                    type: "Late Entry",
                    offense: "Second Offense",
                    color: Colors.orange,
                  ),
                  ViolationItem(
                    name: "Liz Ive",
                    type: "Dress code",
                    offense: "Third Offense",
                    color: Colors.red,
                  ),
                  ViolationItem(
                    name: "Wonu Jeon",
                    type: "ID",
                    offense: "First Offense",
                    color: Colors.yellow,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Scan"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Reports"),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const DashboardCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    super.key,
  });

  Color get iconColor {
    switch (icon) {
      case Icons.report:
        return Colors.red;
      case Icons.pending_actions:
        return Colors.orange;
      case Icons.date_range:
        return Colors.green;
      case Icons.bar_chart:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(icon, color: iconColor, size: 30),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const ActionButton({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.grey),
      ),
    );
  }
}

class ViolationItem extends StatelessWidget {
  final String name;
  final String type;
  final String offense;
  final Color color;

  const ViolationItem({
    required this.name,
    required this.type,
    required this.offense,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(name),
        subtitle: Text(type),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                offense,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.remove_red_eye),
          ],
        ),
      ),
    );
  }
}
