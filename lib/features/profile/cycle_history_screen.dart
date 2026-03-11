import 'package:flutter/material.dart';
import 'cycle_history_service.dart';
import 'package:intl/intl.dart';

class CycleHistoryScreen extends StatefulWidget {
  const CycleHistoryScreen({super.key});

  @override
  State<CycleHistoryScreen> createState() => _CycleHistoryScreenState();
}

class _CycleHistoryScreenState extends State<CycleHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _cycles = [];
  Map<String, dynamic> _stats = {};
  String _activeFilter = "Todo";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final historyResult = await CycleHistoryService.getCycleHistory();
    final statsResult = await CycleHistoryService.getPredictionStats();

    if (mounted) {
      setState(() {
        if (historyResult['success']) {
          _cycles = historyResult['data'];
        }
        if (statsResult['success']) {
          _stats = statsResult['data'];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFFFF0F2),
            ],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              title: const Text(
                'Tus Ciclos',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
              ),
              centerTitle: true,
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFEBD8F5)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  icon: Icons.water_drop,
                                  iconColor: Colors.redAccent,
                                  value: "${_stats['period_duration'] ?? '--'} days",
                                  label: "Sangrado",
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildSummaryCard(
                                  icon: Icons.calendar_month,
                                  iconColor: const Color(0xFF5C5C5C),
                                  value: "${_stats['avg_cycle_duration'] ?? '--'} days",
                                  label: "tu Ciclo",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            "Historial",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          const SizedBox(height: 16),
                          // Filter Bar
                          SizedBox(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildFilterItem("Todo"),
                                _buildFilterItem("Mes anterior"),
                                _buildFilterItem("Ventana Fertil"),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // History items background card (simulated rounded sheet)
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _cycles.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 32),
                              itemBuilder: (context, index) {
                                final cycle = _cycles[index];
                                final start = DateTime.parse(cycle['start_date']);
                                final end = cycle['end_date'] != null ? DateTime.parse(cycle['end_date']) : null;
                                
                                int duration = 0;
                                if (end != null) {
                                  duration = end.difference(start).inDays + 1;
                                } else {
                                  duration = DateTime.now().difference(start).inDays + 1;
                                }

                                return _buildCycleHistoryItem(
                                  dateRange: "${_formatDateRange(start, end)}",
                                  duration: duration,
                                  bleedingDays: _stats['period_duration'] ?? 5,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime? end) {
    String startStr = DateFormat('MMMM d').format(start);
    String endStr = end != null ? DateFormat('MMMM d, yyyy').format(end) : "Presente";
    return "$startStr - $endStr";
  }

  Widget _buildSummaryCard({required IconData icon, required Color iconColor, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Text(
                value,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(String label) {
    bool isActive = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: Padding(
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFF9FA8DA) : Colors.black26,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleHistoryItem({required String dateRange, required int duration, required int bleedingDays}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateRange,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
            ),
            Text(
              "$duration",
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Visual Cycle Bar with dynamic dot
        _buildCycleVisualBar(bleedingDays: bleedingDays),
      ],
    );
  }

  Widget _buildCycleVisualBar({required int bleedingDays}) {
    const int totalSegments = 16;
    // Map bleeding days to segments (e.g., 5 days = 4 segments)
    int dotIndex = (bleedingDays * 0.8).round().clamp(1, totalSegments - 2);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(totalSegments, (index) {
        if (index == dotIndex) {
          return Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFFEBD8F5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEBD8F5).withOpacity(0.5),
                  blurRadius: 4,
                )
              ]
            ),
          );
        }

        bool isBeforeDot = index < dotIndex;
        return Container(
          width: 12,
          height: 4,
          decoration: BoxDecoration(
            color: isBeforeDot ? const Color(0xFFEBD8F5) : const Color(0xFFFFE4EF),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
