import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'admin_service.dart';
import 'users_list_screen.dart';
import 'admin_settings_screen.dart';
import 'dart:math' as math;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _chartController;
  late Animation<double> _chartAnimation;
  int _selectedIndex = -1;
  bool _isLoading = true;
  bool _isLoadingUsers = false;
  Map<String, dynamic>? _stats;
  List<dynamic> _users = [];
  String? _error;
  String? _usersError;
  bool _serverDown = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutQuart,
    );
    _chartController.forward();
    _loadStats();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
      _usersError = null;
    });
    final result = await AdminService.getUsers();
    if (mounted) {
      if (result['success']) {
        setState(() {
          _users = result['data'];
          _isLoadingUsers = false;
        });
      } else {
        setState(() {
          _usersError = result['message'];
          _isLoadingUsers = false;
        });
      }
    }
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _serverDown = false;
    });

    final result = await AdminService.getStatistics();
    
    if (mounted) {
      if (result['success']) {
        setState(() {
          _stats = result['data'];
          _serverDown = false;
          _isLoading = false;
        });
      } else {
        // No bloquear el dashboard: mostrar con datos vacíos y banner de aviso
        setState(() {
          _stats = {};
          _serverDown = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo conectar al servidor: ${result["message"]}'),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF4081))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF), // Blue admin background
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminSettingsScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Gestión de Seguridad'),
            Tab(text: 'Gestión de Usuarios'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Banner de servidor caído
          if (_serverDown)
            Material(
              color: Colors.orange[700],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Servidor no disponible — mostrando datos en cero',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () { _loadStats(); _loadUsers(); },
                      child: const Text('Reintentar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSecurityView(),
                _buildUsersView(),
              ],
            ),
          ),
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
            title: 'Intentos fallidos de login\n(última semana)',
            chart: _buildAnimatedBarChart(),
            actionIcon: Icons.trending_up,
            actionColor: Colors.green,
            dateRange: _getDynamicDateRange(),
          ),
          const SizedBox(height: 24),
          _buildSecurityTextStats(),
        ],
      ),
    );
  }

  String _getDynamicDateRange() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));
    final months = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"];
    return "${months[sevenDaysAgo.month - 1]} ${sevenDaysAgo.day} - ${months[now.month - 1]} ${now.day}";
  }

  Widget _buildSecurityTextStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estado de Seguridad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.green.withAlpha((0.1 * 255).toInt()), shape: BoxShape.circle),
                    child: const Icon(Icons.shield_outlined, size: 16, color: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  const Text('Intentos fallidos hoy', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              Text('${_stats?['failed_logins_24h'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.orange.withAlpha((0.1 * 255).toInt()), shape: BoxShape.circle),
                    child: const Icon(Icons.lock_outline, size: 16, color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  const Text('Usuarios bloqueados', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              const Text('0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
          if (_usersError != null && !_isLoadingUsers)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    const SizedBox(height: 4),
                    Text('No se pudieron cargar usuarios', style: TextStyle(color: Colors.orange[700])),
                    const SizedBox(height: 4),
                    Text(_usersError!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
            )
          else if (_users.isEmpty && !_isLoadingUsers)
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

  Widget _buildChartCard({required String title, required Widget chart, required IconData actionIcon, required Color actionColor, String? dateRange}) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: actionColor.withAlpha((0.1 * 255).toInt()), shape: BoxShape.circle),
                child: Icon(actionIcon, size: 20, color: actionColor),
              ),
            ],
          ),
          if (dateRange != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chevron_left, color: Colors.grey),
                Text(dateRange, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(height: 180, child: chart),
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
        maxY: data.reduce((a, b) => math.max(a, b)) + 5,
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
        maxY: values.reduce((a, b) => math.max(a, b)) + 5,
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

  Widget _buildAnimatedBarChart() {
    // Process backend data
    final Map<String, dynamic> rawSevenDays = _stats?['failed_logins_last_7_days'] ?? {};
    
    // Generate dates for the last 7 days to ensure we have exactly 7 points
    final now = DateTime.now();
    final List<double> rawData = [];
    final List<String> dayLabels = [];
    final weekDays = ["L", "M", "Mi", "J", "V", "S", "D"];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      // Look up using YYYY-MM-DD
      double val = 0.0;
      if (rawSevenDays.containsKey(dateStr)) {
        val = (rawSevenDays[dateStr] as num).toDouble();
      }
      
      rawData.add(val);
      dayLabels.add(weekDays[date.weekday - 1]);
    }

    final double maxVal = rawData.reduce(math.max) > 0 ? rawData.reduce(math.max) : 1;
    final List<double> normalizedData = rawData.map((e) => e / maxVal).toList();
    final primaryColor = Colors.green;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 120, // Reduced height for the card
          child: AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: normalizedData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  final isSelected = _selectedIndex == index;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = isSelected ? -1 : index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 24,
                          height: 90 * value * _chartAnimation.value,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: isSelected
                                ? [primaryColor, primaryColor.withOpacity(0.7)]
                                : [primaryColor.withOpacity(0.2), primaryColor.withOpacity(0.4)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ] : [],
                          ),
                          child: isSelected ? Center(
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            ),
                          ) : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dayLabels[index],
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? primaryColor : Colors.grey[400],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        if (_selectedIndex != -1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Valor: ${rawData[_selectedIndex].toInt()}",
                style: TextStyle(color: primaryColor.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              "Toca una barra para ver detalles",
              style: TextStyle(color: Colors.grey[400], fontSize: 10, fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }

  Widget _buildFlowChart() {
    final flowData = _stats?['flow_analysis'] as Map<String, dynamic>? ?? {};
    final List<double> values = flowData.values.map<double>((e) => (e as num).toDouble()).toList();
    if (values.isEmpty) values.add(0);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: values.reduce((a, b) => math.max(a, b)) + 5,
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

  Widget _buildStatsCard({required String title, required List<_StatItem> stats, IconData? actionIcon, Color? actionColor}) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (actionIcon != null && actionColor != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: actionColor.withAlpha((0.1 * 255).toInt()), shape: BoxShape.circle),
                  child: Icon(actionIcon, size: 20, color: actionColor),
                ),
            ],
          ),
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
