import 'dart:ui'; // for blur
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:translatify/languageSelector.dart';
import 'package:translatify/typingdots.dart';
import 'package:translator/translator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vibration/vibration.dart';

import 'package:openai_dart/openai_dart.dart' hide Image;
import 'package:shared_preferences/shared_preferences.dart';

class ConversationScreen extends StatefulWidget {
  ConversationScreen({Key? key, required this.fromLang, required this.toLang, required this.languages, required this.langCodes}) : super(key: key);
  String fromLang;
  String toLang;
  final List<String> languages;
  final Map<String, String> langCodes;
  
  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with TickerProviderStateMixin {
  final translator = GoogleTranslator();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  late OpenAIClient _openai;
bool _isLoading = false;
  /// Store chat history
  final List<Map<String, String>> _messages = [];
 late Animation<double> _dotAnimation;
  /// Scroll controller for chat auto-scroll
  final ScrollController _scrollController = ScrollController();

  late AnimationController _micAnim;
  
  // SharedPreferences keys
  static const String _messagesKey = 'conversation_messages';
  static const String _fromLangKey = 'conversation_from_lang';
  static const String _toLangKey = 'conversation_to_lang';
  
  final Map<String, String> langFlags = {
    "af": "🇿🇦", // Afrikaans
    "sq": "🇦🇱", // Albanian
    "am": "🇪🇹", // Amharic
    "ar": "🇸🇦", // Arabic
    "hy": "🇦🇲", // Armenian
    "az": "🇦🇿", // Azerbaijani
    "eu": "🇪🇸", // Basque
    "be": "🇧🇾", // Belarusian
    "bn": "🇧🇩", // Bengali
    "bs": "🇧🇦", // Bosnian
    "bg": "🇧🇬", // Bulgarian
    "ca": "🇪🇸", // Catalan
    "ceb": "🇵🇭", // Cebuano
    "co": "🇫🇷", // Corsican
    "hr": "🇭🇷", // Croatian
    "cs": "🇨🇿", // Czech
    "da": "🇩🇰", // Danish
    "nl": "🇳🇱", // Dutch
    "en": "🇬🇧", // English
    "eo": "🌐", // Esperanto
    "et": "🇪🇪", // Estonian
    "tl": "🇵🇭", // Filipino/Tagalog
    "fi": "🇫🇮", // Finnish
    "fr": "🇫🇷", // French
    "fy": "🇳🇱", // Frisian
    "gl": "🇪🇸", // Galician
    "ka": "🇬🇪", // Georgian
    "de": "🇩🇪", // German
    "el": "🇬🇷", // Greek
    "gu": "🇮🇳", // Gujarati
    "ht": "🇭🇹", // Haitian Creole
    "ha": "🇳🇬", // Hausa
    "haw": "🇺🇸", // Hawaiian
    "he": "🇮🇱", // Hebrew
    "hi": "🇮🇳", // Hindi
    "hmn": "🌐", // Hmong
    "hu": "🇭🇺", // Hungarian
    "is": "🇮🇸", // Icelandic
    "ig": "🇳🇬", // Igbo
    "id": "🇮🇩", // Indonesian
    "ga": "🇮🇪", // Irish
    "it": "🇮🇹", // Italian
    "ja": "🇯🇵", // Japanese
    "jv": "🇮🇩", // Javanese
    "kn": "🇮🇳", // Kannada
    "kk": "🇰🇿", // Kazakh
    "km": "🇰🇭", // Khmer
    "rw": "🇷🇼", // Kinyarwanda
    "ko": "🇰🇷", // Korean
    "ku": "🇮🇶", // Kurdish
    "ky": "🇰🇬", // Kyrgyz
    "lo": "🇱🇦", // Lao
    "la": "🇻🇦", // Latin
    "lv": "🇱🇻", // Latvian
    "lt": "🇱🇹", // Lithuanian
    "lb": "🇱🇺", // Luxembourgish
    "mk": "🇲🇰", // Macedonian
    "mg": "🇲🇬", // Malagasy
    "ms": "🇲🇾", // Malay
    "ml": "🇮🇳", // Malayalam
    "mt": "🇲🇹", // Maltese
    "mi": "🇳🇿", // Maori
    "mr": "🇮🇳", // Marathi
    "mn": "🇲🇳", // Mongolian
    "my": "🇲🇲", // Burmese
    "ne": "🇳🇵", // Nepali
    "no": "🇳🇴", // Norwegian
    "ny": "🇲🇼", // Nyanja/Chichewa
    "or": "🇮🇳", // Odia
    "ps": "🇦🇫", // Pashto
    "fa": "🇮🇷", // Persian
    "pl": "🇵🇱", // Polish
    "pt": "🇵🇹", // Portuguese
    "pa": "🇮🇳", // Punjabi
    "ro": "🇷🇴", // Romanian
    "ru": "🇷🇺", // Russian
    "sm": "🇼🇸", // Samoan
    "gd": "🏴", // Scots Gaelic
    "sr": "🇷🇸", // Serbian
    "st": "🇿🇦", // Sesotho
    "sn": "🇿🇼", // Shona
    "sd": "🇵🇰", // Sindhi
    "si": "🇱🇰", // Sinhala
    "sk": "🇸🇰", // Slovak
    "sl": "🇸🇮", // Slovenian
    "so": "🇸🇴", // Somali
    "es": "🇪🇸", // Spanish
    "su": "🇮🇩", // Sundanese
    "sw": "🇰🇪", // Swahili
    "sv": "🇸🇪", // Swedish
    "tg": "🇹🇯", // Tajik
    "ta": "🇮🇳", // Tamil
    "tt": "🇷🇺", // Tatar
    "te": "🇮🇳", // Telugu
    "th": "🇹🇭", // Thai
    "tr": "🇹🇷", // Turkish
    "tk": "🇹🇲", // Turkmen
    "uk": "🇺🇦", // Ukrainian
    "ur": "🇵🇰", // Urdu
    "ug": "🇨🇳", // Uyghur
    "uz": "🇺🇿", // Uzbek
    "vi": "🇻🇳", // Vietnamese
    "cy": "🏴", // Welsh
    "xh": "🇿🇦", // Xhosa
    "yi": "🇮🇱", // Yiddish
    "yo": "🇳🇬", // Yoruba
    "zu": "🇿🇦", // Zulu
  };
  
  final FlutterTts _tts = FlutterTts();
  
  String getFlag(String langCode) {
    String code = langCode.split('-')[0].toLowerCase();
    return langFlags[code] ?? "🌐"; // fallback if not found
  }
  late AnimationController _dotAnim;
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _micAnim =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _openai = OpenAIClient(
      apiKey: dotenv.env['OPENAI_API_KEY'],
   baseUrl: "https://openrouter.ai/api/v1",
    );
        _dotAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _dotAnimation = Tween<double>(begin: 0, end: 3).animate(_dotAnim);
    // Load saved data
    _loadSavedData();
    
  }

