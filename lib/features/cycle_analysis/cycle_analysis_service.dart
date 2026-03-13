import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CycleAnalysisService {
  // Mock data for analysis (This should eventually come from a database)
  static Map<String, dynamic> getMockAnalysisData() {
    return {
      'avg_cycle_length': 28,
      'last_cycle_length': 34,
      'regularity_score': 85,
      'anomalies': [
        {
          'title': 'Retraso detectado',
          'description': 'Tu último ciclo fue 6 días más largo que tu promedio habitual.',
          'severity': 'warning',
        }
      ],
      'correlations': [
        {
          'pattern': 'Dolor de cabeza + Irritabilidad',
          'insight': 'Notamos que cuando tienes dolor de cabeza, tu estado de ánimo suele ser "Irritable".',
          'recommendation': 'Te recomendamos hidratarte más en el día 14 de tu ciclo y practicar 5 minutos de meditación.',
        }
      ],
      'symptoms_summary': [
        {'label': 'Cólicos', 'count': 12, 'trend': 'up', 'icon': 'lib/assets/image/colicos.png'},
        {'label': 'Fatiga', 'count': 8, 'trend': 'stable', 'icon': 'lib/assets/image/fatiga.png'},
        {'label': 'Hinchazón', 'count': 5, 'trend': 'down', 'icon': 'lib/assets/image/hinchazon.png'},
      ],
      'emotions_summary': [
        {'label': 'Tranquila', 'percentage': 60},
        {'label': 'Irritable', 'percentage': 25},
        {'label': 'Sensible', 'percentage': 15},
      ]
    };
  }

  static List<Map<String, String>> getProfessionalAdvice() {
    return [
      {
        'title': 'Consulta a tu ginecólogo',
        'advice': 'Si notas variaciones de más de 7 días de forma frecuente, es recomendable realizar un chequeo hormonal.',
      },
      {
        'title': 'Ritmo de sueño',
        'advice': 'La irregularidad puede estar ligada al estrés. Intenta mantener un horario de sueño constante.',
      }
    ];
  }

  static Future<void> generateAndExportPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, text: 'Reporte de Salud Menstrual - OHTUIE'),
              pw.SizedBox(height: 20),
              pw.Text('Resumen de Ciclos', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
              pw.Bullet(text: 'Promedio de ciclo: ${data['avg_cycle_length']} días'),
              pw.Bullet(text: 'Último ciclo: ${data['last_cycle_length']} días'),
              pw.SizedBox(height: 10),
              pw.Text('Anomalías Detectadas:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...(data['anomalies'] as List).map((a) => pw.Text('- ${a['title']}: ${a['description']}')),
              pw.SizedBox(height: 20),
              pw.Text('Correlaciones y Diagnóstico OHTUIE:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...(data['correlations'] as List).map((c) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Patrón: ${c['pattern']}'),
                  pw.Text('Observación: ${c['insight']}'),
                  pw.Text('Recomendación: ${c['recommendation']}'),
                  pw.SizedBox(height: 5),
                ]
              )),
              pw.SizedBox(height: 20),
              pw.Footer(
                trailing: pw.Text('Generado por OHTUIE App', style: pw.TextStyle(color: PdfColors.grey)),
              )
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
