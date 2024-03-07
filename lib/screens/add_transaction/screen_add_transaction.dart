import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_manager/db/category/category_db.dart';
import 'package:money_manager/db/transactins/transaction_model.dart';
import 'package:money_manager/models/category/category_model.dart';
import 'package:money_manager/models/transaction/transaction_db.dart';
import 'package:money_manager/screens/category/income_category_list.dart';

class ScreenaddTransaction extends StatefulWidget {
  static const routeName = '/add-transaction';

  const ScreenaddTransaction({super.key});

  @override
  State<ScreenaddTransaction> createState() => _ScreenaddTransactionState();
}

class _ScreenaddTransactionState extends State<ScreenaddTransaction> {
  DateTime? _selectedDate;
  CategoryType? _selectedcategoryType;
  CategoryModel? _selectedCategoryModel;
  String? _categoryID;
  final _purposeTextEditingController = TextEditingController();
  final _amountTextEditingController = TextEditingController();
  @override
  void initState() {
    _selectedcategoryType = CategoryType.income;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //purpose
            TextFormField(
              controller: _purposeTextEditingController,
              decoration: InputDecoration(
                  hintText: 'Purpose',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            ),
            SizedBox(height: 20),
            //amount
            TextFormField(
              controller: _amountTextEditingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  hintText: 'Amount',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            ),
            //Calender
            // _selectedDate == null ?
            TextButton.icon(
              onPressed: () async {
                final _selectedDateTemp = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(Duration(days: 30)),
                  lastDate: DateTime.now(),
                );
                if (_selectedDateTemp == Null) {
                  return;
                } else {
                  print(_selectedDateTemp.toString());
                  setState(() {
                    _selectedDate = _selectedDateTemp;
                  });
                }
              },
              icon: Icon(Icons.calendar_today),
              label: Text(_selectedDate == null
                  ? 'Select Date'
                  : _selectedDate.toString()),
            ),
            //   : Text(_selectedDate.toString()),
            //Category
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Radio(
                        value: CategoryType.income,
                        groupValue: _selectedcategoryType,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedcategoryType = CategoryType.income;
                            _categoryID = null;
                          });
                        }),
                    Text('Income'),
                  ],
                ),
                Row(
                  children: [
                    Radio(
                        value: CategoryType.expense,
                        groupValue: _selectedcategoryType,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedcategoryType = CategoryType.expense;
                            _categoryID = null;
                          });
                        }),
                    Text('Expense'),
                  ],
                ),
              ],
            ),
            //Category type
            DropdownButton(
              hint: Text('Select Category'),
              value: _categoryID,
              items: (_selectedcategoryType == CategoryType.income
                      ? CategoryDB().incomeCategoryListListener
                      : CategoryDB().expenseCategoryListListener)
                  .value
                  .map((e) {
                return DropdownMenuItem(
                  value: e.id,
                  child: Text(e.name),
                  onTap: () {
                    _selectedCategoryModel = e;
                  },
                );
              }).toList(),
              onChanged: (selectedValue) {
                print(selectedValue);
                setState(() {
                  _categoryID = selectedValue;
                });
              },
              onTap: () {},
            ),
            //Submit
            ElevatedButton(
                onPressed: () {
                  addTransaction();
                  Navigator.pop(context); 
                  TransactionDB.instance.refresh();
                },
                child: Text('Submit'))
          ],
        ),
      )),
    );
  }

  Future<void> addTransaction() async {
    final _purposeText = _purposeTextEditingController.text;
    final _amountText = _amountTextEditingController.text;
    if (_purposeText.isEmpty) {
      return;
    }
    if (_amountText.isEmpty) return;
    if (_categoryID == null) {
      return;
    }
    if (_selectedDate == null) return;
    final _parseAmount = double.tryParse(_amountText);
    if (_parseAmount == null) return;
    final _model = TransactionModel(
        purpose: _purposeText,
        amount: _parseAmount,
        date: _selectedDate!,
        type: _selectedcategoryType!,
        category: _selectedCategoryModel!);

    await TransactionDB.instance.addTransaction(_model);
  }
}
