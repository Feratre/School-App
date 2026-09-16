import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../state/school_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'ui_kit.dart';

void showUploadRecordingSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const UploadRecordingSheet(),
  );
}

class UploadRecordingSheet extends StatefulWidget {
  const UploadRecordingSheet({super.key});

  @override
  State<UploadRecordingSheet> createState() => _UploadRecordingSheetState();
}

class _UploadRecordingSheetState extends State<UploadRecordingSheet> {
  final _titleCtrl = TextEditingController(text: 'Lezione Filosofia: Kant e Critica Ragion Pura');
  String _selectedSubject = 'Filosofia';
  bool _isUploading = false;
  String _uploadStatus = '';

  final _subjects = ['Filosofia', 'Chimica', 'Matematica', 'Fisica', 'Storia', 'Inglese'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _startUpload() async {
    setState(() {
      _isUploading = true;
      _uploadStatus = 'Upload file audio (WAV / MP3)...';
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _uploadStatus = 'Avvio modello Whisper per Trascrizione...');

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _uploadStatus = 'Divisione automatica argomenti per materia...');

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    school.addRecording(
      title: _titleCtrl.text.trim().isEmpty ? 'Nuova Lezione' : _titleCtrl.text.trim(),
      subject: _selectedSubject,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lezione registrata e trascritta per $_selectedSubject!'),
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
                    Kicker('AUDIO AGENTS · TRASCRIZIONE', color: sc.accent),
                    const SizedBox(height: 2),
                    Text('Upload Registrazione', style: AppTheme.d(22, weight: FontWeight.w700, color: sc.text)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: sc.accentSoft, borderRadius: BorderRadius.circular(12)),
                  child: Icon(PhosphorIconsFill.microphone, size: 22, color: sc.accent),
                ),
              ],
            ),
            const SizedBox(height: 18),

            if (_isUploading) ...[
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
                    Text(_uploadStatus, textAlign: TextAlign.center, style: AppTheme.s(14, weight: FontWeight.w600, color: sc.text)),
                    const SizedBox(height: 8),
                    Text(
                      'L\'audio viene trascritto con Whisper AI e segmentato automaticamente per materia.',
                      textAlign: TextAlign.center,
                      style: AppTheme.s(12, color: sc.textSecondary),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Upload box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: sc.bg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: sc.border),
                ),
                child: Column(
                  children: [
                    Icon(PhosphorIconsRegular.uploadSimple, size: 36, color: sc.accent),
                    const SizedBox(height: 10),
                    Text('Trascina o tocca per selezionare audio', style: AppTheme.d(14, weight: FontWeight.w600, color: sc.text)),
                    const SizedBox(height: 4),
                    Text('Supporta file WAV, MP3, M4A fino a 200MB', style: AppTheme.s(12, color: sc.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text('MATERIA DELLA LEZIONE', style: AppTheme.d(12, weight: FontWeight.w600, color: sc.textSecondary, letterSpacing: 1.5)),
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

              Text('TITOLO / ARGOMENTO LEZIONE', style: AppTheme.d(12, weight: FontWeight.w600, color: sc.textSecondary, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: sc.bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: sc.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: TextField(
                  controller: _titleCtrl,
                  style: AppTheme.s(14, color: sc.text),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Es. Lezione Fisica 26 Ottobre',
                    hintStyle: AppTheme.s(14, color: sc.textTertiary),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              PrimaryButton(
                label: 'CARICA E TRASCRIVI CON AI',
                icon: PhosphorIconsFill.sparkle,
                bg: sc.ember,
                onTap: _startUpload,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
