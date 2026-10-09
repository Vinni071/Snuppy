import 'package:flutter/material.dart';

class NewFileDialog extends StatefulWidget {
  const NewFileDialog({super.key});

  @override
  State<NewFileDialog> createState() => _NewFileDialogState();
}

class _NewFileDialogState extends State<NewFileDialog> {
  final _controller = TextEditingController(text: 'meu-programa');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Uma nova ideia'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dê um nome ao seu arquivo. O código será salvo automaticamente no Luminthor.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 22),
              TextFormField(
                key: const ValueKey('new-file-name'),
                controller: _controller,
                autofocus: true,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Nome do arquivo',
                  suffixText: '.lumi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final name = value?.trim() ?? '';
                  if (name.isEmpty || name.toLowerCase() == '.lumi') {
                    return 'Digite um nome para continuar.';
                  }
                  if (RegExp(r'[\\/:*?"<>|\x00-\x1F]').hasMatch(name) ||
                      name == '.' ||
                      name == '..') {
                    return 'Use um nome sem caracteres especiais de caminho.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Criar arquivo')),
      ],
    );
  }
}
