import 'package:flutter/material.dart';
import '../services/transaction_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool _isIncome = true;
  DateTime _selectedDate = DateTime.now();
  String? selectedCategory;
  final TextEditingController otherCategoryController = TextEditingController();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

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
    dateController.text =
        "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}";
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    dateController.dispose();
    otherCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عملية'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('دخل'),
                  selected: _isIncome,
                  onSelected: (val) {
                    setState(() {
                      _isIncome = true;
                    });
                  },
                  selectedColor: Colors.green.shade300,
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('مصروف'),
                  selected: !_isIncome,
                  onSelected: (val) {
                    setState(() {
                      _isIncome = false;
                    });
                  },
                  selectedColor: Colors.red.shade300,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // المبلغ
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // التصنيف
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'التصنيف',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedCategory = val;
                });
              },
            ),

            // يظهر حقل الكتابة لو المستخدم اختار "أخرى"
            if (selectedCategory == 'أخرى') ...[
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

            // التاريخ
            TextFormField(
              readOnly: true,
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'التاريخ',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                    dateController.text =
                        "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}";
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // ملاحظات
            TextFormField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      if (amountController.text.trim().isEmpty || selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('من فضلك أدخل المبلغ واختر التصنيف')),
                        );
                        return;
                      }

                      // تحديد التصنيف النهائي
                      String finalCategory = selectedCategory == 'أخرى'
                          ? otherCategoryController.text.trim()
                          : selectedCategory!;

                      if (finalCategory.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('من فضلك أدخل اسم التصنيف')),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        await TransactionService().addTransaction(
                          amount: double.parse(amountController.text.trim()),
                          type: _isIncome ? 'دخل' : 'مصروف',
                          category: finalCategory,
                          date: _selectedDate,
                          note: noteController.text.trim(),
                        );

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تمت إضافة العملية بنجاح')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('حدث خطأ أثناء الإضافة')),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
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
                      'إضافة العملية',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}


