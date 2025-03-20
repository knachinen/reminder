import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'reminder_provider.dart';
import 'reminder.dart';
import 'dart:html' as html;

class CreateReminderScreen extends StatefulWidget {
  const CreateReminderScreen({super.key});

  @override
  _CreateReminderScreenState createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> {
  final TextEditingController _textController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Reminder Text'),
            ),
            SizedBox(height: 16),
            Row(
              children: <Widget>[
                Text('Date and Time: ${_selectedDateTime.toString()}'),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _selectDateTime(context),
                  child: Text('Select Date and Time'),
                ),
              ],
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                final newReminder = Reminder(
                  text: _textController.text,
                  dateTime: _selectedDateTime,
                );
                Provider.of<ReminderProvider>(
                  context,
                  listen: false,
                ).addReminder(newReminder);
                Navigator.pop(
                  context,
                  newReminder,
                ); // Pass the new reminder back
              },
              child: Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
