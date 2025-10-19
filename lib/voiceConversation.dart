import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translatify/languageSelector.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:clipboard/clipboard.dart';
import 'package:permission_handler/permission_handler.dart';



class VoiceTranslationScreen extends StatefulWidget {
    final String fromLang;
  final String toLang;
  final List<String> languages;
  final Map<String, String> langCodes;
  VoiceTranslationScreen({
    required this.fromLang,
    required this.toLang,
    required this.languages,
    required this.langCodes,
  });
  @override
  _VoiceTranslationScreenState createState() => _VoiceTranslationScreenState();
}

class _VoiceTranslationScreenState extends State<VoiceTranslationScreen>  with SingleTickerProviderStateMixin {
  final translator = GoogleTranslator();
  final tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  late String _fromLang;
  late String _toLang;
  late AnimationController _micAnim;
  String _inputText = '';
  String _translatedText = '';
  bool _isListening = false;

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
  @override
  void initState() {
    super.initState();
         _fromLang = widget.fromLang;
      _toLang = widget.toLang;
    _initPermissions();
      _micAnim =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
  }

  Future<void> _initPermissions() async {
    await Permission.microphone.request();
    
  }
@override
  void dispose() {
    _micAnim.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        // use language code for localeId (e.g. 'en' or 'en_US') instead of the display name
        localeId: widget.langCodes[_fromLang]?.replaceAll('-', '_'),
        onResult: (result) async {
          setState(() => _inputText = result.recognizedWords);
          final translation = await translator.translate(
            _inputText,
            from: widget.langCodes[_fromLang]!.split('-')[0],
            to: widget.langCodes[_toLang]!.split('-')[0],
          );
          setState(() => _translatedText = translation.text);
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _swapLanguages() {
    setState(() {
      final temp = _fromLang;
      _fromLang = _toLang;
      _toLang = temp;
    });
      // Re-translate the current input using the new language pair
      _translateInput();
  }

  void _speakTranslation() async {
    // ensure we pass the language code (e.g. 'en' or 'en-US') to TTS
    final langCode = widget.langCodes[_toLang]?.split('-')[0];
    if (langCode != null) {
      await tts.setLanguage(langCode);
    }
    await tts.speak(_translatedText);
  }

  Future<void> _translateInput() async {
    if (_inputText.trim().isEmpty) return;
    try {
      final translation = await translator.translate(
        _inputText,
        from: widget.langCodes[_fromLang]!.split('-')[0],
        to: widget.langCodes[_toLang]!.split('-')[0],
      );
      setState(() => _translatedText = translation.text);
    } catch (e) {
      // ignore translation errors silently for now or show a snackbar if desired
    }
  }

  void _copyTranslation() {
    FlutterClipboard.copy(_translatedText).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied to clipboard')),
      );
    });
  }

  // Widget _buildLanguageDropdown(
  //     String currentValue, ValueChanged<String?> onChanged) {
  //   return DropdownButton<String>(
  //     value: currentValue,
  //     isExpanded: true,
  //     underline: SizedBox(),
  //     items: languageMap.entries.map((entry) {
  //       return DropdownMenuItem<String>(
  //         value: entry.key,
  //         child: Text(entry.value),
  //       );
  //     }).toList(),
  //     onChanged: onChanged,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF6F9),
      body: SafeArea(
        child: Stack(
          children: [
            /// ✅ Main Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                    Container(
              padding: const EdgeInsets.only(top: 20,   bottom: 12),
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
                Text('Voice Translation ',
                      style: GoogleFonts.syne(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),),              SizedBox(width: 30,)
                ],
              ),
            ),
                  SizedBox(height: 16),

                  // Language dropdowns
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   padding: EdgeInsets.all(8),
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //         child: _buildLanguageDropdown(
                  //             _fromLang, (val) => setState(() => _fromLang = val!)),
                  //       ),
                  //       Icon(Icons.swap_horiz, color: Colors.grey),
                  //       Expanded(
                  //         child: _buildLanguageDropdown(
                  //             _toLang, (val) => setState(() => _toLang = val!)),
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
          selectedLang: _fromLang,
          title: 'Select To Language',
        ),
      ),
    );
    if (selected != null) {
      setState(() => _fromLang = selected);
      // re-translate current input with new language
      _translateInput();
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
          _fromLang,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Image.asset(
              'assets/change.png',
              width: 20,
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
          selectedLang: _toLang,
          title: 'Select To Language',
        ),
      ),
    );
    if (selected != null) {
      setState(() => _toLang = selected);
      // re-translate current input with new language
      _translateInput();
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
          _toLang,
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
                  SizedBox(height: 16),

                  // Input text
                  Container(
                    padding: EdgeInsets.all(12),
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.topLeft,
                    child: Text(
                      _inputText.isEmpty ? 'Speak something...' : _inputText,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),

                  SizedBox(height: 8),

                  // Translated section
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                            // Text(
                            //   widget.langCodes[_toLang] ?? 'Translation',
                            //   style: TextStyle(fontWeight: FontWeight.bold),
                            // ),
                            // SizedBox(height: 8),
                         
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text(
                                langFlags[widget.langCodes[_toLang]!.split('-')[0]] ?? '🌐',
                                style: TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  " "+_translatedText,
                                  style: TextStyle(fontSize: 16),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.volume_up, color: Colors.pink),
                              onPressed: _speakTranslation,
                            ),
                            IconButton(
                              icon: Icon(Icons.copy, color: Colors.pink),
                              onPressed: _copyTranslation,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  Spacer(),

                  // Mic button with hold functionality
                  GestureDetector(
                    onLongPressStart: (_) => _startListening(),
                    onLongPressEnd: (_) => _stopListening(),
                    child: Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening ? Colors.red : Colors.pink,
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                   SizedBox(height: 24),
                  Text(
                    'Hold to Speak',
                    style: TextStyle(color: Colors.black54),
                  ),

                  SizedBox(height: 24),
                ],
              ),
            ),

            /// ✅ Blur background while listening
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
                          child: const Icon(Icons.mic,
                              color: Colors.white, size: 100),
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
