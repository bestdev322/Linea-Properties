import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_gate.dart';

const Color primaryOrange = Colors.orange;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/img1.png',
      title: 'Built on Trust',
      description:
          'Every deal is backed by verified users, transparent profiles, and mutual ratings',
    ),
    OnboardingPage(
      image: 'assets/img2.png',
      title: 'Secure Escrow Payments',
      description:
          'Secure payments with built-in escrow protection. Your money is safe until you\'re satisfied',
    ),
    OnboardingPage(
      image: 'assets/img3.png',
      title: 'Real-Time Experience',
      description:
          'From instant reservations to QR confirmations, everything happens seamlessly and in real-time',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // last page -> complete onboarding
      _completeOnboarding();
    }
  }

  void _skipToLogin() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image (changes with page)
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_pages[index].image),
                    fit: BoxFit.cover,
                    colorFilter:
                        ColorFilter.mode(Colors.black26, BlendMode.darken),
                  ),
                ),
              );
            },
          ),
          // Content overlay
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pages[_currentPage].title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _pages[_currentPage].description,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 30),
                // Page Indicator (dots)
                Row(
                  children: List.generate(_pages.length, (index) {
                    bool isActive = index == _currentPage;
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: isActive ? 24 : 8,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isActive ? primaryOrange : Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _skipToLogin,
                      child: const Text(
                        "Skip",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _nextPage,
                      child: Row(
                        children: [
                          Text(
                            _currentPage == _pages.length - 1 ? "Start" : "Next ",
                            style: const TextStyle(color: Colors.white),
                          ),
                          if (_currentPage != _pages.length - 1)
                            const Icon(Icons.arrow_forward_ios,
                                size: 14, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String description;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });
}
