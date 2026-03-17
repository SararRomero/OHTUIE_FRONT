import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './cycle_history_service.dart';
import '../profile/user_service.dart';

// ============================================================================
// WIDGETS DESACOPLADOS - COMPONENTES REUTILIZABLES
// (Colocar en su respectiva carpeta de core/widgets si se desea globalizar)
// ============================================================================

class CycleStatCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const CycleStatCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CycleStatCard> createState() => _CycleStatCardState();
}

class _CycleStatCardState extends State<CycleStatCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 88,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.03 : 0.015),
                blurRadius: _isPressed ? 5 : 10,
                offset: Offset(0, _isPressed ? 1 : 4),
              )
            ],
            border: Border.all(
              color: _isPressed 
                ? widget.iconColor.withOpacity(0.1)
                : Colors.black.withOpacity(0.02),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 150),
                    scale: _isPressed ? 1.15 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.iconColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, color: widget.iconColor, size: 14),
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CycleHistoryListItem extends StatelessWidget {
  final String dateRange;
  final int daysCount;
  final List<CycleSegmentStatus> segments;
  final VoidCallback onTap;
  final bool isCurrentCycle;
  final VoidCallback onDelete;

  const CycleHistoryListItem({
    Key? key,
    required this.dateRange,
    required this.daysCount,
    required this.segments,
    required this.onTap,
    required this.onDelete,
    this.isCurrentCycle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCurrentCycle)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        "Ciclo Actual",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF90B0FF),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  Text(
                    dateRange,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    daysCount.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          CycleVisualizerTimeline(segments: segments),
        ],
      ),
    );
  }
}

class CycleVisualizerTimeline extends StatelessWidget {
  final List<CycleSegmentStatus> segments;

  const CycleVisualizerTimeline({
    Key? key,
    required this.segments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: segments.map((status) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: _buildSegmentLine(status),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSegmentLine(CycleSegmentStatus status) {
    // Colores basados en las fases del ciclo
    final Color periodColor = const Color(0xFFEBD8F5); // Morado para el periodo
    final Color fertileColor = const Color(0xFFCCEAFF); // Azul para ventana fértil
    final Color normalColor = const Color(0xFFF5F5F5); // Gris claro para días normales
    final Color dotColor = const Color(0xFF90B0FF); // Punto indicador

    if (status == CycleSegmentStatus.current) {
      return Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: dotColor.withOpacity(0.4),
                blurRadius: 4,
                spreadRadius: 2,
              )
            ]
          ),
        ),
      );
    }

    Color color;
    switch(status) {
      case CycleSegmentStatus.past:
        color = periodColor; // Fallback or logic specific
        break;
      case CycleSegmentStatus.period:
        color = periodColor;
        break;
      case CycleSegmentStatus.fertile:
        color = fertileColor;
        break;
      case CycleSegmentStatus.future:
      default:
        color = normalColor;
        break;
    }

    return Container(
      height: 6, // Slightly thicker like the capsules
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}


enum CycleSegmentStatus { past, current, future, empty, period, fertile } 


// ============================================================================
// PANTALLA PRINCIPAL: Tus Ciclos (CYCLE HISTORY SCREEN)
// ============================================================================

class CyclesHistoryScreen extends StatefulWidget {
  // Parámetro para conectar con la navegación externa
  final VoidCallback? onBack;

  // TODO (Backend): Agregar parámetros requeridos como final String userId;

  const CyclesHistoryScreen({
    Key? key,
    this.onBack,
  }) : super(key: key);

  @override
  State<CyclesHistoryScreen> createState() => _CyclesHistoryScreenState();
}

