import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../models/models.dart';
import '../state/school_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/create_plan_sheet.dart';
import '../widgets/ui_kit.dart';

class AiPlansScreen extends StatelessWidget {
  const AiPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;

    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: school,
        builder: (context, _) {
          final plans = school.plans;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 180 + MediaQuery.paddingOf(context).bottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Piani di Studio AI', style: AppTheme.d(24, weight: FontWeight.w700, color: sc.text)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: sc.bgRaised2, borderRadius: BorderRadius.circular(100)),
                          child: Text('${plans.length} Piani Attivi', style: AppTheme.d(12, weight: FontWeight.w600, color: sc.textSecondary)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // LIST OF ALL PLANS (Each formatted like the full Chimica example)
                    if (plans.isEmpty)
                      SoftCard(
                        radius: 20,
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(PhosphorIconsRegular.sparkle, size: 40, color: sc.accent),
                            const SizedBox(height: 12),
                            Text('Nessun piano di studio attivo', style: AppTheme.d(16, weight: FontWeight.w700, color: sc.text)),
                            const SizedBox(height: 6),
                            Text('Tocca il pulsante qui sotto per creare il tuo primo piano con l\'AI.', style: AppTheme.s(12, color: sc.textSecondary), textAlign: TextAlign.center),
                          ],
                        ),
                      )
                    else
                      for (int i = 0; i < plans.length; i++) ...[
                        _PlanCard(
                          key: ValueKey(plans[i].id),
                          plan: plans[i],
                        ),
                        if (i < plans.length - 1) const SizedBox(height: 20),
                      ],
                  ],
                ),
              ),

              // PULSANTE IN BASSO PER CREARE UN NUOVO PIANO
              Positioned(
                left: 20,
                right: 20,
                bottom: 104 + MediaQuery.paddingOf(context).bottom,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: sc.accent.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () => showCreatePlanSheet(context),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [sc.accent, sc.brass],
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIconsFill.sparkle, size: 20, color: sc.bg),
                          const SizedBox(width: 10),
                          Text(
                            'CREA NUOVO PIANO AI',
                            style: AppTheme.d(15, weight: FontWeight.w700, color: sc.bg, letterSpacing: 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({super.key, required this.plan});

  final StudyPlan plan;

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;

    // Trova il giorno corrente (oggi o il primo non completato)
    final todayDay = plan.days.where((d) => d.isToday).firstOrNull;
    final nextDay = plan.days.where((d) => !d.isCompleted).firstOrNull;
    final displayDay = todayDay ?? nextDay ?? (plan.days.isNotEmpty ? plan.days.first : null);

    return SoftCard(
      radius: 24,
      padding: const EdgeInsets.all(20),
      borderColor: plan.subjectColor.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top info: Subject & Exam countdown
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
                label: plan.daysUntilExam > 0 ? 'EXAM IN ${plan.daysUntilExam} DAYS' : 'EXAM TODAY',
                bg: sc.danger.withValues(alpha: 0.2),
                fg: sc.danger,
                fontSize: 10,
                icon: PhosphorIconsRegular.fire,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(plan.title, style: AppTheme.d(22, weight: FontWeight.w700, color: sc.text)),
          const SizedBox(height: 4),
          Text(
            'Focus carenze: "${plan.keyWeakness}"',
            style: AppTheme.s(12, color: sc.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 14),

          // Progress Bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: plan.progress,
                    minHeight: 5,
                    backgroundColor: sc.bgRaised2,
                    valueColor: AlwaysStoppedAnimation(plan.subjectColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(plan.progress * 100).toInt()}%',
                style: AppTheme.d(12, weight: FontWeight.w700, color: sc.text),
              ),
            ],
          ),

          if (displayDay != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: sc.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sc.border),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIconsRegular.bookOpen, size: 15, color: sc.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Modulo ${displayDay.dayNumber}: ${displayDay.topic}',
                      style: AppTheme.s(12, color: sc.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Pulsante STUDIA ORA
          PrimaryButton(
            label: 'STUDIA ORA',
            icon: PhosphorIconsFill.play,
            bg: sc.ember,
            height: 48,
            onTap: () => school.openPlan(plan.id),
          ),
        ],
      ),
    );
  }
}
