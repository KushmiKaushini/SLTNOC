import 'package:flutter/material.dart';
import '../constants/chat_constants.dart';

class MarkdownText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const MarkdownText({Key? key, required this.text, this.style})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> blocks = [];
    List<String> parts = text.split('```');

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        String code = parts[i];
        String? language;
        int firstNewline = code.indexOf('\n');
        if (firstNewline != -1) {
          String possibleLang = code.substring(0, firstNewline).trim();
          if (possibleLang.isNotEmpty &&
              !possibleLang.contains(' ') &&
              possibleLang.length < 10) {
            language = possibleLang;
            code = code.substring(firstNewline + 1);
          }
        }
        blocks.add(_buildCodeBlock(code.trim(), language));
      } else {
        String normalText = parts[i];
        if (normalText.isNotEmpty) {
          blocks.addAll(_parseParagraphs(normalText));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: blocks,
    );
  }

  Widget _buildCodeBlock(String code, String? language) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x336C63FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language != null) ...[
            Text(
              language.toUpperCase(),
              style: const TextStyle(
                color: kChatAccent2,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 6),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              code,
              style: const TextStyle(
                color: Color(0xFF4ADE80),
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _parseParagraphs(String blockText) {
    List<Widget> widgets = [];
    List<String> lines = blockText.split('\n');
    List<String> currentParagraph = [];

    void flushParagraph() {
      if (currentParagraph.isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: RichText(
            text: TextSpan(
              children: _parseInline(currentParagraph.join('\n')),
              style: TextStyle(
                fontSize: 14,
                color: style?.color ?? Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ),
        ));
        currentParagraph.clear();
      }
    }

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      String trimmed = line.trim();

      if (trimmed.startsWith('#')) {
        flushParagraph();
        int level = 0;
        while (level < trimmed.length && trimmed[level] == '#') {
          level++;
        }
        String headingText = trimmed.substring(level).trim();
        double fontSize = level == 1
            ? 20.0
            : level == 2
                ? 17.0
                : level == 3
                    ? 15.0
                    : 14.0;

        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: RichText(
            text: TextSpan(
              children: _parseInline(headingText),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: style?.color ?? Colors.white,
              ),
            ),
          ),
        ));
      } else if (trimmed.startsWith('- ') ||
          trimmed.startsWith('* ') ||
          trimmed.startsWith('• ')) {
        flushParagraph();
        String itemText = trimmed.substring(2).trim();
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 10, top: 3, bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ',
                  style: TextStyle(
                      fontSize: 14, color: style?.color ?? kChatAccent2)),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: _parseInline(itemText),
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          style?.color ?? Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
      } else if (RegExp(r'^\d+\.\s').hasMatch(trimmed)) {
        flushParagraph();
        Match match = RegExp(r'^(\d+\.)\s(.*)').firstMatch(trimmed)!;
        String number = match.group(1)!;
        String itemText = match.group(2)!;
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 10, top: 3, bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$number ',
                  style: TextStyle(
                      fontSize: 14, color: style?.color ?? kChatAccent2)),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: _parseInline(itemText),
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          style?.color ?? Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
      } else if (trimmed.isEmpty) {
        flushParagraph();
        widgets.add(const SizedBox(height: 4));
      } else {
        currentParagraph.add(line);
      }
    }

    flushParagraph();
    return widgets;
  }

  List<TextSpan> _parseInline(String text) {
    List<TextSpan> spans = [];
    final regex = RegExp(r'(\*\*.*?\*\*|`.*?`|_.*?_)');
    final matches = regex.allMatches(text);

    int start = 0;
    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }

      String matchText = match.group(0)!;
      if (matchText.startsWith('**') && matchText.endsWith('**')) {
        spans.add(TextSpan(
          text: matchText.substring(2, matchText.length - 2),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (matchText.startsWith('`') && matchText.endsWith('`')) {
        spans.add(TextSpan(
          text: matchText.substring(1, matchText.length - 1),
          style: const TextStyle(
            fontFamily: 'monospace',
            backgroundColor: Color(0x226C63FF),
            color: kChatAccent2,
            fontSize: 13,
          ),
        ));
      } else if (matchText.startsWith('_') && matchText.endsWith('_')) {
        spans.add(TextSpan(
          text: matchText.substring(1, matchText.length - 1),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      } else {
        spans.add(TextSpan(text: matchText));
      }

      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }
}
