import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction_details_screen.dart';
import '../services/transaction_service.dart';

class TransactionsListScreen extends StatelessWidget {
  const TransactionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('كل العمليات')),
      body: StreamBuilder<QuerySnapshot>(
        stream: TransactionService().getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('لا توجد عمليات بعد'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              // ✨ أضف docId
              data['docId'] = doc.id;

              return ListTile(
                title: Text('${data['category']} - ${data['amount']} ج.م'),
                subtitle: Text(data['date'].toString().substring(0, 10)),
                trailing: Text(data['type']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
  builder: (context) => TransactionDetailsScreen(docId: data['docId']),
),

                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
