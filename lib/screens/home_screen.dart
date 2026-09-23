import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../state/school_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';
import '../widgets/upload_recording_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static String _formatItalianDate(DateTime d) {
    const days = [
      'Lunedì',
      'Martedì',
      'Mercoledì',
      'Giovedì',
      'Venerdì',
      'Sabato',
      'Domenica',
    ];
    const months = [
      'Gennaio',
      'Febbraio',
      'Marzo',
      'Aprile',
      'Maggio',
      'Giugno',
      'Luglio',
      'Agosto',
      'Settembre',
      'Ottobre',
      'Novembre',
      'Dicembre',
    ];
    final dayName = days[(d.weekday - 1) % 7];
    final monthName = months[(d.month - 1) % 12];
    return '$dayName ${d.day} $monthName';
  }

  static void _showNotificationsSheet(BuildContext context) {
    final notifications = school.notifications.toList();
    school.clearNotifications();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final sc2 = ctx.sc;

        return Container(
          decoration: BoxDecoration(
            color: sc2.bgRaised,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: sc2.border),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24 + MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: sc2.bgRaised2,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifiche',
                    style: AppTheme.d(
                      22,
                      weight: FontWeight.w700,
                      color: sc2.text,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: sc2.danger.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${notifications.length} nuove',
                      style: AppTheme.s(
                        11,
                        weight: FontWeight.w600,
                        color: sc2.danger,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (notifications.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      "Nessuna nuova notifica",
                      style: AppTheme.d(14, color: sc2.textSecondary),
                    ),
                  ),
                )
              else
                for (final n in notifications) ...[
                  Builder(
                    builder: (context) {
                      final isVerifica = n.title.toLowerCase().contains(
                        'verifica',
                      );
                      final notifColor = isVerifica ? sc2.danger : sc2.info;
                      final notifIcon = isVerifica
                          ? PhosphorIconsFill.exam
                          : PhosphorIconsFill.bookOpenText;
                      final timeStr =
                          '${n.time.hour.toString().padLeft(2, '0')}:${n.time.minute.toString().padLeft(2, '0')}';
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: sc2.bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: sc2.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: notifColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                notifIcon,
                                size: 18,
                                color: notifColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          n.title,
                                          style: AppTheme.d(
                                            13,
                                            weight: FontWeight.w700,
                                            color: sc2.text,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        timeStr,
                                        style: AppTheme.s(
                                          10,
                                          color: sc2.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    n.body,
                                    style: AppTheme.s(
                                      12,
                                      color: sc2.textSecondary,
                                    ),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;
    final now = DateTime.now();
    final dateStr = _formatItalianDate(now);
    return AnimatedBuilder(
      animation: school,
      builder: (context, _) {
        final activePlan = school.activePlan;
        final nextExam = school.nextExam;
        final tomorrowHomeworks = school.tomorrowHomework;

        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar: Profile & Notifications + Greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [sc.accent, sc.brass],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'R',
                              style: AppTheme.d(
                                20,
                                weight: FontWeight.w700,
                                color: sc.bg,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Ciao, Reda',
                                  style: AppTheme.d(
                                    18,
                                    weight: FontWeight.w700,
                                    color: sc.text,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            RoundBtn(
                              icon: PhosphorIconsRegular.bell,
                              size: 40,
                              onTap: () => _showNotificationsSheet(context),
                            ),
                            if (school.notifications.isNotEmpty)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: sc.danger,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: sc.emberSoft,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                PhosphorIconsFill.flame,
                                size: 16,
                                color: sc.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${school.studyStreak}',
                                style: AppTheme.d(
                                  14,
                                  weight: FontWeight.w700,
                                  color: sc.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Date kicker
                Text(
                  dateStr.toUpperCase(),
                  style: AppTheme.d(
                    12,
                    weight: FontWeight.w600,
                    color: sc.textTertiary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),

                // HERO CARD: "CONTINUA PIANO"
                SoftCard(
                  radius: 24,
                  padding: const EdgeInsets.all(22),
                  color: sc.bgRaised,
                  borderColor: sc.border,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Kicker('CONTINUA PIANO · OGGI', color: sc.accent),
                          Pill(
                            label: 'TRA ${activePlan.daysUntilExam} GIORNI',
                            bg: sc.accentSoft,
                            fg: sc.accent,
                            fontSize: 10,
                            icon: PhosphorIconsRegular.clock,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        activePlan.title,
                        style: AppTheme.d(
                          28,
                          weight: FontWeight.w700,
                          color: sc.text,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Modulo ${activePlan.currentDayIndex}/${activePlan.totalDays}: ${activePlan.days[activePlan.currentDayIndex - 1].topic}',
                        style: AppTheme.s(13, color: sc.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: activePlan.progress,
                          minHeight: 6,
                          backgroundColor: sc.bgRaised2,
                          valueColor: AlwaysStoppedAnimation(sc.accent),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progresso: ${(activePlan.progress * 100).toInt()}%',
                            style: AppTheme.s(
                              11,
                              weight: FontWeight.w600,
                              color: sc.textTertiary,
                            ),
                          ),
                          Text(
                            '${activePlan.days.where((d) => d.isCompleted).length} di ${activePlan.totalDays} moduli fatti',
                            style: AppTheme.s(
                              11,
                              weight: FontWeight.w600,
                              color: sc.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              label: 'STUDIA ORA',
                              icon: PhosphorIconsFill.play,
                              bg: sc.ember,
                              height: 48,
                              onTap: () => school.goPlans(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ACCESSO RAPIDO A UPLOAD DI REGISTRAZIONI LEZIONI
                GestureDetector(
                  onTap: () => showUploadRecordingSheet(context),
                  child: SoftCard(
                    radius: 20,
                    padding: const EdgeInsets.all(18),
                    borderColor: sc.brass.withValues(alpha: 0.5),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: sc.brass.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            PhosphorIconsFill.microphone,
                            size: 24,
                            color: sc.brass,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UPLOAD REGISTRAZIONE',
                                style: AppTheme.d(
                                  14,
                                  weight: FontWeight.w700,
                                  color: sc.text,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Carica audio lezione per trascrizione e piano AI',
                                style: AppTheme.s(12, color: sc.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          PhosphorIconsRegular.caretRight,
                          size: 16,
                          color: sc.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // PROSSIMA VERIFICA E COMPITI DEL GIORNO DOPO
                Text(
                  'SCADENZE & COMPITI',
                  style: AppTheme.d(
                    12,
                    weight: FontWeight.w600,
                    color: sc.textSecondary,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    // Prossima Verifica Card
                    if (nextExam == null)
                      Expanded(
                        child: SoftCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIconsRegular.exam,
                                size: 20,
                                color: sc.textTertiary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Nessuna verifica imminente',
                                style: AppTheme.s(13, color: sc.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: SoftCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    PhosphorIconsRegular.exam,
                                    size: 20,
                                    color: sc.danger,
                                  ),
                                  Pill(
                                    label: '${nextExam.daysRemaining} gg',
                                    bg: sc.danger.withValues(alpha: 0.15),
                                    fg: sc.danger,
                                    fontSize: 10,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'PROSSIMA VERIFICA',
                                style: AppTheme.d(
                                  10,
                                  weight: FontWeight.w600,
                                  color: sc.textTertiary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                nextExam.title,
                                style: AppTheme.d(
                                  16,
                                  weight: FontWeight.w700,
                                  color: sc.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${nextExam.date.day}/${nextExam.date.month} · ${nextExam.time}',
                                style: AppTheme.s(
                                  11.5,
                                  color: sc.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),

                    // Compiti del giorno dopo Card
                    Expanded(
                      child: SoftCard(
                        radius: 20,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  PhosphorIconsRegular.bookOpenText,
                                  size: 20,
                                  color: sc.warn,
                                ),
                                Pill(
                                  label: 'DOMANI',
                                  bg: sc.warn.withValues(alpha: 0.15),
                                  fg: sc.warn,
                                  fontSize: 10,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'COMPITI DI DOMANI',
                              style: AppTheme.d(
                                10,
                                weight: FontWeight.w600,
                                color: sc.textTertiary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (tomorrowHomeworks.isEmpty) ...[
                              Text(
                                'Nessun compito',
                                style: AppTheme.d(
                                  16,
                                  weight: FontWeight.w700,
                                  color: sc.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tutto completato',
                                style: AppTheme.s(
                                  11.5,
                                  color: sc.textSecondary,
                                ),
                              ),
                            ] else ...[
                              ...tomorrowHomeworks.map((hw) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hw.subject,
                                        style: AppTheme.d(
                                          14,
                                          weight: FontWeight.w700,
                                          color: sc.text,
                                        ),
                                      ),
                                      Text(
                                        hw.description.isEmpty
                                            ? 'Esercizi assegnati'
                                            : hw.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTheme.s(
                                          11,
                                          color: sc.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
