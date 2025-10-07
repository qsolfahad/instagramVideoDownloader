import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translatify/main.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
    void initState() {
    super.initState();
    // Navigate to HomeScreen after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  HomeScreen()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 241, 243), // or your preferred background color
      body: Center(
        child: Container(
           decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Name
               Spacer(),
              Image.asset(
                'assets/Frame.png',
                width: 150,
              ),
              SizedBox(height: 20),
               Text(
                'Translatify',
                style: GoogleFonts.syne(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black, // or your preferred color
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tagline
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Learn 100+ languages with easily curated lessons & techniques.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.syne(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              
             
              Spacer(),
              // Powered by section
            Image.asset(
                'assets/companyLogo.png',
                height: 40,
              ),
               const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}