class _CyclesHistoryScreenState extends State<CyclesHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _cycles = [];
  Map<String, dynamic>? _prediction;
  int _avgCycleDuration = 28;
  int _avgPeriodDuration = 5;

  // Manejo visual de las tabs
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Todo', 'Mes anterior', 'Ventana Fertil'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final cyclesResp = await CycleHistoryService.getCycles();
      final predictionResp = await CycleHistoryService.getPrediction();
      final userResp = await UserService.getUserMe();

      if (mounted) {
        setState(() {
          if (cyclesResp['success']) {
            _cycles = cyclesResp['data'];
          }
          if (predictionResp['success']) {
            _prediction = predictionResp['data'];
          }
          if (userResp['success']) {
            _avgCycleDuration = userResp['data']['cycle_duration'] ?? 28;
            _avgPeriodDuration = userResp['data']['period_duration'] ?? 5;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  Future<void> _deleteCycle(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Ciclo'),
        content: const Text('¿Estás seguro de que deseas eliminar este ciclo? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final resp = await CycleHistoryService.deleteCycle(id);
      if (resp['success']) {
        await _loadData();
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${resp['message']}')),
        );
      }
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Historial'),
        content: const Text('¿Estás seguro de que deseas borrar TODO el historial de ciclos? Esta acción es definitiva.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Limpiar Todo'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final resp = await CycleHistoryService.deleteAllCycles();
      if (resp['success']) {
        await _loadData();
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${resp['message']}')),
        );
      }
    }
  }

  String _formatDateRange(String? start, String? end) {
    if (start == null) return "Fecha desconocida";
    final startDate = DateTime.parse(start);
    final startStr = DateFormat('MMMM d', 'en').format(startDate); 
    
    if (end == null) {
      return "$startStr - Actualidad";
    }
    
    final endDate = DateTime.parse(end);
    final endStr = DateFormat('MMMM d, yyyy', 'en').format(endDate);
    return "$startStr - $endStr";
  }

  int _calculateDays(String? start, String? end) {
    if (start == null) return 0;
    final startDate = DateTime.parse(start);
    final endDate = end != null ? DateTime.parse(end) : DateTime.now();
    return endDate.difference(startDate).inDays;
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  List<dynamic> get _filteredCycles {
    if (_selectedTabIndex == 0) return _cycles;
    
    final now = DateTime.now();
    if (_selectedTabIndex == 1) {
      final prevMonth = now.month == 1 ? 12 : now.month - 1;
      final year = now.month == 1 ? now.year - 1 : now.year;
      return _cycles.where((c) {
        if (c['start_date'] == null) return false;
        final date = DateTime.parse(c['start_date']);
        return date.month == prevMonth && date.year == year;
      }).toList();
    }
    
    if (_selectedTabIndex == 2) {
      return _cycles; 
    }
    
    return _cycles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF0F2), 
              Color(0xFFFFE4EF), 
              Color(0xFFEBD8F5), 
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Tus Ciclos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _clearHistory,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_sweep_outlined,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CycleStatCard(
                        icon: Icons.water_drop,
                        iconColor: Colors.redAccent,
                        title: 'Sangrado',
                        subtitle: '${_prediction?['period_duration'] ?? _avgPeriodDuration} días',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: CycleStatCard(
                        icon: Icons.calendar_month_outlined,
                        iconColor: Colors.black87,
                        title: 'tu Ciclo',
                        subtitle: '${_prediction?['avg_cycle_duration'] ?? _avgCycleDuration} días',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Historial',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_tabs.length, (index) {
                    final isSelected = _selectedTabIndex == index;
                    return GestureDetector(
                      onTap: () => _onTabChanged(index),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected 
                            ? const Color(0xFF90B0FF) 
                            : Colors.grey.withOpacity(0.6),
                        ),
                        child: Text(_tabs[index]),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 15),

              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : _cycles.isEmpty 
                      ? const Center(child: Text("No hay ciclos registrados"))
                      : ListView.separated(
                    padding: const EdgeInsets.only(top: 15, bottom: 25),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredCycles.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 25),
                    itemBuilder: (context, index) {
                      final item = _filteredCycles[index];
                      final start = item['start_date'];
                      final end = item['end_date'];
                      final days = _calculateDays(start, end);
                      int durationToUse = end != null ? days : _avgCycleDuration;
                      if (durationToUse < 1) durationToUse = _avgCycleDuration;
                      
                      const int totalSegments = 14;
                      List<CycleSegmentStatus> segments = List.generate(totalSegments, (i) {
                        double dayOfCycle = (i / (totalSegments - 1)) * durationToUse;
                        if (dayOfCycle < _avgPeriodDuration) {
                          return CycleSegmentStatus.period;
                        }
                        int ovulation = durationToUse - 14;
                        if (dayOfCycle >= (ovulation - 5) && dayOfCycle <= (ovulation + 1)) {
                          return CycleSegmentStatus.fertile;
                        }
                        return CycleSegmentStatus.future;
                      });

                      bool isCurrent = end == null;
                      if (isCurrent) {
                        int currentIndex = (days / _avgCycleDuration * totalSegments).floor().clamp(0, totalSegments - 1);
                        segments[currentIndex] = CycleSegmentStatus.current;
                      }

                      return TweenAnimationBuilder(
                        duration: Duration(milliseconds: 300 + (index * 100).clamp(0, 1000)),
                        tween: Tween<double>(begin: 0, end: 1),
                        curve: Curves.easeOutCubic,
                        builder: (context, double opacity, child) {
                          return Opacity(
                            opacity: opacity.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(0, 10 * (1 - opacity)),
                              child: child,
                            ),
                          );
                        },
                        child: CycleHistoryListItem(
                          dateRange: _formatDateRange(start, end),
                          daysCount: days,
                          segments: segments,
                          isCurrentCycle: isCurrent,
                          onDelete: () => _deleteCycle(item['id'].toString()),
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
