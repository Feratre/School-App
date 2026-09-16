import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../models/models.dart';
import '../state/school_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/ui_kit.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key, required this.plan});

  final StudyPlan plan;

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;
  int _selectedModeIndex = 0; // 0: 25m, 1: 50m, 2: 5m pausa

  final List<int> _durations = [25 * 60, 50 * 60, 5 * 60];
  final List<String> _durationLabels = ['25 min Focus', '50 min Deep', '5 min Pausa'];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          timer.cancel();
          setState(() => _isRunning = false);
          HapticFeedback.heavyImpact();
          _showSessionCompletedDialog();
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _durations[_selectedModeIndex];
    });
  }

  void _selectMode(int index) {
    _timer?.cancel();
    setState(() {
      _selectedModeIndex = index;
      _totalSeconds = _durations[index];
      _remainingSeconds = _durations[index];
      _isRunning = false;
    });
  }

  void _showSessionCompletedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.sc.bgRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(PhosphorIconsFill.confetti, color: context.sc.accent),
            const SizedBox(width: 10),
            Text('Sessione Completata!', style: AppTheme.d(18, weight: FontWeight.w700, color: context.sc.text)),
          ],
        ),
        content: Text(
          'Ottimo lavoro! Hai completato la tua sessione di studio focalizzato per "${widget.plan.title}".',
          style: AppTheme.s(14, color: context.sc.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              school.incrementStreak();
              Navigator.of(context).pop();
            },
            child: Text('Ottimo!', style: AppTheme.d(14, weight: FontWeight.w700, color: context.sc.accent)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSec) {
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;
    final plan = widget.plan;
    final activeDay = plan.days.firstWhere(
      (d) => d.isToday,
      orElse: () => plan.days.isNotEmpty ? plan.days.first : const StudyDay(dayNumber: 1, topic: 'Studio generale', summary: '', materials: []),
    );
    final progress = _totalSeconds > 0 ? (_remainingSeconds / _totalSeconds) : 0.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: sc.bg,
        body: Stack(
          children: [
            const Positioned.fill(
              child: AppBackground(pattern: 'grid'),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Bar: Exit button & Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: sc.bgRaised2,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: sc.border),
                            ),
                            child: Row(
                              children: [
                                Icon(PhosphorIconsRegular.arrowLeft, size: 16, color: sc.text),
                                const SizedBox(width: 6),
                                Text('Termina Focus', style: AppTheme.d(12, weight: FontWeight.w600, color: sc.text)),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sc.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: sc.accent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(PhosphorIconsFill.brain, size: 14, color: sc.accent),
                              const SizedBox(width: 6),
                              Text('SOLO FOCUS', style: AppTheme.d(11, weight: FontWeight.w700, color: sc.accent, letterSpacing: 1)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // WORK IN PROGRESS BANNER
                    SoftCard(
                      radius: 20,
                      padding: const EdgeInsets.all(16),
                      borderColor: sc.warn.withValues(alpha: 0.5),
                      color: sc.warn.withValues(alpha: 0.08),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: sc.warn.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(PhosphorIconsFill.warning, size: 20, color: sc.warn),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('SEZIONE WORK IN PROGRESS 🚧', style: AppTheme.d(12, weight: FontWeight.w700, color: sc.warn, letterSpacing: 0.8)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Questa area è accessibile solo tramite il pulsante Play centrale. Include timer immersivo, piano mirato e prossimamente audio binaurali AI.',
                                  style: AppTheme.s(12, color: sc.textSecondary, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // SELECTED PLAN OVERVIEW
                    SoftCard(
                      radius: 22,
                      padding: const EdgeInsets.all(20),
                      borderColor: plan.subjectColor.withValues(alpha: 0.4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Pill(
                                label: plan.subject.toUpperCase(),
                                bg: plan.subjectColor.withValues(alpha: 0.2),
                                fg: plan.subjectColor,
                                fontSize: 10,
                              ),
                              Pill(
                                label: 'MODULO ${activeDay.dayNumber}/${plan.totalDays}',
                                bg: sc.bgRaised2,
                                fg: sc.textSecondary,
                                fontSize: 10,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(plan.title, style: AppTheme.d(20, weight: FontWeight.w700, color: sc.text)),
                          const SizedBox(height: 4),
                          Text(
                            'Obiettivo: "${activeDay.topic}"',
                            style: AppTheme.s(13, weight: FontWeight.w600, color: sc.accent),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Focus carenze: ${plan.keyWeakness}',
                            style: AppTheme.s(11.5, color: sc.textTertiary),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // TIMER HERO CARD
                    SoftCard(
                      radius: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                      child: Column(
                        children: [
                          // Duration selector tabs
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_durationLabels.length, (i) {
                              final isSel = _selectedModeIndex == i;
                              return GestureDetector(
                                onTap: () => _selectMode(i),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isSel ? sc.ember : sc.bgRaised2,
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(color: isSel ? sc.ember : sc.border),
                                  ),
                                  child: Text(
                                    _durationLabels[i],
                                    style: AppTheme.s(
                                      11,
                                      weight: isSel ? FontWeight.w700 : FontWeight.w500,
                                      color: isSel ? sc.onEmber : sc.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 26),

                          // Circular Visual Progress with Time
                          SizedBox(
                            width: 210,
                            height: 210,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 8,
                                    backgroundColor: sc.bgRaised2,
                                    valueColor: AlwaysStoppedAnimation(
                                      _isRunning ? sc.accent : sc.textSecondary,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isRunning ? PhosphorIconsFill.sparkle : PhosphorIconsRegular.timer,
                                      size: 26,
                                      color: _isRunning ? sc.accent : sc.textTertiary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatTime(_remainingSeconds),
                                      style: AppTheme.d(42, weight: FontWeight.w700, color: sc.text, letterSpacing: 2),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isRunning ? 'CONCENTRAZIONE ATTIVA' : 'IN PAUSA',
                                      style: AppTheme.d(
                                        10,
                                        weight: FontWeight.w600,
                                        color: _isRunning ? sc.accent : sc.textTertiary,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RoundBtn(
                                icon: PhosphorIconsRegular.arrowCounterClockwise,
                                size: 50,
                                color: sc.textSecondary,
                                bg: sc.bgRaised2,
                                onTap: _resetTimer,
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: _toggleTimer,
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [sc.accent, sc.brass],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: sc.accent.withValues(alpha: 0.45),
                                        blurRadius: 22,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isRunning ? PhosphorIconsFill.pause : PhosphorIconsFill.play,
                                    size: 32,
                                    color: sc.bg,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              RoundBtn(
                                icon: PhosphorIconsRegular.check,
                                size: 50,
                                color: sc.sage,
                                bg: sc.bgRaised2,
                                onTap: _showSessionCompletedDialog,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // UPCOMING FEATURES IN FOCUS MODE
                    SoftCard(
                      radius: 20,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(PhosphorIconsRegular.lightbulb, size: 18, color: sc.accent),
                              const SizedBox(width: 8),
                              Text('FUNZIONI IN ARRIVO (WIP)', style: AppTheme.d(11, weight: FontWeight.w700, color: sc.textSecondary, letterSpacing: 1.5)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _wipFeatureRow(sc, PhosphorIconsRegular.waveform, 'Onde Binaurali & Ambient Sound AI', 'Musica generativa 432Hz per massimizzare la concentrazione.'),
                          const SizedBox(height: 10),
                          _wipFeatureRow(sc, PhosphorIconsRegular.shieldCheck, 'AI Distraction Shield', 'Blocco notifiche e schermata a contrasto puro senza stimoli.'),
                          const SizedBox(height: 10),
                          _wipFeatureRow(sc, PhosphorIconsRegular.chatCircleDots, 'Tutor Vocale Whisper AI', 'Poni dubbi al volo sul modulo senza uscire dalla schermata.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wipFeatureRow(SchoolColors sc, IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sc.bgRaised2,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: sc.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: AppTheme.d(12.5, weight: FontWeight.w600, color: sc.text)),
                    const SizedBox(width: 6),
                    Pill(label: 'WIP', bg: sc.bg, fg: sc.accent, fontSize: 8.5, vPad: 2, hPad: 6),
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTheme.s(11, color: sc.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
