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
    
    // Performance optimization: Parallel fetching
    final results = await Future.wait([
      CycleHistoryService.getCycleHistory(),
      CycleHistoryService.getPredictionStats(),
    ]);

    final historyResult = results[0];
    final statsResult = results[1];

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
          color: Color(0xFFFAFBFF),
        ),
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF85A1)))
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryGrid(),
                          const SizedBox(height: 35),
                          const Text(
                            "Historial",
                            style: TextStyle(
                              fontSize: 26, 
                              fontWeight: FontWeight.w900, 
                              color: Colors.black,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildFilterBar(),
                          const SizedBox(height: 24),
                          _buildHistoryList(),
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

  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Text(
              'Tus Ciclos',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(width: 48), // Spacer for centering
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return Row(
      children: [
        Expanded(
          child: _InteractiveSummaryCard(
            gradient: const [Color(0xFFFFB2C1), Color(0xFFFF85A1)],
            icon: Icons.water_drop_rounded,
            value: "${_stats['period_duration'] ?? '--'}",
            unit: "días",
            label: "Sangrado",
            shadowColor: const Color(0xFFFFB2C1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _InteractiveSummaryCard(
            gradient: const [Color(0xFFBDD4FF), Color(0xFF81A4FF)],
            icon: Icons.calendar_month_rounded,
            value: "${_stats['avg_cycle_duration'] ?? '--'}",
            unit: "días",
            label: "tu Ciclo",
            shadowColor: const Color(0xFFBDD4FF),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 25, offset: const Offset(0, 12)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _cycles.length,
        separatorBuilder: (context, index) => Divider(height: 48, color: Colors.grey[50]),
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

          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 400 + (index * 100)),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            ),
            child: _buildCycleHistoryItem(
              dateRange: _formatDateRange(start, end),
              duration: duration,
              bleedingDays: _stats['period_duration'] ?? 5,
            ),
          );
        },
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime? end) {
    String startStr = DateFormat('MMM d').format(start);
    String endStr = end != null ? DateFormat('MMM d, yyyy').format(end) : "Hoy";
    return "$startStr - $endStr";
  }

  Widget _buildFilterBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterItem("Todo"),
            _buildFilterItem("Mes anterior"),
            _buildFilterItem("Ventana Fértil"),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterItem(String label) {
    bool isActive = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 24),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFFFF85A1) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
            color: isActive ? const Color(0xFFFF85A1) : Colors.grey[400],
          ),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFF5F6FF), borderRadius: BorderRadius.circular(8)),
              child: Text(
                "$duration días",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF81A4FF)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildCycleVisualBar(bleedingDays: bleedingDays),
      ],
    );
  }

  Widget _buildCycleVisualBar({required int bleedingDays}) {
    const int totalSegments = 16;
    int dotIndex = (bleedingDays * 0.8).round().clamp(1, totalSegments - 2);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(totalSegments, (index) {
        if (index == dotIndex) {
          return Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFFFF85A1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(color: const Color(0xFFFF85A1).withOpacity(0.4), blurRadius: 6, spreadRadius: 1),
              ],
            ),
          );
        }

        bool isBeforeDot = index < dotIndex;
        return Container(
          width: 12,
          height: 5,
          decoration: BoxDecoration(
            color: isBeforeDot ? const Color(0xFFFFB2C1) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _InteractiveSummaryCard extends StatefulWidget {
  final List<Color> gradient;
  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final Color shadowColor;

  const _InteractiveSummaryCard({
    required this.gradient,
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.shadowColor,
  });

  @override
  State<_InteractiveSummaryCard> createState() => _InteractiveSummaryCardState();
}

class _InteractiveSummaryCardState extends State<_InteractiveSummaryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {},
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor.withOpacity(_isPressed ? 0.2 : 0.4),
                blurRadius: _isPressed ? 8 : 15,
                offset: Offset(0, _isPressed ? 4 : 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(widget.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.value,
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.unit,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
