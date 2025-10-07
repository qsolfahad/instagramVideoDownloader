import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:language_tool/language_tool.dart';

/// Full custom SpellCheckerScreen with a custom TextEditingController that
/// highlights error ranges inside the editable TextField (no overlay tricks).
class SpellCheckerScreen extends StatefulWidget {
  const SpellCheckerScreen({Key? key}) : super(key: key);

  @override
  State<SpellCheckerScreen> createState() => _SpellCheckerScreenState();
}

/// Simple issue model
class _Issue {
  final String message;
  final String short;
  final String ruleId;
  final String description;
  final int offset;
  final int length;
  final List<String> replacements;

  _Issue({
    required this.message,
    required this.short,
    required this.ruleId,
    required this.description,
    required this.offset,
    required this.length,
    required this.replacements,
  });
}

/// Custom controller which paints highlighted spans for issues.
class HighlightEditingController extends TextEditingController {
  List<_Issue> issues = [];
  final TextStyle baseStyle;

  HighlightEditingController({String? text, required this.baseStyle})
      : super(text: text);

  /// Override buildTextSpan so EditableText (used by TextField) renders styled spans.
  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, bool withComposing = false}) {
    final text = value.text;
    final resolvedBase = baseStyle.merge(style);

    if (text.isEmpty || issues.isEmpty) {
      return TextSpan(text: text, style: resolvedBase);
    }

    // Defensive: only keep valid issues and sort them
    final valid = issues
        .where((iss) =>
            iss.offset >= 0 &&
            iss.length > 0 &&
            iss.offset + iss.length <= text.length)
        .toList()
      ..sort((a, b) => a.offset.compareTo(b.offset));

    if (valid.isEmpty) {
      return TextSpan(text: text, style: resolvedBase);
    }

    List<TextSpan> spans = [];
    int last = 0;

    for (final iss in valid) {
      final start = iss.offset;
      final end = iss.offset + iss.length;

      if (start > last) {
        spans.add(TextSpan(text: text.substring(last, start), style: resolvedBase));
      }

      final wrongText = text.substring(start, end);
      spans.add(TextSpan(
        text: wrongText,
        style: resolvedBase.copyWith(
          color: Colors.red.shade800,
          decoration: TextDecoration.underline,
          decorationColor: Colors.red.shade800,
          decorationStyle: TextDecorationStyle.wavy,
          fontWeight: FontWeight.w600,
        ),
      ));

      last = end;
    }

    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last), style: resolvedBase));
    }

    return TextSpan(children: spans, style: resolvedBase);
  }
}

class _SpellCheckerScreenState extends State<SpellCheckerScreen> {
  late HighlightEditingController _controller;
  final LanguageTool _lt = LanguageTool();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _fieldKey = GlobalKey();

  final List<DropdownMenuItem<String>> _languageItems = const [
    DropdownMenuItem(value: 'en-US', child: Text('English (US)')),
    DropdownMenuItem(value: 'en-GB', child: Text('English (UK)')),
    DropdownMenuItem(value: 'fr', child: Text('French')),
    DropdownMenuItem(value: 'es', child: Text('Spanish')),
    DropdownMenuItem(value: 'de', child: Text('German')),
    DropdownMenuItem(value: 'pt-BR', child: Text('Portuguese (Brazil)')),
    DropdownMenuItem(value: 'ru', child: Text('Russian')),
    DropdownMenuItem(value: 'ar', child: Text('Arabic')),
    DropdownMenuItem(value: 'fa', child: Text('Persian')),
    DropdownMenuItem(value: 'tr', child: Text('Turkish')),
    DropdownMenuItem(value: 'it', child: Text('Italian')),
    DropdownMenuItem(value: 'nl', child: Text('Dutch')),
    DropdownMenuItem(value: 'pl', child: Text('Polish')),
  ];

  String _selectedLang = 'en-US';
  bool _isChecking = false;
  List<_Issue> _issues = [];
  String _checkedText = '';

