import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../models/models.dart';
import '../services/google_calendar_service.dart';
import '../state/school_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/create_plan_sheet.dart';
import '../widgets/ui_kit.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  static String _formatMonthYear(DateTime d) {
    const months = [
      'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
      'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
    ];
    return '${months[(d.month - 1) % 12]} ${d.year}';
  }

  /// Numero di giorni nel mese
  static int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Offset lunedì-domenica (0=Lun, 6=Dom)
  static int _monthStartOffset(int year, int month) {
    // weekday: 1=Mon … 7=Sun
    return DateTime(year, month, 1).weekday - 1;
  }

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;

    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: school,
        builder: (context, _) {
          final monthStr = _formatMonthYear(school.calendarMonth);
          final selectedEvents = school.calendarEvents.where((e) {
            return e.date.year == school.selectedDate.year &&
                e.date.month == school.selectedDate.month &&
                e.date.day == school.selectedDate.day;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Kicker('ORGANIZZAZIONE & SCADENZE', color: sc.info),
                        const SizedBox(height: 2),
                        Text('Calendario',
                            style: AppTheme.d(24,
                                weight: FontWeight.w700, color: sc.text)),
                      ],
                    ),
                    Pill(
                      label: 'AGG EVENTO',
                      bg: sc.ember,
                      fg: sc.onEmber,
                      icon: PhosphorIconsBold.plus,
                      onTap: () => _showAddEventDialog(context),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Google Calendar sync banner ────────────────────────
                _GoogleSyncBanner(sc: sc),

                const SizedBox(height: 12),

                // ── Calendar card ─────────────────────────────────────
                SoftCard(
                  radius: 22,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      // Month navigator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RoundBtn(
                            icon: PhosphorIconsRegular.caretLeft,
                            size: 36,
                            onTap: school.prevMonth,
                          ),
                          Text(
                            monthStr.toUpperCase(),
                            style: AppTheme.d(16,
                                weight: FontWeight.w700,
                                color: sc.text,
                                letterSpacing: 2),
                          ),
                          RoundBtn(
                            icon: PhosphorIconsRegular.caretRight,
                            size: 36,
                            onTap: school.nextMonth,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Weekday labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (final d in ['L', 'M', 'M', 'G', 'V', 'S', 'D'])
                            SizedBox(
                              width: 36,
                              child: Text(
                                d,
                                textAlign: TextAlign.center,
                                style: AppTheme.d(11,
                                    weight: FontWeight.w600,
                                    color: sc.textTertiary),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Days grid — fully dynamic
                      _buildMonthGrid(context, sc),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Events for selected date ───────────────────────────
                Text(
                  'EVENTI DEL ${school.selectedDate.day}/${school.selectedDate.month}/${school.selectedDate.year}',
                  style: AppTheme.d(11,
                      weight: FontWeight.w600,
                      color: sc.textSecondary,
                      letterSpacing: 2),
                ),
                const SizedBox(height: 10),

                if (selectedEvents.isEmpty)
                  SoftCard(
                    radius: 18,
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(PhosphorIconsRegular.calendarBlank,
                              size: 32, color: sc.textTertiary),
                          const SizedBox(height: 8),
                          Text('Nessun evento per questa data',
                              style: AppTheme.d(14,
                                  weight: FontWeight.w600,
                                  color: sc.textSecondary)),
                          const SizedBox(height: 4),
                          Text(
                            'Tocca "Agg Evento" per aggiungere una verifica o compito.',
                            style: AppTheme.s(12, color: sc.textTertiary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  for (final ev in selectedEvents)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SoftCard(
                        radius: 20,
                        padding: const EdgeInsets.all(18),
                        borderColor: ev.type == CalendarEventType.verifica
                            ? sc.danger.withValues(alpha: 0.5)
                            : ev.type == CalendarEventType.compito
                                ? sc.warn.withValues(alpha: 0.5)
                                : sc.sage.withValues(alpha: 0.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Pill(
                                  label: ev.type.name.toUpperCase(),
                                  bg: (ev.type == CalendarEventType.verifica
                                          ? sc.danger
                                          : ev.type == CalendarEventType.compito
                                              ? sc.warn
                                              : sc.sage)
                                      .withValues(alpha: 0.15),
                                  fg: ev.type == CalendarEventType.verifica
                                      ? sc.danger
                                      : ev.type == CalendarEventType.compito
                                          ? sc.warn
                                          : sc.sage,
                                  fontSize: 10,
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      school.removeCalendarEvent(ev.id),
                                  child: Icon(PhosphorIconsRegular.trash,
                                      size: 16, color: sc.textTertiary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(ev.title,
                                style: AppTheme.d(18,
                                    weight: FontWeight.w700, color: sc.text)),
                            const SizedBox(height: 4),
                            Text(ev.details,
                                style:
                                    AppTheme.s(12, color: sc.textSecondary)),
                            const SizedBox(height: 14),
                            if (ev.type == CalendarEventType.verifica)
                              PrimaryButton(
                                label: 'AGGIUNGI PIANO PER QUESTO EVENTO',
                                icon: PhosphorIconsFill.sparkle,
                                height: 42,
                                bg: sc.ember,
                                onTap: () => showCreatePlanSheet(context),
                              ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Dynamic month grid ─────────────────────────────────────────────────────
  Widget _buildMonthGrid(BuildContext context, SchoolColors sc) {
    final year = school.calendarMonth.year;
    final month = school.calendarMonth.month;
    final totalDays = _daysInMonth(year, month);
    final startOffset = _monthStartOffset(year, month);
    // Round up to full weeks
    final totalCells = ((startOffset + totalDays) / 7).ceil() * 7;
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final dayNum = index - startOffset + 1;
        if (dayNum < 1 || dayNum > totalDays) {
          return const SizedBox.shrink();
        }

        final cellDate = DateTime(year, month, dayNum);

        final isSelected = cellDate.year == school.selectedDate.year &&
            cellDate.month == school.selectedDate.month &&
            cellDate.day == school.selectedDate.day;

        final isToday = cellDate.year == today.year &&
            cellDate.month == today.month &&
            cellDate.day == today.day;

        final hasEvent = school.calendarEvents.any((e) =>
            e.date.year == cellDate.year &&
            e.date.month == cellDate.month &&
            e.date.day == cellDate.day);

        return GestureDetector(
          onTap: () => school.selectCalendarDate(cellDate),
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isSelected
                  ? sc.ember
                  : isToday
                      ? sc.accentSoft
                      : hasEvent
                          ? sc.bgRaised2
                          : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: sc.ember)
                  : isToday
                      ? Border.all(color: sc.accent.withValues(alpha: 0.6))
                      : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNum',
                  style: AppTheme.d(
                    13,
                    weight: FontWeight.w700,
                    color: isSelected
                        ? sc.onEmber
                        : isToday
                            ? sc.accent
                            : sc.text,
                  ),
                ),
                if (hasEvent)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? sc.onEmber : sc.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Add event sheet ────────────────────────────────────────────────────────
  void _showAddEventDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();
    final sc = context.sc;
    CalendarEventType selectedType = CalendarEventType.verifica;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Container(
          decoration: BoxDecoration(
            color: sc.bgRaised,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: sc.border),
          ),
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, 24 + MediaQuery.viewInsetsOf(ctx).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHandle(),
              const SizedBox(height: 10),
              Text('AGGIUNGI EVENTO',
                  style: AppTheme.d(18,
                      weight: FontWeight.w700, color: sc.text)),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final t in CalendarEventType.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Pill(
                        label: t.name.toUpperCase(),
                        bg: selectedType == t ? sc.ember : sc.bgRaised2,
                        fg: selectedType == t
                            ? sc.onEmber
                            : sc.textSecondary,
                        onTap: () =>
                            setDialogState(() => selectedType = t),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleCtrl,
                style: AppTheme.s(14, color: sc.text),
                decoration: InputDecoration(
                  hintText: 'Titolo evento (es. Verifica di Fisica)',
                  hintStyle: AppTheme.s(13, color: sc.textTertiary),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: detailsCtrl,
                style: AppTheme.s(14, color: sc.text),
                decoration: InputDecoration(
                  hintText: 'Dettagli / orario / argomenti',
                  hintStyle: AppTheme.s(13, color: sc.textTertiary),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'SALVA EVENTO',
                onTap: () {
                  if (titleCtrl.text.isNotEmpty) {
                    school.addCalendarEvent(
                      title: titleCtrl.text.trim(),
                      subject: 'Generale',
                      date: school.selectedDate,
                      type: selectedType,
                      details: detailsCtrl.text.trim(),
                    );
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GoogleSyncBanner
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleSyncBanner extends StatelessWidget {
  const _GoogleSyncBanner({required this.sc});
  final SchoolColors sc;

  String _formatTime(DateTime? dt) {
    if (dt == null) return '—';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final isSignedIn = school.isGoogleSignedIn;
    final isSyncing = school.isSyncing;
    final syncError = school.syncError;
    final lastSync = school.lastSyncTime;
    final user = isSignedIn
        ? GoogleCalendarService.instance.currentUser
        : null;

    if (!isSignedIn) {
      // ── Banner di accesso ──────────────────────────────────────────
      return GestureDetector(
        onTap: () => school.googleSignIn(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: sc.bgRaised,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: sc.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: sc.bgRaised2,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  // Icona Google — usiamo un'icona generica colorata
                  child: Icon(PhosphorIconsRegular.googleLogo,
                      size: 20, color: sc.accent),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sincronizza Google Calendar',
                        style: AppTheme.d(13,
                            weight: FontWeight.w700, color: sc.text)),
                    Text('Tocca per accedere e importare i tuoi eventi',
                        style: AppTheme.s(11, color: sc.textSecondary)),
                  ],
                ),
              ),
              Icon(PhosphorIconsRegular.caretRight,
                  size: 16, color: sc.textTertiary),
            ],
          ),
        ),
      );
    }

    // ── Banner sync attivo ─────────────────────────────────────────────
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: sc.bgRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: syncError != null
              ? sc.danger.withValues(alpha: 0.5)
              : sc.sage.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          // Avatar utente
          CircleAvatar(
            radius: 16,
            backgroundColor: sc.accentSoft,
            child: Text(
              (user?.displayName ?? user?.email ?? 'G')
                  .substring(0, 1)
                  .toUpperCase(),
              style: AppTheme.d(14,
                  weight: FontWeight.w700, color: sc.accent),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.email ?? 'Google Calendar',
                  style: AppTheme.s(12,
                      weight: FontWeight.w600, color: sc.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (syncError != null)
                  Text(syncError,
                      style: AppTheme.s(10, color: sc.danger),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)
                else
                  Text(
                    isSyncing
                        ? 'Sincronizzazione in corso…'
                        : 'Ultimo sync: ${_formatTime(lastSync)}',
                    style: AppTheme.s(10, color: sc.textSecondary),
                  ),
              ],
            ),
          ),
          // Sync indicator / pulsante manuale
          if (isSyncing)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: sc.accent,
              ),
            )
          else
            GestureDetector(
              onTap: () => school.syncFromGoogle(),
              child: Icon(PhosphorIconsRegular.arrowsClockwise,
                  size: 18, color: sc.accent),
            ),
          const SizedBox(width: 10),
          // Disconnetti
          GestureDetector(
            onTap: () => school.googleSignOut(),
            child:
                Icon(PhosphorIconsRegular.signOut, size: 18, color: sc.textTertiary),
          ),
        ],
      ),
    );
  }
}
