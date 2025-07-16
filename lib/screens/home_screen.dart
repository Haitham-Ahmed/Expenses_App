import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import 'transaction_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مصروفي'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: TransactionService().getTransactions(),
              builder: (context, snapshot) {
                double totalBalance = 0.0;
                if (snapshot.hasData) {
                  final transactions = snapshot.data!.docs;
                  for (var doc in transactions) {
                    final data = doc.data() as Map<String, dynamic>;
                    final amount = data['amount'] ?? 0;
                    final type = data['type'];
                    if (type == 'دخل') {
                      totalBalance += amount;
                    } else {
                      totalBalance -= amount;
                    }
                  }
                }
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  color: Colors.green.shade100,
                  child: SizedBox(
                    width: double.infinity,
                    height: 120,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'الرصيد الكلي',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${totalBalance.toStringAsFixed(2)} ج.م',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'أحدث العمليات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: TransactionService().getTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('حدث خطأ'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final transactions = snapshot.data!.docs;

                  if (transactions.isEmpty) {
                    return const Center(child: Text('لا توجد عمليات بعد'));
                  }

                  return ListView(
                    children:
                        transactions.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final type = data['type'];
                          final amount = data['amount'];
                          final category = data['category'];

                          final isIncome = type == 'دخل';
                          final icon =
                              isIncome
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward;
                          final color = isIncome ? Colors.green : Colors.red;

                          return _buildTransactionItem(
                            category,
                            '${isIncome ? '+' : '-'}${amount} ج.م',
                            icon,
                            color,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => TransactionDetailsScreen(
                                        docId: doc.id,
                                      ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-transaction');
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
          } else if (index == 1) {
            Navigator.pushNamed(context, '/reports');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/settings');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'التقارير',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String amount,
    IconData icon,
    Color iconColor, {
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title),
        trailing: Text(
          amount,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
