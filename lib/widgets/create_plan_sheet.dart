import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../state/school_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'ui_kit.dart';

void showCreatePlanSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CreatePlanSheet(),
  );
}

class CreatePlanSheet extends StatefulWidget {
  const CreatePlanSheet({super.key});

  @override
  State<CreatePlanSheet> createState() => _CreatePlanSheetState();
}

class _CreatePlanSheetState extends State<CreatePlanSheet> {
  final _topicCtrl = TextEditingController(text: 'Elettrostatica e Campo Elettrico');
  final _weaknessCtrl = TextEditingController(text: 'Formule per il calcolo del flusso del campo e Teorema di Gauss');
  String _selectedSubject = 'Fisica';
  int _daysCount = 5;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  bool _isGenerating = false;
  String _generationStatus = '';

  final _subjects = ['Fisica', 'Chimica', 'Matematica', 'Storia', 'Filosofia', 'Inglese', 'Biologia'];

  @override
  void dispose() {
    _topicCtrl.dispose();
    _weaknessCtrl.dispose();
    super.dispose();
  }

  void _generate() async {
    setState(() {
      _isGenerating = true;
      _generationStatus = '1/4 Analisi fonti e trascrizioni lezioni...';
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _generationStatus = '2/4 Elaborazione piano con Agente AI...');

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _generationStatus = '3/4 Generazione sintesi audio Podcast...');

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _generationStatus = '4/4 Inserimento in Calendario...');

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    school.addPlan(
      subject: _selectedSubject,
      title: _topicCtrl.text.trim().isEmpty ? 'Verifica' : _topicCtrl.text.trim(),
      examDate: _selectedDate,
      keyWeakness: _weaknessCtrl.text.trim(),
      daysCount: _daysCount,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Piano di Studio AI per $_selectedSubject creato con successo!'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;

    return Container(
      decoration: BoxDecoration(
        color: sc.bgRaised,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: sc.border),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHandle(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Kicker('NUOVO PIANO DI STUDIO', color: sc.brass),
                    const SizedBox(height: 2),
                    Text('Analisi & Creazione AI', style: AppTheme.d(22, weight: FontWeight.w700, color: sc.text)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: sc.accentSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(PhosphorIconsFill.sparkle, size: 22, color: sc.accent),
                ),
              ],
            ),
            const SizedBox(height: 18),

            if (_isGenerating) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: sc.bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sc.accent),
                ),
                child: Column(
                  children: [
                    const CircularProgressIndicator(strokeWidth: 3),
                    const SizedBox(height: 18),
                    Text(
                      _generationStatus,
                      textAlign: TextAlign.center,
                      style: AppTheme.s(14, weight: FontWeight.w600, color: sc.text),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'L\'agente AI sta strutturando i moduli giornalieri e il podcast di ripasso.',
                      textAlign: TextAlign.center,
                      style: AppTheme.s(12, color: sc.textSecondary),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Step 1: Materia
              Text('1. MATERIA', style: AppTheme.d(12, weight: FontWeight.w600, color: sc.textSecondary, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _subjects.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final sub = _subjects[i];
                    final sel = sub == _selectedSubject;
                    return Pill(
                      label: sub,
                      bg: sel ? sc.ember : sc.bgRaised2,
                      fg: sel ? sc.onEmber : sc.textSecondary,
                      onTap: () => setState(() => _selectedSubject = sub),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Step 2: Argomento
              Text('2. ARGOMENTO VERIFICA', style: AppTheme.d(12, weight: FontWeight.w600, color: sc.textSecondary, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: sc.bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: sc.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: TextField(
                  controller: _topicCtrl,
                  style: AppTheme.s(14, color: sc.text),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Es. Chimica Organica, Termodinamica...',
                    hintStyle: AppTheme.s(14, color: sc.textTertiary),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Step 3: Fonti / Trascrizioni
              Text('3. FONTI (Trascrizioni da NAS)', style: AppTheme.d(12, weight: FontWeight.w600, color: sc.textSecondary, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final nasRecordings = school.recordings.where((r) => r.subject.toLowerCase() == _selectedSubject.toLowerCase()).toList();
                  final count = nasRecordings.length;
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: sc.bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: sc.border),
                    ),
                    child: Row(
                      children: [
                        Icon(PhosphorIconsRegular.hardDrives, size: 22, color: sc.accent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$count Trascrizioni lezioni NAS', style: AppTheme.d(13, weight: FontWeight.w600, color: sc.text)),
                              Text('Trovate sul NAS per $_selectedSubject', style: AppTheme.s(11, color: sc.textSecondary)),
                            ],
                          ),
                        ),
                        if (count > 0)
                          Icon(PhosphorIconsFill.checkCircle, size: 18, color: sc.sage)
                        else
                          Icon(PhosphorIconsRegular.warning, size: 18, color: sc.warn),
                      ],
                    ),
                  );
                }
              ),

              const SizedBox(height: 16),

              // Step 4: Carenze principali
              Text('4. PRINCIPALI CARENZE O DUBBI', style: AppTheme.d(12, weight: FontWeight.w600, color: sc.textSecondary, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: sc.bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: sc.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: TextField(
                  controller: _weaknessCtrl,
                  maxLines: 2,
                  style: AppTheme.s(13, color: sc.text),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Cosa trovi più difficile? (es. dimostrazioni formule, memorizzare date...)',
                    hintStyle: AppTheme.s(13, color: sc.textTertiary),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Giorni di studio & Scadenza
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DURATA PIANO', style: AppTheme.d(11, weight: FontWeight.w600, color: sc.textSecondary, letterSpacing: 1)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: sc.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: sc.border)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _daysCount = (_daysCount - 1).clamp(2, 14)),
                                child: Icon(PhosphorIconsBold.minus, size: 16, color: sc.text),
                              ),
                              Text('$_daysCount giorni', style: AppTheme.d(14, weight: FontWeight.w700, color: sc.text)),
                              GestureDetector(
                                onTap: () => setState(() => _daysCount = (_daysCount + 1).clamp(2, 14)),
                                child: Icon(PhosphorIconsBold.plus, size: 16, color: sc.text),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DATA VERIFICA', style: AppTheme.d(11, weight: FontWeight.w600, color: sc.textSecondary, letterSpacing: 1)),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 90)),
                            );
                            if (picked != null) setState(() => _selectedDate = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(color: sc.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: sc.border)),
                            child: Row(
                              children: [
                                Icon(PhosphorIconsRegular.calendarCheck, size: 16, color: sc.accent),
                                const SizedBox(width: 8),
                                Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: AppTheme.d(14, weight: FontWeight.w600, color: sc.text)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              PrimaryButton(
                label: 'GENERA PIANO CON AI',
                icon: PhosphorIconsFill.sparkle,
                bg: sc.ember,
                onTap: _generate,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
