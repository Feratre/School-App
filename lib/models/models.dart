import 'package:flutter/material.dart';

class SubjectInfo {
  final String name;
  final Color color;
  final IconData? icon;

  const SubjectInfo({required this.name, required this.color, this.icon});
}

class StudyMaterial {
  final String id;
  final String name;
  final String type; // 'pdf', 'audio', 'summary', 'video'
  final String sizeOrDuration;
  final String? summarySnippet;

  const StudyMaterial({
    required this.id,
    required this.name,
    required this.type,
    required this.sizeOrDuration,
    this.summarySnippet,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'sizeOrDuration': sizeOrDuration,
    'summarySnippet': summarySnippet,
  };

  factory StudyMaterial.fromJson(Map<String, dynamic> j) => StudyMaterial(
    id: j['id'] ?? '',
    name: j['name'] ?? '',
    type: j['type'] ?? '',
    sizeOrDuration: j['sizeOrDuration'] ?? '',
    summarySnippet: j['summarySnippet'],
  );
}

class StudyDay {
  final int dayNumber;
  final String topic;
  final String summary;
  final List<StudyMaterial> materials;
  final bool isCompleted;
  final bool isToday;

  const StudyDay({
    required this.dayNumber,
    required this.topic,
    required this.summary,
    required this.materials,
    this.isCompleted = false,
    this.isToday = false,
  });

  Map<String, dynamic> toJson() => {
    'dayNumber': dayNumber,
    'topic': topic,
    'summary': summary,
    'materials': materials.map((m) => m.toJson()).toList(),
    'isCompleted': isCompleted,
  };

  factory StudyDay.fromJson(Map<String, dynamic> j) => StudyDay(
    dayNumber: j['dayNumber'] ?? 0,
    topic: j['topic'] ?? '',
    summary: j['summary'] ?? '',
    materials:
        (j['materials'] as List<dynamic>?)
            ?.map((m) => StudyMaterial.fromJson(m))
            .toList() ??
        [],
    isCompleted: j['isCompleted'] ?? false,
  );
}

class StudyPlan {
  final String id;
  final String title;
  final String subject;
  final Color subjectColor;
  final DateTime examDate;
  final double progress; // 0.0 to 1.0
  final int totalDays;
  final int currentDayIndex;
  final String keyWeakness; // carenze principali indicate dall'utente
  final List<StudyDay> days;
  final bool hasPodcast;
  final String podcastTitle;
  final String podcastDuration;

  const StudyPlan({
    required this.id,
    required this.title,
    required this.subject,
    required this.subjectColor,
    required this.examDate,
    required this.progress,
    required this.totalDays,
    required this.currentDayIndex,
    required this.keyWeakness,
    required this.days,
    this.hasPodcast = true,
    this.podcastTitle = '',
    this.podcastDuration = '12 min',
  });

  int get daysUntilExam {
    final diff = examDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subject': subject,
    'subjectColorValue': subjectColor.toARGB32(),
    'examDate': examDate.toIso8601String(),
    'progress': progress,
    'totalDays': totalDays,
    'currentDayIndex': currentDayIndex,
    'keyWeakness': keyWeakness,
    'days': days.map((d) => d.toJson()).toList(),
    'hasPodcast': hasPodcast,
    'podcastTitle': podcastTitle,
    'podcastDuration': podcastDuration,
  };

  factory StudyPlan.fromJson(Map<String, dynamic> j) => StudyPlan(
    id: j['id'] ?? '',
    title: j['title'] ?? '',
    subject: j['subject'] ?? '',
    subjectColor: Color(j['subjectColorValue'] ?? 0xFF9E9E9E),
    examDate: DateTime.tryParse(j['examDate'] ?? '') ?? DateTime.now(),
    progress: (j['progress'] ?? 0.0).toDouble(),
    totalDays: j['totalDays'] ?? 1,
    currentDayIndex: j['currentDayIndex'] ?? 1,
    keyWeakness: j['keyWeakness'] ?? '',
    days:
        (j['days'] as List<dynamic>?)
            ?.map((d) => StudyDay.fromJson(d))
            .toList() ??
        [],
    hasPodcast: j['hasPodcast'] ?? true,
    podcastTitle: j['podcastTitle'] ?? '',
    podcastDuration: j['podcastDuration'] ?? '12 min',
  );
}

class HomeworkItem {
  final String id;
  final String subject;
  final String teacher;
  final DateTime dueDate;
  final String description;
  final List<String> attachments;
  final bool isCompleted;

  const HomeworkItem({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.dueDate,
    required this.description,
    required this.attachments,
    this.isCompleted = false,
  });
}

class ExamItem {
  final String id;
  final String title;
  final String subject;
  final DateTime date;
  final String time;
  final String classroom;

  const ExamItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.date,
    required this.time,
    this.classroom = 'Aula 3B',
  });

  int get daysRemaining => date.difference(DateTime.now()).inDays;
}

class LessonRecording {
  final String id;
  final String title;
  final String subject;
  final DateTime date;
  final String duration;
  final String status; // 'Trascritto', 'In elaborazione', 'Pronto per AI'
  final String transcriptSnippet;

  const LessonRecording({
    required this.id,
    required this.title,
    required this.subject,
    required this.date,
    required this.duration,
    required this.status,
    required this.transcriptSnippet,
  });
}

enum CalendarEventType { verifica, compito, studio, altro }

class CalendarEvent {
  final String id;
  final String?
  googleEventId; // null = evento locale, non-null = sincronizzato con Google
  final String title;
  final String subject;
  final DateTime date;
  final CalendarEventType type;
  final String details;

  const CalendarEvent({
    required this.id,
    this.googleEventId,
    required this.title,
    required this.subject,
    required this.date,
    required this.type,
    required this.details,
  });
}

class AppNotification {
  final String title;
  final String body;
  final DateTime time;
  final IconData? icon;
  final Color? color;

  const AppNotification({
    required this.title,
    required this.body,
    required this.time,
    this.icon,
    this.color,
  });
}
