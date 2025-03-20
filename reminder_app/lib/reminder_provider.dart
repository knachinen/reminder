import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'reminder.dart';

class ReminderProvider with ChangeNotifier {
  List<Reminder> _reminders = [];

  List<Reminder> get reminders => _reminders;

  ReminderProvider() {
    _loadReminders();
  }

  Future<void> addReminder(Reminder reminder) async {
    _reminders.add(reminder);
    _reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    await _saveReminders();
    notifyListeners();
  }

  Future<void> removeReminder(String id) async {
    _reminders.removeWhere((reminder) => reminder.id == id);
    await _saveReminders();
    notifyListeners();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList('reminders');
    if (remindersJson != null) {
      _reminders =
          remindersJson
              .map((json) => Reminder.fromJson(jsonDecode(json)))
              .toList();
      _reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      notifyListeners();
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson =
        _reminders.map((reminder) => jsonEncode(reminder.toJson())).toList();
    await prefs.setStringList('reminders', remindersJson);
  }
}
