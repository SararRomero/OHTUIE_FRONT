import 'package:flutter/material.dart';
import '../shared/chart_card.dart';
import '../charts/age_distribution_chart.dart';
import '../charts/retention_chart.dart';
import '../charts/calendar_usage_chart.dart';
import 'user_management_card.dart';
import 'advanced_stats_card.dart';

class UsersTabView extends StatelessWidget {
  final List<dynamic> users;
  final bool isLoadingUsers;
  final String? usersError;
  final Map<String, dynamic>? stats;
  final bool isStatsLoading;
  final VoidCallback onRefreshUsers;
  final VoidCallback onViewAllUsers;

  const UsersTabView({
    super.key,
    required this.users,
    required this.isLoadingUsers,
    required this.usersError,
    required this.stats,
    required this.isStatsLoading,
    required this.onRefreshUsers,
    required this.onViewAllUsers,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          UserManagementCard(
            onTap: onViewAllUsers,
          ),
          const SizedBox(height: 16),
          ChartCard(
            title: 'Distribución por edades\n(total)',
            chart: AgeDistributionChart(ageData: stats?['age_distribution']),
            actionIcon: Icons.analytics_outlined,
            actionColor: Colors.orange,
            loadingColor: Colors.orange,
            isLoading: isStatsLoading,
          ),
          const SizedBox(height: 16),
          AdvancedStatsCard(stats: stats),
          const SizedBox(height: 16),
          ChartCard(
            title: 'Análisis de Retención',
            chart: RetentionChart(retentionData: stats?['retention_stats']),
            actionIcon: Icons.donut_large_rounded,
            actionColor: Colors.deepPurple,
            loadingColor: Colors.deepPurple,
            isLoading: isStatsLoading,
          ),
          const SizedBox(height: 16),
          ChartCard(
            title: 'Uso del Calendario (7 días)',
            chart: CalendarUsageChart(usageData: stats?['calendar_usage_last_7_days']),
            actionIcon: Icons.calendar_month_rounded,
            actionColor: Colors.purple[300]!,
            loadingColor: Colors.purple[300]!,
            isLoading: isStatsLoading,
          ),
        ],
      ),
    );
  }
}
