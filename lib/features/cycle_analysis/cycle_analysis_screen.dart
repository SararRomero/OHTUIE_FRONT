import 'package:flutter/material.dart';
import 'cycle_analysis_service.dart';

class CycleAnalysisScreen extends StatefulWidget {
  const CycleAnalysisScreen({super.key});

  @override
  State<CycleAnalysisScreen> createState() => _CycleAnalysisScreenState();
}

class _CycleAnalysisScreenState extends State<CycleAnalysisScreen> {
  final Map<String, dynamic> _data = CycleAnalysisService.getMockAnalysisData();
  bool _isExporting = false;

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
            colors: [Color(0xFFF0F5FF), Color(0xFFFCF0F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryGrid(),
                      const SizedBox(height: 25),
                      _buildAnomalyAlert(),
                      const SizedBox(height: 25),
                      _buildDetectiveCard(),
                      const SizedBox(height: 25),
                      _buildSymptomStats(),
                      const SizedBox(height: 25),
                      _buildAdviceSection(),
                      const SizedBox(height: 30),
                      _buildExportButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFF5F5F5)),
                ),
              ),
            ),
          ),
          const Text(
            "Análisis de tus Ciclos",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            "Promedio",
            "${_data['avg_cycle_length']} días",
            Icons.history,
            const Color(0xFFBDD4FF),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            "Regularidad",
            "${_data['regularity_score']}%",
            Icons.auto_graph,
            const Color(0xFFFFB2C1),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAnomalyAlert() {
    final anomaly = (_data['anomalies'] as List).first;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9800), size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  anomaly['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100), fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  anomaly['description'],
                  style: TextStyle(color: Colors.orange[900]?.withOpacity(0.8), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectiveCard() {
    final correlation = (_data['correlations'] as List).first;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFF3E5F5), shape: BoxShape.circle),
                child: const Icon(Icons.psychology, color: Color(0xFF9C27B0), size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                "Detective OHTUIE",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "🧠 Correlación Detectada:",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9C27B0), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            correlation['insight'],
            style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    correlation['recommendation'],
                    style: TextStyle(fontSize: 13, color: Colors.grey[700], fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Top Síntomas del Ciclo",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...(_data['symptoms_summary'] as List).map((s) => _buildSymptomRow(s)),
      ],
    );
  }

  Widget _buildSymptomRow(Map<String, dynamic> s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Image.asset(s['icon'], fit: BoxFit.contain),
          ),
          const SizedBox(width: 16),
          Text(s['label'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const Spacer(),
          Text("${s['count']} veces", style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAdviceSection() {
    final advices = CycleAnalysisService.getProfessionalAdvice();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recomendaciones Profesionales",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...advices.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFFFF85A1), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(a['advice']!, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildExportButton() {
    return GestureDetector(
      onTap: _isExporting ? null : () async {
        setState(() => _isExporting = true);
        await CycleAnalysisService.generateAndExportPdf(_data);
        setState(() => _isExporting = false);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: _isExporting 
          ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  "Exportar Reporte a PDF",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
      ),
    );
  }
}
