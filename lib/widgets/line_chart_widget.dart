import 'package:flutter/material.dart';
import 'package:flutter_charts/flutter_charts.dart';

class ChartWidget extends StatelessWidget {
  final List<double> cashData;
  final List<double> creditData;
  final List<String> xUserLabels;

  const ChartWidget({
    super.key,
    required this.cashData,
    required this.creditData,
    required this.xUserLabels,
  });

  @override
  Widget build(BuildContext context) {
    // Prepare data series
    List<List<double>> dataRows = [cashData, creditData];

    // Chart options
    ChartOptions chartOptions = const ChartOptions(
      dataContainerOptions: DataContainerOptions(
        startYAxisAtDataMinRequested: true,
      ),
    );

    // Chart data setup
    ChartData chartData = ChartData(
      dataRows: dataRows,
      xUserLabels: xUserLabels,
      dataRowsLegends: const ['Cash', 'Credit'],
      chartOptions: chartOptions,
    );

    // Create line chart container
    LineChartTopContainer lineChartContainer = LineChartTopContainer(
      chartData: chartData,
    );

    // Create line chart painter
    LineChartPainter lineChartPainter = LineChartPainter(
      lineChartContainer: lineChartContainer,
    );

    // Create line chart widget
    LineChart lineChart = LineChart(
      painter: lineChartPainter,
    );

    // Wrap the chart in a container for styling
    return Container(
      height: 300, // Adjust height as needed
      padding: const EdgeInsets.all(8.0),
      child: lineChart,
    );
  }
}
