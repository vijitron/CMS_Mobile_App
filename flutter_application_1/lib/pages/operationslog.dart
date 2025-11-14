// pages/operations_log.dart
import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';  // Import the shared sidebar

// Data model for a log entry
class OperationLogEntry {
  final String timestamp;
  final String craneId;
  final String operation;
  final String duration;
  final int load;

  OperationLogEntry({
    required this.timestamp,
    required this.craneId,
    required this.operation,
    required this.duration,
    required this.load,
  });
}

class OperationsLogPage extends StatefulWidget {
  const OperationsLogPage({super.key});

  @override
  State<OperationsLogPage> createState() => _OperationsLogPageState();
}

class _OperationsLogPageState extends State<OperationsLogPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Mock data for the table
  final List<OperationLogEntry> _logEntries = [
    OperationLogEntry(timestamp: '2023-06-15 08:23:45', craneId: 'CRN-001', operation: 'HOIST UP', duration: '2:15', load: 3250),
    OperationLogEntry(timestamp: '2023-06-15 08:45:12', craneId: 'CRN-002', operation: 'LT FORWARD', duration: '1:42', load: 4800),
    OperationLogEntry(timestamp: '2023-06-15 09:12:33', craneId: 'CRN-001', operation: 'HOIST DOWN', duration: '1:56', load: 3250),
    OperationLogEntry(timestamp: '2023-06-15 09:30:18', craneId: 'CRN-003', operation: 'SWITCH', duration: '0:45', load: 1200),
    OperationLogEntry(timestamp: '2023-06-15 10:05:27', craneId: 'CRN-004', operation: 'HOIST UP', duration: '3:22', load: 5700),
    OperationLogEntry(timestamp: '2023-06-15 10:45:52', craneId: 'CRN-002', operation: 'HOIST DOWN', duration: '2:18', load: 4800),
    OperationLogEntry(timestamp: '2023-06-15 11:15:06', craneId: 'CRN-005', operation: 'LT FORWARD', duration: '4:33', load: 7500),
    OperationLogEntry(timestamp: '2023-06-15 11:52:41', craneId: 'CRN-001', operation: 'HOIST UP', duration: '1:47', load: 2800),
    OperationLogEntry(timestamp: '2023-06-15 12:30:15', craneId: 'CRN-003', operation: 'CT LEFT', duration: '3:05', load: 3200),
  ];

  // Filter states
  String? selectedCrane;
  String? selectedOperation;
  String? selectedDateRange;
  bool _showFilters = false;
  int _selectedTab = 0; // 0: Overview, 1: Operations

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      drawer: Sidebar(onItemSelected: (title) {}),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Operations Log',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete record of all crane operations',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Tab Navigation
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _selectedTab = 0),
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedTab == 0 ? const Color(0xFF1976D2).withOpacity(0.1) : Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Overview',
                      style: TextStyle(
                        color: _selectedTab == 0 ? const Color(0xFF1976D2) : Colors.grey,
                        fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _selectedTab = 1),
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedTab == 1 ? const Color(0xFF1976D2).withOpacity(0.1) : Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Operations',
                      style: TextStyle(
                        color: _selectedTab == 1 ? const Color(0xFF1976D2) : Colors.grey,
                        fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Toggle
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _showFilters,
                  onChanged: (value) => setState(() => _showFilters = value),
                  activeThumbColor: const Color(0xFF1976D2),
                ),
              ],
            ),
          ),

          // Filters Panel
          if (_showFilters) ...[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildFilterChipSection('Crane', ['All Cranes', 'CRN-001', 'CRN-002', 'CRN-003', 'CRN-004', 'CRN-005']),
                  const SizedBox(height: 12),
                  _buildFilterChipSection('Operation', ['All Types', 'HOIST UP', 'HOIST DOWN', 'LT FORWARD', 'CT LEFT', 'SWITCH']),
                  const SizedBox(height: 12),
                  _buildFilterChipSection('Date', ['All Dates', 'Today', 'This Week', 'This Month']),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _resetFilters,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1976D2),
                            side: const BorderSide(color: Color(0xFF1976D2)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],

          // Content Area
          Expanded(
            child: _selectedTab == 0 ? _buildOverviewTab() : _buildOperationsTab(),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Color(0xFF1976D2)),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: const Text(
        'CraneIQ',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 1,
      iconTheme: const IconThemeData(color: Color(0xFF1976D2)),
      actions: [
        IconButton(
          icon: const Icon(Icons.home, color: Color(0xFF1976D2)),
          onPressed: () {
            Navigator.pushNamed(context, '/dashboard');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary Cards Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3, // Increased aspect ratio to provide more vertical space
            children: [
              _buildSummaryCard(
                icon: Icons.unfold_more,
                title: 'HOIST',
                value: '142',
                details: '87 UP • 55 DOWN',
                color: const Color(0xFF4CAF50),
              ),
              _buildSummaryCard(
                icon: Icons.swap_horiz,
                title: 'CT',
                value: '76',
                details: '45 LEFT • 31 RIGHT',
                color: const Color(0xFFFF9800),
              ),
              _buildSummaryCard(
                icon: Icons.arrow_forward,
                title: 'LT',
                value: '98',
                details: '62 FWD • 36 REV',
                color: const Color(0xFFFFC107),
              ),
              _buildSummaryCard(
                icon: Icons.power_settings_new,
                title: 'SWITCH',
                value: '53',
                color: const Color(0xFF9E9E9E),
              ),
              _buildSummaryCard(
                icon: Icons.timer,
                title: 'DURATION',
                value: '8:42:15',
                color: const Color(0xFF00BCD4),
              ),
              _buildSummaryCard(
                icon: Icons.fitness_center,
                title: 'LOAD',
                value: '287.5T',
                color: const Color(0xFF9C27B0),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Activity
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._logEntries.take(3).map(_buildOperationCard),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Quick Stats
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickStat('Total Ops', '${_logEntries.length}'),
                  Container(width: 1, height: 30, color: Colors.grey[300]),
                  _buildQuickStat('Active Cranes', '5'),
                  Container(width: 1, height: 30, color: Colors.grey[300]),
                  _buildQuickStat('Avg Duration', '2:18'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Operations List
          Expanded(
            child: ListView.builder(
              itemCount: _logEntries.length,
              itemBuilder: (context, index) => _buildOperationCard(_logEntries[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    String? details,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12), // Reduced padding to create more space
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Better space distribution
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4), // Reduced padding
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 16), // Reduced icon size
                ),
                const Spacer(),
                Container(
                  width: 3, // Reduced width
                  height: 16, // Reduced height
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // Reduced spacing
            Text(
              title,
              style: TextStyle(
                fontSize: 11, // Reduced font size
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2), // Reduced spacing
            Text(
              value,
              style: const TextStyle(
                fontSize: 16, // Reduced font size
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (details != null) ...[
              const SizedBox(height: 2), // Reduced spacing
              Text(
                details,
                style: TextStyle(
                  fontSize: 9, // Reduced font size
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOperationCard(OperationLogEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOperationChip(entry.operation),
                Text(
                  entry.duration,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.crisis_alert, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  entry.craneId,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                Icon(Icons.fitness_center, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${entry.load} kg',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    entry.timestamp,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationChip(String operation) {
    final (color, textColor) = switch (operation) {
      'HOIST UP' => (const Color(0xFF4CAF50), Colors.white),
      'HOIST DOWN' => (const Color(0xFF8BC34A), Colors.white),
      'LT FORWARD' => (const Color(0xFFFFC107), Colors.black87),
      'LT REVERSE' => (const Color(0xFFFF9800), Colors.white),
      'CT LEFT' => (const Color(0xFF2196F3), Colors.white),
      'CT RIGHT' => (const Color(0xFF03A9F4), Colors.white),
      _ => (const Color(0xFF9E9E9E), Colors.white),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        operation,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFilterChipSection(String title, List<String> options) {
    String? selectedValue;
    final filterMap = {
      'Crane': selectedCrane,
      'Operation': selectedOperation,
      'Date': selectedDateRange,
    };
    selectedValue = filterMap[title];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            return FilterChip(
              label: Text(option),
              selected: selectedValue == option,
              onSelected: (selected) {
                setState(() {
                  switch (title) {
                    case 'Crane':
                      selectedCrane = selected ? option : null;
                      break;
                    case 'Operation':
                      selectedOperation = selected ? option : null;
                      break;
                    case 'Date':
                      selectedDateRange = selected ? option : null;
                      break;
                  }
                });
              },
              backgroundColor: Colors.grey[100],
              selectedColor: const Color(0xFF1976D2).withOpacity(0.2),
              checkmarkColor: const Color(0xFF1976D2),
              labelStyle: TextStyle(
                color: selectedValue == option ? const Color(0xFF1976D2) : Colors.grey[700],
                fontWeight: selectedValue == option ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _applyFilters() {
    setState(() {
      _showFilters = false;
    });
  }

  void _resetFilters() {
    setState(() {
      selectedCrane = null;
      selectedOperation = null;
      selectedDateRange = null;
      _showFilters = false;
    });
  }
}