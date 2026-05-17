import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _iconController;
  late AnimationController _textController;
  late AnimationController _pulseController;

  late Animation<double> _iconScale;
  late Animation<double> _iconFade;
  late Animation<Offset>  _iconSlide;
  late Animation<double> _titleFade;
  late Animation<Offset>  _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset>  _subtitleSlide;
  late Animation<double> _pulseScale;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.notifications_active_outlined,
      'title': 'Never Miss a Date',
      'subtitle': 'Track all your important expiration dates in one place — IDs, subscriptions, insurance & more.',
      'color': const Color(0xFF6C63FF),
    },
    {
      'icon': Icons.access_time_rounded,
      'title': 'Get Notified Early',
      'subtitle': 'Receive smart reminders before anything expires so you always have time to renew.',
      'color': const Color(0xFF3ECFCF),
    },
    {
      'icon': Icons.check_circle_outline_rounded,
      'title': 'Stay Organized',
      'subtitle': 'Keep everything under control and never deal with the stress of expired documents again.',
      'color': const Color(0xFFFF6B9D),
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _playPageAnimation();
  }

  void _setupAnimations() {
    _iconController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _iconController, curve: Curves.elasticOut));
    _iconFade  = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _iconController, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));
    _iconSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(CurvedAnimation(parent: _iconController, curve: Curves.easeOutCubic));

    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _titleFade    = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _titleSlide   = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(CurvedAnimation(parent: _textController, curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)));
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textController, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));
    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(CurvedAnimation(parent: _textController, curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)));

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  void _playPageAnimation() {
    _iconController.reset();
    _textController.reset();
    _iconController.forward().then((_) => _textController.forward());
  }

  Future<void> _goToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_launched', true); // ✅ الإصلاح: true مش false

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
    } else {
      _goToLogin();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C1340), Color(0xFF9A0EFA)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSkipButton(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) {
                    setState(() => _currentPage = i);
                    _playPageAnimation();
                  },
                  itemCount: _pages.length,
                  itemBuilder: (_, i) => _buildPage(_pages[i]),
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 20, 0),
        child: GestureDetector(
          onTap: _goToLogin,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Skip', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _iconFade,
            child: SlideTransition(
              position: _iconSlide,
              child: ScaleTransition(
                scale: _iconScale,
                child: AnimatedBuilder(
                  animation: _pulseScale,
                  builder: (_, child) => Transform.scale(scale: _pulseScale.value, child: child),
                  child: Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.15), blurRadius: 30, spreadRadius: 10)],
                    ),
                    child: Center(
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                        child: Icon(page['icon'] as IconData, color: Colors.white, size: 48),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          FadeTransition(
            opacity: _titleFade,
            child: SlideTransition(
              position: _titleSlide,
              child: Text(page['title'], textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.2)),
            ),
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _subtitleFade,
            child: SlideTransition(
              position: _subtitleSlide,
              child: Text(page['subtitle'], textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15, height: 1.6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    final isLast = _currentPage == _pages.length - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (i) {
              final isActive = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _nextPage,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child)),
              child: isLast
                  ? Container(
                key: const ValueKey('getstarted'),
                width: double.infinity, height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: const Center(
                  child: Text('Get Started', style: TextStyle(color: Color(0xFF361250), fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              )
                  : Container(
                key: const ValueKey('next'),
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: const Center(child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF361250), size: 24)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}