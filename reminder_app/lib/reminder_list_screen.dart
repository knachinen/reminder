import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'reminder.dart';
import 'create_reminder_screen.dart'; // Import the CreateReminderScreen
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  _ReminderListScreenState createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  List<Reminder> reminders = []; // Store your reminders here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders'),
      ),
      body: ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return Dismissible(
            key: Key(reminder.id), // Use the reminder's ID as the key
            onDismissed: (direction) {
              setState(() {
                reminders.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${reminder.text} deleted')),
              );
            },
            background: Container(color: Colors.red), // Background color when swiping
            child: ListTile(
              title: Text(reminder.text),
              subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(reminder.dateTime)),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateReminderScreen()),
          );
          if (result != null && result is Reminder) {
            setState(() {
              reminders.add(result);
              reminders.sort((a,b)=> a.dateTime.compareTo(b.dateTime));
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}