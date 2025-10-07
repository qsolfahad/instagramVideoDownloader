  import 'dart:io';
  import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:image_picker/image_picker.dart';
  import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:share_plus/share_plus.dart';
import 'package:translatify/languageSelector.dart';
  import 'package:translator/translator.dart';

  class CameraTranslateScreen extends StatefulWidget {
    final String fromLang;
    final String toLang;
    final List<String> languages;
    final Map<String, String> langCodes;
    
    CameraTranslateScreen({
      Key? key, 
      required this.fromLang, 
      required this.toLang, 
      required this.languages, 
      required this.langCodes
    }) : super(key: key);

    @override
    State<CameraTranslateScreen> createState() => _CameraTranslateScreenState();
  }

  class _CameraTranslateScreenState extends State<CameraTranslateScreen> {
    final translator = GoogleTranslator();
    late String _fromLang;
    late String _toLang;

    bool showOriginal = true;
    File? imageFile;
    String extractedText = "";
    String translatedText = "";
    bool isTranslating = false;
    final ScrollController _scrollController = ScrollController();

    @override
    void initState() {
      super.initState();
      print(widget.languages);
      _fromLang = widget.fromLang;
      _toLang = widget.toLang;
    }
  Row _buildBubbleActions(String? text, Color iconColor, String? langCode) {
    return Row(children: [
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
    ]);
  }
   final FlutterTts _tts = FlutterTts();
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
  Future<void> _stop() async {
  await _tts.stop();
}
    Future<void> _pickImage(ImageSource source) async {
     
      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path);
          extractedText = "";
          translatedText = "";
        });

        _processImage(File(pickedFile.path));
      }
    }

    Future<void> _processImage(File image) async {
      final textRecognizer = TextRecognizer();
      final inputImage = InputImage.fromFile(image);
      final RecognizedText recognisedText = 
          await textRecognizer.processImage(inputImage);

      setState(() {
        extractedText = recognisedText.text;
      });
 setState(() {
        showOriginal = true;
      });
      await textRecognizer.close();
    }

    Future<void> _translateText() async {
      if (extractedText.isEmpty) return;
      
      setState(() {
        isTranslating = true;
      });
      
      try {
        final translation = await translator.translate(
          extractedText,
          from: widget.langCodes[_fromLang] ?? '',
          to: widget.langCodes[_toLang] ?? '',
        );

        setState(() {
          translatedText = translation.text;
          isTranslating = false;
          showOriginal = false;
        });
        
        // Scroll to top after translation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      } catch (e) {
        setState(() {
          translatedText = "Translation failed. Please try again.";
          isTranslating = false;
        });
      }
    }



    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 10),
              
            
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Camera Translation',
                  style: GoogleFonts.syne(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
                child: Row(
                        children: [
                    
                             Expanded(
            child: GestureDetector(
  onTap: () async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LanguageSelectorPage(
          languages: widget.languages,
          selectedLang: _fromLang,
          title: 'Select From Language',
        ),
      ),
    );
    if (selected != null) {
      setState(() => _fromLang = selected);
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
          selectedLang: _toLang,
          title: 'Select To Language',
        ),
      ),
    );
    if (selected != null) {
      setState(() => _toLang = selected);
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
              ),
        SizedBox(height: 10),
              // Image preview section
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(imageFile!, fit: BoxFit.contain),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_search, size: 50, color: Colors.grey),
                              SizedBox(height: 10),
                              Text(
                                "Capture or Select an Image",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
        
              // Results section with scrollable text
              if (extractedText.isNotEmpty || translatedText.isNotEmpty)
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Original text section
                              if (extractedText.isNotEmpty && showOriginal)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.text_snippet, size: 18, color: Colors.pink),
                                        SizedBox(width: 5),
                                        Text(
                                          "Original Text ($_fromLang):",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.pink,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: SelectableText(
                                        extractedText,
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    _buildBubbleActions(extractedText, Colors.pink, widget.langCodes[_fromLang]),
                                  ],
                                  
                                ),
                              
                              // Translated text section
                              if (translatedText.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.translate, size: 18, color: Colors.pink),
                                        SizedBox(width: 5),
                                        Text(
                                          "Translation ($_toLang):",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.pink,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.pink[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.pink[100]!),
                                      ),
                                      child: SelectableText(
                                        translatedText,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.pink[800],
                                        ),
                                      ),
                                    ),
                                     _buildBubbleActions(translatedText, Colors.pink, widget.langCodes[_toLang]),
                                  ],
                                ),
                              
                              // Loading indicator for translation
                              if (isTranslating)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Translating...",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  flex: 4,
                  child: Container(),
                ),
        
              // Bottom controls
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.image, color: Colors.pink, size: 28),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                    FloatingActionButton(
                      backgroundColor: Colors.pink,
                      child: Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.pink, size: 28),
                      onPressed: () {
                        setState(() {
                          imageFile = null;
                          extractedText = "";
                          translatedText = "";
                        });
                      },
                    ),
                    // Translate button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: _translateText,
                      icon: Icon(Icons.translate),
                      label: Text("Translate"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }