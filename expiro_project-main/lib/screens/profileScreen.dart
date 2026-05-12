import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/items.dart';
import '../state/items_store.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'settingScreen.dart';



class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {

  String _userName       = 'Your Name';
  String _userEmail      = 'your@email.com';
  bool   _loadingProfile = true;

  late AnimationController _headerCtrl;
  late AnimationController _avatarCtrl;
  late AnimationController _statsCtrl;
  late AnimationController _listCtrl;
  late AnimationController _settingsCtrl;

  late Animation<double> _headerFade;
  late Animation<Offset>  _headerSlide;
  late Animation<double> _avatarScale;
  late Animation<double> _avatarFade;
  late List<Animation<double>> _statFades;
  late List<Animation<double>> _statScales;
  late List<Animation<Offset>>  _statSlides;
  late Animation<double> _listFade;
  late Animation<double> _settingsFade;
  late Animation<Offset>  _settingsSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadProfile();
  }

  void _setupAnimations() {
    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _headerFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

    _avatarCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _avatarScale = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _avatarCtrl, curve: Curves.elasticOut));
    _avatarFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _avatarCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));

    _statsCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _statFades  = [];
    _statScales = [];
    _statSlides = [];
    for (int i = 0; i < 2; i++) {
      final s = i * 0.3, e = (s + 0.6).clamp(0.0, 1.0);
      _statFades.add(Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _statsCtrl, curve: Interval(s, e, curve: Curves.easeOut))));
      _statScales.add(Tween<double>(begin: 0.82, end: 1.0).animate(CurvedAnimation(parent: _statsCtrl, curve: Interval(s, e, curve: Curves.easeOutBack))));
      _statSlides.add(Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(CurvedAnimation(parent: _statsCtrl, curve: Interval(s, e, curve: Curves.easeOutCubic))));
    }

    _listCtrl      = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _listFade      = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _listCtrl, curve: Curves.easeOut));
    _settingsCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _settingsFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _settingsCtrl, curve: Curves.easeOut));
    _settingsSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _settingsCtrl, curve: Curves.easeOutCubic));
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName       = prefs.getString('profile_name')  ?? 'Your Name';
      _userEmail      = prefs.getString('profile_email') ?? 'your@email.com';
      _loadingProfile = false;
    });
    _playSequence();
  }

  Future<void> _playSequence() async {
    await _headerCtrl.forward();
    _avatarCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _statsCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 250));
    _listCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _settingsCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _avatarCtrl.dispose();
    _statsCtrl.dispose();
    _listCtrl.dispose();
    _settingsCtrl.dispose();
    super.dispose();
  }

  void _openEditProfile() {
    final nameCtrl  = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(
        nameController:  nameCtrl,
        emailController: emailCtrl,
        onSave: (name, email) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_name',  name);
          await prefs.setString('profile_email', email);
          setState(() { _userName = name; _userEmail = email; });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark = c.isDark;

    final store = ItemsScope.of(context);

    if (_loadingProfile) {
      return Scaffold(
        backgroundColor: c.scaffold,
        body: Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    final totalItems   = store.totalCount;
    final expiringSoon = store.soonCount;

    final soonItems = store.items
        .where((i) => i.status == ItemStatus.soon || i.status == ItemStatus.expired)
        .toList()
      ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));

    final displayItems = soonItems.take(5).toList();

    return Scaffold(
      backgroundColor: c.scaffold,
      body: SingleChildScrollView(
        child: Column(
          children: [

            FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(position: _headerSlide, child: _buildHeader(c)),
            ),

            FadeTransition(
              opacity: _avatarFade,
              child: ScaleTransition(scale: _avatarScale, child: _buildUserInfo(c)),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _animatedStatCard(c, index: 0, value: totalItems,   label: 'All Items',     icon: Icons.notifications_outlined, color: AppColors.red),
                  const SizedBox(width: 7),
                  _animatedStatCard(c, index: 1, value: expiringSoon, label: 'Expiring Soon', icon: Icons.warning_amber_rounded,  color: AppColors.red),
                ],
              ),
            ),


            FadeTransition(
              opacity: _listFade,
              child: _buildExpiringSoonSection(c, displayItems),
            ),

            FadeTransition(
              opacity: _settingsFade,
              child: SlideTransition(position: _settingsSlide, child: _buildSettingsSection(c, store)),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }


  Widget _buildHeader(AppColors c) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: c.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.teal.withOpacity(c.isDark ? 1.0 : 0.9)),
                ),
                child: Icon(Icons.arrow_back_ios_new, color: c.textPrimary, size: 16),
              ),
            ),
            Text('Profile', style: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(width: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [AppColors.purple, AppColors.teal]),
              border: Border.all(color: c.scaffold, width: 3),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 14),
          Text(_userName,  style: TextStyle(color: c.textPrimary,   fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(_userEmail, style: TextStyle(color: c.textSecondary, fontSize: 13)),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _openEditProfile,
            icon: const Icon(Icons.edit_outlined, size: 14, color: AppColors.purple),
            label: const Text('Edit Profile', style: TextStyle(color: AppColors.purple, fontSize: 13)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.purple),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }


  Widget _animatedStatCard(AppColors c, {
    required int index,
    required int value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: FadeTransition(
        opacity: _statFades[index],
        child: SlideTransition(
          position: _statSlides[index],
          child: ScaleTransition(
            scale: _statScales[index],
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.teal.withOpacity(c.isDark ? 1.0 : 1.0)),
                boxShadow: [BoxShadow(color: c.shadow, blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedBuilder(
                        animation: _statsCtrl,
                        builder: (_, __) => Text(
                          '${(_statFades[index].value * value).round()}',
                          style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(label, style: TextStyle(color: c.textSecondary, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpiringSoonSection(AppColors c, List<Item> items) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time_filled, color: AppColors.red, size: 18),
              const SizedBox(width: 5),
              Text('Expiring Soon', style: TextStyle(color: c.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text('See all', style: TextStyle(color: AppColors.purple, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.teal.withOpacity(c.isDark ? 1.0 : 0.9)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.teal, size: 20),
                  const SizedBox(width: 12),
                  Text('All items are fresh!', style: TextStyle(color: c.textSecondary, fontSize: 14)),
                ],
              ),
            )
          else
            ...items.asMap().entries.map((e) => _buildItemTile(c, e.value, e.key)),
        ],
      ),
    );
  }

  Widget _buildItemTile(AppColors c, Item item, int index) {
    final days = item.daysLeft;
    final Color urgencyColor = days < 0 ? AppColors.red
        : days <= 2 ? AppColors.red
        : days <= 5 ? AppColors.orange
        : AppColors.teal;

    final String daysLabel = days < 0    ? 'Expired!'
        : days == 0 ? 'Today!'
        : days == 1 ? '1 day left'
        : '$days days left';

    return TweenAnimationBuilder<double>(
      key: ValueKey(item.id),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 60).clamp(0, 300)),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) =>
          Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: child)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: urgencyColor.withOpacity(0.35)),
          boxShadow: [BoxShadow(color: c.shadow, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: urgencyColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.type.icon, color: urgencyColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,       style: TextStyle(color: c.textPrimary,   fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(item.type.label, style: TextStyle(color: c.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: urgencyColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(daysLabel, style: TextStyle(color: urgencyColor, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(AppColors c, ItemsStore store) {
    final settings = [
      {'icon': Icons.notifications_outlined, 'label': 'Notification Settings', 'color': AppColors.purple},
      {'icon': Icons.palette_outlined,        'label': 'Appearance',            'color': AppColors.teal},
      {'icon': Icons.backup_outlined,         'label': 'Backup & Restore',      'color': AppColors.orange},
      {'icon': Icons.logout,                  'label': 'Log Out',               'color': AppColors.red},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: TextStyle(color: c.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: c.isDark ? const Color(0xFF1C1040) : const Color(0xFFF0EDF8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.teal.withOpacity(c.isDark ? 1.0 : 1.0)),
              boxShadow: [BoxShadow(color: c.shadow, blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: List.generate(settings.length, (i) {
                final isLast = i == settings.length - 1;
                final color  = settings[i]['color'] as Color;
                final label  = settings[i]['label'] as String;
                return Column(
                  children: [
                    _SettingsTileAnimated(
                      c: c,
                      icon:  settings[i]['icon'] as IconData,
                      label: label,
                      color: color,
                      index: i,
                      onTap: () {
                        if (label == 'Log Out') {
                          Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                          );
                        } else {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (_) => SettingsScreen(
                              items: store.items,
                              onClearAll: () => store.clearAll(),
                            )),
                          );
                        }
                      },
                    ),
                    if (!isLast)
                      Divider(height: 1, color: c.divider, indent: 60),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}


class _SettingsTileAnimated extends StatefulWidget {
  final AppColors c;
  final IconData icon;
  final String label;
  final Color color;
  final int index;
  final VoidCallback onTap;

  const _SettingsTileAnimated({
    required this.c,
    required this.icon,
    required this.label,
    required this.color,
    required this.index,
    required this.onTap,
  });

  @override
  State<_SettingsTileAnimated> createState() => _SettingsTileAnimatedState();
}

class _SettingsTileAnimatedState extends State<_SettingsTileAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double>   _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _pressScale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _pressCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isLogout = widget.label == 'Log Out';
    return GestureDetector(
      onTapDown:   (_) => _pressCtrl.forward(),
      onTapUp:     (_) { _pressCtrl.reverse(); widget.onTap(); },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _pressScale,
        child: ListTile(
          leading: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.icon, color: widget.color, size: 18),
          ),
          title: Text(widget.label,
              style: TextStyle(
                color: isLogout ? AppColors.red : widget.c.textPrimary,
                fontSize: 14,
              )),
          trailing: !isLogout
              ? Icon(Icons.chevron_right, color: widget.c.textSecondary, size: 20)
              : null,
        ),
      ),
    );
  }
}



class _EditProfileSheet extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final void Function(String name, String email) onSave;

  const _EditProfileSheet({
    required this.nameController,
    required this.emailController,
    required this.onSave,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _sheetCtrl;
  late Animation<double>   _sheetFade;
  late Animation<Offset>   _sheetSlide;

  @override
  void initState() {
    super.initState();
    _sheetCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _sheetFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOut));
    _sheetSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOutCubic));
    _sheetCtrl.forward();
  }

  @override
  void dispose() { _sheetCtrl.dispose(); super.dispose(); }

  void _save() {
    final name  = widget.nameController.text.trim();
    final email = widget.emailController.text.trim();
    if (name.isEmpty) return;
    widget.onSave(name, email);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c           = AppColors.of(context);
    final isDark      = c.isDark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return FadeTransition(
      opacity: _sheetFade,
      child: SlideTransition(
        position: _sheetSlide,
        child: Container(
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.teal.withOpacity(c.isDark ? 1.0 : 1.0)),
          ),
          padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: c.divider, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Edit Profile', style: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: c.cardAlt, shape: BoxShape.circle),
                      child: Icon(Icons.close, size: 14, color: c.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Name',  style: TextStyle(color: c.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              _buildField(c, widget.nameController,  'Your name',       Icons.person_outline),
              const SizedBox(height: 16),
              Text('Email', style: TextStyle(color: c.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              _buildField(c, widget.emailController, 'your@email.com', Icons.email_outlined,
                  inputType: TextInputType.emailAddress),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Save Changes',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(AppColors c, TextEditingController ctrl, String hint, IconData icon,
      {TextInputType inputType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: c.inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.teal.withOpacity(c.isDark ? 1.0 : 1.0)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: inputType,
        style: TextStyle(color: c.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: c.textHint, fontSize: 14),
          prefixIcon: Icon(icon, color: c.textSecondary, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}