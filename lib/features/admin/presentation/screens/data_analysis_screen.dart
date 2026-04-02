import 'package:flutter/material.dart';
import '../../data/admin_service.dart';
import '../widgets/shared/kpi_card.dart';
import 'package:fl_chart/fl_chart.dart';

class DataAnalysisScreen extends StatefulWidget {
  const DataAnalysisScreen({super.key});

  @override
  State<DataAnalysisScreen> createState() => _DataAnalysisScreenState();
}

class _DataAnalysisScreenState extends State<DataAnalysisScreen> {
  bool _isLoadingPulse = true;
  bool _isLoadingEngagement = true;
  bool _isLoadingFunnel = true;
  bool _isLoadingSentiment = true;
  
  Map<String, dynamic>? _pulseData;
  Map<String, dynamic>? _engagementData;
  List<dynamic>? _funnelData;
  Map<String, dynamic>? _sentimentData;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    _loadPulse();
    _loadEngagement();
    _loadFunnel();
    _loadSentiment();
  }

  Future<void> _loadPulse() async {
    setState(() => _isLoadingPulse = true);
    try {
      final result = await AdminService.getDataAnalysis();
      if (mounted && result['success']) {
        setState(() => _pulseData = result['data']['user_pulse']);
      }
    } finally {
      if (mounted) setState(() => _isLoadingPulse = false);
    }
  }

  Future<void> _loadEngagement() async {
    setState(() => _isLoadingEngagement = true);
    try {
      final result = await AdminService.getDataAnalysis();
      if (mounted && result['success']) {
        setState(() => _engagementData = result['data']['engagement']);
      }
    } finally {
      if (mounted) setState(() => _isLoadingEngagement = false);
    }
  }

  Future<void> _loadFunnel() async {
    setState(() => _isLoadingFunnel = true);
    try {
      final result = await AdminService.getDataAnalysis();
      if (mounted && result['success']) {
        setState(() => _funnelData = result['data']['funnel']);
      }
    } finally {
      if (mounted) setState(() => _isLoadingFunnel = false);
    }
  }

  Future<void> _loadSentiment() async {
    setState(() => _isLoadingSentiment = true);
    try {
      final result = await AdminService.getDataAnalysis();
      if (mounted && result['success']) {
        setState(() => _sentimentData = result['data']['sentiment']);
      }
    } finally {
      if (mounted) setState(() => _isLoadingSentiment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text(
          'Análisis de Datos',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: const Icon(Icons.chevron_left, color: Colors.black, size: 24),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: (_isLoadingPulse || _isLoadingEngagement || _isLoadingFunnel || _isLoadingSentiment)
            ? const LinearProgressIndicator(color: Colors.indigo, backgroundColor: Colors.transparent, minHeight: 2)
            : Container(height: 2, color: Colors.transparent),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Pulso de Usuario', Icons.analytics_rounded, showRefresh: true, onRefresh: _loadPulse),
              const SizedBox(height: 20),
              // Analysis KPIs
              const SizedBox(height: 20),
              // Analysis KPIs - Always visible, showing "..." when loading
              Row(
                children: [
                  Expanded(
                    child: KPICard(
                      title: 'Retención Semana 1',
                      value: _isLoadingPulse ? '...' : (_pulseData?['retention'] ?? '0%'),
                      subtitle: _isLoadingPulse ? 'Cargando...' : '+5% vs mes anterior',
                      icon: Icons.loop_rounded,
                      color: Colors.teal,
                      delay: 0,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: KPICard(
                      title: 'Tiempo Medio',
                      value: _isLoadingPulse ? '...' : (_pulseData?['avg_time'] ?? '0m'),
                      subtitle: _isLoadingPulse ? 'Cargando...' : 'Por sesión diaria',
                      icon: Icons.timer_outlined,
                      color: Colors.indigo,
                      delay: 100,
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              _buildSectionHeader('Participación por Funciones', Icons.pie_chart_rounded, showRefresh: true, onRefresh: _loadEngagement),
              const SizedBox(height: 16),
              _buildEngagementChart(),
              
              const SizedBox(height: 32),
              _buildSectionHeader('Embudo de Conversión', Icons.filter_list_rounded, showRefresh: true, onRefresh: _loadFunnel),
              const SizedBox(height: 16),
              _buildConversionFunnel(),
              const SizedBox(height: 40),
              _buildSectionHeader('Perspectivas de Sentimiento', Icons.mood_rounded, showRefresh: true, onRefresh: _loadSentiment),
              const SizedBox(height: 20),
              _buildSentimentAnalysis(),
              
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {bool showRefresh = false, VoidCallback? onRefresh}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.indigo),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        if (showRefresh) ...[
          const Spacer(),
          GestureDetector(
            onTap: onRefresh ?? _loadAllData,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh_rounded, size: 16, color: Colors.black54),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEngagementChart() {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: _isLoadingEngagement
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 45,
                      sections: [
                        PieChartSectionData(color: Colors.pinkAccent, value: (_engagementData?['Calendario']?['percent'] ?? 40).toDouble(), radius: 25, title: ''),
                        PieChartSectionData(color: Colors.amber, value: (_engagementData?['Síntomas']?['percent'] ?? 30).toDouble(), radius: 25, title: ''),
                        PieChartSectionData(color: Colors.cyan, value: (_engagementData?['Predicciones']?['percent'] ?? 30).toDouble(), radius: 25, title: ''),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('Calendario', Colors.pinkAccent, '${_engagementData?['Calendario']?['percent'] ?? 0}%'),
                      const SizedBox(height: 10),
                      _buildLegendItem('Síntomas', Colors.amber, '${_engagementData?['Síntomas']?['percent'] ?? 0}%'),
                      const SizedBox(height: 10),
                      _buildLegendItem('Predicciones', Colors.cyan, '${_engagementData?['Predicciones']?['percent'] ?? 0}%'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String percent) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "$label ($percent)", 
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildConversionFunnel() {
    if (_isLoadingFunnel) {
       return Container(
         height: 150,
         alignment: Alignment.center,
         child: const CircularProgressIndicator(),
       );
    }

    final stages = _funnelData ?? [
      {'label': 'Registros', 'value': '100%', 'color': '0xFF5C6BC0'},
      {'label': 'Perfil Completo', 'value': '0%', 'color': '0xFF7986CB'},
      {'label': 'Primer Síntoma', 'value': '0%', 'color': '0xFF9FA8DA'},
      {'label': 'Usuaria Activa', 'value': '0%', 'color': '0xFFC5CAE9'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: stages.map((stage) {
          final colorCode = int.parse(stage['label'] == 'Registros' ? '0xFF5C6BC0' : stage['color'] as String);
          final color = Color(colorCode);
          final valueStr = stage['value'] as String;
          final percent = (double.tryParse(valueStr.replaceAll('%', '')) ?? 0) / 100;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stage['label'] as String, 
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.indigo[900]),
                    ),
                    if (percent < 0.2)
                      Text(valueStr, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 24,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percent.clamp(0.05, 1.0),
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: color.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 8),
                        child: percent >= 0.15 
                            ? Text(valueStr, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSentimentAnalysis() {
    if (_isLoadingSentiment) {
       return Container(
         height: 100,
         alignment: Alignment.center,
         child: const CircularProgressIndicator(),
       );
    }

    final metrics = _sentimentData?['metrics'] ?? {'Positive': 0, 'Neutral': 0, 'Critical': 0};
    final tags = List<String>.from(_sentimentData?['tags'] ?? []);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSentimentMetric('Positivo', Icons.favorite_rounded, Colors.green, '${metrics['Positive']}%'),
              _buildSentimentMetric('Neutral', Icons.sentiment_neutral_rounded, Colors.grey, '${metrics['Neutral']}%'),
              _buildSentimentMetric('Crítico', Icons.error_outline_rounded, Colors.redAccent, '${metrics['Critical']}%'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Temas más comentados',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((t) => _buildTag(t, Colors.indigo)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentMetric(String label, IconData icon, Color color, String value) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
