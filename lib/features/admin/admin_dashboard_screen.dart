import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'admin_service.dart';
import 'users_list_screen.dart';
import 'dart:math' as math;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isLoadingUsers = false;
  Map<String, dynamic>? _stats;
  List<dynamic> _users = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStats();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);
    final result = await AdminService.getUsers();
    if (mounted) {
      if (result['success']) {
        setState(() {
          _users = result['data'];
          _isLoadingUsers = false;
        });
      } else {
        setState(() => _isLoadingUsers = false);
      }
    }
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await AdminService.getStatistics();
    
    if (mounted) {
      if (result['success']) {
        setState(() {
          _stats = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'];
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF4081))),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadStats,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F3), // Light pink background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'OHTUIE',
          style: TextStyle(color: Color(0xFFFF4081), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF4081),
          labelColor: const Color(0xFFFF4081),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Gestión de Seguridad'),
            Tab(text: 'Gestión de Usuarios'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSecurityView(),
          _buildUsersView(),
        ],
      ),
    );
  }

  Widget _buildSecurityView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildChartCard(
            title: 'Intentos fallidos de login (últimas 24h)',
            chart: _buildLineChart([
              FlSpot(0, 1),
              FlSpot(1, 1.5),
              FlSpot(2, 1.2),
              FlSpot(3, 2.5),
              FlSpot(4, 2),
              FlSpot(5, 3.5),
              FlSpot(6, _stats?['failed_logins_24h']?.toDouble() ?? 0),
            ], color: Colors.green),
            actionIcon: Icons.trending_up,
            actionColor: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildStatsCard(
            title: 'Estado de Seguridad',
            stats: [
              _StatItem(label: 'Intentos fallidos hoy', value: '${_stats?['failed_logins_24h'] ?? 0}'),
              _StatItem(label: 'Usuarios bloqueados', value: '0'),
              _StatItem(label: 'Alertas críticas', value: '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUserList(),
          const SizedBox(height: 24),
          _buildChartCard(
            title: 'Métricas del sistema',
            chart: _buildBarChart(),
            actionIcon: Icons.bar_chart,
            actionColor: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildAdvancedStatsCard(),
          const SizedBox(height: 16),
          _buildChartCard(
            title: 'Distribución por edades',
            chart: _buildAgeChart(),
            actionIcon: Icons.pie_chart_outline,
            actionColor: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            title: 'Análisis de flujo menstrual',
            chart: _buildFlowChart(),
            actionIcon: Icons.bubble_chart,
            actionColor: Colors.pink[200]!,
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    // Only show top 3 users
    final displayUsers = _users.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Gestión de Usuarios', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              if (_isLoadingUsers)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              else
                IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _loadUsers),
            ],
          ),
          const SizedBox(height: 16),
          if (_users.isEmpty && !_isLoadingUsers)
            const Center(child: Text('No hay usuarios registrados'))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayUsers.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final user = displayUsers[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(user['full_name'] ?? 'Sin nombre', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user['email'] ?? ''),
                  leading: CircleAvatar(
                    backgroundColor: Colors.pink[50], // Aesthetic touch
                    child: Text(
                      (user['full_name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(color: Color(0xFFFF4081)),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UsersListScreen()),
                ).then((_) => _loadUsers()); // Reload on return
              },
              child: const Text('Ver todos los usuarios', style: TextStyle(color: Color(0xFFFF4081))),
            ),
          ),
        ],
      ),
    );
  }

  // _showEditUserDialog and _deleteUser removed from here as they are now in UsersListScreen

  Widget _buildChartCard({required String title, required Widget chart, required IconData actionIcon, required Color actionColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded( // Fix overflow
                child: Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: actionColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(actionIcon, size: 20, color: actionColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chevron_left, color: Colors.grey),
              const Text('Enero 23 - Febrero 23', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 150, child: chart),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final regs = _stats?['user_registrations_last_7_days'] as Map<String, dynamic>? ?? {};
    final List<double> data = regs.values.map<double>((e) => (e as num).toDouble()).toList();
    if (data.isEmpty) data.add(0);
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (data.reduce((a, b) => math.max(a, b)) as num).toDouble() + 5,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i],
                color: const Color(0xFFB3CEFF),
                width: 15,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAgeChart() {
    final ageData = _stats?['age_distribution'] as Map<String, dynamic>? ?? {};
    final labels = ["<18", "18-25", "26-35", "36-45", "46+"];
    final List<double> values = labels.map<double>((l) => (ageData[l] ?? 0 as num).toDouble()).toList();
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (values.reduce((a, b) => math.max(a, b)) as num).toDouble() + 5,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(labels[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(values.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                color: Colors.orange[200],
                width: 20,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLineChart(List<FlSpot> spots, {required Color color}) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowChart() {
    final flowData = _stats?['flow_analysis'] as Map<String, dynamic>? ?? {};
    final List<double> values = flowData.values.map<double>((e) => (e as num).toDouble()).toList();
    if (values.isEmpty) values.add(0);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (values.reduce((a, b) => math.max(a, b)) as num).toDouble() + 5,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(values.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                color: const Color(0xFFFFE5E9),
                width: 15,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAdvancedStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estadísticas Avanzadas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              height: 150,
              width: 150,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      startDegreeOffset: 180,
                      sections: [
                        PieChartSectionData(value: 30, color: Colors.blue[200], radius: 20, showTitle: false),
                        PieChartSectionData(value: 20, color: Colors.orange[200], radius: 25, showTitle: false),
                        PieChartSectionData(value: 15, color: Colors.green[200], radius: 30, showTitle: false),
                        PieChartSectionData(value: 35, color: Colors.pink[200], radius: 35, showTitle: false),
                      ],
                    ),
                  ),
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Salud', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text('100%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildStatRow('Total de usuarias registradas', '${_stats?['total_users'] ?? 0}', Colors.pink[100]!),
          _buildStatRow('Usuarias activas', '${_stats?['active_users'] ?? 0}', Colors.pink[200]!),
          _buildStatRow('Total de ciclos registrados', '${_stats?['total_cycles'] ?? 0}', Colors.pink[300]!),
          _buildStatRow('Promedio de ciclo global', '${_stats?['avg_cycle_duration'] ?? 28} días', Colors.blue[100]!),
          _buildStatRow('Promedio de menstruación', '${_stats?['avg_period_duration'] ?? 5} días', Colors.blue[200]!),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
            ],
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatsCard({required String title, required List<_StatItem> stats}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ...stats.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.label, style: const TextStyle(color: Colors.grey)),
                Text(item.value, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  _StatItem({required this.label, required this.value});
}
