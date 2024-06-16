import 'package:flutter/material.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> dataMap;
  final List<Color> colorList;

  const PieChartWidget({
    super.key,
    required this.dataMap,
    required this.colorList,
  });

  @override
  Widget build(BuildContext context) {
    return PieChart(
      dataMap: dataMap,
      animationDuration: const Duration(milliseconds: 1000),
      chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 2.2,
      colorList: colorList,
      initialAngleInDegree: 0,
      chartType: ChartType.disc,
      ringStrokeWidth: 32,
      legendOptions: LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.right,
        showLegends: true,
        legendShape: BoxShape.rectangle,
        legendTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: AppColor
              .primaryTextColor, // Adjust as per your AppColor.primaryTextColor
        ),
      ),
      chartValuesOptions: ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: true,
        showChartValuesOutside: true,
        decimalPlaces: 1,
        chartValueStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 10,
          color: AppColor
              .placeholderTextColor, // Adjust as per your AppColor.primaryTextColor
        ),
      ),
    );
  }
}
