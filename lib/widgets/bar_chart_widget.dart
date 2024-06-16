import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:order_processing_app/utils/app_colors.dart';

class BarChartWidget extends StatefulWidget {
  final Map<String, double> dataMap;
  final List<Color> colorList;

  const BarChartWidget({
    super.key,
    required this.dataMap,
    required this.colorList,
  });

  @override
  _BarChartWidgetState createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  late double maxY;

  @override
  void initState() {
    super.initState();
    maxY = calculateMaxY();
  }

  @override
  void didUpdateWidget(covariant BarChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataMap != widget.dataMap) {
      maxY = calculateMaxY();
    }
  }

  double calculateMaxY() {
    double highestValue = widget.dataMap.values
        .fold(0, (prev, element) => element > prev ? element : prev);

    double baseMargin = (highestValue / 10).ceil() * 10;

    // Add additional margin if highestValue is more than 1000
    if (highestValue > 1000) {
      baseMargin += 100;
    }

    return baseMargin;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY, // Use the dynamically calculated maxY
          barGroups: widget.dataMap.entries.map((entry) {
            return BarChartGroupData(
              x: entry.key.hashCode,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: widget.colorList[
                      widget.dataMap.keys.toList().indexOf(entry.key) %
                          widget.colorList.length],
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  width: 16,
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                reservedSize: 0,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 25,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    '${value.toInt()}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                      color: AppColor.placeholderTextColor,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: true), // Turn off grid lines
          borderData: FlBorderData(
            show: false,
            border: const Border(
              left: BorderSide(
                color: AppColor.widgetStroke,
                width: 1,
              ),
              bottom: BorderSide(
                color: AppColor.widgetStroke,
                width: 1,
              ),
              top: BorderSide(
                color: Colors.transparent,
                width: 0,
              ),
              right: BorderSide(
                color: Colors.transparent,
                width: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
