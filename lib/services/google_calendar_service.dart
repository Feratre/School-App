import 'dart:async';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
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

  // serverClientId = Web OAuth 2.0 Client ID — OBBLIGATORIO su Android affinché
  // google_sign_in generi un access token usabile dalle googleapis HTTP calls.
  static const _serverClientId =
      '883921912656-is2aqbu1a10rqjsh9fpr7ghm8k40js6m.apps.googleusercontent.com';

  final _googleSignIn = GoogleSignIn(
    scopes: _scopes,
    serverClientId: _serverClientId,
  );

  // Stato corrente
  GoogleSignInAccount? _currentUser;
  gcal.CalendarApi? _calendarApi;

  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null && _calendarApi != null;

  // Ultimo errore di autenticazione
  String? _lastAuthError;
  String? get lastAuthError => _lastAuthError;

  // Stream di cambiamento utente
  final _userController = StreamController<GoogleSignInAccount?>.broadcast();
  Stream<GoogleSignInAccount?> get onUserChanged => _userController.stream;

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    _googleSignIn.onCurrentUserChanged.listen((account) async {
      debugPrint('[GCal] onCurrentUserChanged: ${account?.email}');
      _currentUser = account;
      _calendarApi = null;
      _lastAuthError = null;
      if (account != null) {
        await _initApi();
      }
      _userController.add(_calendarApi != null ? _currentUser : null);
    });
    // Tenta silent sign-in all'avvio (nessun popup)
    try {
      await _googleSignIn.signInSilently();
    } catch (e) {
      debugPrint('[GCal] Silent sign-in failed: $e');
    }
  }

  Future<GoogleSignInAccount?> signIn() async {
    _lastAuthError = null;
    try {
      final account = await _googleSignIn.signIn();
      debugPrint('[GCal] signIn result: ${account?.email}');
      return account;
    } catch (e) {
      _lastAuthError = e.toString();
      debugPrint('[GCal] signIn error: $e');
      _userController.add(null);
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _calendarApi = null;
    _lastAuthError = null;
    _userController.add(null);
  }

  Future<void> _initApi() async {
    try {
      debugPrint('[GCal] Getting authenticated HTTP client…');
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient != null) {
        _calendarApi = gcal.CalendarApi(httpClient);
        debugPrint('[GCal] CalendarApi initialized ✓');
      } else {
        _lastAuthError = 'Impossibile ottenere token OAuth2. '
            'Verifica che il SHA-1 sia registrato in Google Cloud Console.';
        debugPrint('[GCal] authenticatedClient() returned null');
      }
    } catch (e) {
      _lastAuthError = e.toString();
      _calendarApi = null;
      debugPrint('[GCal] _initApi error: $e');
    }
  }

  Future<gcal.CalendarApi?> _getApi() async {
    if (_calendarApi != null) return _calendarApi;
    if (_currentUser == null) return null;
    await _initApi();
    return _calendarApi;
  }

  // ── Read events ───────────────────────────────────────────────────────────

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
      debugPrint('[GCal] Fetched ${result.items?.length ?? 0} events');
      return result.items ?? [];
    } catch (e) {
      debugPrint('[GCal] fetchEvents error: $e');
      return [];
    }
  }

  Future<List<gcal.Event>> fetchEventsForMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return fetchEvents(timeMin: start, timeMax: end);
  }

  // ── Write events ──────────────────────────────────────────────────────────

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
            gcal.EventReminder(method: 'email', minutes: 1440),
          ],
        ),
      );

      final created = await api.events.insert(event, 'primary');
      debugPrint('[GCal] Event created: ${created.id}');
      return created.id;
    } catch (e) {
      debugPrint('[GCal] createEvent error: $e');
      return null;
    }
  }

  Future<bool> deleteEvent(String googleEventId) async {
    final api = await _getApi();
    if (api == null) return false;

    try {
      await api.events.delete('primary', googleEventId);
      return true;
    } catch (e) {
      debugPrint('[GCal] deleteEvent error: $e');
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static DateTime? eventDate(gcal.Event event) {
    final dt = event.start?.dateTime ?? event.start?.date;
    return dt?.toLocal();
  }

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
