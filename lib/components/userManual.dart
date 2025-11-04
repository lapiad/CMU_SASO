import 'package:flutter/material.dart';

class UserManualScreen extends StatelessWidget {
  const UserManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Manual',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 6,
        backgroundColor: const Color(0xFF446EAD),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf7faff), Color(0xFFdce6ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionHeader("📘 Overview"),
            _infoCard(
              icon: Icons.dashboard,
              title: "Dashboard Overview",
              description:
                  "The Dashboard serves as the main landing page after login. It provides a snapshot of the system’s status, including the total number of recorded violations, categorized by their current status (Pending, In Progress, Reviewed, and Closed). "
                  "It also highlights the most recent violations, allowing quick access to view or manage them directly.",
            ),
            _sectionHeader("🧭 Navigation"),
            _infoCard(
              icon: Icons.menu,
              title: "Side Menu Navigation",
              description:
                  "Tap the menu icon (☰) at the top-left corner of any page to open the navigation drawer. From here, you can easily switch between the following modules:\n"
                  "• Dashboard — overview of all violations and system stats\n"
                  "• Violation Logs — view and manage all violation records\n"
                  "• Summary Reports — generate analytical summaries\n"
                  "• User Management — manage user accounts and permissions\n"
                  "• User Manual — access this help guide",
            ),
            _infoCard(
              icon: Icons.notifications,
              title: "Notifications",
              description:
                  "The bell icon in the top bar displays the count of pending violation reports. Tap the icon to view a detailed list of all pending cases and take appropriate actions such as reviewing, updating, or closing reports.",
            ),

            _sectionHeader("📋 Violation Logs Page"),
            _infoCard(
              icon: Icons.list_alt,
              title: "Viewing Violations",
              description:
                  "The Violation Logs page lists all recorded student violations in a tabular format. Each record includes details such as student name, ID number, type of violation, date reported, assigned handler, and current status.\n\n"
                  "Records are color-coded for quick identification:\n"
                  "• Pending – Yellow highlight\n"
                  "• In Progress – Blue highlight\n"
                  "• Reviewed / Closed – Green highlight",
            ),
            _infoCard(
              icon: Icons.search,
              title: "Search and Filter Options",
              description:
                  "You can quickly locate specific records using the search bar at the top. Simply type the student’s name, ID, or violation keyword.\n\n"
                  "Use filters to refine your view:\n"
                  "• Filter by Date Range – view violations within a selected time period\n"
                  "• Filter by Status – focus on pending, in-progress, or closed violations\n"
                  "• Filter by Violation Type – e.g., attendance, misconduct, etc.",
            ),
            _infoCard(
              icon: Icons.edit_note,
              title: "Editing and Updating Reports",
              description:
                  "To update a violation record, tap on the desired entry to open its details page. From here, you can:\n"
                  "• Edit the violation details\n"
                  "• Change its current status (e.g., from Pending to In Progress)\n"
                  "• Add remarks or administrative notes\n"
                  "• Assign the case to another reviewer or handler",
            ),
            _infoCard(
              icon: Icons.refresh,
              title: "Auto-Refresh & Manual Sync",
              description:
                  "The Violation Logs page automatically refreshes data every 30 seconds to ensure you always see the latest updates. You can also manually refresh by pulling down on the list or tapping the refresh icon in the top-right corner.",
            ),
            _infoCard(
              icon: Icons.file_download,
              title: "Export and Download",
              description:
                  "Admins can export the violation logs into external formats for reporting or backup. Supported formats include PDF and CSV.\n"
                  "When exporting, filters currently applied on-screen will also affect the exported data for accuracy.",
            ),

            _sectionHeader("📈 Summary Reports Page"),
            _infoCard(
              icon: Icons.analytics,
              title: "Purpose and Overview",
              description:
                  "The Summary Reports page provides analytical data on violations over time. It is especially useful for administrators to identify behavioral trends, repeat violations, and areas that require attention.",
            ),
            _infoCard(
              icon: Icons.query_stats,
              title: "Report Features",
              description:
                  "Features include:\n"
                  "• Total Violation Counts (daily, weekly, monthly)\n"
                  "• Category Breakdown by Violation Type\n"
                  "• Trend Graphs and Pie Charts for easy visualization\n"
                  "• Date range selection for specific reporting periods\n"
                  "• Export options for generating printed summaries",
            ),
            _infoCard(
              icon: Icons.settings,
              title: "Report Filtering",
              description:
                  "Users can filter reports by department, violation type, or student group. "
                  "This helps isolate data for detailed analysis or administrative evaluation.",
            ),

            _sectionHeader("🛠️ Creating and Managing Violations"),
            _infoCard(
              icon: Icons.add_circle_outline,
              title: "Creating a New Violation",
              description:
                  "Select 'Create New Violation Report' from the dashboard or side menu. Enter the following required details:\n"
                  "• Student name and ID number\n"
                  "• Type of violation\n"
                  "• Description or notes about the incident\n"
                  "• Date and location of the event\n\n"
                  "Once completed, click 'Save' to record the new violation.",
            ),
            _infoCard(
              icon: Icons.pending_actions,
              title: "Pending and In-progress Violations",
              description:
                  "All newly created reports appear under the 'Pending' category until reviewed by an authorized user. "
                  "You can update the report’s progress from the Violation Logs page or directly from the Dashboard summary cards.",
            ),

            _sectionHeader("👤 User Management Page (Admin Only)"),
            _infoCard(
              icon: Icons.admin_panel_settings,
              title: "Adding and Editing Users",
              description:
                  "Admins can access the User Management module to maintain system users. Options include:\n"
                  "• Adding new accounts (admin, staff, reviewer)\n"
                  "• Editing user details such as name, email, or role\n"
                  "• Deactivating accounts when no longer needed",
            ),
            _infoCard(
              icon: Icons.security,
              title: "User Roles and Permissions",
              description:
                  "Roles determine access levels within the system:\n"
                  "• Admin – full system control including reports, exports, and user management\n"
                  "• Staff – can create and update violation records\n"
                  "• Reviewer – can verify and close reports assigned to them",
            ),

            _sectionHeader("👥 Account and Settings"),
            _infoCard(
              icon: Icons.person_outline,
              title: "Profile Settings",
              description:
                  "Tap your profile icon (top-right corner) to open account settings. From there, you can change your display name, email, and password.",
            ),
            _infoCard(
              icon: Icons.logout,
              title: "Logging Out",
              description:
                  "Select 'Logout' from your profile dropdown to securely exit the system. You’ll be redirected to the login page.",
            ),

            _sectionHeader("💡 Tips and Troubleshooting"),
            _infoCard(
              icon: Icons.info_outline,
              title: "System Tips",
              description:
                  "• Regularly refresh your pages to view the latest updates.\n"
                  "• Use filters and search for faster data navigation.\n"
                  "• Keep your login credentials secure.\n"
                  "• Export data periodically for backups.",
            ),
            _infoCard(
              icon: Icons.help_outline,
              title: "Common Issues",
              description:
                  "If data does not update automatically, tap the manual refresh button or check your internet connection. "
                  "If export files are not downloading, verify app storage permissions or contact the admin for support.",
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back to Dashboard"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF446EAD),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Helper Widgets =====

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF2c3e50),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF446EAD), size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
