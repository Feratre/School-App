import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_colors.dart';

final school = SchoolState();

class SchoolState extends ChangeNotifier {
  String _route = 'home';
  String get route => _route;

  String? _selectedPlanId;
  String? get selectedPlanId => _selectedPlanId;

  int _selectedDayNumber = 3;
  int get selectedDayNumber => _selectedDayNumber;

  bool _isPodcastPlaying = false;
  bool get isPodcastPlaying => _isPodcastPlaying;

  double _podcastProgress = 0.35; // 0.0 to 1.0
  double get podcastProgress => _podcastProgress;

  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;

  int _studyStreak = 5;
  int get studyStreak => _studyStreak;
  void incrementStreak() {
    _studyStreak++;
    notifyListeners();
  }

  final List<bool> _weekActivity = [true, true, true, true, true, false, false];
  List<bool> get weekActivity => List.unmodifiable(_weekActivity);

  DateTime _calendarMonth = DateTime(2026, 3, 1);
  DateTime get calendarMonth => _calendarMonth;

  DateTime _selectedDate = DateTime(2026, 3, 30);
  DateTime get selectedDate => _selectedDate;

  // Study plans ordered by due date
  final List<StudyPlan> _plans = [
    StudyPlan(
      id: 'plan-1',
      title: 'Chimica: Reazioni e Nomenclatura',
      subject: 'Chimica',
      subjectColor: SchoolColors.dark.sage,
      examDate: DateTime(2026, 3, 30),
      progress: 0.65,
      totalDays: 5,
      currentDayIndex: 3,
      keyWeakness: 'Nomenclatura idrocarburi & sostituzione elettrofila',
      podcastTitle: 'Podcast AI: Ripasso Chimica Lezione 3',
      podcastDuration: '14 min',
      days: [
        StudyDay(
          dayNumber: 1,
          topic: 'Struttura atomica del carbonio e ibridazione sp3, sp2, sp',
          summary:
              'Concetti chiave: legami sigma e pi-greco, geometria molecolare tetraedrica e planare, elettronegatività nei compiti di chimica.',
          materials: [
            StudyMaterial(
              id: 'm1',
              name: 'Appunti_Ibridazione_Carbonio.pdf',
              type: 'pdf',
              sizeOrDuration: '1.4 MB',
            ),
          ],
          isCompleted: true,
        ),
        StudyDay(
          dayNumber: 2,
          topic: 'Alcani, Alcheni e Alchini: regole IUPAC ed isomerie',
          summary:
              'Classificazione catene lineari e ramificate. Regola di Markovnikov per le addizioni elettrofile sugli alcheni.',
          materials: [
            StudyMaterial(
              id: 'm2',
              name: 'Lezione_Chimica_24_Marzo.mp3',
              type: 'audio',
              sizeOrDuration: '48 min',
            ),
          ],
          isCompleted: true,
        ),
        StudyDay(
          dayNumber: 3,
          topic: 'Reazioni di addizione e sostituzione elettrofila aromatica',
          summary:
              'Meccanismo dell’intermedio cationico carbocatione. Sostituenti attivanti e disattivanti sull’anello benzenico con orientamento orto-para e meta.',
          materials: [
            StudyMaterial(
              id: 'm3_1',
              name: 'Riassunto_AI_Sostituzione_Aromatica.pdf',
              type: 'summary',
              sizeOrDuration: '3 pag.',
              summarySnippet: 'Intermedio di Wheland e delocalizzazione di carica',
            ),
            StudyMaterial(
              id: 'm3_2',
              name: 'Audio_Lezione_Prof_Chimica.wav',
              type: 'audio',
              sizeOrDuration: '32 min',
            ),
          ],
          isCompleted: false,
          isToday: true,
        ),
        StudyDay(
          dayNumber: 4,
          topic: 'Gruppi funzionali: Alcoli, Aldeidi e Chetoni',
          summary:
              'Proprietà fisiche, legami idrogeno e reazioni di ossidoriduzione (da alcol primario ad aldeide e acido carbossilico).',
          materials: [
            StudyMaterial(
              id: 'm4',
              name: 'Schemi_Gruppi_Funzionali.pdf',
              type: 'pdf',
              sizeOrDuration: '2.1 MB',
            ),
          ],
          isCompleted: false,
        ),
        StudyDay(
          dayNumber: 5,
          topic: 'Simulazione verifica completa e Flashcards AI',
          summary:
              'Test rapido da 20 quesiti con correzione istantanea da parte dell’agente AI e spiegazione dettagliata degli errori.',
          materials: [
            StudyMaterial(
              id: 'm5',
              name: 'Quiz_Simulazione_Verifica.ai',
              type: 'quiz',
              sizeOrDuration: '20 domande',
            ),
          ],
          isCompleted: false,
        ),
      ],
    ),
    StudyPlan(
      id: 'plan-2',
      title: 'Matematica: Equazioni e Parabole',
      subject: 'Matematica',
      subjectColor: SchoolColors.dark.accent,
      examDate: DateTime(2026, 4, 6),
      progress: 0.25,
      totalDays: 7,
      currentDayIndex: 2,
      keyWeakness: 'Metodo del completamento del quadrato e coordinate del vertice',
      podcastTitle: 'Podcast AI: Trucchi per il Completamento Quadrato',
      podcastDuration: '10 min',
      days: [
        StudyDay(
          dayNumber: 1,
          topic: 'Risoluzione geometrica del completamento del quadrato',
          summary: 'Aggiunta e sottrazione del termine (b/2a)^2 per formare il quadrato di un binomio.',
          materials: [
            StudyMaterial(
              id: 'm_mat_1',
              name: 'metodo del completamento del quadrato.pdf',
              type: 'pdf',
              sizeOrDuration: '147 KB',
            ),
          ],
          isCompleted: true,
        ),
        StudyDay(
          dayNumber: 2,
          topic: 'Equazione della parabola con asse parallelo all’asse y',
          summary: 'Formule del vertice V(-b/2a, -delta/4a), fuoco e retta direttrice.',
          materials: [
            StudyMaterial(
              id: 'm_mat_2',
              name: 'Esercizi_Guida_Parabola.pdf',
              type: 'pdf',
              sizeOrDuration: '890 KB',
            ),
          ],
          isCompleted: false,
          isToday: true,
        ),
      ],
    ),
    StudyPlan(
      id: 'plan-3',
      title: 'Storia: La Prima Guerra Mondiale',
      subject: 'Storia',
      subjectColor: SchoolColors.dark.brass,
      examDate: DateTime(2026, 4, 18),
      progress: 0.10,
      totalDays: 6,
      currentDayIndex: 1,
      keyWeakness: 'Cause diplomatiche, alleanze e Trattato di Versailles',
      podcastTitle: 'Podcast AI: Cronologia 1914-1918',
      podcastDuration: '18 min',
      days: [
        StudyDay(
          dayNumber: 1,
          topic: 'L’attentato di Sarajevo e il sistema di alleanze contrapposte',
          summary: 'La Triplice Intesa e la Triplice Alleanza, mobilitazione generale e piano Schlieffen.',
          materials: [
            StudyMaterial(
              id: 'm_st_1',
              name: 'Mappe_Concettuali_1914.pdf',
              type: 'pdf',
              sizeOrDuration: '3.4 MB',
            ),
          ],
          isCompleted: false,
          isToday: true,
        ),
      ],
    ),
  ];

