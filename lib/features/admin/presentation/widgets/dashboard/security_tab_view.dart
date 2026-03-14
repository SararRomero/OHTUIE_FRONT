import 'package:flutter/material.dart';
import '../shared/chart_card.dart';
import '../charts/animated_bar_chart.dart';
import 'security_stats_section.dart';
import 'registration_stats_section.dart';

class SecurityTabView extends StatelessWidget {
  final Map<String, dynamic>? stats;
  final bool isFailedLoginsLoading;
  final bool isRegistrationsLoading;
  final int failedLoginsWeekOffset;
  final int registrationsWeekOffset;
  final int failedLoginSelectedIndex;
  final int registrationsSelectedIndex;
  final String Function(int) dateRangeFormatter;
  final Function(int) onFailedLoginTap;
  final Function(int) onRegistrationTap;
  final VoidCallback onFailedLoginPrev;
  final VoidCallback onFailedLoginNext;
  final VoidCallback onRegistrationPrev;
  final VoidCallback onRegistrationNext;

  const SecurityTabView({
    super.key,
    required this.stats,
    required this.isFailedLoginsLoading,
    required this.isRegistrationsLoading,
    required this.failedLoginsWeekOffset,
    required this.registrationsWeekOffset,
    required this.failedLoginSelectedIndex,
    required this.registrationsSelectedIndex,
    required this.dateRangeFormatter,
    required this.onFailedLoginTap,
    required this.onRegistrationTap,
    required this.onFailedLoginPrev,
    required this.onFailedLoginNext,
    required this.onRegistrationPrev,
    required this.onRegistrationNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ChartCard(
            title: 'Intentos fallidos de login\n(semanal)',
            chart: AnimatedBarChart(
              dataMap: stats?['failed_logins_last_7_days'] ?? {},
              color: Colors.green,
              selectedIndex: failedLoginSelectedIndex,
              weekOffset: failedLoginsWeekOffset,
              onTap: onFailedLoginTap,
            ),
            actionIcon: Icons.trending_up,
            actionColor: Colors.green,
            loadingColor: Colors.green,
            isLoading: isFailedLoginsLoading,
            dateRange: dateRangeFormatter(failedLoginsWeekOffset),
            onPrev: onFailedLoginPrev,
            onNext: onFailedLoginNext,
          ),
          const SizedBox(height: 16),
          SecurityStatsSection(stats: stats),
          const SizedBox(height: 24),
          ChartCard(
            title: 'Registros de nuevas usuarias\n(semanal)',
            chart: AnimatedBarChart(
              dataMap: stats?['user_registrations_last_7_days'] ?? {},
              color: Colors.blue,
              selectedIndex: registrationsSelectedIndex,
              weekOffset: registrationsWeekOffset,
              onTap: onRegistrationTap,
            ),
            actionIcon: Icons.person_add_outlined,
            actionColor: Colors.blue,
            loadingColor: Colors.blue,
            isLoading: isRegistrationsLoading,
            dateRange: dateRangeFormatter(registrationsWeekOffset),
            onPrev: onRegistrationPrev,
            onNext: onRegistrationNext,
          ),
          const SizedBox(height: 16),
          RegistrationStatsSection(stats: stats),
        ],
      ),
    );
  }
}
