import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../auth/auth_service.dart';
import '../profile/user_service.dart';
import '../../core/network/api_client.dart';

class CycleAnalysisService {
  static Future<Map<String, dynamic>> fetchCycleAnalysis() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return getMockAnalysisData();

      final response = await ApiClient.get("/cycles/analysis", token: token);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error response: ${response.body}");
        return getMockAnalysisData();
      }
    } catch (e) {
      print("Error in fetchCycleAnalysis: $e");
      return getMockAnalysisData();
    }
  }

  // Mock data for analysis (Used as fallback or initial state)
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

  static pw.Widget _buildSectionTitle(String title, PdfColor color) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15, top: 10),
      padding: const pw.EdgeInsets.only(bottom: 5),
      decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: color, width: 2))),
      child: pw.Text(title, style: pw.TextStyle(color: color, fontSize: 16, fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _buildStatBox(String title, String value, PdfColor color) {
    return pw.Container(
      width: 150, 
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color.shade(0.2), width: 1.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700), textAlign: pw.TextAlign.center),
          pw.SizedBox(height: 8),
          pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: color)),
        ]
      )
    );
  }

  static Future<void> generateAndExportPdf(Map<String, dynamic> data) async {
    // 1. Fetch user data
    String patientName = "Usuaria OHTUIE";
    String patientEmail = "No especificado";
    int periodDuration = 5;
    
    try {
      final userResult = await UserService.getUserMe();
      if (userResult['success']) {
        patientName = userResult['data']['full_name'] ?? patientName;
        patientEmail = userResult['data']['email'] ?? patientEmail;
        periodDuration = userResult['data']['period_duration'] ?? 5;
      }
    } catch (e) {
      // Fallback variables remain
    }

    final String currentDate = DateFormat('d \'de\' MMMM, yyyy', 'es').format(DateTime.now());

    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#FF85A1');
    final secondaryColor = PdfColor.fromHex('#81A4FF');
    final textColor = PdfColor.fromHex('#333333');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // HEADER
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Reporte de Salud Menstrual', style: pw.TextStyle(color: primaryColor, fontSize: 22, fontWeight: pw.FontWeight.bold)),
                  pw.Text('OHTUIE', style: pw.TextStyle(color: secondaryColor, fontSize: 22, fontWeight: pw.FontWeight.bold)),
                ]
              )
            ),
            pw.SizedBox(height: 10),
            
            // DATE & PATIENT INFO
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F5F6FF'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Información de la Paciente', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: textColor)),
                      pw.SizedBox(height: 5),
                      pw.Text('Nombre: $patientName', style: pw.TextStyle(fontSize: 11, color: textColor)),
                      pw.Text('Email: $patientEmail', style: pw.TextStyle(fontSize: 11, color: textColor)),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Fecha del Reporte', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: textColor)),
                      pw.SizedBox(height: 5),
                      pw.Text(currentDate, style: pw.TextStyle(fontSize: 11, color: textColor)),
                    ]
                  )
                ]
              )
            ),
            pw.SizedBox(height: 25),

            // CYCLE SUMMARY
            _buildSectionTitle('Resumen de Ciclos', primaryColor),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildStatBox('Promedio del Ciclo', '${data['avg_cycle_length']} días', secondaryColor),
                _buildStatBox('Duración del Periodo', '$periodDuration días', primaryColor),
                _buildStatBox('Ventana Fértil Est.', '6 días', PdfColor.fromHex('#9575CD')),
              ]
            ),
            pw.SizedBox(height: 25),

            // SYMPTOMS
            _buildSectionTitle('Síntomas Frecuentes', textColor),
            pw.TableHelper.fromTextArray(
              headers: ['Síntoma Registrado', 'Frecuencia en los últimos ciclos'],
              data: (data['symptoms_summary'] as List).map((s) => [s['label'], '${s['count']} veces']).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 11),
              headerDecoration: pw.BoxDecoration(color: primaryColor),
              cellStyle: pw.TextStyle(fontSize: 10, color: textColor),
              cellHeight: 25,
              cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.center},
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            ),
            pw.SizedBox(height: 25),

            // ANOMALIES
            if ((data['anomalies'] as List).isNotEmpty) ...[
              _buildSectionTitle('Anomalías Detectadas', PdfColor.fromHex('#FF9800')),
              ...(data['anomalies'] as List).map((a) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#FFF3E0'),
                  border: pw.Border.all(color: PdfColor.fromHex('#FFB74D'), width: 1),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('⚠️ ${a['title']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#E65100'), fontSize: 12)),
                    pw.SizedBox(height: 6),
                    pw.Text(a['description'], style: pw.TextStyle(color: textColor, fontSize: 11)),
                  ]
                )
              )),
            ],

            // CORRELATIONS
            if ((data['correlations'] as List).isNotEmpty) ...[
              _buildSectionTitle('Análisis Detective OHTUIE', PdfColor.fromHex('#9C27B0')),
              ...(data['correlations'] as List).map((c) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F3E5F5'),
                  border: pw.Border.all(color: PdfColor.fromHex('#CE93D8'), width: 1),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Patrón Detectado: ${c['pattern']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#7B1FA2'), fontSize: 12)),
                    pw.SizedBox(height: 8),
                    pw.Text('Observación: ${c['insight']}', style: pw.TextStyle(color: textColor, fontSize: 11)),
                    pw.SizedBox(height: 8),
                    pw.Text('Recomendación: ${c['recommendation']}', style: pw.TextStyle(color: PdfColors.grey800, fontSize: 11, fontStyle: pw.FontStyle.italic)),
                  ]
                )
              )),
            ],

          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 20),
            padding: const pw.EdgeInsets.only(top: 15),
            decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 1))),
            child: pw.Text(
              'Este documento es generado automáticamente por OHTUIE App y sirve como apoyo informativo para sus revisiones médicas.\nNo reemplaza el diagnóstico, tratamiento o consejo de un profesional de la salud calificado.',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9),
            ),
          );
        }
      )
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Reporte_OHTUIE_${patientName.replaceAll(' ', '_')}.pdf',
    );
  }
}
