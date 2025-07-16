import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: TransactionService().getTransactions(),
          builder: (context, snapshot) {
            double totalIncome = 0;
            double totalExpense = 0;

            // نجمع الدخل والمصروف لكل شهر
            Map<String, double> monthlyIncome = {};
            Map<String, double> monthlyExpense = {};

            if (snapshot.hasData) {
              final transactions = snapshot.data!.docs;
              for (var doc in transactions) {
                final data = doc.data() as Map<String, dynamic>;
                final amount = (data['amount'] ?? 0).toDouble();
                final type = data['type'];
                final dateStr = data['date'];
                DateTime date = DateTime.tryParse(dateStr) ?? DateTime.now();

                String monthKey = DateFormat('yyyy-MM').format(date); // مثال: 2025-07

                if (type == 'دخل') {
                  totalIncome += amount;
                  monthlyIncome[monthKey] = (monthlyIncome[monthKey] ?? 0) + amount;
                } else if (type == 'مصروف') {
                  totalExpense += amount;
                  monthlyExpense[monthKey] = (monthlyExpense[monthKey] ?? 0) + amount;
                }
              }
            }

            // نحصل على آخر 6 شهور مرتبة
            List<String> last6Months = List.generate(6, (index) {
              DateTime date = DateTime.now().subtract(Duration(days: 30 * (5 - index)));
              return DateFormat('yyyy-MM').format(date);
            });

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (totalIncome == 0 && totalExpense == 0) {
              return const Center(child: Text('لا توجد بيانات بعد لرسم التقرير'));
            }

            return Column(
              children: [
                // Pie Chart
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: [
                        if (totalIncome > 0)
                          PieChartSectionData(
                            color: Colors.green,
                            value: totalIncome,
                            title: 'دخل',
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        if (totalExpense > 0)
                          PieChartSectionData(
                            color: Colors.red,
                            value: totalExpense,
                            title: 'مصروف',
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // المؤشرات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildIndicator(Colors.green, 'الدخل: ${totalIncome.toStringAsFixed(2)} ج.م'),
                    _buildIndicator(Colors.red, 'المصروف: ${totalExpense.toStringAsFixed(2)} ج.م'),
                  ],
                ),
                const SizedBox(height: 24),

                // Bar Chart
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _maxY(monthlyIncome, monthlyExpense) * 1.2,
                      barGroups: last6Months.map((month) {
                        final income = monthlyIncome[month] ?? 0;
                        final expense = monthlyExpense[month] ?? 0;
                        return BarChartGroupData(
                          x: int.parse(month.split('-')[1]), // الشهر كرقم
                          barRods: [
                            BarChartRodData(
                              toY: income,
                              color: Colors.green,
                              width: 8,
                            ),
                            BarChartRodData(
                              toY: expense,
                              color: Colors.red,
                              width: 8,
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              String monthNum = value.toInt().toString().padLeft(2, '0');
                              return Text(monthNum, style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildIndicator(Color color, String text) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  double _maxY(Map<String, double> income, Map<String, double> expense) {
    double maxIncome = income.values.isEmpty ? 0 : income.values.reduce((a, b) => a > b ? a : b);
    double maxExpense = expense.values.isEmpty ? 0 : expense.values.reduce((a, b) => a > b ? a : b);
    return maxIncome > maxExpense ? maxIncome : maxExpense;
  }
}
