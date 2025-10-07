import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MoreScreen extends StatefulWidget {
  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String appVersion = "1.0.0";

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  void _shareApp(BuildContext context) {
    // Show bottom sheet for share options
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Share Translatify",
              style: GoogleFonts.syne(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Share this amazing translation app with your friends!",
                textAlign: TextAlign.center,
                style: GoogleFonts.syne(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Cancel", style: GoogleFonts.syne()),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showShareSuccess(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Share", style: GoogleFonts.syne(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showShareSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Share intent launched!", style: GoogleFonts.syne()),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _rateApp(BuildContext context) {
    // Navigate to rate screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RateAppScreen(),
      ),
    );
  }

  void _showFeedback(BuildContext context) {
    // Navigate to feedback screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackScreen(appVersion: appVersion),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    // Navigate to privacy policy screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrivacyPolicyScreen(),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    // Navigate to about screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AboutScreen(appVersion: appVersion),
      ),
    );
  }

void _contactSupport(BuildContext context) async {
  final String email = 'fahad.nexifylab@gmail.com';
  final String subject = 'Translatify Support Request';
  final String body = 'Hello Translatify Support Team,\n\nI need assistance with:';
  
  final String emailUrl = 'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
  
  try {
     await launchUrl(Uri.parse(emailUrl));
   
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to open email app", style: GoogleFonts.syne()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Modern Header
            Container(
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
              child: Row(
                children: [
                  // GestureDetector(
                  //   onTap: () => Navigator.pop(context),
                  //   child: Container(
                  //     width: 40,
                  //     height: 40,
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       shape: BoxShape.circle,
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black.withOpacity(0.1),
                  //           blurRadius: 8,
                  //           offset: const Offset(0, 2),
                  //         ),
                  //       ],
                  //     ),
                  //     child: Icon(Icons.arrow_back_rounded, color: Colors.pink),
                  //   ),
                  // ),
                  Spacer(),
                  Text(
                    'Settings',
                    style: GoogleFonts.syne(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Spacer(),
                 // Image.asset('assets/logo.png', height: 32),
                ],
              ),
            ),

            // Settings Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Profile Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.pink.shade50, Colors.blue.shade50],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Image.asset('assets/logo.png', height: 30),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Translatify',
                                  style: GoogleFonts.syne(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Language Translator',
                                  style: GoogleFonts.syne(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'v$appVersion',
                                    style: GoogleFonts.syne(
                                      fontSize: 12,
                                      color: Colors.pink,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32),

                    // Settings Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildSettingCard(
                          icon: Icons.share_rounded,
                          title: 'Share App',
                          color: Colors.blue,
                          onTap: () => _shareApp(context),
                        ),
                        _buildSettingCard(
                          icon: Icons.star_rounded,
                          title: 'Rate App',
                          color: Colors.amber,
                          onTap: () => _rateApp(context),
                        ),
                        _buildSettingCard(
                          icon: Icons.feedback_rounded,
                          title: 'Feedback',
                          color: Colors.green,
                          onTap: () => _showFeedback(context),
                        ),
                        _buildSettingCard(
                          icon: Icons.privacy_tip_rounded,
                          title: 'Privacy',
                          color: Colors.purple,
                          onTap: () => _showPrivacyPolicy(context),
                        ),
                        _buildSettingCard(
                          icon: Icons.info_rounded,
                          title: 'About',
                          color: Colors.orange,
                          onTap: () => _showAbout(context),
                        ),
                        _buildSettingCard(
                          icon: Icons.support_rounded,
                          title: 'Support',
                          color: Colors.red,
                          onTap: () => _contactSupport(context),
                        ),
                      ],
                    ),

                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.syne(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modern Screens for each feature

class RateAppScreen extends StatefulWidget {
  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  int _selectedRating = 0;
  bool _isHovering = false;
  int _hoverIndex = -1;

  void _sendRatingEmail(int rating, String? feedback) async {
    final String email = 'fahad.nexifylab@gmail.com';
    final String subject = 'Translatify App Rating - $rating Stars';
    
    String body = 'User Rating: $rating/5 stars\n\n';
    if (feedback != null && feedback.isNotEmpty) {
      body += 'Additional Feedback:\n$feedback\n\n';
    }
    body += 'Submitted on: ${DateTime.now().toString()}';
    
   final String emailUrl = 'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
    final Uri emailLaunchUri = Uri.parse(emailUrl);
    
    try {
        await launchUrl(emailLaunchUri);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Thank you for your rating!", style: GoogleFonts.syne()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
     
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send rating", style: GoogleFonts.syne()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Additional Feedback",
              style: GoogleFonts.syne(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Would you like to share any additional comments?",
              style: GoogleFonts.syne(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: feedbackController,
              decoration: InputDecoration(
                hintText: "Your comments (optional)...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              maxLines: 4,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _sendRatingEmail(_selectedRating, null);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Skip", style: GoogleFonts.syne()),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _sendRatingEmail(_selectedRating, feedbackController.text.trim());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Send Rating", style: GoogleFonts.syne(color: Colors.white)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getRatingMessage(int rating) {
    switch (rating) {
      case 1:
        return "We're sorry to hear that. What can we improve?";
      case 2:
        return "We'd love to make Translatify better for you.";
      case 3:
        return "We're glad you're enjoying Translatify!";
      case 4:
        return "Great! We're happy you like Translatify!";
      case 5:
        return "Excellent! Thank you for loving Translatify!";
      default:
        return "Your rating helps us improve and reach more people.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(context, "Rate App"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(_selectedRating > 0 ? 0.3 : 0.1),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        size: 80,
                        color: _selectedRating > 0 ? Colors.amber : Colors.amber.shade200,
                      ),
                    ),
                    SizedBox(height: 32),
                    Text(
                      _selectedRating > 0 ? "You rated us $_selectedRating stars" : "Enjoying Translatify?",
                      style: GoogleFonts.syne(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      _selectedRating > 0 ? _getRatingMessage(_selectedRating) : "Your rating helps us improve and reach more people who need translation help.",
                      style: GoogleFonts.syne(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    MouseRegion(
                      onEnter: (_) => setState(() => _isHovering = true),
                      onExit: (_) => setState(() {
                        _isHovering = false;
                        _hoverIndex = -1;
                      }),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starIndex = index + 1;
                          return MouseRegion(
                            onHover: (_) => setState(() => _hoverIndex = starIndex),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedRating = starIndex),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  Icons.star_rounded,
                                  size: 48,
                                  color: _getStarColor(starIndex),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 40),
                    if (_selectedRating > 0) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showFeedbackDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _selectedRating >= 4 ? "Send Awesome Rating" : "Send Rating & Feedback",
                            style: GoogleFonts.syne(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Maybe Later", style: GoogleFonts.syne(color: Colors.grey)),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please select a rating first", style: GoogleFonts.syne()),
                                backgroundColor: Colors.orange,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text("Rate Now", style: GoogleFonts.syne(color: Colors.grey.shade600, fontSize: 16)),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Maybe Later", style: GoogleFonts.syne(color: Colors.grey)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStarColor(int starIndex) {
    if (_isHovering && starIndex <= _hoverIndex) {
      return Colors.amber.shade400;
    }
    if (starIndex <= _selectedRating) {
      return Colors.amber;
    }
    return Colors.grey.shade300;
  }
}


class FeedbackScreen extends StatefulWidget {
  final String appVersion;

  const FeedbackScreen({required this.appVersion});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(context, "Feedback"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "We'd love to hear from you!",
                      style: GoogleFonts.syne(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Your feedback helps us make Translatify better.",
                      style: GoogleFonts.syne(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 32),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Tell us what you think...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_controller.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please enter your feedback", style: GoogleFonts.syne()),
                                backgroundColor: Colors.pink,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          _sendFeedbackEmail(_controller.text.trim(), context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text("Send Feedback", style: GoogleFonts.syne(color: Colors.white, fontSize: 16)),
                      ),
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

  void _sendFeedbackEmail(String feedback, BuildContext context) async {
    final String email = 'fahad.nexifylab@gmail.com';
    final String subject = 'Translatify Feedback - v${widget.appVersion}';
    final String body = feedback;
   final String emailUrl = 'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
    
    try {
      await launchUrl(Uri.parse(emailUrl.toString()));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Opening email app...", style: GoogleFonts.syne()),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to open email app", style: GoogleFonts.syne()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(context, "Privacy Policy"),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Privacy Matters",
                      style: GoogleFonts.syne(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    _buildPrivacyPoint(
                      "Data Protection",
                      "We respect your privacy and are committed to protecting your personal data.",
                    ),
                    _buildPrivacyPoint(
                      "Translation Data",
                      "Translatify only processes text and voice data for translation purposes in real-time.",
                    ),
                    _buildPrivacyPoint(
                      "No Storage",
                      "We do not store your personal conversations, translations, or any sensitive data.",
                    ),
                    _buildPrivacyPoint(
                      "Local Processing",
                      "Camera translations are processed locally when possible to maximize your privacy.",
                    ),
                    _buildPrivacyPoint(
                      "Transparency",
                      "We believe in being transparent about how we handle your data.",
                    ),
                    SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.security_rounded, size: 40, color: Colors.blue),
                          SizedBox(height: 12),
                          Text(
                            "Your data is safe with us",
                            style: GoogleFonts.syne(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildPrivacyPoint(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.syne(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.syne(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  final String appVersion;

  const AboutScreen({required this.appVersion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(context, "About"),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset('assets/logo.png', height: 50),
                    ),
                    SizedBox(height: 24),
                    Text(
                      "Translatify",
                      style: GoogleFonts.syne(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Your Ultimate Language Companion",
                      style: GoogleFonts.syne(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "Version $appVersion",
                        style: GoogleFonts.syne(
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    ..._buildFeatureList(),
                    SizedBox(height: 32),
                    Text(
                      "Developed with ❤️ using Flutter",
                      style: GoogleFonts.syne(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
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

  List<Widget> _buildFeatureList() {
    final features = [
      {"icon": Icons.translate_rounded, "text": "Real-time Translation"},
      {"icon": Icons.mic_rounded, "text": "Voice Conversations"},
      {"icon": Icons.camera_alt_rounded, "text": "Camera Translation"},
      {"icon": Icons.auto_awesome_rounded, "text": "AI Dictionary"},
      {"icon": Icons.spellcheck_rounded, "text": "Spelling Checker"},
    ];

    return features.map((feature) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(feature["icon"] as IconData, color: Colors.pink),
            SizedBox(width: 16),
            Text(
              feature["text"] as String,
              style: GoogleFonts.syne(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

Widget _buildAppBar(BuildContext context, String title) {
  return Container(
    padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Back button aligned to the left
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Image.asset('assets/back.png', height: 40),
          ),
        ),
        // Title centered
        Text(
          title,
          style: GoogleFonts.syne(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}