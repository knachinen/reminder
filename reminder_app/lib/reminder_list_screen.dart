import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'reminder.dart';
import 'create_reminder_screen.dart'; // Import the CreateReminderScreen
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'dart:convert'; // For JSON encoding/decoding
// For JSON encoding/decoding
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:provider/provider.dart';
import 'reminder_provider.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  _ReminderListScreenState createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  List<Reminder> reminders = []; // Store your reminders here
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadReminders();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul')); //set your timezone here.
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      reminder.id.hashCode,
      'Reminder',
      reminder.text,
      tz.TZDateTime.from(reminder.dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminder Channel',
          channelDescription: 'Channel for Reminder notifications',
          // androidScheduleMode: AndroidScheduleMode.exact,
        ),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      // androidAllowWhileIdle: true,
      // uiLocalNotificationDateInterpretation:
      // UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList('reminders');
    if (remindersJson != null) {
      setState(() {
        reminders =
            remindersJson
                .map((json) => Reminder.fromJson(jsonDecode(json)))
                .toList();
        reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        //reschedule all notifications after loading the list
        for (var reminder in reminders) {
          _scheduleNotification(reminder);
        }
      });
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson =
        reminders.map((reminder) => jsonEncode(reminder.toJson())).toList();
    await prefs.setStringList('reminders', remindersJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reminders')),
      body: Consumer<ReminderProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return Dismissible(
                key: Key(reminder.id), // Use the reminder's ID as the key
                onDismissed: (direction) {
                  setState(() {
                    _cancelNotification(reminder.id.hashCode);
                    reminders.removeAt(index);
                    _saveReminders();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${reminder.text} deleted')),
                  );
                },
                background: Container(
                  color: Colors.red,
                ), // Background color when swiping
                child: ListTile(
                  title: Text(reminder.text),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(reminder.dateTime),
                  ),
                ),
              );
            },
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
              reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
