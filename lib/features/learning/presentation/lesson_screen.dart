import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../editor/presentation/providers/editor_provider.dart';
import '../../home/presentation/providers/workspace_provider.dart';
import '../domain/learning_path.dart';
import 'providers/learning_provider.dart';
import 'widgets/learning_style.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final String lessonId;
  const LessonScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int? _answer;
  bool? _correct;
  bool _saving = false;
  String? _saveError;

  @override
  void didUpdateWidget(covariant LessonScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessonId != widget.lessonId) {
      _answer = null;
      _correct = null;
      _saving = false;
      _saveError = null;
    }
  }

  void _practice(LumiLesson lesson) {
    final workspace = ref.read(workspaceProvider.notifier);
    final origin = 'Trilha Lumi · ${lesson.id}';
    final existing = ref
        .read(workspaceProvider)
        .documents
        .where((doc) => doc.origin == origin);
    final document = existing.isNotEmpty
        ? existing.first
        : workspace.create(
            name: '${lesson.id}.lumi', source: lesson.code, origin: origin);
    ref.read(editorProvider.notifier).openDocument(document);
    context.push('/editor?from=learn');
  }

  Future<void> _checkAnswer(LumiLesson lesson) async {
    if (_answer == null || _saving) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      final correct = await ref
          .read(learningProvider.notifier)
          .submitAnswer(lesson, _answer!);
      if (mounted) setState(() => _correct = correct);
    } catch (_) {
      if (mounted) {
        setState(() => _saveError =
            'Não foi possível salvar seu progresso. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _back() => context.canPop() ? context.pop() : context.go('/learn');

  @override
  Widget build(BuildContext context) {
    final c = LearningColors.of(context);
    final lesson = LearningPath.lessonById(widget.lessonId);
    final progress = ref.watch(learningProvider);
    final unlocked = lesson != null && progress.isUnlocked(lesson);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        foregroundColor: c.text,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
            tooltip: 'Voltar à trilha',
            onPressed: _back,
            icon: const Icon(Icons.arrow_back_rounded)),
        title: Text(
            lesson?.isProject == true ? 'Hora de criar' : 'Uma nova descoberta',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: !unlocked
            ? Center(
                child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.lock_outline_rounded, size: 48, color: c.muted),
                  const SizedBox(height: 16),
                  Text(
                      lesson == null
                          ? 'Esta aula não foi encontrada.'
                          : 'Conclua a etapa anterior para abrir esta aula.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.text)),
                  const SizedBox(height: 16),
                  FilledButton(
                      onPressed: () => context.go('/learn'),
                      style: learningButtonStyle(c),
                      child: const Text('Ver minha trilha')),
                ]),
              ))
            : Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ListView(
                    key: ValueKey('lesson-content-${lesson.id}'),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                    children: [
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        LearningStat(
                            icon: Icons.schedule_rounded,
                            label: '${lesson.minutes} min'),
                        LearningStat(
                            icon: Icons.bolt_rounded, label: '${lesson.xp} XP'),
                        if (progress.isCompleted(lesson))
                          const LearningStat(
                              icon: Icons.check_circle_outline_rounded,
                              label: 'Concluída'),
                      ]),
                      const SizedBox(height: 22),
                      Text(lesson.title,
                          style: TextStyle(
                              color: c.text,
                              fontSize: 32,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1)),
                      const SizedBox(height: 16),
                      Text(lesson.explanation,
                          style: TextStyle(
                              color: c.text, fontSize: 15, height: 1.8)),
                      const SizedBox(height: 26),
                      _sectionTitle(c, 'Veja em Lumi', Icons.code_rounded),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: c.palette.console,
                            borderRadius: BorderRadius.circular(20)),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SelectableText(lesson.code,
                              style: TextStyle(
                                  color: c.palette.syntaxIdentifier,
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  height: 1.8)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _card(
                          c,
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('SAÍDA ESPERADA',
                                    style: TextStyle(
                                        color: c.muted,
                                        fontSize: 10,
                                        letterSpacing: 1.4,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 8),
                                SelectableText(lesson.output,
                                    style: TextStyle(
                                        color: c.text,
                                        fontFamily: 'monospace',
                                        fontSize: 13,
                                        height: 1.6)),
                              ])),
                      const SizedBox(height: 26),
                      _sectionTitle(
                          c, 'Agora é com você', Icons.science_outlined),
                      const SizedBox(height: 12),
                      Text(lesson.challenge,
                          style: TextStyle(
                              color: c.text, fontSize: 14, height: 1.7)),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        key: const ValueKey('practice-lesson'),
                        onPressed: () => _practice(lesson),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: c.text,
                            side: BorderSide(color: c.border),
                            minimumSize: const Size(48, 52),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16))),
                        icon: const Icon(Icons.terminal_rounded, size: 20),
                        label: const Text('Praticar no editor'),
                      ),
                      const SizedBox(height: 10),
                      Text(
                          'Seu exercício fica salvo em Arquivos. Volte para esta aula depois de experimentar.',
                          style: TextStyle(
                              color: c.muted, fontSize: 12, height: 1.6)),
                      const SizedBox(height: 30),
                      _card(
                          c,
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _sectionTitle(c, 'Confira sua descoberta',
                                    Icons.psychology_outlined),
                                const SizedBox(height: 10),
                                Text(
                                    'Acerte a pergunta para concluir a etapa. A prática no editor é livre.',
                                    style: TextStyle(
                                        color: c.muted,
                                        fontSize: 12,
                                        height: 1.6)),
                                const SizedBox(height: 20),
                                Text(lesson.question,
                                    style: TextStyle(
                                        color: c.text,
                                        fontSize: 16,
                                        height: 1.5,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 16),
                                for (var i = 0; i < lesson.answers.length; i++)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Semantics(
                                      selected: _answer == i,
                                      child: OutlinedButton(
                                        key: ValueKey('answer-$i'),
                                        onPressed: _saving || _correct == true
                                            ? null
                                            : () => setState(() {
                                                  _answer = i;
                                                  _correct = null;
                                                }),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: c.text,
                                          disabledForegroundColor: c.text,
                                          backgroundColor:
                                              _answer == i ? c.tint : c.surface,
                                          side: BorderSide(
                                              color: _answer == i
                                                  ? c.accent
                                                  : c.border,
                                              width: _answer == i ? 2 : 1),
                                          padding: const EdgeInsets.all(16),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14)),
                                        ),
                                        child: Row(children: [
                                          Icon(
                                              _answer == i
                                                  ? Icons.radio_button_checked
                                                  : Icons
                                                      .radio_button_unchecked,
                                              size: 20),
                                          const SizedBox(width: 12),
                                          Expanded(
                                              child: Text(lesson.answers[i],
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      height: 1.5))),
                                        ]),
                                      ),
                                    ),
                                  ),
                                if (_correct != null) ...[
                                  const SizedBox(height: 8),
                                  Semantics(
                                    liveRegion: true,
                                    child: Text(
                                        _correct!
                                            ? 'Isso mesmo! ${lesson.feedback}'
                                            : 'Ainda não. ${lesson.feedback} Tente novamente.',
                                        key: const ValueKey('answer-feedback'),
                                        style: TextStyle(
                                            color: c.text,
                                            fontSize: 13,
                                            height: 1.7)),
                                  ),
                                ],
                                if (_saveError != null)
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Text(_saveError!,
                                          style: TextStyle(color: c.text))),
                                const SizedBox(height: 18),
                                if (_correct != true)
                                  FilledButton(
                                    key: const ValueKey('check-answer'),
                                    style: learningButtonStyle(c),
                                    onPressed: _answer == null || _saving
                                        ? null
                                        : () => _checkAnswer(lesson),
                                    child: Text(_saving
                                        ? 'Salvando...'
                                        : 'Conferir resposta'),
                                  )
                                else ...[
                                  Text(
                                      progress.nextLesson == null
                                          ? 'Jornada concluída. Sua conquista: Criador Lumi!'
                                          : 'Etapa concluída! A próxima descoberta está liberada.',
                                      style: TextStyle(
                                          color: c.text,
                                          fontWeight: FontWeight.w700,
                                          height: 1.5)),
                                  const SizedBox(height: 14),
                                  FilledButton.icon(
                                    key: const ValueKey('next-lesson'),
                                    style: learningButtonStyle(c),
                                    onPressed: () {
                                      final index =
                                          LearningPath.lessons.indexOf(lesson);
                                      if (index + 1 <
                                          LearningPath.lessons.length) {
                                        context.pushReplacement(
                                            '/learn/lesson/${LearningPath.lessons[index + 1].id}');
                                      } else {
                                        context.go('/learn');
                                      }
                                    },
                                    icon:
                                        const Icon(Icons.arrow_forward_rounded),
                                    label: Text(
                                        LearningPath.lessons.last == lesson
                                            ? 'Ver minhas conquistas'
                                            : 'Próxima descoberta'),
                                  ),
                                ],
                              ])),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _sectionTitle(LearningColors c, String title, IconData icon) =>
      Row(children: [
        Icon(icon, color: c.accent, size: 22),
        const SizedBox(width: 9),
        Expanded(
            child: Text(title,
                style: TextStyle(
                    color: c.text, fontWeight: FontWeight.w800, fontSize: 16))),
      ]);

  Widget _card(LearningColors c, Widget child) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.border)),
        child: child,
      );
}
