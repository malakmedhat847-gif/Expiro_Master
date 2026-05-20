import 'package:expiro_project/screens/homeScreen.dart';
import 'package:expiro_project/screens/registerScreen.dart';
import 'package:expiro_project/service/prefs_keys.dart';
import 'package:expiro_project/state/items_store.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey            = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading       = false;


  late AnimationController _topController;
  late AnimationController _cardController;
  late AnimationController _fieldsController;
  late AnimationController _buttonController;

  late Animation<double> _topFade;
  late Animation<Offset> _topSlide;

  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  late List<Animation<double>> _fieldFades;
  late List<Animation<Offset>> _fieldSlides;

  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _playSequence();
  }

  void _setupAnimations() {

    _topController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _topFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _topController, curve: Curves.easeOut));
    _topSlide =
        Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero).animate(
            CurvedAnimation(parent: _topController, curve: Curves.easeOutCubic));

    _cardController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _cardController, curve: Curves.easeOut));
    _cardSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
            CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic));

    _fieldsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fieldFades  = [];
    _fieldSlides = [];
    for (int i = 0; i < 4; i++) {
      final start = i * 0.18;
      final end   = (start + 0.50).clamp(0.0, 1.0);
      _fieldFades.add(Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: _fieldsController,
          curve: Interval(start, end, curve: Curves.easeOut))));
      _fieldSlides.add(
          Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
              CurvedAnimation(
                  parent: _fieldsController,
                  curve: Interval(start, end, curve: Curves.easeOutCubic))));
    }

    _buttonController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _buttonFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _buttonController, curve: Curves.easeOut));
    _buttonSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _buttonController, curve: Curves.easeOutCubic));
  }

  Future<void> _playSequence() async {
    await _topController.forward();
    _cardController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _fieldsController.forward();
    await Future.delayed(const Duration(milliseconds: 350));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _topController.dispose();
    _cardController.dispose();
    _fieldsController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validate fields
    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email');
      return;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      _showError('Please enter a valid email');
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showError('Please enter your password');
      return;
    }
    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    final email = _emailController.text.trim();
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();

    // 1. Identify the user FIRST so all subsequent namespaced writes are correct.
    await prefs.setString(PrefsKeys.currentUserId, email);
    await prefs.setBool(PrefsKeys.isLoggedIn, true);

    // 2. Save profile under this user's namespace.
    await prefs.setString(PrefsKeys.profileEmail(email), email);
    final existingName = prefs.getString(PrefsKeys.profileName(email)) ?? '';
    if (existingName.isEmpty || existingName == 'Your Name') {
      final namePart = email.contains('@') ? email.split('@')[0] : email;
      await prefs.setString(PrefsKeys.profileName(email), namePart);
    }

    // 3. Reset in-memory store state, then load data for this user.
    if (mounted) {
      final store = ItemsScope.read(context);
      store.clearInMemory();
      await store.load();
    }

    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF271930), Color(0xFF9B07FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _topFade,
                child: SlideTransition(
                  position: _topSlide,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(28, 32, 28, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome Back 👋',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text('Login to your account',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: FadeTransition(
                  opacity: _cardFade,
                  child: SlideTransition(
                    position: _cardSlide,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF000000),
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: SingleChildScrollView(
                        padding:
                        const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            FadeTransition(
                              opacity: _fieldFades[0],
                              child: SlideTransition(
                                position: _fieldSlides[0],
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Email'),
                                    _buildTextField(
                                      controller: _emailController,
                                      hint: 'Enter your email',
                                      icon: Icons.email_outlined,
                                      inputType: TextInputType.emailAddress,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            FadeTransition(
                              opacity: _fieldFades[1],
                              child: SlideTransition(
                                position: _fieldSlides[1],
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Password'),
                                    _buildTextField(
                                      controller: _passwordController,
                                      hint: 'Enter your password',
                                      icon: Icons.lock_outline,
                                      isPassword: true,
                                      obscure: _obscurePassword,
                                      onToggle: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            FadeTransition(
                              opacity: _fieldFades[2],
                              child: SlideTransition(
                                position: _fieldSlides[2],
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text('Forgot Password?',style: TextStyle(color: Color(0xFF7322B0)),),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            FadeTransition(
                              opacity: _buttonFade,
                              child: SlideTransition(
                                position: _buttonSlide,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ElevatedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          const Color(0xFF7422B1),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(15)),
                                          elevation: 0,
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                          width: 22, height: 22,
                                          child: CircularProgressIndicator(
                                              color: Colors.white, strokeWidth: 2),
                                        )
                                            : const Text('Login',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ),

                                    const SizedBox(height: 24),
                                    _buildDivider(),
                                    const SizedBox(height: 20),
                                    _buildSocialButtons(),
                                    const SizedBox(height: 24),

                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text("Don't have an account?",
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                fontSize: 13)),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                    const RegisterScreen()),
                                              ),
                                          child: const Text('Register',
                                              style: TextStyle(
                                                  color: Color(0xFF7322B0),
                                                  fontWeight:
                                                  FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFFE53935),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword               = false,
    bool obscure                  = false,
    VoidCallback? onToggle,
    TextInputType inputType       = TextInputType.text,
  }) {
    return TextFormField(
      controller:   controller,
      obscureText:  obscure,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText:  hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.35), size: 20),
        suffixIcon: isPassword
            ? GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.white.withOpacity(0.35), size: 20,
          ),
        )
            : null,
        filled:    true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF7322B0), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('OR',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.3), fontSize: 12)),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialBtn(Icons.facebook,    const Color(0xFF7322B0)),
        const SizedBox(width: 16),
        _socialBtn(Icons.g_mobiledata, Color(0xFF7322B0)),
        const SizedBox(width: 16),
        _socialBtn(Icons.apple,Color(0xFF7322B0)),
      ],
    );
  }

  Widget _socialBtn(IconData icon, Color iconColor) {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Icon(icon, color: iconColor, size: 24),
    );
  }
}