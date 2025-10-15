import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'main.dart';

class AddHomeworkPage extends StatefulWidget {
  const AddHomeworkPage({super.key});
  @override
  State<AddHomeworkPage> createState() => _AddHomeworkPageState();
}

class _AddHomeworkPageState extends State<AddHomeworkPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  DateTime? _dueDate;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final hw = Homework(
      id: Random().nextInt(999999).toString(),
      subject: _subjectCtrl.text.trim(),
      title: _titleCtrl.text.trim(),
      dueDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
    );
    context.read<HomeworkBloc>().add(AddHomework(hw));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Homework")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _subjectCtrl,
                decoration: InputDecoration(
                  labelText: "Subject",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                validator: (v) => v == null || v.isEmpty ? "Enter subject" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: "Homework Title",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                validator: (v) => v == null || v.isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _dueDate == null
                          ? "No date selected"
                          : "Due: ${_dueDate!.toLocal().toString().split(' ')[0]}",
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                  ),
                  TextButton(
                      onPressed: _pickDate,
                      child: const Text("Pick Date",
                          style: TextStyle(color: Colors.indigo))),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save Homework"),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