  List<StudyPlan> get plans => List.unmodifiable(_plans);

  StudyPlan get activePlan {
    if (_selectedPlanId != null) {
      final found = _plans.where((p) => p.id == _selectedPlanId);
      if (found.isNotEmpty) return found.first;
    }
    return _plans.first;
  }

  // Upcoming exam from scraping
  final ExamItem _nextExam = ExamItem(
    id: 'ex-1',
    title: 'Verifica di Chimica',
    subject: 'Chimica',
    date: DateTime(2026, 3, 30),
    time: '10:15 - 11:15',
    classroom: 'Aula 3B',
  );
  ExamItem get nextExam => _nextExam;

  // Tomorrow homework from scraping
  final List<HomeworkItem> _homework = [
    HomeworkItem(
      id: 'hw-1',
      subject: 'MATEMATICA',
      teacher: 'LUCCHELLI ELISABETTA',
      dueDate: DateTime(2026, 2, 6),
      description:
          'In allegato Metodo del completamento dei quadrati\nesercizi pag 388 I FONDAMENTALI + N 49, 50, 51, 59, 61, 66, 70, 72, 73, 75, 94, 98',
      attachments: ['metodo del completamento del quadrato.pdf', 'esercizi per interrogazione 6 febbraio.pdf'],
    ),
  ];
  List<HomeworkItem> get homework => List.unmodifiable(_homework);

  // Lesson Recordings
  final List<LessonRecording> _recordings = [
    LessonRecording(
      id: 'rec-1',
      title: 'Lezione Chimica: Aromatici e Benzene',
      subject: 'Chimica',
      date: DateTime(2026, 3, 26),
      duration: '48 min',
      status: 'Trascritto (100%)',
      transcriptSnippet:
          'Il benzene presenta 6 elettroni pi delocalizzati su tutto l\'anello. Questa particolare stabilità impedisce le classiche reazioni di addizione...',
    ),
    LessonRecording(
      id: 'rec-2',
      title: 'Lezione Matematica: Completamento del quadrato',
      subject: 'Matematica',
      date: DateTime(2026, 3, 25),
      duration: '52 min',
      status: 'Trascritto (100%)',
      transcriptSnippet:
          'Prendiamo l\'equazione generica ax^2 + bx + c. Dividiamo tutto per a, e focalizziamoci sui primi due termini...',
    ),
    LessonRecording(
      id: 'rec-3',
      title: 'Lezione Fisica: Secondo Principio Termodinamica',
      subject: 'Fisica',
      date: DateTime(2026, 3, 24),
      duration: '40 min',
      status: 'Pronto per AI',
      transcriptSnippet: 'Trascrizione generata tramite Whisper AI pronta per estrazione schemi e podcast riassuntivo.',
    ),
  ];
  List<LessonRecording> get recordings => List.unmodifiable(_recordings);

