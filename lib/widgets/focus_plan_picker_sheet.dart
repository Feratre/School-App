import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../models/models.dart';
import '../screens/focus_mode_screen.dart';
import '../state/school_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'ui_kit.dart';

void showFocusPlanPickerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const FocusPlanPickerSheet(),
  );
}

class FocusPlanPickerSheet extends StatelessWidget {
  const FocusPlanPickerSheet({super.key});

  void _startFocusSession(BuildContext context, StudyPlan plan) {
    Navigator.of(context).pop(); // Chiudi bottom sheet
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FocusModeScreen(plan: plan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;
    final plans = school.plans;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: BoxDecoration(
        color: sc.bgRaised,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: sc.border),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHandle(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Kicker('MODALITÀ CONCENTRAZIONE', color: sc.accent),
              Pill(
                label: 'WORK IN PROGRESS',
                bg: sc.warn.withValues(alpha: 0.15),
                fg: sc.warn,
                fontSize: 9.5,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Scegli il Piano di Studio',
            style: AppTheme.d(22, weight: FontWeight.w700, color: sc.text),
          ),
          const SizedBox(height: 4),
          Text(
            'Seleziona il piano su cui vuoi concentrarti per entrare nell\'area di studio immersivo:',
            style: AppTheme.s(12.5, color: sc.textSecondary),
          ),
          const SizedBox(height: 18),

          Flexible(
            child: plans.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        'Nessun piano creato. Crea prima un piano nella sezione Piano AI.',
                        style: AppTheme.s(13, color: sc.textTertiary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: plans.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      final todayDay = plan.days.firstWhere(
                        (d) => d.isToday,
                        orElse: () => plan.days.isNotEmpty ? plan.days.first : const StudyDay(dayNumber: 1, topic: '', summary: '', materials: []),
                      );

                      return GestureDetector(
                        onTap: () => _startFocusSession(context, plan),
                        child: SoftCard(
                          radius: 20,
                          padding: const EdgeInsets.all(16),
                          borderColor: sc.border,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Pill(
                                    label: plan.subject.toUpperCase(),
                                    bg: plan.subjectColor.withValues(alpha: 0.15),
                                    fg: plan.subjectColor,
                                    fontSize: 10,
                                  ),
                                  Pill(
                                    label: 'TRA ${plan.daysUntilExam} GG',
                                    bg: sc.bgRaised2,
                                    fg: sc.textSecondary,
                                    fontSize: 9.5,
                                    icon: PhosphorIconsRegular.clock,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                plan.title,
                                style: AppTheme.d(16, weight: FontWeight.w700, color: sc.text),
                              ),
                              if (todayDay.topic.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  'Argomento: ${todayDay.topic}',
                                  style: AppTheme.s(12, color: sc.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 12),
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
                                  const SizedBox(width: 10),
                                  Text(
                                    '${(plan.progress * 100).toInt()}%',
                                    style: AppTheme.s(11, weight: FontWeight.w600, color: sc.textTertiary),
                                  ),
                                  const SizedBox(width: 14),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: sc.ember,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(PhosphorIconsFill.play, size: 11, color: sc.onEmber),
                                        const SizedBox(width: 4),
                                        Text(
                                          'FOCUS',
                                          style: AppTheme.d(10.5, weight: FontWeight.w700, color: sc.onEmber, letterSpacing: 0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
