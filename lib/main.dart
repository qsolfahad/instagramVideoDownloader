import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translatify/aiDictionary.dart';
import 'package:translatify/camera.dart';
import 'package:translatify/conversation.dart';
import 'package:translatify/languageSelector.dart';
import 'package:translatify/setting.dart';
import 'package:translatify/spelling.dart';
import 'package:translatify/splash_screen.dart';
import 'package:translatify/translation.dart';
import 'package:translatify/voiceConversation.dart';

void main() async {
   await dotenv.load(fileName: "assets/.env");
   runApp(TranslatorApp());
}

class TranslatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language Translator',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.pink,
        highlightColor: Colors.pink.shade100, // used for text selection etc.
        splashColor: Colors.pink.shade200,    // ripple color on tap
        hoverColor: Colors.pink.shade100,     // hover color on web
        focusColor: Colors.pink.shade300,     // for focused fields
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.pink,
          selectionColor: Colors.pink.shade200,
          selectionHandleColor: Colors.pink,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.pink,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: SplashScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

 Map<String, String> langCodes = {
  "Afrikaans": "af",
  "Albanian": "sq",
  "Amharic": "am",
  "Arabic": "ar",
  "Armenian": "hy",
  "Azerbaijani": "az",
  "Basque": "eu",
  "Belarusian": "be",
  "Bengali": "bn",
  "Bosnian": "bs",
  "Bulgarian": "bg",
  "Catalan": "ca",
  "Cebuano": "ceb",
  // "Chinese (Simplified)": "zh-CN",
  // "Chinese (Traditional)": "zh-TW",
  "Corsican": "co",
  "Croatian": "hr",
  "Czech": "cs",
  "Danish": "da",
  "Dutch": "nl",
  "English": "en",
  "Esperanto": "eo",
  "Estonian": "et",
  "Filipino": "tl",
  "Finnish": "fi",
  "French": "fr",
  "Frisian": "fy",
  "Galician": "gl",
  "Georgian": "ka",
  "German": "de",
  "Greek": "el",
  "Gujarati": "gu",
  "Haitian Creole": "ht",
  "Hausa": "ha",
  "Hawaiian": "haw",
  "Hebrew": "he",
  "Hindi": "hi",
  "Hmong": "hmn",
  "Hungarian": "hu",
  "Icelandic": "is",
  "Igbo": "ig",
  "Indonesian": "id",
  "Irish": "ga",
  "Italian": "it",
  "Japanese": "ja",
  "Javanese": "jv",
  "Kannada": "kn",
  "Kazakh": "kk",
  "Khmer": "km",
  "Kinyarwanda": "rw",
  "Korean": "ko",
  "Kurdish": "ku",
  "Kyrgyz": "ky",
  "Lao": "lo",
  "Latin": "la",
  "Latvian": "lv",
  "Lithuanian": "lt",
  "Luxembourgish": "lb",
  "Macedonian": "mk",
  "Malagasy": "mg",
  "Malay": "ms",
  "Malayalam": "ml",
  "Maltese": "mt",
  "Maori": "mi",
  "Marathi": "mr",
  "Mongolian": "mn",
  "Myanmar (Burmese)": "my",
  "Nepali": "ne",
  "Norwegian": "no",
  "Nyanja (Chichewa)": "ny",
  "Odia (Oriya)": "or",
  "Pashto": "ps",
  "Persian": "fa",
  "Polish": "pl",
  "Portuguese": "pt",
  "Punjabi": "pa",
  "Romanian": "ro",
  "Russian": "ru",
  "Samoan": "sm",
  "Scots Gaelic": "gd",
  "Serbian": "sr",
  "Sesotho": "st",
  "Shona": "sn",
  "Sindhi": "sd",
  "Sinhala": "si",
  "Slovak": "sk",
  "Slovenian": "sl",
  "Somali": "so",
  "Spanish": "es",
  "Sundanese": "su",
  "Swahili": "sw",
  "Swedish": "sv",
  "Tagalog (Filipino)": "tl",
  "Tajik": "tg",
  "Tamil": "ta",
  "Tatar": "tt",
  "Telugu": "te",
  "Thai": "th",
  "Turkish": "tr",
  "Turkmen": "tk",
  "Ukrainian": "uk",
  "Urdu": "ur",
  "Uyghur": "ug",
  "Uzbek": "uz",
  "Vietnamese": "vi",
  "Welsh": "cy",
  "Xhosa": "xh",
  "Yiddish": "yi",
  "Yoruba": "yo",
  "Zulu": "zu",
};
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(),
      CameraTranslateScreen(
          fromLang: (context.findAncestorStateOfType<_HomeContentState>()?.fromLang ?? "English"),
            toLang: (context.findAncestorStateOfType<_HomeContentState>()?.toLang ?? "French"),
            languages: langCodes.keys.toList(),
            langCodes: langCodes,
        ),
      MoreScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
      icon: ImageIcon(AssetImage('assets/home.png')),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: ImageIcon(AssetImage('assets/camera.png')),
      label: 'Camera',
    ),
    BottomNavigationBarItem(
      icon: ImageIcon(AssetImage('assets/setting.png')),
      label: 'Setting',
    ),
        ],
      ),
    );
  }
}

