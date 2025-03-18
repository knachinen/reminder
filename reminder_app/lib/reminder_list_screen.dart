import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'reminder.dart';
import 'create_reminder_screen.dart'; // Import the CreateReminderScreen

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
          return ListTile(
            title: Text(reminders[index].text),
            subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(reminders[index].dateTime)),
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