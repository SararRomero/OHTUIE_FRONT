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
  bool _isLoading = true;
  Map<String, dynamic>? _analysisData;

  @override
  void initState() {
    super.initState();
    _loadAnalysisData();
  }

  Future<void> _loadAnalysisData() async {
    setState(() => _isLoading = true);
    
    // Simulate complex data fetching
    final result = await AdminService.getStatistics();
    
    if (mounted) {
      setState(() {
        if (result['success']) {
          _analysisData = result['data'];
        }
        _isLoading = false;
      });
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
      ),
      body: RefreshIndicator(
        onRefresh: _loadAnalysisData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Pulso de Usuario', Icons.analytics_rounded),
              const SizedBox(height: 16),
              // Analysis KPIs
              SizedBox(
                height: 165,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    KPICard(
                      title: 'Retención W1',
                      value: _isLoading ? '...' : '68%',
                      subtitle: '+5% vs mes anterior',
                      icon: Icons.loop_rounded,
                      color: Colors.teal,
                      delay: 0,
                    ),
                    const SizedBox(width: 16),
                    KPICard(
                      title: 'Tiempo Medio',
                      value: _isLoading ? '...' : '12m',
                      subtitle: 'Por sesión diaria',
                      icon: Icons.timer_outlined,
                      color: Colors.indigo,
                      delay: 100,
                    ),
                    const SizedBox(width: 16),
                    KPICard(
                      title: 'Satisfacción',
                      value: _isLoading ? '...' : '4.8',
                      subtitle: 'CSAT Score (1-5)',
                      icon: Icons.star_rounded,
                      color: Colors.amber,
                      delay: 200,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              _buildSectionHeader('Participación por Funciones', Icons.pie_chart_rounded),
              const SizedBox(height: 16),
              _buildEngagementChart(),
              
              const SizedBox(height: 32),
              _buildSectionHeader('Embudo de Conversión', Icons.filter_list_rounded),
              const SizedBox(height: 16),
              _buildConversionFunnel(),

              const SizedBox(height: 32),
              _buildSectionHeader('Perspectivas de Sentimiento', Icons.mood_rounded),
              const SizedBox(height: 16),
              _buildSentimentAnalysis(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
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
      child: _isLoading
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
                        PieChartSectionData(color: Colors.pinkAccent, value: 40, radius: 25, title: ''),
                        PieChartSectionData(color: Colors.amber, value: 25, radius: 25, title: ''),
                        PieChartSectionData(color: Colors.cyan, value: 20, radius: 25, title: ''),
                        PieChartSectionData(color: Colors.purpleAccent, value: 15, radius: 25, title: ''),
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
                      _buildLegendItem('Calendario', Colors.pinkAccent),
                      const SizedBox(height: 10),
                      _buildLegendItem('Síntomas', Colors.amber),
                      const SizedBox(height: 10),
                      _buildLegendItem('Predicciones', Colors.cyan),
                      const SizedBox(height: 10),
                      _buildLegendItem('Comunidad', Colors.purpleAccent),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
      ],
    );
  }

  Widget _buildConversionFunnel() {
    final stages = [
      {'label': 'Registros', 'value': '100%', 'color': Colors.indigo[400]},
      {'label': 'Perfil Completo', 'value': '85%', 'color': Colors.indigo[300]},
      {'label': 'Primer Síntoma', 'value': '62%', 'color': Colors.indigo[200]},
      {'label': 'Usuaria Activa', 'value': '48%', 'color': Colors.indigo[100]},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: stages.map((stage) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(stage['label'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: double.parse((stage['value'] as String).replaceAll('%', '')) / 100,
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [stage['color'] as Color, (stage['color'] as Color).withOpacity(0.7)]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(stage['value'] as String, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSentimentAnalysis() {
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
              _buildSentimentMetric('Positivo', Icons.favorite_rounded, Colors.green, '72%'),
              _buildSentimentMetric('Neutral', Icons.sentiment_neutral_rounded, Colors.grey, '20%'),
              _buildSentimentMetric('Crítico', Icons.error_outline_rounded, Colors.redAccent, '8%'),
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
            children: [
              _buildTag('Precisión', Colors.green),
              _buildTag('Diseño UI', Colors.blue),
              _buildTag('Carga rápida', Colors.teal),
              _buildTag('Notificaciones', Colors.orange),
              _buildTag('Privacidad', Colors.indigo),
            ],
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
