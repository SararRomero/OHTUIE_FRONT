import 'package:flutter/material.dart';

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

  const CycleHistoryListItem({
    Key? key,
    required this.dateRange,
    required this.daysCount,
    required this.segments,
    required this.onTap,
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
              Text(
                dateRange,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                daysCount.toString(),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
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
    // Colores basados en la imagen compartida y en la paleta actual
    final Color pastColor = const Color(0xFFE1D0F5); // Morado claro para "días pasados"
    final Color dotColor = const Color(0xFFE1D0F5); // Morado para el punto principal
    final Color futureColor = const Color(0xFFFDEAF0); // Rosado muy claro para "días futuros"

    if (status == CycleSegmentStatus.current) {
      return Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    Color color = (status == CycleSegmentStatus.past) ? pastColor : futureColor;

    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}


// ============================================================================
// MODELOS MOCK (REMOVER O REEMPLAZAR DURANTE LA INTEGRACIÓN AL BACKEND)
// ============================================================================

enum CycleSegmentStatus { past, current, future, empty }

class CycleHistoryMock {
  final String dateRange;
  final int daysCount;
  final List<CycleSegmentStatus> segments;

  CycleHistoryMock({
    required this.dateRange,
    required this.daysCount,
    required this.segments,
  });
}


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
  // TODO (Backend): Variable para controlar la carga (Loading state)
  // bool isLoading = false;

  // Manejo visual de las tabs
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Todo', 'Mes anterior', 'Ventana Fertil'];

  // Datos quemados para UI (Mock Data)
  late final List<CycleHistoryMock> _mockData;

  @override
  void initState() {
    super.initState();
    // TODO (Backend): Llamar al provider/bloc/cubit para cargar datos aquí en vez de usar mocks
    
    _mockData = [
      CycleHistoryMock(
        dateRange: 'March 11 - March 16, 2024',
        daysCount: 20,
        segments: _createSegments(3, 1, 6),
      ),
      CycleHistoryMock(
        dateRange: 'March 15 - March 20, 2024',
        daysCount: 21,
        segments: _createSegments(4, 1, 5),
      ),
      CycleHistoryMock(
        dateRange: 'March 16 - March 21, 2024',
        daysCount: 19,
        segments: _createSegments(2, 1, 7),
      ),
      CycleHistoryMock(
        dateRange: 'March 19 - March 28, 2024',
        daysCount: 22,
        segments: _createSegments(1, 1, 8),
      ),
      CycleHistoryMock(
        dateRange: 'March 10 - March 28, 2024',
        daysCount: 21,
        segments: _createSegments(5, 1, 4),
      ),
      CycleHistoryMock(
        dateRange: 'March 20 - March 29, 2024',
        daysCount: 18,
        segments: _createSegments(4, 1, 5),
      ),
      CycleHistoryMock(
        dateRange: 'March 5 - March 10, 2024',
        daysCount: 29,
        segments: _createSegments(0, 0, 10), // Ejemplo sin "current" (solo futuros o vacíos)
      ),
    ];
  }

  // Generador de segmentos temporales para la UI
  List<CycleSegmentStatus> _createSegments(int past, int current, int future) {
    List<CycleSegmentStatus> list = [];
    for (int i = 0; i < past; i++) list.add(CycleSegmentStatus.past);
    for (int i = 0; i < current; i++) list.add(CycleSegmentStatus.current);
    for (int i = 0; i < future; i++) list.add(CycleSegmentStatus.future);
    return list;
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    // TODO (Backend): Refetch la información cuando se cambie la tab.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Fondo con los colores dados aplicados como gradiente
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF0F2), // Top
              Color(0xFFFFE4EF), // Center
              Color(0xFFEBD8F5), // Bottom
            ],
          ),
        ),
        child: SafeArea(
          // Utilizamos un CustomScrollView en el futuro si hay mucha información vertical
          // Por el momento un Column que encaja "Historial" en un listado expandido
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==============================
              // HEADER ROW (Back + Título)
              // ==============================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                child: Row(
                  children: [
                    // Back button
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
                    const SizedBox(width: 36), // Evitar desbalance visual del título
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ==============================
              // TOP CARDS
              // ==============================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CycleStatCard(
                        icon: Icons.water_drop,
                        iconColor: Colors.redAccent, // Blood drop icon color
                        title: 'Sangrado',
                        subtitle: '3 days', // TODO (Backend): Mock parameter
                        onTap: () {
                          // TODO (Backend): Acción al presionar tarjeta "Sangrado"
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: CycleStatCard(
                        icon: Icons.calendar_month_outlined,
                        iconColor: Colors.black87, // Calendar icon color
                        title: 'tu Ciclo',
                        subtitle: '26 days', // TODO (Backend): Mock parameter
                        onTap: () {
                          // TODO (Backend): Acción al presionar tarjeta "tu Ciclo"
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // ==============================
              // HISTORIAL TITLE
              // ==============================
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

              // ==============================
              // TAB BAR
              // ==============================
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
                          // Blue si está seleccionado, Gris claro si no
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

              // ==============================
              // HISTORY LIST (White Container)
              // ==============================
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 15, bottom: 25),
                    physics: const BouncingScrollPhysics(), // Animación nativa fluida al scrollear
                    itemCount: _mockData.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 25),
                    itemBuilder: (context, index) {
                      final item = _mockData[index];
                      // Animación simple de Entrada
                      return TweenAnimationBuilder(
                        duration: Duration(milliseconds: 300 + (index * 100)),
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
                          dateRange: item.dateRange,
                          daysCount: item.daysCount,
                          segments: item.segments,
                          onTap: () {
                            // TODO (Backend): Acción al presionar un ciclo particular
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20), // Bottom safe space
            ],
          ),
        ),
      ),
    );
  }
}
