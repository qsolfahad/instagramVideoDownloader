import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:openai_dart/openai_dart.dart' as OpenAI;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiDictionaryScreen extends StatefulWidget {
  final List<String> languages;
  const AiDictionaryScreen({Key? key, required this.languages}) : super(key: key);
  @override
  State<AiDictionaryScreen> createState() => _AiDictionaryScreenState();
}

class _AiDictionaryScreenState extends State<AiDictionaryScreen> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  late stt.SpeechToText _speech;
  late final OpenAI.OpenAIClient _openai;

  bool _isListening = false;
  bool _isLoading = false;

  String word = "";
  String definition = "";
  String phonetic = "";
  String example = "";
  List<String> synonyms = [];

  String fromLang = "English";

 

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _openai = OpenAI.OpenAIClient(
      apiKey: dotenv.env['OPENAI_API_KEY'] ?? '',
      baseUrl: "https://openrouter.ai/api/v1",
    );
  }

  Future<void> _speak(String text, [String? langCode]) async {
    if (text.isEmpty) return;
    await _tts.setLanguage(langCode ?? "en-US");
    await _tts.speak(text);
  }

  void _copy(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard")),
    );
  }

  void _share(String text) {
    if (text.isEmpty) return;
    Share.share(text);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() => _controller.text = result.recognizedWords);
          },
        );
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  Future<void> _searchWord() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      word = input;
      definition = "";
      phonetic = "";
      example = "";
      synonyms = [];
      _isLoading = true;
    });

    try {
      final response = await _openai.createChatCompletion(
        request: OpenAI.CreateChatCompletionRequest(
          model: OpenAI.ChatCompletionModel.modelId("gpt-3.5-turbo"),
          messages: [
            OpenAI. ChatCompletionMessage.system(
              content:
                  "You are a multilingual dictionary assistant. When given a word and a language, return its definition, phonetic spelling, example sentence, and synonyms in that same language. Format your response as JSON like this:\n{\n\"definition\": \"...\",\n\"phonetic\": \"...\",\n\"example\": \"...\",\n\"synonyms\": [\"...\", \"...\"]\n}",
            ),
            OpenAI.ChatCompletionMessage.user(
              content: OpenAI.ChatCompletionUserMessageContent.string(
                "Language: $fromLang. Word: $input",
              ),
            ),
          ],
          maxTokens: 400,
          temperature: 0.7,
        ),
      );

      final raw = response.choices.first.message.content ?? "";

      // Try to decode JSON safely
      final parsed = _safeJsonDecode(raw);

      setState(() {
        definition = parsed['definition'] ?? 'No definition available.';
        phonetic = parsed['phonetic'] ?? '';
        example = parsed['example'] ?? '';
        synonyms = List<String>.from(parsed['synonyms'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        definition = "Error fetching meaning: $e";
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _safeJsonDecode(String text) {
    try {
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start != -1 && end != -1) {
        final jsonText = text.substring(start, end + 1);
        return json.decode(jsonText);
      }
    } catch (_) {}
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE5EC), Color(0xFFDFF7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                 Container(
              padding: const EdgeInsets.only(  bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Image.asset(
                    'assets/back.png',
                    width: 38,
                    height: 38,
                  ),
                  ),
                Text('Ai Dictionary ',
                      style: GoogleFonts.syne(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),),              SizedBox(width: 30,)
                ],
              ),
            ),
           
                const SizedBox(height: 25),

                // Language selector
                _buildLangSelector("Language", fromLang, (val) {
                  setState(() => fromLang = val);
                }),
                const SizedBox(height: 20),

                // Search input
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter a word...",
                            hintStyle: GoogleFonts.inter(
                              color: Colors.grey.shade500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.pink,
                        ),
                        onPressed: _listen,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Search button
                ElevatedButton(
                  onPressed: _searchWord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 14),
                  ),
                  child: Text("Search",
                      style: GoogleFonts.syne(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 25),

                // Results
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Colors.pinkAccent))
                      : definition.isEmpty
                          ? Center(
                              child: Text(
                                "Type a word to get its meaning ✨",
                                style: GoogleFonts.inter(
                                  color: Colors.grey.shade600,
                                  fontSize: 15,
                                ),
                              ),
                            )
                          : _buildResultCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLangSelector(
      String label, String value, Function(String) onSelect) {
    return GestureDetector(
      onTap: () async {
        final lang = await showModalBottomSheet<String>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _buildLangBottomSheet(),
        );
        if (lang != null) onSelect(lang);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.pink.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: GoogleFonts.syne(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.pink),
          ],
        ),
      ),
    );
  }

  Widget _buildLangBottomSheet() {
    return ListView.builder(
      itemCount: widget.languages.length,
      itemBuilder: (context, index) {
        final lang = widget.languages[index];
        return ListTile(
          title: Text(lang, style: GoogleFonts.syne(fontSize: 16)),
          onTap: () => Navigator.pop(context, lang),
        );
      },
    );
  }

Widget _buildResultCard() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.pink.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.all(18),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word + actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  word,
                  style: GoogleFonts.syne(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.pink),
                    onPressed: () => _copy(word),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.pink),
                    onPressed: () => _speak(word),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.pink),
                    onPressed: () => _share(word),
                  ),
                ],
              ),
            ],
          ),
          if (phonetic.isNotEmpty)
            Text(
              phonetic,
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
          const SizedBox(height: 12),

          Text(
            definition,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),

          if (example.isNotEmpty)
            Text(
              "💡 Example: $example",
              style: GoogleFonts.inter(
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade700,
              ),
            ),

          if (synonyms.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text("🔁 Synonyms:",
                style: GoogleFonts.syne(
                    fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: synonyms.take(5).map((s) {
                return GestureDetector(
                  onTap: () {
                    // When tapped → search that synonym
                    setState(() {
                      _controller.text = s;
                    });
                    _searchWord();
                  },
                  child: Chip(
                    label: Text(s),
                    backgroundColor: Colors.pinkAccent.withOpacity(0.1),
                    labelStyle: GoogleFonts.inter(color: Colors.pink),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    ),
  );
}

}
