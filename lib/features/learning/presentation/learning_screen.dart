import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/branding/luminthor_logo.dart';
import '../../settings/presentation/providers/settings_provider.dart';
import '../domain/learning_path.dart';
import 'providers/learning_provider.dart';
import 'widgets/journey_map.dart';
import 'widgets/learning_style.dart';

class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({super.key});

  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen> {
  final _moduleKeys =
      List.generate(LearningPath.modules.length, (_) => GlobalKey());

  void _open(LumiLesson lesson) {
    final progress = ref.read(learningProvider);
    if (!progress.isUnlocked(lesson)) {
      final previous =
          LearningPath.lessons[LearningPath.lessons.indexOf(lesson) - 1];
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content:
                Text('Conclua “${previous.title}” para liberar esta etapa.')));
      return;
    }
    context.push('/learn/lesson/${lesson.id}');
  }

  void _scrollToModule(int index) {
    final target = _moduleKeys[index].currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(target,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic);
  }

  void _showAchievements() {
    final c = LearningColors.of(context);
    final progress = ref.read(learningProvider);
    showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: c.surface,
              title: Text('Suas conquistas', style: TextStyle(color: c.text)),
              content: SizedBox(
                  width: 360,
                  child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      for (final module in LearningPath.modules)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                              module.lessons.every(progress.isCompleted)
                                  ? Icons.workspace_premium_rounded
                                  : Icons.lock_outline_rounded,
                              color: module.lessons.every(progress.isCompleted)
                                  ? c.accent
                                  : c.muted),
                          title: Text(module.badge,
                              style: TextStyle(color: c.text, fontSize: 14)),
                          subtitle: Text(
                              module.lessons.every(progress.isCompleted)
                                  ? 'Conquistada!'
                                  : '${module.lessons.where(progress.isCompleted).length}/3 etapas concluídas',
                              style: TextStyle(color: c.muted, fontSize: 12)),
                        ),
                    ]),
                  )),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Voltar à jornada',
                        style: TextStyle(color: c.accent)))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final c = LearningColors.of(context);
    final progress = ref.watch(learningProvider);
    final next = progress.nextLesson;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        foregroundColor: c.text,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
            tooltip: 'Voltar à Home',
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
            icon: const Icon(Icons.arrow_back_rounded)),
        title: const Text('Trilha Lumi',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        actions: [
          LearningStat(icon: Icons.bolt_rounded, label: '${progress.xp} XP'),
          IconButton(
              tooltip: c.dark ? 'Ativar tema claro' : 'Ativar tema escuro',
              onPressed: () =>
                  ref.read(settingsProvider.notifier).toggleTheme(),
              icon: Icon(
                  c.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  size: 20)),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth >= 960;
          return Center(
              child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (wide) _sidebar(c, progress),
              Expanded(
                  child: Column(children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(
                        wide ? 40 : 24, 10, wide ? 40 : 24, 8),
                    child: _progress(c, progress)),
                Expanded(
                    child: SingleChildScrollView(
                  key: const PageStorageKey('lumi-learning-map'),
                  child: Center(
                      child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < LearningPath.modules.length; i++)
                            _module(c, progress, i),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32, 0, 32, 36),
                            child: Column(children: [
                              Icon(Icons.auto_awesome_rounded,
                                  color: next == null ? c.accent : c.muted,
                                  size: 28),
                              const SizedBox(height: 12),
                              Text(
                                  next == null
                                      ? 'Sua jornada é só o começo.'
                                      : 'Cada passo, uma nova possibilidade.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: c.text,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              Text(
                                  next == null
                                      ? 'Revise, experimente e continue criando com Lumi.'
                                      : '18 etapas. 6 conquistas. Um mundo de ideias para criar.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: c.muted,
                                      fontSize: 12,
                                      height: 1.6)),
                            ]),
                          ),
                        ]),
                  )),
                )),
              ])),
            ]),
          ));
        }),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: c.surface, border: Border(top: BorderSide(color: c.border))),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Row(children: [
                  Expanded(
                      child: FilledButton.icon(
                    key: const ValueKey('continue-learning'),
                    style: learningButtonStyle(c),
                    onPressed: () => _open(next ?? LearningPath.lessons.first),
                    icon: Icon(
                        next == null
                            ? Icons.replay_rounded
                            : Icons.route_rounded,
                        size: 20),
                    label: Text(next == null
                        ? 'Revisitar jornada'
                        : progress.completed.isEmpty
                            ? 'Começar jornada'
                            : 'Continuar jornada'),
                  )),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    tooltip: 'Ver conquistas',
                    onPressed: _showAchievements,
                    style: IconButton.styleFrom(
                        backgroundColor: c.locked,
                        foregroundColor: c.text,
                        minimumSize: const Size(52, 52)),
                    icon: const Icon(Icons.emoji_events_outlined),
                  ),
                ]),
              )),
        ),
      ),
    );
  }

  Widget _sidebar(LearningColors c, LearningProgress progress) => Container(
        width: 280,
        decoration:
            BoxDecoration(border: Border(right: BorderSide(color: c.border))),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            LuminthorLogo(isDark: c.dark, width: 42, part: LogoPart.symbol),
            const SizedBox(height: 22),
            Text('Seu caminho\ncom Lumi.',
                style: TextStyle(
                    color: c.text,
                    fontSize: 32,
                    height: 1.1,
                    letterSpacing: -1.2,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(
                'Da primeira linha à sua própria criação. Uma descoberta de cada vez.',
                style: TextStyle(color: c.muted, fontSize: 13, height: 1.7)),
            const SizedBox(height: 36),
            Text('EXPLORE A JORNADA',
                style: TextStyle(
                    color: c.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6)),
            const SizedBox(height: 14),
            for (var i = 0; i < LearningPath.modules.length; i++)
              _moduleLink(c, progress, i),
            const SizedBox(height: 26),
            OutlinedButton.icon(
              onPressed: _showAchievements,
              style: OutlinedButton.styleFrom(
                  foregroundColor: c.text, side: BorderSide(color: c.border)),
              icon: const Icon(Icons.workspace_premium_outlined, size: 19),
              label: Text('${progress.completedModules} de 6 conquistas'),
            ),
          ]),
        ),
      );

  Widget _progress(LearningColors c, LearningProgress progress) =>
      Column(children: [
        Row(children: [
          Expanded(
              child: Text('${progress.completed.length} de 18 etapas',
                  style: TextStyle(
                      color: c.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Icon(Icons.workspace_premium_outlined, color: c.accent, size: 17),
          const SizedBox(width: 5),
          Text('${progress.completedModules}/6',
              style: TextStyle(color: c.muted, fontSize: 11)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.fraction,
              minHeight: 4,
              color: c.accent,
              backgroundColor: c.border,
              semanticsLabel:
                  'Progresso da trilha: ${progress.completed.length} de 18 etapas',
            )),
      ]);

  Widget _moduleLink(LearningColors c, LearningProgress progress, int index) {
    final module = LearningPath.modules[index];
    final complete = module.lessons.every(progress.isCompleted);
    final current = module.lessons.contains(progress.nextLesson);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TextButton(
        onPressed: () => _scrollToModule(index),
        style: TextButton.styleFrom(
            foregroundColor: c.text,
            backgroundColor: current ? c.locked : Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10)),
        child: Row(children: [
          SizedBox(
              width: 24,
              child: complete
                  ? Icon(Icons.check_circle_rounded, size: 18, color: c.accent)
                  : Text('0${index + 1}',
                      style: TextStyle(
                          color: current ? c.accentLight : c.muted,
                          fontSize: 12))),
          const SizedBox(width: 10),
          Expanded(
              child: Text(module.title, style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 16, color: c.muted),
        ]),
      ),
    );
  }

  Widget _module(LearningColors c, LearningProgress progress, int index) {
    final module = LearningPath.modules[index];
    final complete = module.lessons.every(progress.isCompleted);
    final current = module.lessons.contains(progress.nextLesson);
    return Container(
      key: _moduleKeys[index],
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
      decoration: BoxDecoration(
          gradient: RadialGradient(
        center: const Alignment(-.4, -.4),
        radius: 1,
        colors: [current || complete ? c.tint : c.background, c.background],
      )),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: current ? c.action : c.locked,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('MÓDULO 0${index + 1}',
                        style: TextStyle(
                            color: current ? c.onAction : c.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .8)),
                  ),
                  const SizedBox(height: 10),
                  Text(module.title,
                      style: TextStyle(
                          color: c.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(module.subtitle,
                      style:
                          TextStyle(color: c.muted, fontSize: 11, height: 1.5)),
                ])),
            const SizedBox(width: 14),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                  '${module.lessons.where(progress.isCompleted).length}/3',
                  style: TextStyle(color: c.muted, fontSize: 11)),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        JourneyMap(
            module: module,
            moduleIndex: index,
            progress: progress,
            onOpen: _open),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
              complete
                  ? Icons.workspace_premium_rounded
                  : Icons.workspace_premium_outlined,
              color: complete ? c.accent : c.muted,
              size: 18),
          const SizedBox(width: 7),
          Flexible(
              child: Text(module.badge,
                  style: TextStyle(color: c.muted, fontSize: 11))),
        ]),
        const SizedBox(height: 24),
        Divider(color: c.border, indent: 70, endIndent: 70, height: 1),
      ]),
    );
  }
}