  @override
  void initState() {
    super.initState();
    final baseStyle = GoogleFonts.poppins(fontSize: 16, color: Colors.black, height: 1.4);
    _controller = HighlightEditingController(baseStyle: baseStyle);

    // FIX: The `addListener` below caused a bug where every text change (e.g., applying a suggestion)
    // would reset all issues, preventing the user from fixing them one by one.
    // We now manage the state for issues and checked text directly within `_applySuggestion`
    // to avoid a full state reset on every text modification.
  //  _controller.addListener(() {
      // if (_checkedText.isNotEmpty && _controller.text != _checkedText) {
      //   if (_issues.isNotEmpty) {
      //     setState(() {
      //       _issues = [];
      //       _controller.issues = [];
      //       _checkedText = '';
      //     });
      //   }
      // }
  //  });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _checkSpelling() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;

    setState(() {
      _isChecking = true;
      _issues = [];
      _controller.issues = [];
    });

    try {
      List<_Issue> found = [];

      if (_selectedLang == 'auto') {
        final matches = await _lt.check(text);
        found = matches.map((m) {
          final replacements = (m.replacements ?? []).map((r) => r.toString()).toList();
          return _Issue(
            message: m.message ?? 'Issue detected',
            short: m.shortMessage ?? '',
            ruleId: '',
            description: m.issueDescription ?? '',
            offset: m.offset ?? 0,
            length: m.length ?? 0,
            replacements: replacements,
          );
        }).toList();
      } else {
        final uri = Uri.parse('https://api.languagetool.org/v2/check');
        final resp = await http.post(
          uri,
          headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8'},
          body: {
            'text': text,
            'language': _selectedLang,
            'enabledOnly': 'false',
          },
        );

        if (resp.statusCode != 200) {
          throw Exception('LanguageTool API error: ${resp.statusCode}');
        }

        final data = json.decode(resp.body) as Map<String, dynamic>;
        final matches = (data['matches'] as List).cast<Map<String, dynamic>>();

        found = matches.map((m) {
          final rule = (m['rule'] as Map?) ?? {};
          final reps = ((m['replacements'] as List?) ?? [])
              .cast<Map>()
              .map((e) => (e['value'] ?? '').toString())
              .toList();

          return _Issue(
            message: (m['message'] ?? '').toString(),
            short: (m['shortMessage'] ?? '').toString(),
            ruleId: (rule['id'] ?? '').toString(),
            description: (rule['description'] ?? '').toString(),
            offset: (m['offset'] ?? 0) as int,
            length: (m['length'] ?? 0) as int,
            replacements: reps,
          );
        }).toList();
      }

      // Filter invalid offsets and sort
      found = found
          .where((iss) =>
              iss.offset >= 0 &&
              iss.length > 0 &&
              iss.offset + iss.length <= text.length)
          .toList()
        ..sort((a, b) => a.offset.compareTo(b.offset));

      setState(() {
        _issues = found;
        _controller.issues = found;
        _checkedText = text;
      });
    } catch (e) {
      setState(() {
        _issues = [
          _Issue(
            message: 'Could not check text. $e',
            short: 'Network/API error',
            ruleId: 'ERROR',
            description: '',
            offset: 0,
            length: 0,
            replacements: const [],
          )
        ];
        _controller.issues = _issues;
        _checkedText = _controller.text;
      });
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  /// Apply a suggestion by replacing the issue range with the selected suggestion.
  void _applySuggestion(_Issue issue, String suggestion) {
    final original = _controller.text;
    final start = issue.offset;
    final end = issue.offset + issue.length;
    if (start < 0 || end > original.length || start > end) return;

    final updated = original.replaceRange(start, end, suggestion);
    final diff = suggestion.length - issue.length;

    setState(() {
      // Step 1: Update the text in the controller
      _controller.text = updated;

      // Step 2: Remove the fixed issue from our state list
      final fixedIndex = _issues.indexOf(issue);
      if (fixedIndex != -1) {
        _issues.removeAt(fixedIndex);
      }

      // Step 3: Adjust the offsets for all remaining issues that appear after the correction
      for (var i = 0; i < _issues.length; i++) {
        final currentIssue = _issues[i];
        if (currentIssue.offset > start) {
          _issues[i] = _Issue(
            message: currentIssue.message,
            short: currentIssue.short,
            ruleId: currentIssue.ruleId,
            description: currentIssue.description,
            offset: currentIssue.offset + diff,
            length: currentIssue.length,
            replacements: currentIssue.replacements,
          );
        }
      }

      // Step 4: Update the controller's internal issues list and the checked text string
      _controller.issues = _issues;
      _checkedText = _controller.text; // keep checked text synced

      // Step 5: Place the cursor after the applied suggestion for a better user experience
      _controller.selection = TextSelection.collapsed(offset: start + suggestion.length);
    });
  }

  /// Show bottom sheet with suggestions for tapped issue
  void _showSuggestionsForIssue(_Issue issue) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final reps = issue.replacements;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(issue.short.isNotEmpty ? issue.short : issue.message,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (issue.description.isNotEmpty)
                Text(issue.description, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),
              if (reps.isEmpty)
                const Text('No suggestions available.')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in reps)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.grey),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _applySuggestion(issue, s);
                        },
                        child: Text(s),
                      ),
                  ],
                ),
              const SizedBox(height: 12),
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ]),
          ),
        );
      },
    );
  }

  /// Map a tap position inside the text field to a text offset, then check if it falls on any issue.
  /// If it falls on an issue -> open suggestions. Otherwise, move caret to tapped position.
  void _onFieldTapDown(TapDownDetails details) {
    final renderBox = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // get local position inside the widget
    final local = renderBox.globalToLocal(details.globalPosition);

    // Build a TextPainter with the same TextSpan used by controller to map coords -> offset
    final span = _controller.buildTextSpan(context: context, style: _controller.baseStyle);
    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      maxLines: null,
    );

    // width should be the width of the inner text area
    final availableWidth = renderBox.size.width;
    tp.layout(minWidth: 0, maxWidth: availableWidth);

    // TextPainter expects an offset relative to the text origin; here local is fine
    final pos = tp.getPositionForOffset(Offset(local.dx, local.dy));
    final tappedOffset = pos.offset;

    // Check if tapped offset is part of an issue
    for (final iss in _issues) {
      if (tappedOffset >= iss.offset && tappedOffset < iss.offset + iss.length) {
        // tapped an issue -> show suggestions
        _showSuggestionsForIssue(iss);
        return;
      }
    }

    // No issue tapped -> move caret to tapped position and request focus
    _focusNode.requestFocus();
    setState(() {
      _controller.selection = TextSelection.collapsed(offset: tappedOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    const contentPadding = EdgeInsets.all(12.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF1F5), Color(0xFFE0F2FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Container(
                padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Image.asset('assets/back.png', width: 38, height: 38),
                    ),
                    Text('Spelling Checker', style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
                    const SizedBox(width: 30),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Language Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedLang,
                  decoration: const InputDecoration(
                    labelText: 'Language',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  items: _languageItems,
                  onChanged: (v) => setState(() => _selectedLang = v ?? 'auto'),
                ),
              ),

              const SizedBox(height: 12),

              // Custom editable text area (totally custom)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: contentPadding,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: _onFieldTapDown,
                  child: Container(
                    key: _fieldKey,
                    // Use TextField but rely on controller.buildTextSpan to style text
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: 6,
                      style: _controller.baseStyle.copyWith(color: Colors.black),
                      cursorColor: Colors.pink,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: "Type/paste text to check…",
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Check Button
              ElevatedButton.icon(
                onPressed: _isChecking ? null : _checkSpelling,
                icon: const Icon(Icons.spellcheck),
                label: const Text("Check Spelling"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 16),

              // Results area
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))]),
                  child: _isChecking
                      ? const Center(child: CircularProgressIndicator())
                      : _issues.isEmpty
                          ? Center(
                              child: Text(
                                _checkedText.isEmpty ? "Type text above and press Check Spelling." : "✅ Looks good! No issues found.",
                                style: const TextStyle(fontSize: 16),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _issues.length,
                              separatorBuilder: (_, __) => const Divider(height: 24),
                              itemBuilder: (context, i) {
                                final issue = _issues[i];
                                final hasSuggestion = issue.replacements.isNotEmpty;
                                String badWord = '';
                                final text = _controller.text;
                                if (issue.offset >= 0 && issue.offset + issue.length <= text.length) {
                                  badWord = text.substring(issue.offset, issue.offset + issue.length);
                                }
                                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(children: [
                                    const Icon(Icons.error_outline, color: Colors.pink),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(issue.short.isNotEmpty ? issue.short : issue.message, style: const TextStyle(fontWeight: FontWeight.w600))),
                                    if (badWord.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                        child: Text(badWord, style: const TextStyle(color: Colors.redAccent)),
                                      ),
                                  ]),
                                  if (issue.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(issue.description, style: const TextStyle(color: Colors.black54)),
                                  ],
                                  const SizedBox(height: 8),
                                  if (hasSuggestion)
                                    Wrap(spacing: 8, runSpacing: 8, children: [
                                      for (final s in issue.replacements)
                                        GestureDetector(
                                          onTap: () => _applySuggestion(issue, s),
                                          child: Chip(label: Text(s), backgroundColor: const Color(0xFFE0F2FE)),
                                        ),
                                      TextButton(onPressed: () => _showSuggestionsForIssue(issue), child: const Text('More')),
                                    ])
                                  else
                                    const Text('No suggestions available for this issue.', style: TextStyle(color: Colors.black54)),
                                ]);
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
