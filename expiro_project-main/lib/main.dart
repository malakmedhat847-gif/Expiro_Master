import 'package:expiro_project/screens/homeScreen.dart';
import 'package:expiro_project/screens/login_screen.dart';
import 'package:expiro_project/screens/onbording_screen.dart';
import 'package:expiro_project/service/notification_service.dart';
import 'package:expiro_project/service/prefs_keys.dart';
import 'package:expiro_project/state/items_store.dart';
import 'package:expiro_project/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  final ItemsStore _store = ItemsStore();

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  Future<void> _loadTheme() async {
    final prefs  = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(PrefsKeys.darkMode) ?? false;
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.darkMode, isDark);
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return ItemsScope(
      store: _store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        initialRoute: '/',
        routes: {
          '/':           (_) => const SplashScreen(),
          '/onboarding': (_) => const OnboardingScreen(),
          '/login':      (_) => const LoginScreen(),
          '/home':       (_) => const HomeScreen(),
        },

        // ── Light Theme
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF0EEFF),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.light,
            primary: const Color(0xFF6C63FF),
            secondary: const Color(0xFF3ECFCF),
            surface: Colors.white,
            background: const Color(0xFFF0EEFF),
          ),
          useMaterial3: false,
          fontFamily: 'Roboto',
          cardColor: Colors.white,
          dividerColor: const Color(0xFFDDD8F5),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFF3ECFCF),
            unselectedItemColor: Color(0xFF9B93C0),
            elevation: 8,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF5F2FF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFF3ECFCF).withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFF3ECFCF).withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
            ),
          ),
        ),

        // ── Dark Theme
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0A0A14),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.dark,
            primary: const Color(0xFF6C63FF),
            secondary: const Color(0xFF3ECFCF),
            surface: const Color(0xFF1C1040),
            background: const Color(0xFF0A0A14),
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          // Dark purple cards against black bg
          cardColor: const Color(0xFF1C1040),
          dividerColor: const Color(0xFF2A1D50),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF080810),
            selectedItemColor: Color(0xFF3ECFCF),
            unselectedItemColor: Color(0xFF6B6490),
            elevation: 8,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF150D30),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3ECFCF), width: 1.8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3ECFCF), width: 1.8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3ECFCF), width: 2.0),
            ),
          ),
        ),
      ),
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoCtrl;
  late AnimationController _counterCtrl;
  late AnimationController _lineCtrl;
  late AnimationController _loadingCtrl;
  late AnimationController _bgNumbersCtrl;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _lineFade;
  late Animation<double> _lineWidth;
  late Animation<double> _loadingFade;
  late Animation<double> _bgNumbersFade;

  int _counter = 1;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _logoFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));

    _counterCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _counterCtrl.addListener(() {
      final val = (_counterCtrl.value * 100).round().clamp(1, 100);
      if (val != _counter) setState(() => _counter = val);
    });

    _lineCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _lineFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _lineCtrl, curve: Curves.easeOut));
    _lineWidth = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _lineCtrl, curve: Curves.easeOutCubic));

    _loadingCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _loadingFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _loadingCtrl, curve: Curves.easeOut));

    _bgNumbersCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _bgNumbersFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _bgNumbersCtrl, curve: Curves.easeOut));
  }

  Future<void> _startSequence() async {
    _bgNumbersCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _lineCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _loadingCtrl.forward();


    final store = ItemsScope.read(context);
    _counterCtrl.forward();
    await store.load();

    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    _navigate();
  }

  Future<void> _navigate() async {
    final prefs      = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool(PrefsKeys.hasLaunched) ?? false;
    if (!hasLaunched) {
      await prefs.setBool(PrefsKeys.hasLaunched, true);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }
    final isLoggedIn = prefs.getBool(PrefsKeys.isLoggedIn) ?? false;
    if (!mounted) return;
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
    debugPrint('has_launched = $hasLaunched');
    debugPrint('is_logged_in = $isLoggedIn');
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _counterCtrl.dispose();
    _lineCtrl.dispose();
    _loadingCtrl.dispose();
    _bgNumbersCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.6, -0.3),
                radius: 1.2,
                colors: [Color(0xFF6B1FA8), Color(0xFF1A0030), Colors.black],
              ),
            ),
          ),
          Positioned(
            right: -size.width * 0.2,
            top: size.height * 0.1,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFF4A0080).withOpacity(0.5), Colors.transparent],
                ),
              ),
            ),
          ),
          FadeTransition(
            opacity: _bgNumbersFade,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Stack(
                children: [
                  Positioned(left: -size.width * 0.08, top: size.height * 0.05,    child: _buildBgNumber('5')),
                  Positioned(right: -size.width * 0.04, top: size.height * 0.04,   child: _buildBgNumber('12')),
                  Positioned(right: -size.width * 0.05, top: size.height * 0.45,   child: _buildBgNumber('12')),
                  Positioned(right: -size.width * 0.05, bottom: size.height * 0.05, child: _buildBgNumber('12')),
                  Positioned(left: -size.width * 0.1,  bottom: size.height * 0.1,  child: _buildBgNumber('3')),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        // R  G  B  A  offset
                        1, 0, 0, 0, 0,   // R' = R
                        0, 1, 0, 0, 0,   // G' = G
                        0, 0, 1, 0, 0,   // B' = B
                        // A' = luminance → black(0)=transparent, white(1)=opaque
                        0.2126, 0.7152, 0.0722, 0, 0,
                      ]),
                      child: Image.asset(
                        'assets/images/splash.jpg',
                        width: size.width * 0.65,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _lineFade,
                  child: AnimatedBuilder(
                    animation: _lineWidth,
                    builder: (_, __) => Container(
                      width: size.width * 0.65 * _lineWidth.value,
                      height: 1.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.transparent,
                          AppColors.teal.withOpacity(0.8),
                          AppColors.teal,
                          AppColors.teal.withOpacity(0.8),
                          Colors.transparent,
                        ]),
                        boxShadow: [BoxShadow(color: AppColors.teal.withOpacity(0.6), blurRadius: 12, spreadRadius: 2)],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                FadeTransition(
                  opacity: _loadingFade,
                  child: Text(
                    _counter.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 4),
                  ),
                ),
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: _loadingFade,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('جاري التحميل',
                          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      _PulsingDot(),
                      const SizedBox(width: 8),
                      Text('Loading',
                          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500, letterSpacing: 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBgNumber(String number) {
    return Text(number,
        style: TextStyle(fontSize: 200, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.07), height: 1));
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.6, end: 1.2).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 8, height: 8,
        decoration: BoxDecoration(
          color: AppColors.teal,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.teal.withOpacity(0.6), blurRadius: 6, spreadRadius: 1)],
        ),
      ),
    );
  }
}