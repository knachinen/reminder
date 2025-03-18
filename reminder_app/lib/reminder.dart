import 'package:uuid/uuid.dart';

class Reminder {
  final String id;
  final String text;
  final DateTime dateTime;

  Reminder({
    String? id,
    required this.text,
    required this.dateTime,
  }) : id = id ?? Uuid().v4();

  // You can add a factory constructor to create a Reminder from a map (for storage)
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      text: json['text'],
      dateTime: DateTime.parse(json['dateTime']),
    );
  }

  // You can add a method to convert a Reminder to a map (for storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}