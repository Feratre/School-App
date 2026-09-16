import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../models/models.dart';
import '../state/school_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'ui_kit.dart';

void showPodcastPlayerSheet(BuildContext context, [StudyPlan? plan]) {
  if (plan != null) {
    school.openPlan(plan.id);
  }
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const PodcastPlayerSheet(),
  );
}

class PodcastPlayerSheet extends StatefulWidget {
  const PodcastPlayerSheet({super.key});

  @override
  State<PodcastPlayerSheet> createState() => _PodcastPlayerSheetState();
}

class _PodcastPlayerSheetState extends State<PodcastPlayerSheet> {
  @override
  Widget build(BuildContext context) {
    final sc = context.sc;
    final plan = school.activePlan;

    return Container(
      decoration: BoxDecoration(
        color: sc.bgRaised,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: sc.border),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 28 + MediaQuery.paddingOf(context).bottom),
      child: AnimatedBuilder(
        animation: school,
        builder: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHandle(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Kicker('PODCAST AI · TEXT TO SPEECH', color: sc.accent),
                  Pill(
                    label: '${school.playbackSpeed}x',
                    bg: sc.bgRaised2,
                    fg: sc.textSecondary,
                    onTap: school.cycleSpeed,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Album / topic hero banner
              Container(
                height: 130,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      plan.subjectColor.withValues(alpha: 0.35),
                      sc.bgRaised2,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sc.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: plan.subjectColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: plan.subjectColor),
                      ),
                      child: Icon(PhosphorIconsFill.sparkle, size: 36, color: plan.subjectColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Pill(
                            label: plan.subject.toUpperCase(),
                            bg: plan.subjectColor.withValues(alpha: 0.2),
                            fg: plan.subjectColor,
                            fontSize: 10,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            plan.podcastTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.d(18, weight: FontWeight.w700, color: sc.text),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Generato da AI Speech Agent · ${plan.podcastDuration}',
                            style: AppTheme.s(11, color: sc.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Synced Transcript Preview
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: sc.bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: sc.border),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIconsRegular.quotes, size: 18, color: sc.accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '"...per determinare l\'orientamento orto-para o meta, consideriamo l\'effetto induttivo e mesomero dei sostituenti..."',
                        style: AppTheme.s(12, color: sc.textSecondary, letterSpacing: 0.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Progress Bar
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: sc.accent,
                  inactiveTrackColor: sc.bgRaised2,
                  thumbColor: sc.accent,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                ),
                child: Slider(
                  value: school.podcastProgress,
                  onChanged: (v) => school.setPodcastProgress(v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(school.podcastProgress * 14).toInt()}:${((school.podcastProgress * 14 * 60) % 60).toInt().toString().padLeft(2, '0')}',
                      style: AppTheme.s(11, color: sc.textSecondary),
                    ),
                    Text('14:00', style: AppTheme.s(11, color: sc.textSecondary)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundBtn(
                    icon: PhosphorIconsRegular.rewindCircle,
                    size: 46,
                    color: sc.textSecondary,
                    onTap: () => school.setPodcastProgress((school.podcastProgress - 0.05).clamp(0.0, 1.0)),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: school.togglePodcast,
                    child: Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [sc.accent, sc.brass],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: sc.accent.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        school.isPodcastPlaying ? PhosphorIconsFill.pause : PhosphorIconsFill.play,
                        size: 28,
                        color: sc.bg,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  RoundBtn(
                    icon: PhosphorIconsRegular.fastForwardCircle,
                    size: 46,
                    color: sc.textSecondary,
                    onTap: () => school.setPodcastProgress((school.podcastProgress + 0.05).clamp(0.0, 1.0)),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
