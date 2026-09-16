import 'package:flutter/material.dart';

class SubjectInfo {
  final String name;
  final Color color;
  final IconData? icon;

  const SubjectInfo({
    required this.name,
    required this.color,
    this.icon,
  });
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

enum CalendarEventType { verifica, compito, studio }

class CalendarEvent {
  final String id;
  final String title;
  final String subject;
  final DateTime date;
  final CalendarEventType type;
  final String details;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.subject,
    required this.date,
    required this.type,
    required this.details,
  });
}
