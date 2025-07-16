import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> addTransaction({
    required double amount,
    required String type,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    if (userId == null) return;
    await _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .add({
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'note': note ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getTransactions() {
    if (userId == null) {
      return const Stream.empty();
    }
    return _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<void> deleteTransaction(String transactionId) async {
    if (userId == null) return;
    await _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  Future<void> updateTransaction(
    String docId,
    Map<String, dynamic> data,
  ) async {
    if (userId == null) return;
    await _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(docId)
        .update(data);
  }
}


