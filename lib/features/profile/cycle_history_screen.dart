import 'package:flutter/material.dart';
import 'cycle_history_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  final List<String> _filters = ["Todo", "Mes anterior", "5 últimos", "Actual"];

  // Multi-selection state
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es', null).then((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (_cycles.isEmpty) {
       setState(() => _isLoading = true);
    }
    
    final results = await Future.wait([
      CycleHistoryService.getCycleHistory(),
      CycleHistoryService.getPredictionStats(),
    ]);

    if (mounted) {
      setState(() {
        if (results[0]['success']) {
          _cycles = results[0]['data'];
        }
        if (results[1]['success']) {
          _stats = results[1]['data'];
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmBatchDelete() async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFFFB2C1), Color(0xFFFF85A1)]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_sweep_outlined, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                _selectedIds.length == _cycles.length ? "¡Limpiar Historial!" : "¡Eliminar Ciclos!",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "¿Estás seguro de que deseas borrar ${_selectedIds.length} ciclo(s) seleccionados? Esta acción es definitiva.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text("Cancelar", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF85A1).withOpacity(0.15),
                        foregroundColor: const Color(0xFFFF85A1),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(_selectedIds.length == _cycles.length ? "Limpiar Todo" : "Eliminar", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final resp = await CycleHistoryService.deleteCyclesBatch(_selectedIds.toList());
      if (resp['success']) {
        setState(() {
          _isSelectionMode = false;
          _selectedIds.clear();
        });
        await _loadData();
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Error: ${resp['message']}'),
          ),
        );
      }
    }
  }

  List<dynamic> get _filteredCycles {
    if (_cycles.isEmpty) return [];
    final now = DateTime.now();
    switch (_activeFilter) {
      case "Mes anterior":
        final prevMonth = now.month == 1 ? 12 : now.month - 1;
        final prevYear = now.month == 1 ? now.year - 1 : now.year;
        return _cycles.where((c) {
           final start = DateTime.parse(c['start_date']);
           return start.month == prevMonth && start.year == prevYear;
        }).toList();
      case "5 últimos":
        return _cycles.take(5).toList();
      case "Actual":
        if (_cycles.isNotEmpty) return [_cycles.first];
        return [];
      case "Todo":
      default:
        return _cycles;
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
              child: Stack(
                children: [
                  refreshIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget refreshIndicator() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFFFF85A1),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
          if (_isLoading)
            const Positioned(
              top: 0, left: 0, right: 0,
              child: LinearProgressIndicator(color: Color(0xFFFF85A1), backgroundColor: Colors.transparent, minHeight: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!_isSelectionMode) ...[
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 24),
                  onPressed: () => setState(() => _isSelectionMode = true),
                ),
              ),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black, size: 28),
                onPressed: () => setState(() {
                  _isSelectionMode = false;
                  _selectedIds.clear();
                }),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _selectedIds.length == _filteredCycles.length && _filteredCycles.isNotEmpty,
                    shape: const CircleBorder(),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedIds.addAll(_filteredCycles.map((c) => c['id'].toString()));
                        } else {
                          _selectedIds.clear();
                        }
                      });
                    },
                    activeColor: const Color(0xFFFF85A1),
                  ),
                  const Text('Todo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              IconButton(
                icon: Icon(Icons.delete_sweep_outlined, 
                      color: _selectedIds.isEmpty ? Colors.grey[400] : Colors.redAccent, 
                      size: 28),
                onPressed: _selectedIds.isEmpty ? null : _confirmBatchDelete,
              ),
            ],
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
            cardGradient: const [Color(0xFFFFF2F5), Color(0xFFFFEAF0)],
            iconGradient: const [Color(0xFFFFB2C1), Color(0xFFFF85A1)],
            textColor: Colors.black87,
            icon: Icons.water_drop_rounded,
            value: "${_stats['period_duration'] ?? '--'}",
            unit: "días",
            label: "Sangrado",
            shadowColor: const Color(0xFFFFB2C1).withOpacity(0.4),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _InteractiveSummaryCard(
            cardGradient: const [Color(0xFFF5F8FF), Color(0xFFE8EFFF)],
            iconGradient: const [Color(0xFFBDD4FF), Color(0xFF81A4FF)],
            textColor: Colors.black87,
            icon: Icons.calendar_month_rounded,
            value: "${_stats['avg_cycle_duration'] ?? '--'}",
            unit: "días",
            label: "Ciclo",
            shadowColor: const Color(0xFFBDD4FF).withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    final list = _filteredCycles;
    if (list.isEmpty) {
       return const Center(child: Padding(
         padding: EdgeInsets.all(40),
         child: Text("No hay datos para este filtro", style: TextStyle(color: Colors.grey)),
       ));
    }

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
        itemCount: list.length,
        separatorBuilder: (context, index) => Divider(height: 48, color: Colors.grey[50]),
        itemBuilder: (context, index) {
          final cycle = list[index];
          final String id = cycle['id'].toString();
          final start = DateTime.parse(cycle['start_date']);
          final periodEnd = cycle['end_date'] != null ? DateTime.parse(cycle['end_date']) : null;
          final int bleedingDuration = periodEnd != null ? periodEnd.difference(start).inDays + 1 : 0;
          
          // Find full cycle end based on the original full cycles list to be accurate
          int originalIndex = _cycles.indexOf(cycle);
          DateTime? fullCycleEnd;
          if (originalIndex > 0) {
            final nextCycleStart = DateTime.parse(_cycles[originalIndex - 1]['start_date']);
            fullCycleEnd = nextCycleStart.subtract(const Duration(days: 1));
          }

          final int fullCycleDays = fullCycleEnd != null 
              ? fullCycleEnd.difference(start).inDays + 1 
              : DateTime.now().difference(start).inDays + 1;

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
            child: Row(
              children: [
                if (_isSelectionMode)
                  Checkbox(
                    value: _selectedIds.contains(id),
                    shape: const CircleBorder(),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedIds.add(id);
                        } else {
                          _selectedIds.remove(id);
                        }
                      });
                    },
                    activeColor: const Color(0xFFFF85A1),
                  ),
                Expanded(
                  child: _buildCycleHistoryItem(
                    dateRange: _formatDateRange(start, fullCycleEnd),
                    fullDuration: fullCycleDays,
                    bleedingDays: bleedingDuration > 0 ? bleedingDuration : (_stats['period_duration'] ?? 5),
                    isCurrent: cycle['end_date'] == null && originalIndex == 0,
                    startDate: start,
                    onTap: () {
                      if (_isSelectionMode) {
                        setState(() {
                          if (_selectedIds.contains(id)) {
                            _selectedIds.remove(id);
                          } else {
                            _selectedIds.add(id);
                          }
                        });
                      } else {
                        _showCycleDetailModal(context, fullCycleDays, bleedingDuration > 0 ? bleedingDuration : (_stats['period_duration'] ?? 5));
                      }
                    }
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime? end) {
    String startStr = DateFormat('d MMM', 'es').format(start);
    String endStr = end != null ? DateFormat('d MMM, yyyy', 'es').format(end) : "Hoy";
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
          children: _filters.map((f) => _buildFilterItem(f)).toList(),
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

  Widget _buildCycleHistoryItem({
    required String dateRange, 
    required int fullDuration, 
    required int bleedingDays, 
    required VoidCallback onTap,
    required DateTime startDate,
    bool isCurrent = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isCurrent)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          "Ciclo Actual",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF81A4FF),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    Text(
                      dateRange,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: ShapeDecoration(
                  color: const Color(0xFFF5F6FF), 
                  shape: const StadiumBorder(
                    side: BorderSide(color: Color(0xFF81A4FF), width: 0.1)
                  ),
                  shadows: [
                    BoxShadow(color: const Color(0xFF81A4FF).withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                  ]
                ),
                child: Row(
                  children: [
                    Text(
                      "$bleedingDays días",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF81A4FF)),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.water_drop_rounded, size: 14, color: Color(0xFF81A4FF))
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _buildCycleVisualBar(
          bleedingDays: bleedingDays, 
          totalDays: fullDuration, 
          isCurrent: isCurrent,
          startDate: startDate,
        ),
      ],
    );
  }

  Widget _buildCycleVisualBar({
    required int bleedingDays, 
    required int totalDays, 
    required DateTime startDate,
    bool isCurrent = false,
  }) {
    const int totalSegments = 16;
    final int avgCycle = _stats['avg_cycle_duration'] ?? 28;
    final int effectiveDuration = isCurrent ? avgCycle : totalDays;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(totalSegments, (index) {
        double dayOfCycle = (index / (totalSegments - 1)) * effectiveDuration;
        final Color periodColor = const Color(0xFFFFB2C1); // PINK
        final Color fertileColor = const Color(0xFFCCEAFF);
        final Color normalColor = const Color(0xFFF5F5F5);
        final Color dotColor = const Color(0xFFFF85A1);

        bool isPeriod = dayOfCycle < bleedingDays;
        int ovulation = effectiveDuration - 14;
        bool isFertile = dayOfCycle >= (ovulation - 5) && dayOfCycle <= (ovulation + 1);

        if (isCurrent) {
          int currentIndex = ((DateTime.now().difference(startDate).inDays) / avgCycle * totalSegments).floor().clamp(0, totalSegments - 1);
          if (index == currentIndex) {
            return Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(color: dotColor.withOpacity(0.4), blurRadius: 6, spreadRadius: 1),
                ],
              ),
            );
          }
        }

        Color segmentColor = isPeriod ? periodColor : (isFertile ? fertileColor : normalColor);
        return Container(
          width: 12,
          height: 6,
          decoration: BoxDecoration(
            color: segmentColor,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  void _showCycleDetailModal(BuildContext context, int totalDays, int bleedingDays) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text("Detalles del Ciclo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModalStatItem(Icons.water_drop, "Sangrado", "$bleedingDays días", const Color(0xFFFF85A1)),
                Container(width: 1, height: 40, color: Colors.grey[200]),
                _buildModalStatItem(Icons.calendar_month, "Ciclo Total", "$totalDays días", const Color(0xFF81A4FF)),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F6FF),
                  foregroundColor: const Color(0xFF81A4FF),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Entendido", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildModalStatItem(IconData icon, String title, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }
}

class _InteractiveSummaryCard extends StatefulWidget {
  final List<Color> cardGradient;
  final List<Color> iconGradient;
  final Color textColor;
  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final Color shadowColor;

  const _InteractiveSummaryCard({
    required this.cardGradient,
    required this.iconGradient,
    required this.textColor,
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

  void _showCardActionModal() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: widget.iconGradient),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                "¡Tu resumen!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "El promedio de tu ${widget.label.toLowerCase()} es de ${widget.value} ${widget.unit}. Mantén el registro de tus ciclos para predicciones más precisas.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.shadowColor.withOpacity(0.15),
                    foregroundColor: widget.iconGradient.last,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Cerrar", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _showCardActionModal,
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        curve: Curves.easeOutBack,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.cardGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.01 : 0.03),
                blurRadius: _isPressed ? 5 : 15,
                spreadRadius: 0,
                offset: Offset(0, _isPressed ? 2 : 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: widget.iconGradient),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: Colors.white, size: 18),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.value,
                    style: TextStyle(color: widget.textColor, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.unit,
                    style: TextStyle(color: widget.textColor.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: TextStyle(color: widget.textColor.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
