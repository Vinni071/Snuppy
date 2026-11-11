import 'package:flutter/material.dart';

/// "From idea to execution" onboarding dialog.
class HomeGuideDialog extends StatelessWidget {
  const HomeGuideDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Da ideia à execução'),
      content: const SizedBox(
          width: 380,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GuideStep(
                    number: '01',
                    title: 'Escreva em Lumi',
                    description:
                        'Crie um arquivo ou escolha um template para começar.'),
                SizedBox(height: 20),
                _GuideStep(
                    number: '02',
                    title: 'Execute e explore',
                    description:
                        'Toque em Execute. Veja a saída, os tokens e a árvore de sintaxe nas abas do editor.'),
                SizedBox(height: 20),
                _GuideStep(
                    number: '03',
                    title: 'Entenda cada passo',
                    description:
                        'Na aba de depuração, acompanhe as variáveis e avance pela execução do programa.'),
              ])),
      actions: [
        FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vamos começar'))
      ],
    );
  }
}

class _GuideStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _GuideStep({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(number,
          style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700)),
      const SizedBox(width: 14),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        Text(description, style: const TextStyle(fontSize: 13, height: 1.5))
      ])),
    ]);
  }
}
