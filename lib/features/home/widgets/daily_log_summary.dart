import 'package:flutter/material.dart';

class DailyLogSummary extends StatelessWidget {
  final Map<String, dynamic>? dailyLog;
  final Map<String, Map<String, String>> moodOptions;
  final Map<String, Map<String, String>> symptomOptions;
  final Map<String, String> flowOptions;

  const DailyLogSummary({
    super.key,
    required this.dailyLog,
    required this.moodOptions,
    required this.symptomOptions,
    required this.flowOptions,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyLog == null) return const SizedBox.shrink();

    final symptoms = List<String>.from(dailyLog?['symptoms'] ?? []);
    final moods = List<String>.from(dailyLog?['moods'] ?? []);
    final flow = dailyLog?['flow'] ?? 'none';

    if (symptoms.isEmpty && moods.isEmpty && flow == 'none') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (moods.isNotEmpty) ...[
          const Text(
            "Estados de ánimo",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: moods.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final moodId = moods[index];
                final moodInfo = moodOptions[moodId] ?? {'label': moodId, 'imagePath': 'lib/assets/image/normal.png'};
                return _buildChip(moodInfo['imagePath']!, moodInfo['label']!);
              },
            ),
          ),
          const SizedBox(height: 25),
        ],
        if (symptoms.isNotEmpty || flow != 'none') ...[
          const Text(
            "Síntomas y Flujo",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (flow != 'none') ...[
                  _buildChipWithIcon(
                    Icons.water_drop, 
                    "Flujo: ${flowOptions[flow] ?? flow}",
                    const Color(0xFFFF4081),
                  ),
                  const SizedBox(width: 12),
                ],
                ...symptoms.map((symptomId) {
                  final symptomInfo = symptomOptions[symptomId] ?? {'label': symptomId, 'imagePath': 'lib/assets/image/dolor_de_cabeza.png'};
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildChip(symptomInfo['imagePath']!, symptomInfo['label']!),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChip(String imagePath, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(imagePath, width: 22, height: 22),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildChipWithIcon(IconData icon, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
