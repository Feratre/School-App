import 'dart:async';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// Custom AuthClient per integrare account.authHeaders con googleapis
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GoogleCalendarService
// ─────────────────────────────────────────────────────────────────────────────

class GoogleCalendarService {
  GoogleCalendarService._();
  static final GoogleCalendarService instance = GoogleCalendarService._();

  static const _scopes = [gcal.CalendarApi.calendarScope];

  final _googleSignIn = GoogleSignIn(
    scopes: _scopes,
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
    // Tenta silent sign-in all'avvio
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
      if (account != null) {
        // Verifica autorizzazione ambiti (Calendar scope)
        final hasScope = await _googleSignIn.canAccessScopes(_scopes);
        if (!hasScope) {
          debugPrint('[GCal] Requesting missing scopes…');
          final granted = await _googleSignIn.requestScopes(_scopes);
          if (!granted) {
            _lastAuthError = 'Permesso d’accesso a Google Calendar non concesso dall’utente.';
            _userController.add(null);
            return null;
          }
        }
      }
      return account;
    } catch (e) {
      _lastAuthError = 'Errore accesso Google: ${e.toString()}';
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
    final account = _currentUser;
    if (account == null) return;

    try {
      debugPrint('[GCal] Initializing Calendar API for ${account.email}…');

      // 1. Tenta tramite extension_google_sign_in_as_googleapis_auth
      http.Client? httpClient;
      try {
        httpClient = await _googleSignIn.authenticatedClient();
      } catch (e) {
        debugPrint('[GCal] extension authenticatedClient error: $e');
      }

      // 2. Fallback diretto tramite account.authHeaders
      if (httpClient == null) {
        debugPrint('[GCal] Falling back to direct authHeaders…');
        final headers = await account.authHeaders;
        debugPrint('[GCal] Headers obtained: ${headers.keys.join(', ')}');
        if (headers.isNotEmpty) {
          httpClient = _GoogleAuthClient(headers);
        }
      }

      if (httpClient != null) {
        _calendarApi = gcal.CalendarApi(httpClient);
        _lastAuthError = null;
        debugPrint('[GCal] CalendarApi initialized successfully ✓');
      } else {
        _lastAuthError = 'Impossibile ottenere i token di autenticazione Google.';
        debugPrint('[GCal] Both auth methods failed.');
      }
    } catch (e) {
      _lastAuthError = 'Errore inizializzazione API: $e';
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
