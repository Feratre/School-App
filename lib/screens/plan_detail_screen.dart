import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../models/models.dart';
import '../state/school_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';

class PlanDetailScreen extends StatefulWidget {
  const PlanDetailScreen({super.key});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  int _tab = 0; // 0 = Fonti, 1 = Programma, 2 = Chat AI

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;

    return AnimatedBuilder(
      animation: school,
      builder: (context, _) {
        final plan = school.activePlan;

        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back + subject pill
                    Row(
                      children: [
                        GestureDetector(
                          onTap: school.goPlans,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: sc.bgRaised,
                              shape: BoxShape.circle,
                              border: Border.all(color: sc.border),
                            ),
                            child: Icon(Icons.arrow_back_ios_new_rounded,
                                size: 16, color: sc.text),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Pill(
                          label: plan.subject.toUpperCase(),
                          bg: plan.subjectColor.withValues(alpha: 0.2),
                          fg: plan.subjectColor,
                          fontSize: 10,
                        ),
                        const Spacer(),
                        Pill(
                          label: plan.daysUntilExam > 0
                              ? 'ESAME TRA ${plan.daysUntilExam} GG'
                              : 'ESAME OGGI',
                          bg: sc.danger.withValues(alpha: 0.15),
                          fg: sc.danger,
                          fontSize: 10,
                          icon: PhosphorIconsRegular.fire,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      plan.title,
                      style: AppTheme.d(22, weight: FontWeight.w700, color: sc.text),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: plan.progress,
                              minHeight: 5,
                              backgroundColor: sc.bgRaised2,
                              valueColor:
                                  AlwaysStoppedAnimation(plan.subjectColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${(plan.progress * 100).toInt()}%',
                          style: AppTheme.d(12,
                              weight: FontWeight.w700, color: sc.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Tab bar ──────────────────────────────────────
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: sc.bgRaised,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: sc.border),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _tabBtn(context, 0, PhosphorIconsRegular.bookOpen,
                              'Fonti'),
                          _tabBtn(context, 1, PhosphorIconsRegular.path,
                              'Programma'),
                          _tabBtn(context, 2,
                              PhosphorIconsRegular.chatTeardropText, 'Chat AI'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Body ─────────────────────────────────────────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  child: KeyedSubtree(
                    key: ValueKey(_tab),
                    child: _tabBody(context, plan),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabBtn(BuildContext context, int idx, IconData icon, String label) {
    final sc = context.sc;
    final sel = _tab == idx;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _tab = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: sel ? sc.bgRaised2 : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: sel
                ? Border.all(color: sc.border.withValues(alpha: 0.6))
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: sel ? sc.accent : sc.textTertiary),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTheme.s(
                  13,
                  weight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel ? sc.text : sc.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabBody(BuildContext context, StudyPlan plan) {
    switch (_tab) {
      case 0:
        return _SourcesTab(plan: plan);
      case 1:
        return _ProgramTab(plan: plan);
      case 2:
        return _ChatTab(plan: plan);
      default:
        return _SourcesTab(plan: plan);
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TAB 0 – FONTI
// ════════════════════════════════════════════════════════════════════════════

class _SourcesTab extends StatelessWidget {
  const _SourcesTab({required this.plan});
  final StudyPlan plan;

  static const _typeIcon = {
    'pdf': PhosphorIconsRegular.filePdf,
    'audio': PhosphorIconsRegular.waveform,
    'summary': PhosphorIconsRegular.fileText,
    'quiz': PhosphorIconsRegular.checkSquare,
    'video': PhosphorIconsRegular.videoCamera,
  };

  static const _typeLabel = {
    'pdf': 'PDF',
    'audio': 'Audio',
    'summary': 'Riassunto AI',
    'quiz': 'Quiz',
    'video': 'Video',
  };

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;

    // Collect all materials with day info
    final allMaterials = <({StudyMaterial mat, int dayNumber, String dayTopic})>[];
    for (final day in plan.days) {
      for (final mat in day.materials) {
        allMaterials.add((mat: mat, dayNumber: day.dayNumber, dayTopic: day.topic));
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MATERIALI DEL PIANO · ${allMaterials.length} FILE',
            style: AppTheme.d(11,
                weight: FontWeight.w600,
                color: sc.textTertiary,
                letterSpacing: 2),
          ),
          const SizedBox(height: 14),

          if (allMaterials.isEmpty)
            SoftCard(
              radius: 20,
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(PhosphorIconsRegular.folderOpen,
                      size: 38, color: sc.textTertiary),
                  const SizedBox(height: 12),
                  Text('Nessun materiale caricato',
                      style: AppTheme.d(15,
                          weight: FontWeight.w700, color: sc.text)),
                  const SizedBox(height: 6),
                  Text(
                    'I materiali appariranno qui man mano che vengono aggiunti ai moduli.',
                    style: AppTheme.s(12, color: sc.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            for (final item in allMaterials) ...[ 
              _MaterialCard(
                material: item.mat,
                dayNumber: item.dayNumber,
                dayTopic: item.dayTopic,
                planColor: plan.subjectColor,
                typeIcon: _typeIcon[item.mat.type] ??
                    PhosphorIconsRegular.file,
                typeLabel:
                    _typeLabel[item.mat.type] ?? item.mat.type.toUpperCase(),
              ),
              const SizedBox(height: 10),
            ],

          const SizedBox(height: 16),

          // Add material button
          GhostButton(
            label: 'AGGIUNGI MATERIALE',
            icon: PhosphorIconsRegular.plus,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Funzionalità in arrivo!'),
                backgroundColor: context.sc.bgRaised,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({
    required this.material,
    required this.dayNumber,
    required this.dayTopic,
    required this.planColor,
    required this.typeIcon,
    required this.typeLabel,
  });

  final StudyMaterial material;
  final int dayNumber;
  final String dayTopic;
  final Color planColor;
  final IconData typeIcon;
  final String typeLabel;

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;
    return SoftCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: planColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(typeIcon, size: 22, color: planColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.name,
                  style: AppTheme.d(13,
                      weight: FontWeight.w600, color: sc.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Pill(
                      label: typeLabel,
                      bg: planColor.withValues(alpha: 0.15),
                      fg: planColor,
                      fontSize: 9,
                      hPad: 7,
                      vPad: 3,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Giorno $dayNumber · ${material.sizeOrDuration}',
                      style: AppTheme.s(11, color: sc.textTertiary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(PhosphorIconsRegular.caretRight,
              size: 16, color: sc.textTertiary),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TAB 1 – PROGRAMMA (Duolingo-style vertical path)
// ════════════════════════════════════════════════════════════════════════════

class _ProgramTab extends StatelessWidget {
  const _ProgramTab({required this.plan});
  final StudyPlan plan;

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERCORSO DI STUDIO · ${plan.totalDays} MODULI',
            style: AppTheme.d(11,
                weight: FontWeight.w600,
                color: sc.textTertiary,
                letterSpacing: 2),
          ),
          const SizedBox(height: 20),

          // Duolingo-style vertical path
          for (int i = 0; i < plan.days.length; i++)
            _DuolingoNode(
              day: plan.days[i],
              planColor: plan.subjectColor,
              isLast: i == plan.days.length - 1,
              index: i,
            ),
        ],
      ),
    );
  }
}

class _DuolingoNode extends StatelessWidget {
  const _DuolingoNode({
    required this.day,
    required this.planColor,
    required this.isLast,
    required this.index,
  });

  final StudyDay day;
  final Color planColor;
  final bool isLast;
  final int index;

  // Alternating horizontal offset to create the zigzag path
  double get _offset {
    // Pattern: center, right, center, left, center, right...
    const offsets = [0.0, 0.22, 0.0, -0.22, 0.0];
    return offsets[index % offsets.length];
  }

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;
    final isCompleted = day.isCompleted;
    final isToday = day.isToday;
    final isLocked = !isCompleted && !isToday;

    Color nodeColor;
    Color nodeBorder;
    Color iconColor;
    IconData nodeIcon;

    if (isCompleted) {
      nodeColor = planColor;
      nodeBorder = planColor;
      iconColor = Colors.white;
      nodeIcon = PhosphorIconsBold.checkCircle;
    } else if (isToday) {
      nodeColor = sc.ember;
      nodeBorder = sc.accent;
      iconColor = sc.onEmber;
      nodeIcon = PhosphorIconsFill.star;
    } else {
      nodeColor = sc.bgRaised2;
      nodeBorder = sc.border;
      iconColor = sc.textTertiary;
      nodeIcon = PhosphorIconsRegular.lock;
    }

    return Column(
      children: [
        // Node row with alignment offset
        FractionallySizedBox(
          widthFactor: 1.0,
          child: Align(
            alignment: Alignment(_offset, 0),
            child: GestureDetector(
              onTap: () {
                if (!isLocked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Avvio Modulo ${day.dayNumber}: ${day.topic}'),
                      backgroundColor: context.sc.bgRaised,
                    ),
                  );
                }
              },
              child: Column(
                children: [
                  // Badge "OGGI" sopra il nodo
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: sc.accent,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'OGGI',
                        style: AppTheme.d(10,
                            weight: FontWeight.w700,
                            color: sc.bg,
                            letterSpacing: 1),
                      ),
                    ),

                  // Main node circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: nodeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: nodeBorder, width: 3),
                      boxShadow: isToday
                          ? [
                              BoxShadow(
                                color: sc.accent.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : isCompleted
                              ? [
                                  BoxShadow(
                                    color:
                                        planColor.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(nodeIcon, size: 26, color: iconColor),
                        const SizedBox(height: 2),
                        Text(
                          'G${day.dayNumber}',
                          style: AppTheme.d(11,
                              weight: FontWeight.w700, color: iconColor),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Topic card below node
                  SizedBox(
                    width: 200,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? planColor.withValues(alpha: 0.12)
                            : isToday
                                ? sc.accentSoft
                                : sc.bgRaised,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isToday
                              ? sc.accent.withValues(alpha: 0.4)
                              : isCompleted
                                  ? planColor.withValues(alpha: 0.3)
                                  : sc.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            day.topic,
                            style: AppTheme.d(12,
                                weight: FontWeight.w700,
                                color: isLocked
                                    ? sc.textTertiary
                                    : sc.text),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          if (!isLocked) ...[ 
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isCompleted)
                                  Pill(
                                    label: 'COMPLETATO',
                                    bg: planColor.withValues(alpha: 0.2),
                                    fg: planColor,
                                    fontSize: 9,
                                    hPad: 6,
                                    vPad: 2,
                                  )
                                else
                                  Pill(
                                    label: '${day.materials.length} MATERIALI',
                                    bg: sc.accentSoft,
                                    fg: sc.accent,
                                    fontSize: 9,
                                    hPad: 6,
                                    vPad: 2,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Connector line to next node
        if (!isLast)
          SizedBox(
            height: 48,
            child: CustomPaint(
              painter: _ConnectorPainter(
                fromOffset: _offset,
                toOffset: _DuolingoNode(
                  day: day,
                  planColor: planColor,
                  isLast: false,
                  index: index + 1,
                )._offset,
                color: isCompleted
                    ? planColor.withValues(alpha: 0.5)
                    : sc.border,
              ),
              size: const Size(double.infinity, 48),
            ),
          ),
      ],
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter({
    required this.fromOffset,
    required this.toOffset,
    required this.color,
  });

  final double fromOffset;
  final double toOffset;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fromX = size.width / 2 + fromOffset * size.width / 2;
    final toX = size.width / 2 + toOffset * size.width / 2;

    final path = Path()
      ..moveTo(fromX, 0)
      ..cubicTo(
        fromX, size.height * 0.4,
        toX, size.height * 0.6,
        toX, size.height,
      );

    // Draw dashes
    const dashLen = 8.0;
    const gapLen = 6.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0;
      while (dist < metric.length) {
        canvas.drawPath(
          metric.extractPath(dist, dist + dashLen),
          paint,
        );
        dist += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) =>
      old.fromOffset != fromOffset ||
      old.toOffset != toOffset ||
      old.color != color;
}

// ════════════════════════════════════════════════════════════════════════════
// TAB 2 – CHAT AI
// ════════════════════════════════════════════════════════════════════════════

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class _ChatTab extends StatefulWidget {
  const _ChatTab({required this.plan});
  final StudyPlan plan;

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: '👋 Ciao! Sono il tuo tutor AI per questo piano di studio. Puoi chiedermi spiegazioni, esercizi o dubbi su qualsiasi argomento del programma. Come posso aiutarti?',
      isUser: false,
      time: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];
  bool _isTyping = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true, time: DateTime.now()));
      _isTyping = true;
    });
    _ctrl.clear();
    _scrollToBottom();

    // Placeholder response (Groq API verrà integrata in seguito)
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessage(
        text: '💡 Ottima domanda su "${widget.plan.subject}"! La risposta dettagliata verrà fornita dall\'AI Groq una volta configurata l\'API. Per ora, ti consiglio di ripassare: ${widget.plan.keyWeakness}.',
        isUser: false,
        time: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Column(
      children: [
        // Message list
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, i) {
              if (_isTyping && i == _messages.length) {
                return _TypingBubble(sc: sc);
              }
              final msg = _messages[i];
              return _Bubble(message: msg, sc: sc, planColor: widget.plan.subjectColor);
            },
          ),
        ),

        // Input bar
        Container(
          margin: EdgeInsets.fromLTRB(20, 0, 20, 100 + bottomPad),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: sc.bgRaised,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sc.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: AppTheme.s(14, color: sc.text),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Chiedi al tutor AI…',
                    hintStyle: AppTheme.s(14, color: sc.textTertiary),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: sc.ember,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: sc.accent.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(PhosphorIconsFill.paperPlaneTilt,
                      size: 18, color: sc.onEmber),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.sc,
    required this.planColor,
  });

  final _ChatMessage message;
  final SchoolColors sc;
  final Color planColor;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[ 
            // AI avatar
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              decoration: BoxDecoration(
                color: planColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(PhosphorIconsFill.sparkle,
                  size: 16, color: planColor),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? sc.ember : sc.bgRaised,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(color: sc.border),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color: sc.ember.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                message.text,
                style: AppTheme.s(
                  13,
                  color: isUser ? sc.onEmber : sc.text,
                  height: 1.45,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble({required this.sc});
  final SchoolColors sc;

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sc = widget.sc;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: sc.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(PhosphorIconsFill.sparkle, size: 16, color: sc.accent),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: sc.bgRaised,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: sc.border),
            ),
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i / 3.0;
                    final v = ((_anim.value - delay).clamp(0.0, 1.0));
                    final opacity =
                        (0.3 + 0.7 * (v < 0.5 ? v * 2 : (1 - v) * 2))
                            .clamp(0.3, 1.0);
                    return Container(
                      width: 7,
                      height: 7,
                      margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                      decoration: BoxDecoration(
                        color: sc.textTertiary.withValues(alpha: opacity),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
