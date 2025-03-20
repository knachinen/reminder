import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'reminder_list_screen.dart';
import 'reminder_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReminderProvider(),
      child: MaterialApp(
        title: 'Reminder App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: ReminderListScreen(),
      ),
    );
  }
}
