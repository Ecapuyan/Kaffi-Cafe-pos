import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kaffi_cafe_pos/models/voucher_model.dart';
import 'package:kaffi_cafe_pos/utils/app_theme.dart';
import 'package:kaffi_cafe_pos/widgets/text_widget.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  final Stream<QuerySnapshot> _vouchersStream =
      FirebaseFirestore.instance.collection('vouchers').orderBy('expiryDate', descending: true).snapshots();

  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _discountController = TextEditingController();
  String _discountType = 'percentage';
  DateTime _expiryDate = DateTime.now();
  bool _isActive = true;

  Future<void> _addVoucher() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await FirebaseFirestore.instance.collection('vouchers').add({
        'code': _codeController.text,
        'discount': double.parse(_discountController.text),
        'discountType': _discountType,
        'expiryDate': Timestamp.fromDate(_expiryDate),
        'isActive': _isActive,
      });
      Navigator.of(context).pop();
    }
  }

  Future<void> _updateVoucher(String id) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await FirebaseFirestore.instance.collection('vouchers').doc(id).update({
        'code': _codeController.text,
        'discount': double.parse(_discountController.text),
        'discountType': _discountType,
        'expiryDate': Timestamp.fromDate(_expiryDate),
        'isActive': _isActive,
      });
      Navigator.of(context).pop();
    }
  }
  
  Future<void> _deleteVoucher(String id) async {
    await FirebaseFirestore.instance.collection('vouchers').doc(id).delete();
  }

  void _showAddVoucherDialog() {
    _codeController.clear();
    _discountController.clear();
    _discountType = 'percentage';
    _expiryDate = DateTime.now();
    _isActive = true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: TextWidget(text: 'Add Voucher', fontSize: 20),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _codeController,
                        decoration: InputDecoration(labelText: 'Voucher Code'),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a code' : null,
                      ),
                      TextFormField(
                        controller: _discountController,
                        decoration: InputDecoration(labelText: 'Discount'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a discount' : null,
                      ),
                      DropdownButtonFormField<String>(
                        value: _discountType,
                        decoration: InputDecoration(labelText: 'Discount Type'),
                        items: ['percentage', 'fixed']
                            .map((label) => DropdownMenuItem(
                                  child: Text(label),
                                  value: label,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _discountType = value!;
                          });
                        },
                      ),
                      ListTile(
                        title: Text('Expiry Date: ${DateFormat.yMd().format(_expiryDate)}'),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _expiryDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _expiryDate = pickedDate;
                            });
                          }
                        },
                      ),
                      SwitchListTile(
                        title: Text('Active'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addVoucher,
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditVoucherDialog(Voucher voucher) {
    _codeController.text = voucher.code;
    _discountController.text = voucher.discount.toString();
    _discountType = voucher.discountType;
    _expiryDate = voucher.expiryDate.toDate();
    _isActive = voucher.isActive;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: TextWidget(text: 'Edit Voucher', fontSize: 20),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _codeController,
                        decoration: InputDecoration(labelText: 'Voucher Code'),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a code' : null,
                      ),
                      TextFormField(
                        controller: _discountController,
                        decoration: InputDecoration(labelText: 'Discount'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a discount' : null,
                      ),
                      DropdownButtonFormField<String>(
                        value: _discountType,
                        decoration: InputDecoration(labelText: 'Discount Type'),
                        items: ['percentage', 'fixed']
                            .map((label) => DropdownMenuItem(
                                  child: Text(label),
                                  value: label,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _discountType = value!;
                          });
                        },
                      ),
                      ListTile(
                        title: Text('Expiry Date: ${DateFormat.yMd().format(_expiryDate)}'),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _expiryDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _expiryDate = pickedDate;
                            });
                          }
                        },
                      ),
                      SwitchListTile(
                        title: Text('Active'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _updateVoucher(voucher.id),
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
  
  void _showDeleteConfirmationDialog(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Voucher'),
          content: Text('Are you sure you want to delete this voucher?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteVoucher(id);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateVoucherStatus(String id, bool isActive) async {
    await FirebaseFirestore.instance
        .collection('vouchers')
        .doc(id)
        .update({'isActive': isActive});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextWidget(
          text: 'Voucher Management',
          fontSize: 20,
          color: Colors.white,
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _vouchersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: TextWidget(text: 'Something went wrong', fontSize: 16));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: TextWidget(text: 'No vouchers found.', fontSize: 16));
          }

          return ListView(
            padding: const EdgeInsets.all(8),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              final voucher =
                  Voucher.fromMap(document.data() as Map<String, dynamic>, document.id);
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: TextWidget(text: voucher.code, fontSize: 16, fontFamily: 'Bold'),
                  subtitle: TextWidget(
                    text:
                        '${voucher.discountType == 'percentage' ? '${voucher.discount}%' : 'P${voucher.discount.toStringAsFixed(2)}'} off - Expires: ${DateFormat.yMd().format(voucher.expiryDate.toDate())}',
                    fontSize: 14,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: voucher.isActive,
                        onChanged: (value) {
                          _updateVoucherStatus(voucher.id, value);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditVoucherDialog(voucher);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmationDialog(voucher.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVoucherDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
