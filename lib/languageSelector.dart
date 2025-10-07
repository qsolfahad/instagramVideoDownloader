import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSelectorPage extends StatefulWidget {
  final List<String> languages;
  final String selectedLang;
  final String title;

  const LanguageSelectorPage({
    Key? key,
    required this.languages,
    required this.selectedLang,
    required this.title,
  }) : super(key: key);

  @override
  State<LanguageSelectorPage> createState() => _LanguageSelectorPageState();
}

class _LanguageSelectorPageState extends State<LanguageSelectorPage> {
  final TextEditingController _searchController = TextEditingController();
  late String _selectedLang;
  List<String> filteredLanguages = [];

  @override
  void initState() {
    super.initState();
    _selectedLang = widget.selectedLang;
    filteredLanguages = widget.languages;
  }

  void _filterLanguages(String query) {
    setState(() {
      filteredLanguages = widget.languages
          .where((lang) => lang.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f5f6),
      
      body: Column(
        children: [
             Container(
              padding: const EdgeInsets.only(top: 40, left: 16,  bottom: 12),
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
                Text('Select Language',
                      style: GoogleFonts.syne(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),),              SizedBox(width: 30,)
                ],
              ),
            ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterLanguages,
                cursorColor: Colors.pink,
                decoration: InputDecoration(
                  hintText: 'Search language...',
                  hintStyle: GoogleFonts.syne(
                    color: Colors.grey.shade500,
                    fontSize: 15,
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.pink, size: 22),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredLanguages.length,
              itemBuilder: (context, index) {
                final lang = filteredLanguages[index];
                final isSelected = lang == _selectedLang;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedLang = lang);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.pink.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            isSelected ? Colors.pink : Colors.grey.shade300,
                        width: isSelected ? 1.3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        lang,
                        style: GoogleFonts.syne(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.pink,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(5),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      /// ✅ Confirm Button (visible only when user selects a language)
      bottomNavigationBar: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _selectedLang.isNotEmpty ? 80 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: _selectedLang.isNotEmpty
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context, _selectedLang);
                  },
                  child: Text(
                    "Confirm",
                    style: GoogleFonts.syne(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
