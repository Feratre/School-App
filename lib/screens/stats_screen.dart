import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../state/school_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Kicker('RENDIMENTO & PROGRESSI', color: sc.sage),
                    const SizedBox(height: 2),
                    Text('Statistiche', style: AppTheme.d(24, weight: FontWeight.w700, color: sc.text)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: sc.emberSoft, borderRadius: BorderRadius.circular(100)),
                  child: Row(
                    children: [
                      Icon(PhosphorIconsFill.flame, size: 16, color: sc.accent),
                      const SizedBox(width: 4),
                      Text('${school.studyStreak} gg', style: AppTheme.d(14, weight: FontWeight.w700, color: sc.accent)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Main streak card
            SoftCard(
              radius: 20,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: sc.accentSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(PhosphorIconsFill.fire, size: 28, color: sc.accent),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('STUDY STREAK ATTIVO', style: AppTheme.d(11, weight: FontWeight.w600, color: sc.brass, letterSpacing: 2)),
                        const SizedBox(height: 2),
                        Text('5 Giorni Consecutivi', style: AppTheme.d(20, weight: FontWeight.w700, color: sc.text)),
                        const SizedBox(height: 2),
                        Text('Ottima costanza! Mancano 2 giorni all\'obiettivo settimanale.', style: AppTheme.s(12, color: sc.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2x2 Stats Grid
            Row(
              children: [
                Expanded(child: _statTile(sc, 'ORE SETTIMANA', '14.5', unit: ' h')),
                const SizedBox(width: 12),
                Expanded(child: _statTile(sc, 'MODULI COMPLETATI', '12', valueColor: sc.sage)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statTile(sc, 'QUIZ SUPERATI', '24', unit: ' / 28')),
                const SizedBox(width: 12),
                Expanded(child: _statTile(sc, 'ACCURATEZZA AI', '86', unit: '%', valueColor: sc.accent)),
              ],
            ),

            const SizedBox(height: 22),

            // GymMane style activity Heatmap
            SoftCard(
              radius: 20,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('MAPPA ATTIVITÀ DI STUDIO', style: AppTheme.d(11, weight: FontWeight.w600, color: sc.textSecondary, letterSpacing: 2)),
                      Icon(PhosphorIconsRegular.chartBar, size: 16, color: sc.textTertiary),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _StudyHeatmap(sc: sc),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Materie breakdown
            Text('DISTRIBUZIONE TEMPO PER MATERIA', style: AppTheme.d(11, weight: FontWeight.w600, color: sc.textSecondary, letterSpacing: 2)),
            const SizedBox(height: 12),
            _subjectProgressRow(sc, 'Chimica Organica', 0.45, '6.5 h', sc.sage),
            const SizedBox(height: 10),
            _subjectProgressRow(sc, 'Matematica', 0.30, '4.2 h', sc.accent),
            const SizedBox(height: 10),
            _subjectProgressRow(sc, 'Storia', 0.15, '2.3 h', sc.brass),
            const SizedBox(height: 10),
            _subjectProgressRow(sc, 'Fisica', 0.10, '1.5 h', sc.info),
          ],
        ),
      ),
    );
  }

  Widget _statTile(SchoolColors sc, String label, String value, {String? unit, Color? valueColor}) {
    return SoftCard(
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.d(10, weight: FontWeight.w600, color: sc.textTertiary, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              text: value,
              style: AppTheme.d(26, weight: FontWeight.w700, color: valueColor ?? sc.text),
              children: [
                if (unit != null)
                  TextSpan(text: unit, style: AppTheme.d(15, weight: FontWeight.w600, color: sc.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _subjectProgressRow(SchoolColors sc, String subject, double pct, String time, Color color) {
    return SoftCard(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject, style: AppTheme.d(14, weight: FontWeight.w700, color: sc.text)),
              Text(time, style: AppTheme.s(12, weight: FontWeight.w600, color: sc.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: sc.bgRaised2,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyHeatmap extends StatelessWidget {
  const _StudyHeatmap({required this.sc});
  final SchoolColors sc;

  @override
  Widget build(BuildContext context) {
    // 7 rows (days of week), 10 columns (weeks)
    final levels = [
      [2, 3, 0, 1, 3, 2, 1, 3, 2, 3],
      [1, 2, 3, 2, 1, 0, 2, 3, 3, 2],
      [3, 1, 2, 3, 2, 3, 1, 2, 1, 3],
      [0, 2, 1, 3, 3, 2, 3, 1, 2, 3],
      [2, 3, 3, 1, 2, 3, 2, 3, 3, 3],
      [1, 0, 2, 1, 0, 2, 1, 2, 1, 0],
      [0, 1, 0, 2, 1, 1, 0, 1, 2, 0],
    ];

    Color blockColor(int lvl) {
      switch (lvl) {
        case 3:
          return sc.accent;
        case 2:
          return sc.accent.withValues(alpha: 0.65);
        case 1:
          return sc.accent.withValues(alpha: 0.3);
        default:
          return sc.heatEmpty;
      }
    }

    return Column(
      children: [
        for (int r = 0; r < 7; r++)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int c = 0; c < 10; c++)
                  Container(
                    width: 24,
                    height: 18,
                    decoration: BoxDecoration(
                      color: blockColor(levels[r][c]),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
