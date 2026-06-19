import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/editor_provider.dart';
import 'package:ide/features/settings/presentation/providers/settings_provider.dart';
import 'console_panel.dart';
import 'lumi_code_controller.dart';

class EditorTab extends ConsumerStatefulWidget {
  const EditorTab({super.key});

  @override
  ConsumerState<EditorTab> createState() => _EditorTabState();
}

class _EditorTabState extends ConsumerState<EditorTab> {
  late LumiCodeController _codeController;
  late ScrollController _textScrollController;

  @override
  void initState() {
    super.initState();
    final initialCode = ref.read(editorProvider).source;
    _codeController = LumiCodeController(text: initialCode);
    _textScrollController = ScrollController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _textScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(editorProvider.notifier);

    // Sync editor text if it changes from provider (e.g. loaded template)
    if (_codeController.text != state.source) {
      _codeController.text = state.source;
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF303030), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x73000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          const _EditorWindowHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
              child: TextField(
                controller: _codeController,
                scrollController: _textScrollController,
                expands: true,
                minLines: null,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                cursorColor: Colors.white,
                textAlignVertical: TextAlignVertical.top,
                style: AppTheme.editorTextStyle.copyWith(
                  fontSize: settings.fontSize,
                  height: 1.48,
                  color: const Color(0xFFF4F4F4),
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: notifier.updateSource,
                readOnly: state.isDebugging,
              ),
            ),
          ),
          const ConsolePanel(),
        ],
      ),
    );
  }
}

class _EditorWindowHeader extends StatelessWidget {
  const _EditorWindowHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: const BoxDecoration(
        color: Color(0xFF151515),
        border: Border(
          bottom: BorderSide(color: Color(0xFF282828), width: 1),
        ),
      ),
      child: const Row(
        children: [
          _WindowDot(),
          SizedBox(width: 7),
          _WindowDot(),
          SizedBox(width: 7),
          _WindowDot(),
          SizedBox(width: 15),
          Flexible(
            child: Text(
              'Editor.lumi',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF777777),
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  const _WindowDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF343434),
        border: Border.all(color: const Color(0xFF454545), width: 0.7),
      ),
    );
  }
}