  // Calendar Events
  final List<CalendarEvent> _calendarEvents = [
    CalendarEvent(
      id: 'ce-1',
      title: 'Verifica di Chimica',
      subject: 'Chimica',
      date: DateTime(2026, 3, 30),
      type: CalendarEventType.verifica,
      details: 'Ore 10:15 - 11:15 in Aula 3B. Argomenti: Ibridazione, Alcani, Aromatici.',
    ),
    CalendarEvent(
      id: 'ce-2',
      title: 'Compiti Matematica',
      subject: 'Matematica',
      date: DateTime(2026, 3, 28),
      type: CalendarEventType.compito,
      details: 'Esercizi pag 388 + Metodo del completamento del quadrato.',
    ),
    CalendarEvent(
      id: 'ce-3',
      title: 'Sessione AI: Flashcards e Quiz',
      subject: 'Chimica',
      date: DateTime(2026, 3, 29),
      type: CalendarEventType.studio,
      details: 'Simulazione verifica con Agente AI e ripasso formule.',
    ),
  ];
  List<CalendarEvent> get calendarEvents => List.unmodifiable(_calendarEvents);

  // Navigation handlers
  void goHome() {
    _route = 'home';
    notifyListeners();
  }

  void goPlans() {
    _route = 'ai-plans';
    notifyListeners();
  }

  void goStats() {
    _route = 'stats';
    notifyListeners();
  }

  void goCalendar() {
    _route = 'calendar';
    notifyListeners();
  }

  void openPlan(String planId) {
    _selectedPlanId = planId;
    _route = 'plan-detail';
    notifyListeners();
  }

  void selectDayNumber(int day) {
    _selectedDayNumber = day;
    notifyListeners();
  }

  void selectCalendarDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void prevMonth() {
    _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1, 1);
    notifyListeners();
  }

  void nextMonth() {
    _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 1);
    notifyListeners();
  }

  // Podcast player actions
  void togglePodcast() {
    _isPodcastPlaying = !_isPodcastPlaying;
    notifyListeners();
  }

  void setPodcastProgress(double val) {
    _podcastProgress = val.clamp(0.0, 1.0);
    notifyListeners();
  }

  void cycleSpeed() {
    if (_playbackSpeed == 1.0) {
      _playbackSpeed = 1.25;
    } else if (_playbackSpeed == 1.25) {
      _playbackSpeed = 1.5;
    } else if (_playbackSpeed == 1.5) {
      _playbackSpeed = 2.0;
    } else {
      _playbackSpeed = 1.0;
    }
    notifyListeners();
  }

  // Add new plan
  void addPlan({
    required String subject,
    required String title,
    required DateTime examDate,
    required String keyWeakness,
    required int daysCount,
  }) {
    Color color = SchoolColors.dark.sage;
    if (subject.toLowerCase().contains('mat')) color = SchoolColors.dark.accent;
    if (subject.toLowerCase().contains('fis')) color = SchoolColors.dark.info;
    if (subject.toLowerCase().contains('sto')) color = SchoolColors.dark.brass;

    final newPlan = StudyPlan(
      id: 'plan-${DateTime.now().millisecondsSinceEpoch}',
      title: '$subject: $title',
      subject: subject,
      subjectColor: color,
      examDate: examDate,
      progress: 0.0,
      totalDays: daysCount,
      currentDayIndex: 1,
      keyWeakness: keyWeakness,
      podcastTitle: 'Podcast AI: Introduzione a $title',
      podcastDuration: '15 min',
      days: List.generate(
        daysCount,
        (i) => StudyDay(
          dayNumber: i + 1,
          topic: 'Giorno ${i + 1}: Studio approfondito di $title (Modulo ${i + 1})',
          summary: 'Pianificazione automatica generata dall’AI con focus sulle carenze: $keyWeakness.',
          materials: [
            StudyMaterial(
              id: 'm_new_${i + 1}',
              name: 'Riassunto_Modulo_${i + 1}.pdf',
              type: 'summary',
              sizeOrDuration: '2 pag.',
            ),
          ],
          isToday: i == 0,
        ),
      ),
    );

    _plans.add(newPlan);
    _plans.sort((a, b) => a.examDate.compareTo(b.examDate));
    _selectedPlanId = newPlan.id;
    _route = 'ai-plans';
    notifyListeners();
  }

  // Upload recording
  void addRecording({required String title, required String subject}) {
    final rec = LessonRecording(
      id: 'rec-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subject: subject,
      date: DateTime.now(),
      duration: '35 min',
      status: 'Trascritto (100%)',
      transcriptSnippet: 'Audio analizzato con successo. Trascrizione disponibile e integrata nel piano AI.',
    );
    _recordings.insert(0, rec);
    notifyListeners();
  }

  // Add event
  void addCalendarEvent({
    required String title,
    required String subject,
    required DateTime date,
    required CalendarEventType type,
    required String details,
  }) {
    _calendarEvents.add(
      CalendarEvent(
        id: 'ce-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        subject: subject,
        date: date,
        type: type,
        details: details,
      ),
    );
    notifyListeners();
  }

  void removeCalendarEvent(String id) {
    _calendarEvents.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
