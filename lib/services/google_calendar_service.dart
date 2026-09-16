import 'dart:async';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;

// ─────────────────────────────────────────────────────────────────────────────
// GoogleCalendarService
//
// Gestisce autenticazione Google e sincronizzazione bidirezionale con
// Google Calendar API v3.
// ─────────────────────────────────────────────────────────────────────────────

class GoogleCalendarService {
  GoogleCalendarService._();
  static final GoogleCalendarService instance = GoogleCalendarService._();

  static const _scopes = [gcal.CalendarApi.calendarScope];

  final _googleSignIn = GoogleSignIn(scopes: _scopes);

  // Stato corrente
  GoogleSignInAccount? _currentUser;
  gcal.CalendarApi? _calendarApi;

  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  // Stream di cambiamento utente
  final _userController = StreamController<GoogleSignInAccount?>.broadcast();
  Stream<GoogleSignInAccount?> get onUserChanged => _userController.stream;

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    _googleSignIn.onCurrentUserChanged.listen((account) async {
      _currentUser = account;
      _calendarApi = null;
      if (account != null) {
        await _initApi();
      }
      _userController.add(_currentUser);
    });
    // Tenta silent sign-in all'avvio
    try {
      await _googleSignIn.signInSilently();
    } catch (_) {}
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _calendarApi = null;
    _userController.add(null);
  }

  Future<void> _initApi() async {
    try {
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient != null) {
        _calendarApi = gcal.CalendarApi(httpClient);
      }
    } catch (e) {
      _calendarApi = null;
    }
  }

  Future<gcal.CalendarApi?> _getApi() async {
    if (_calendarApi != null) return _calendarApi;
    if (_currentUser == null) return null;
    await _initApi();
    return _calendarApi;
  }

  // ── Read events ───────────────────────────────────────────────────────────

  /// Recupera tutti gli eventi Google Calendar in un intervallo di tempo.
  Future<List<gcal.Event>> fetchEvents({
    DateTime? timeMin,
    DateTime? timeMax,
  }) async {
    final api = await _getApi();
    if (api == null) return [];

    try {
      final now = DateTime.now();
      final result = await api.events.list(
        'primary',
        timeMin: (timeMin ?? DateTime(now.year, now.month - 1, 1)).toUtc(),
        timeMax: (timeMax ?? DateTime(now.year, now.month + 2, 0)).toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
        maxResults: 250,
      );
      return result.items ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Recupera eventi per un mese specifico.
  Future<List<gcal.Event>> fetchEventsForMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return fetchEvents(timeMin: start, timeMax: end);
  }

  // ── Write events ──────────────────────────────────────────────────────────

  /// Crea un evento su Google Calendar.
  /// Restituisce l'ID dell'evento creato, o null in caso di errore.
  Future<String?> createEvent({
    required String title,
    required String description,
    required DateTime date,
    bool allDay = true,
  }) async {
    final api = await _getApi();
    if (api == null) return null;

    try {
      final event = gcal.Event(
        summary: title,
        description: description,
        start: allDay
            ? gcal.EventDateTime(
                date: DateTime(date.year, date.month, date.day),
              )
            : gcal.EventDateTime(
                dateTime: date.toUtc(),
                timeZone: 'Europe/Rome',
              ),
        end: allDay
            ? gcal.EventDateTime(
                date: DateTime(date.year, date.month, date.day + 1),
              )
            : gcal.EventDateTime(
                dateTime: date.add(const Duration(hours: 1)).toUtc(),
                timeZone: 'Europe/Rome',
              ),
        reminders: gcal.EventReminders(
          useDefault: false,
          overrides: [
            gcal.EventReminder(method: 'popup', minutes: 60),
            gcal.EventReminder(method: 'email', minutes: 1440), // 24h prima
          ],
        ),
      );

      final created = await api.events.insert(event, 'primary');
      return created.id;
    } catch (e) {
      return null;
    }
  }

  /// Elimina un evento da Google Calendar tramite il suo ID.
  Future<bool> deleteEvent(String googleEventId) async {
    final api = await _getApi();
    if (api == null) return false;

    try {
      await api.events.delete('primary', googleEventId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Converte un gcal.Event in una data locale (supporta allDay e dateTime).
  static DateTime? eventDate(gcal.Event event) {
    final dt = event.start?.dateTime ?? event.start?.date;
    return dt?.toLocal();
  }

  /// Tipo di evento ricavato dai colori/categorie di Google Calendar.
  static String eventCategory(gcal.Event event) {
    final summary = (event.summary ?? '').toLowerCase();
    if (summary.contains('verifica') ||
        summary.contains('esame') ||
        summary.contains('test') ||
        summary.contains('interrogazione')) {
      return 'verifica';
    }
    if (summary.contains('compito') ||
        summary.contains('homework') ||
        summary.contains('consegna')) {
      return 'compito';
    }
    return 'altro';
  }

  void dispose() {
    _userController.close();
  }
}
