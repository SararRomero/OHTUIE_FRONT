import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final Widget chart;
  final IconData actionIcon;
  final Color actionColor;
  final Color loadingColor;
  final bool isLoading;
  final String? dateRange;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const ChartCard({
    super.key,
    required this.title,
    required this.chart,
    required this.actionIcon,
    required this.actionColor,
    required this.loadingColor,
    required this.isLoading,
    this.dateRange,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: actionColor.withAlpha((0.15 * 255).toInt()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(actionIcon, size: 18, color: actionColor),
                ),
              ),
            ],
          ),
          if (dateRange != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.grey),
                  onPressed: onPrev,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                Text(
                  dateRange!,
                  style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.grey),
                  onPressed: onNext,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: loadingColor))
                : chart,
          ),
        ],
      ),
    );
  }
}