  // Load saved messages and language preferences
  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load language preferences
      final savedFromLang = prefs.getString(_fromLangKey);
      final savedToLang = prefs.getString(_toLangKey);
      
      if (savedFromLang != null && savedToLang != null) {
        setState(() {
          widget.fromLang = savedFromLang;
          widget.toLang = savedToLang;
        });
      }
      
      // Load messages
      final savedMessages = prefs.getStringList(_messagesKey);
      if (savedMessages != null && savedMessages.isNotEmpty) {
        setState(() {
          _messages.clear();
          for (final messageJson in savedMessages) {
            try {
              final messageMap = Map<String, String>.from(json.decode(messageJson));
              _messages.add(messageMap);
            } catch (e) {
              print('Error parsing message: $e');
            }
          }
        });
        
        // Scroll to bottom after loading messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      print('Error loading saved data: $e');
    }
  }

  // Save messages to SharedPreferences
  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messages.map((message) => json.encode(message)).toList();
      await prefs.setStringList(_messagesKey, messagesJson);
    } catch (e) {
      print('Error saving messages: $e');
    }
  }

  // Save language preferences
  Future<void> _saveLanguagePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fromLangKey, widget.fromLang);
      await prefs.setString(_toLangKey, widget.toLang);
    } catch (e) {
      print('Error saving language preferences: $e');
    }
  }

  @override
  void dispose() {
    _micAnim.dispose();
     _dotAnim.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _translate(String input) async {
    if (input.isEmpty) return;
    // Use OpenAI to improve or rephrase the input before translation
   setState(() => _isLoading = true);
    String improvedInput = input;
    try {
     final chat = await _openai.createChatCompletion(
  request: CreateChatCompletionRequest(
    model: ChatCompletionModel.modelId( "gpt-3.5-turbo" ),
    messages: [
      ChatCompletionMessage.system(
        content: "You are a helpful and concise question-answering assistant. Your purpose is to provide clear and accurate answers to user's questions. Do not engage in casual conversation or provide information that isn't directly related to the user's query.",
      ),
      ChatCompletionMessage.user(
        content: ChatCompletionUserMessageContent.string("User's question: " + input),
      ),
    ],
    maxTokens: 100,
    temperature: 0.7,
  ),
);

if (chat.choices.isNotEmpty) {
  improvedInput = chat.choices.first.message?.content?.trim() ?? input;
}
print(
  "Original Input: $input\nImproved Input: $improvedInput"
);
    } catch (e) {
      print("OpenAI error: $e");
    }
    final translation = await translator.translate(
      improvedInput,
      from: widget.langCodes[widget.fromLang]!.split('-')[0], // e.g., "en"
      to: widget.langCodes[widget.toLang]!.split('-')[0], // e.g., "fr"
    );
 

    setState(() {
      _isLoading = false;
      // Save both spoken & translated directly in the chat list
      _messages.add({
        "spoken": input,
        "translated": translation.text,
        "flag": widget.langCodes[widget.toLang]!,
        'toLang': widget.toLang,
        'fromLang': widget.fromLang,
        'flagResponse': widget.langCodes[widget.fromLang]!,
      });
    });

    // Save the updated messages
    _saveMessages();

    // Auto-scroll to bottom
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  Future<void> _speak(String text, String? langCode) async {
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
  
  Color leftBubbleColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade200;

  Color rightBubbleColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Colors.blueGrey.shade700
        : const Color(0xff25D366); // WhatsApp green
  
  List<Widget> _buildBubbleActions(String? text, Color iconColor, String? langCode) {
    return [
      IconButton(
        icon: Icon(Icons.copy, size: 18, color: iconColor),
        onPressed: () => _copy(text ?? ""),
      ),
      IconButton(
        icon: Icon(Icons.volume_up, size: 18, color: iconColor),
        onPressed: () => _speak(text ?? "", langCode),
      ),
      IconButton(
        icon: Icon(Icons.share, size: 18, color: iconColor),
        onPressed: () => _share(text ?? ""),
      ),
    ];
  }
  
  /// Left bubble (received)
  Widget leftBubble(Map<String, String> msg) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55),
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0x14E25896), // transparent pink overlay
                Color(0x14E25896),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              topLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getFlag(msg["flagResponse"] ?? ""),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg["spoken"] ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87, // good contrast on light gradient
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildBubbleActions(msg["spoken"], Colors.black87, msg["toLang"]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Right bubble (sent)
  Widget rightBubble(Map<String, String> msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55),
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0x14E25896), // transparent pink overlay
                Color.fromARGB(19, 88, 120, 226),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      msg["translated"] ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87, // high contrast
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildBubbleActions(msg["translated"], Colors.black87, msg["fromLang"]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                getFlag(msg["flag"] ?? ""),
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _swapLanguages() {
    setState(() {
      final temp = widget.fromLang;
      widget.fromLang = widget.toLang;
      widget.toLang = temp;
    });
    
    // Save the new language preferences
    _saveLanguagePreferences();
  }

  Future<void> _askMicPermission() async {
    var status = await Permission.microphone.request();
    if (status.isDenied) {
      print("Microphone permission denied");
    }
  }

  void _startListening(String lang) async {
    _askMicPermission();
    bool available = await _speech.initialize(
      onStatus: (val) => print("Status: $val"),
      onError: (val) => print("Error: $val"),
    );

    if (available) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100); // small buzz
      }
      setState(() => _isListening = true);

      _speech.listen(
        localeId: widget.langCodes[lang],
        onResult: (val) async {
          if (val.finalResult && val.recognizedWords.isNotEmpty) {
            await _translate(val.recognizedWords); // use words directly
          }
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  // Add a method to clear chat history if needed
  Future<void> _clearChatHistory() async {
    setState(() {
      _messages.clear();
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_messagesKey);
    } catch (e) {
      print('Error clearing chat history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 241, 243),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              /// ---- Main UI ----
              Column(
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Image.asset('assets/back.png', height: 40),
                        ),
                        const Spacer(),
                        const Text(
                          "Conversation",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        // Add a clear button if you want to enable clearing chat history
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: _clearChatHistory,
                          tooltip: "Clear chat history",
                        ),
                      ],
                    ),
                  ),

                  /// Chat Bubbles Area
                  Expanded(
                    child: _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children:  [
                                Image.asset('assets/conversations.png', height: 120),
                                const SizedBox(height: 16),
                                Text(
                                  "Conversation",
                                  style: GoogleFonts.syne(
                                    fontSize: 28,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Pick a language & start having a conversation",
                                  style: GoogleFonts.poppins(color: Colors.black45, fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  /// Spoken bubble (Left - fromLang)
                                  leftBubble(msg),
                                  rightBubble(msg),
                                ],
                              );
                            },
                          )
                  ),
  if (_isLoading)
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55),
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0x14E25896),
                            Color(0x14E25896),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16),
                          topLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: TypingDots(animation: _dotAnimation),
                    ),
                  ),

                  // Bottom Panel
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                             Expanded(
            child:GestureDetector(
  onTap: () async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LanguageSelectorPage(
          languages: widget.languages,
          selectedLang: widget.fromLang,
          title: 'Select To Language',
        ),
      ),
    );
    if (selected != null) {
      setState(() => widget.fromLang = selected);
    }
  },
  child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
 
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.fromLang,
          style: GoogleFonts.syne(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ],
    ),
  ),
),

              ),
            ),
          ),
                            GestureDetector(
                              onTap: _swapLanguages,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Image.asset(
                                  'assets/change.png',
                                  width: 20,
                                ),
                              ),
                            ),
                            Expanded(
            child:GestureDetector(
  onTap: () async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LanguageSelectorPage(
          languages: widget.languages,
          selectedLang: widget.toLang,
          title: 'Select To Language',
        ),
      ),
    );
    if (selected != null) {
      setState(() => widget.toLang = selected);
    }
  },
  child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
 
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.toLang,
          style: GoogleFonts.syne(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ],
    ),
  ),
),

              ),
            ),
          ),
                          ],
                        ),
                        const Divider(thickness: 1, color: Colors.grey),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTapDown: (_) => _startListening(widget.fromLang),
                              onTapUp: (_) => _stopListening(),
                              onTapCancel: () => _stopListening(),
                              child: FloatingActionButton(
                                heroTag: "mic1",
                                backgroundColor: const Color(0xffE25896),
                                child: Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                ),
                                onPressed: () {},
                              ),
                            ),
                            // GestureDetector(
                            //   onTapDown: (_) => _startListening(widget.toLang),
                            //   onTapUp: (_) => _stopListening(),
                            //   onTapCancel: () => _stopListening(),
                            //   child: FloatingActionButton(
                            //     heroTag: "mic2",
                            //     backgroundColor: const Color(0xff78A1D2),
                            //     child: Icon(
                            //       _isListening ? Icons.mic : Icons.mic_none,
                            //     ),
                            //     onPressed: () {},
                            //   ),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                         "Hold to Speak",
                          style: TextStyle(
                            color: _isListening ? Colors.green : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              /// ---- Blur Overlay when listening ----
              if (_isListening)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: ScaleTransition(
                          scale: Tween(begin: 1.0, end: 1.3).animate(
                            CurvedAnimation(
                              parent: _micAnim,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: const Icon(Icons.mic, color: Colors.white, size: 100),
                        ),
                      ),
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