import 'package:expenses_app/services/transaction_service.dart';
import 'package:flutter/material.dart';

class EditTransactionScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditTransactionScreen({super.key, required this.data});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController amountController;
  late TextEditingController noteController;
  late TextEditingController otherCategoryController;
  String type = 'دخل'; 
  String category = '';
  DateTime? selectedDate;

  bool _isLoading = false;

  final List<String> categories = [
    'طعام',
    'مواصلات',
    'ترفيه',
    'راتب',
    'تسوق',
    'صحة',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(
        text: widget.data['amount']?.toString() ?? '');
    noteController = TextEditingController(text: widget.data['note'] ?? '');
    otherCategoryController = TextEditingController();

    type = widget.data['type'] ?? 'دخل';

    category = widget.data['category'] ?? '';
    if (!categories.contains(category)) {
      category = 'أخرى';
      otherCategoryController.text = widget.data['category'];
    }

    if (type != 'دخل' && type != 'مصروف') {
      type = 'دخل';
    }

    String? dateString = widget.data['date'];
    if (dateString != null) {
      selectedDate = DateTime.tryParse(dateString);
    } else {
      selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    otherCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docId = widget.data['docId'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل العملية'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(
                labelText: 'التصنيف',
                border: OutlineInputBorder(),
              ),
              items: categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    category = value;
                  });
                }
              },
            ),
            if (category == 'أخرى') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: otherCategoryController,
                decoration: const InputDecoration(
                  labelText: 'اكتب التصنيف',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(
                labelText: 'النوع',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'دخل', child: Text('دخل')),
                DropdownMenuItem(value: 'مصروف', child: Text('مصروف')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    type = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('التاريخ'),
              subtitle: Text(
                selectedDate != null
                    ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                    : 'لم يتم اختيار تاريخ',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      if (amountController.text.trim().isEmpty ||
                          category.isEmpty ||
                          selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('يرجى ملء جميع الحقول المطلوبة')),
                        );
                        return;
                      }
                      String finalCategory = category == 'أخرى'
                          ? otherCategoryController.text.trim()
                          : category;
                      if (finalCategory.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('يرجى كتابة اسم التصنيف')),
                        );
                        return;
                      }
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        await TransactionService().updateTransaction(
                          docId,
                          {
                            'amount': double.tryParse(
                                    amountController.text.trim()) ??
                                0,
                            'category': finalCategory,
                            'note': noteController.text.trim(),
                            'type': type,
                            'date': selectedDate!.toIso8601String(),
                          },
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('تم تحديث العملية بنجاح')),
                          );
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('حدث خطأ أثناء التحديث')),
                          );
                        }
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'حفظ التعديلات',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