/// ---------------------- HOME CONTENT ----------------------
class HomeContent extends StatefulWidget {
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String fromLang = 'English';
  String toLang = 'French';



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // ---------------------- FIXED HEADER ----------------------
            Container(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/logo.png', height: 30),
                  RichText(
                    text: TextSpan(
                      text: 'Language ',
                      style: GoogleFonts.syne(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: 'Translator',
                          style: GoogleFonts.syne(color: Colors.pink),
                        ),
                      ],
                    ),
                  ),
                SizedBox(width: 30,)
                ],
              ),
            ),

            // ---------------------- SCROLLABLE BODY ----------------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Language selector
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
                          Row(
                            children: [
                    
                               Expanded(
            child: GestureDetector(
  onTap: () async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LanguageSelectorPage(
          languages: langCodes.keys.toList(),
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
                                child: Image.asset('assets/change.png',width: 20,),
                              ),
                                Expanded(
            child:GestureDetector(
  onTap: () async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LanguageSelectorPage(
          languages: langCodes.keys.toList(),
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

                    // Input box
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TranslationPage(
                              fromLang: fromLang,
                              toLang: toLang,
                              languages: langCodes.keys.toList(),
                              langCodes: langCodes,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 160,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                           border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                             Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Enter text...',
                                style: GoogleFonts.syne(color: Colors.grey,fontWeight: FontWeight.w700),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Image.asset('assets/copy.png',width: 20,),
                            ),
                          ],
                        ),
                      ),
                    ),
                        ],
                      ),
                    ),

                   

                    // Grid buttons
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        buildGridButton('assets/conversation.png', 'Conversation'),
                        buildGridButton('assets/voice.png', 'Voice Translation'),
                        buildGridButton('assets/spellcheck.png', 'Spelling Checker'),
                        buildGridButton('assets/dictionary.png', 'AI Dictionary'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGridButton(String imagePath, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          if (label == 'Conversation') {
            Navigator.push(context,
                MaterialPageRoute(builder: (e) => ConversationScreen(  fromLang: fromLang,
                              toLang: toLang, languages: langCodes.keys.toList(),
                              langCodes: langCodes,)));
          } else if (label == 'Voice Translation') {
            Navigator.push(context,
                MaterialPageRoute(builder: (e) => VoiceTranslationScreen(
                      fromLang: fromLang,
                                toLang: toLang,
                                languages: langCodes.keys.toList(),
                                langCodes: langCodes,
                )));
          } else if (label == 'Spelling Checker') {
            Navigator.push(context,
                MaterialPageRoute(builder: (e) => SpellCheckerScreen()));
          } else if (label == 'AI Dictionary') {
            Navigator.push(context,
                MaterialPageRoute(builder: (e) => AiDictionaryScreen(
                  languages: langCodes.keys.toList(),
                )));
          }
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(imagePath,width: 26,),
              const SizedBox(height: 8),
              Text(
                label,
                style:  GoogleFonts.syne(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------- MORE SCREEN ----------------------
