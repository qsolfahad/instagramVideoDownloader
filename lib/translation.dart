import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // for Clipboard
import 'package:translatify/languageSelector.dart';
import 'package:translator/translator.dart'; // ✅ import translator

class TranslationPage extends StatefulWidget {
  final String fromLang;
  final String toLang;
  final List<String> languages;
  final Map<String, String> langCodes;

  const TranslationPage({
    required this.fromLang,
    required this.toLang,
    required this.languages,
    required this.langCodes,
    Key? key,
  }) : super(key: key);

  @override
  _TranslationPageState createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  late String fromLang;
  late String toLang;
  final TextEditingController _textController = TextEditingController();
bool _isTranslating = false;
  final GoogleTranslator _translator = GoogleTranslator(); // ✅ Translator instance
  String _translatedText = ""; // ✅ To store translated result

  final FlutterTts _flutterTts = FlutterTts(); // ✅ TTS instance

  @override
  void initState() {
    super.initState();
    fromLang = widget.fromLang;
    toLang = widget.toLang;
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage(widget.langCodes[toLang] ?? "en");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  Future<void> _translateText() async {
  if (_textController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter text to translate")),
    );
    return;
  }

  setState(() => _isTranslating = true);

  try {
    final translation = await _translator.translate(
      _textController.text,
      from: widget.langCodes[fromLang] ?? 'auto',
      to: widget.langCodes[toLang] ?? 'en',
    );

    setState(() {
      _translatedText = translation.text;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Translation failed: $e")),
    );
  } finally {
    setState(() => _isTranslating = false);
  }
}
Widget translationLoader() {
  return const SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ Allows body to resize when keyboard opens
    
      body:Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120), // leave space for button
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Container(
              padding: const EdgeInsets.only(top: 40,   bottom: 12),
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
                Text('Translation ',
                      style: GoogleFonts.syne(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),),              SizedBox(width: 30,)
                ],
              ),
            ),
           
              Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.grey.shade300,
    ),
    color: Colors.white,
  ),
  child: Column(
    children: [
      // Language Dropdown Row
      Row(
        children: [
          Expanded(
            child: GestureDetector(
  onTap: () async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LanguageSelectorPage(
          languages: widget.languages,
          selectedLang: fromLang,
          title: 'Select From Language',
        ),
      ),
    );
    if (selected != null) {
      setState(() => fromLang = selected);
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
          fromLang,
          style: GoogleFonts.syne(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
            maxLines: 1, // ✅ only one line
  overflow: TextOverflow.ellipsis, 
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
          selectedLang: toLang,
          title: 'Select To Language',
        ),
      ),
    );
    if (selected != null) {
      setState(() => toLang = selected);
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
          toLang,
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

      const SizedBox(height: 12),

      // Input Box (styled as tappable to navigate)
     Container(
          height: 200,
         
          child: Stack(
            children: [
            TextField(
                      controller: _textController,
                      maxLines: 12,
                       textInputAction: TextInputAction.done, // ✅ Show "done" instead of newline
                        onSubmitted: (_) => _translateText(),
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: 'Enter text...',
                        hintStyle: GoogleFonts.syne(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color:  Colors.grey.shade300,),
                        ),
                        contentPadding:
                            const EdgeInsets.fromLTRB(12, 12, 100, 12),
                      ),
                    ),
                  
                  Positioned(
                    right: 8,
                    top: 0,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.paste, color: Colors.grey),
                          onPressed: () async {
                            final data =
                                await Clipboard.getData('text/plain');
                            if (data != null) {
                              _textController.text = data.text ?? '';
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.grey),
                          onPressed: () {
                            if (_textController.text.isNotEmpty) {
                              Clipboard.setData(
                                ClipboardData(text: _textController.text),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Copied to clipboard"),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      
    ],
  ),
),

              const SizedBox(height: 16),
      
              // Translation result
              if (_translatedText.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Translation",
                            style: GoogleFonts.syne(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.volume_up,
                                    color: Colors.pink),
                                onPressed: () => _speak(_translatedText),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy,
                                    color: Colors.pink),
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: _translatedText));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Copied translation")),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _translatedText,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ),  bottomNavigationBar: SafeArea(
        child: Container(
          color: const Color.fromARGB(255, 245, 234, 236),
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _translateText,
              child: GestureDetector(
                
            onTap: _isTranslating ? null : _translateText,
  child: _isTranslating
      ? translationLoader()
      : const Text(
          'Translate',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
),

            ),
          ),
        ),
      ),
    );
  }
}
