import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/IDScanner.dart';

class SchoolGuardHome extends StatefulWidget {
  const SchoolGuardHome({super.key});

  @override
  State<SchoolGuardHome> createState() => _SchoolGuardHomeState();
}

class _SchoolGuardHomeState extends State<SchoolGuardHome> {
  final List<Map<String, String>> scanData = [
    {
      "name": "Annie Batumbakal",
      "id": "202205249",
      "offense": "1st",
      "violation": "Academic Dishonesty",
      "time": "2 mins",
    },
    {
      "name": "Juan Dela Cruz",
      "id": "202205232",
      "offense": "2nd",
      "violation": "Improper Uniform",
      "time": "5 mins",
    },
    {
      "name": "James Reid",
      "id": "202205211",
      "offense": "3rd",
      "violation": "Serious Misconduct",
      "time": "10 mins",
    },
    {
      "name": "Sponge Cola",
      "id": "202209211",
      "offense": "1st",
      "violation": "Late Attendance",
      "time": "15 mins",
    },
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredData = scanData
        .where(
          (scan) =>
              scan["id"]!.contains(searchQuery) ||
              scan["name"]!.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildScannerCard(),
              const SizedBox(height: 20),

              // ✅ Search box
              TextField(
                decoration: InputDecoration(
                  hintText: "Search student ID or name...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() => searchQuery = value);
                },
              ),

              const SizedBox(height: 20),
              _buildRecentScans(filteredData),
              const SizedBox(height: 16),
              _buildViewAllButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Header with stats
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade700, Colors.indigo.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.shield, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Safety and Security Office\nCMU - DRMS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: IconButton(
                  icon: const Icon(Icons.person, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statBox("47", "Students Scanned"),
              Container(height: 40, width: 1, color: Colors.white24),
              _statBox("12", "Violations Today"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  // 🔹 Scanner card
  Widget _buildScannerCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.camera_alt, size: 50, color: Colors.indigo.shade600),
          const SizedBox(height: 12),
          const Text(
            "Ready to Scan",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Text(
            "Position the student ID card in front of the camera",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentIDScannerApp(),
                ),
              );
              if (result != null && result is Map<String, String>) {
                setState(() => scanData.insert(0, result));
              }
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text("Start Scan"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Recent scans
  Widget _buildRecentScans(List<Map<String, String>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Scans",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...data.take(3).map((scan) => _scanTile(scan)),
      ],
    );
  }

  Widget _scanTile(Map<String, String> scan) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade100,
          child: const Icon(Icons.person, color: Colors.indigo),
        ),
        title: Text(
          scan["name"] ?? "",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${scan["id"]} • ${scan["violation"]}",
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        trailing: _offenseBadge(scan["offense"] ?? "", scan["time"]),
      ),
    );
  }

  Widget _offenseBadge(String offense, String? time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: offense == "1st"
                ? Colors.yellow.shade700
                : offense == "2nd"
                ? Colors.orange
                : Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "$offense Offense",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (time != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(time, style: const TextStyle(fontSize: 12)),
          ),
      ],
    );
  }

  // 🔹 View all button
  Widget _buildViewAllButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                height: 550,
                width: MediaQuery.of(context).size.width * 0.9,
                child: _ScanHistoryModal(scanData: scanData),
              ),
            ),
          );
        },
        child: const Text(
          "View All Scan History",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// 🔹 Full scan history modal
class _ScanHistoryModal extends StatefulWidget {
  final List<Map<String, String>> scanData;
  const _ScanHistoryModal({required this.scanData});

  @override
  State<_ScanHistoryModal> createState() => _ScanHistoryModalState();
}

class _ScanHistoryModalState extends State<_ScanHistoryModal> {
  String searchQuery = "";
  List<String> selectedStatuses = [];
  List<String> selectedViolations = [];

  @override
  Widget build(BuildContext context) {
    final filteredData = widget.scanData.where((scan) {
      final matchesSearch =
          scan["name"]!.toLowerCase().contains(searchQuery.toLowerCase()) ||
          scan["id"]!.contains(searchQuery);
      final matchesStatus =
          selectedStatuses.isEmpty ||
          selectedStatuses.contains(scan["offense"]);
      final matchesViolation =
          selectedViolations.isEmpty ||
          selectedViolations.contains(scan["violation"]);
      return matchesSearch && matchesStatus && matchesViolation;
    }).toList();

    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          "Scan History",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search by name or student ID",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.indigo),
                onPressed: () => _showFilterOptions(context),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() => searchQuery = value),
          ),
        ),

        if (selectedStatuses.isNotEmpty || selectedViolations.isNotEmpty)
          Wrap(
            spacing: 6,
            children: [
              ...selectedStatuses.map((s) => _buildChip(s, Colors.orange)),
              ...selectedViolations.map((v) => _buildChip(v, Colors.blue)),
            ],
          ),

        const SizedBox(height: 8),

        Expanded(
          child: filteredData.isEmpty
              ? const Center(
                  child: Text(
                    "No results found",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) => Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo.shade100,
                        child: const Icon(Icons.person, color: Colors.indigo),
                      ),
                      title: Text(
                        filteredData[index]["name"] ?? "",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "${filteredData[index]["id"]} • ${filteredData[index]["violation"]}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: filteredData[index]["offense"] == "1st"
                                  ? Colors.yellow.shade700
                                  : filteredData[index]["offense"] == "2nd"
                                  ? Colors.orange
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${filteredData[index]["offense"]} Offense",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            filteredData[index]["time"] ?? "",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }

  // 🔹 Filter Bottom Sheet
  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(50),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Filter Options",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Status",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: ["1st", "2nd", "3rd"].map((status) {
                        final isSelected = selectedStatuses.contains(status);
                        return ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          selectedColor: Colors.orange.shade300,
                          onSelected: (val) {
                            setModalState(() {
                              val
                                  ? selectedStatuses.add(status)
                                  : selectedStatuses.remove(status);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Violation",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 3, // ✅ keeps all boxes same ratio
                      children:
                          [
                            "Academic Dishonesty",
                            "Improper Uniform",
                            "Late Attendance",
                            "Serious Misconduct",
                          ].map((violation) {
                            final isSelected = selectedViolations.contains(
                              violation,
                            );
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  if (isSelected) {
                                    selectedViolations.remove(violation);
                                  } else {
                                    selectedViolations.add(violation);
                                  }
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.shade300
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                ),
                                child: Text(
                                  violation,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              selectedStatuses.clear();
                              selectedViolations.clear();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("Clear All"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: const Text("Apply"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18),
      onDeleted: () {
        setState(() {
          selectedStatuses.remove(label);
          selectedViolations.remove(label);
        });
      },
    );
  }
}
