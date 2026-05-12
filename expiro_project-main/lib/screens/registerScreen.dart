import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homeScreen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey                  = GlobalKey<FormState>();
  final _nameController           = TextEditingController();
  final _emailController          = TextEditingController();
  final _passwordController       = TextEditingController();
  final _confirmPasswordController= TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _isLoading       = false;

  late AnimationController _topCtrl;
  late AnimationController _cardCtrl;
  late AnimationController _fieldsCtrl;
  late AnimationController _buttonCtrl;

  late Animation<double> _topFade;
  late Animation<Offset>  _topSlide;
  late Animation<double> _cardFade;
  late Animation<Offset>  _cardSlide;
  late List<Animation<double>> _fieldFades;
  late List<Animation<Offset>>  _fieldSlides;
  late Animation<double> _buttonFade;
  late Animation<Offset>  _buttonSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _playSequence();
  }

  void _setupAnimations() {

    _topCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _topFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _topCtrl,  curve: Curves.easeOut));
    _topSlide = Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _topCtrl, curve: Curves.easeOutCubic));


    _cardCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _cardFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _cardCtrl,  curve: Curves.easeOut));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));

    _fieldsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fieldFades  = [];
    _fieldSlides = [];
    for (int i = 0; i < 4; i++) {
      final s = i * 0.17, e = (s + 0.48).clamp(0.0, 1.0);
      _fieldFades.add(Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _fieldsCtrl, curve: Interval(s, e, curve: Curves.easeOut))));
      _fieldSlides.add(Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _fieldsCtrl, curve: Interval(s, e, curve: Curves.easeOutCubic))));
    }

    _buttonCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _buttonFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _buttonCtrl,  curve: Curves.easeOut));
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _buttonCtrl, curve: Curves.easeOutCubic));
  }

  Future<void> _playSequence() async {
    await _topCtrl.forward();
    _cardCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _fieldsCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _buttonCtrl.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _topCtrl.dispose();
    _cardCtrl.dispose();
    _fieldsCtrl.dispose();
    _buttonCtrl.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your name';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(v.trim())) return 'Please enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter a password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name',  _nameController.text.trim());
    await prefs.setString('profile_email', _emailController.text.trim());
    await prefs.setBool('is_logged_in', true);

    setState(() => _isLoading = false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
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
            colors: [Color(0xFF271930), Color(0xFF8C0AE5)],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
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
                          Text("Don't have account?",
                              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text('Register to get started',
                              style: TextStyle(color: Colors.white70, fontSize: 15)),
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
                          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
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
                                      _buildLabel('Full Name'),
                                      _buildField(
                                        controller: _nameController,
                                        hint: 'Enter your full name',
                                        icon: Icons.person_outline,
                                        validator: _validateName,
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
                                      _buildLabel('Email'),
                                      _buildField(
                                        controller: _emailController,
                                        hint: 'Enter your email',
                                        icon: Icons.email_outlined,
                                        inputType: TextInputType.emailAddress,
                                        validator: _validateEmail,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              FadeTransition(
                                opacity: _fieldFades[2],
                                child: SlideTransition(
                                  position: _fieldSlides[2],
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Password'),
                                      _buildField(
                                        controller: _passwordController,
                                        hint: 'Enter your password',
                                        icon: Icons.lock_outline,
                                        isPassword: true,
                                        obscure: _obscurePassword,
                                        onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                                        validator: _validatePassword,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              FadeTransition(
                                opacity: _fieldFades[3],
                                child: SlideTransition(
                                  position: _fieldSlides[3],
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Confirm Password'),
                                      _buildField(
                                        controller: _confirmPasswordController,
                                        hint: 'Confirm your password',
                                        icon: Icons.lock_outline,
                                        isPassword: true,
                                        obscure: _obscureConfirm,
                                        onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                        validator: _validateConfirm,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              FadeTransition(
                                opacity: _buttonFade,
                                child: SlideTransition(
                                  position: _buttonSlide,
                                  child: Column(
                                    children: [

                                      GestureDetector(
                                        onTap: _isLoading ? null : _handleRegister,
                                        child: Container(
                                          width: double.infinity,
                                          height: 55,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF281A31), Color(
                                                  0xFF8B0DE7)],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF790FE2).withOpacity(0.4),
                                                blurRadius: 14,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: _isLoading
                                                ? const SizedBox(
                                              width: 22, height: 22,
                                              child: CircularProgressIndicator(
                                                  color: Colors.white, strokeWidth: 2),
                                            )
                                                : const Text('Register',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 24),
                                      _buildDivider(),
                                      const SizedBox(height: 20),
                                      _buildSocialButtons(),
                                      const SizedBox(height: 24),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Already have an account? ',
                                              style: TextStyle(
                                                  color: Colors.white.withOpacity(0.5),
                                                  fontSize: 13)),
                                          TextButton(
                                            onPressed: () => Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                                            ),
                                            child: const Text('Login',
                                                style: TextStyle(
                                                    color: Color(0xFF7A10E4),
                                                    fontWeight: FontWeight.w600)),
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
      ),
    );
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

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword               = false,
    bool obscure                  = false,
    VoidCallback? onToggle,
    TextInputType inputType       = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller:  controller,
      obscureText: obscure,
      keyboardType: inputType,
      validator:   validator,
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
          borderSide: const BorderSide(color: Color(0xFF7C14DA), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 11),
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
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialBtn(Icons.facebook,     const Color(0xFF7B14DF)),
        const SizedBox(width: 16),
        _socialBtn(Icons.g_mobiledata, Color(0xFF7B11DD)),
        const SizedBox(width: 16),
        _socialBtn(Icons.apple,        Color(0xFF7B10E0)),
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