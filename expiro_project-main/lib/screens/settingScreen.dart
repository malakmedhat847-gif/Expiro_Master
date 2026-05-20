import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/items.dart';
import '../service/notification_service.dart';
import '../service/prefs_keys.dart';
import '../state/items_store.dart';
import '../theme/app_colors.dart';

class SettingScreen extends StatelessWidget {
     final List<Item> items;
     final VoidCallback? onClearAll;
     const SettingScreen({super.key, this.items = const [], this.onClearAll});

     @override
     Widget build(BuildContext context) =>
         SettingsScreen(items: items, onClearAll: onClearAll);
}


class SettingsScreen extends StatefulWidget {
     final List<Item> items;
     final VoidCallback? onClearAll;
     const SettingsScreen({super.key, this.items = const [], this.onClearAll});

     @override
     State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {

     bool   _darkMode             = false;
     bool   _notificationsEnabled = true;

     String _selectedUnit  = 'days';
     int    _selectedValue = 3;

     final List<int> _dayValues   = [1, 3, 7];
     final List<int> _monthValues = [1, 3, 6, 10, 12];

     late AnimationController _headerCtrl;
     late AnimationController _sectionsCtrl;
     late Animation<double> _headerFade;
     late Animation<Offset>  _headerSlide;
     late List<Animation<double>> _sectionFades;
     late List<Animation<Offset>>  _sectionSlides;
     late List<Animation<double>> _sectionScales;

     @override
     void initState() {
          super.initState();
          _setupAnimations();
          _loadPrefs();
     }

     void _setupAnimations() {
          _headerCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
          _headerFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));
          _headerSlide = Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero)
              .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

          _sectionsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
          _sectionFades  = []; _sectionSlides = []; _sectionScales = [];
          for (int i = 0; i < 5; i++) {
               final s = i * 0.16, e = (s + 0.50).clamp(0.0, 1.0);
               _sectionFades.add(Tween<double>(begin: 0, end: 1).animate(
                   CurvedAnimation(parent: _sectionsCtrl, curve: Interval(s, e, curve: Curves.easeOut))));
               _sectionSlides.add(Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
                   CurvedAnimation(parent: _sectionsCtrl, curve: Interval(s, e, curve: Curves.easeOutCubic))));
               _sectionScales.add(Tween<double>(begin: 0.94, end: 1.0).animate(
                   CurvedAnimation(parent: _sectionsCtrl, curve: Interval(s, e, curve: Curves.easeOut))));
          }
     }

     Future<void> _loadPrefs() async {
          final prefs  = await SharedPreferences.getInstance();
          final userId = prefs.getString(PrefsKeys.currentUserId) ?? '';
          setState(() {
               _darkMode             = prefs.getBool(PrefsKeys.darkMode)                         ?? false;
               _notificationsEnabled = prefs.getBool(PrefsKeys.notificationsEnabled(userId))    ?? true;
               _selectedUnit         = prefs.getString(PrefsKeys.notifyUnit(userId))             ?? 'days';
               _selectedValue        = prefs.getInt(PrefsKeys.notifyValue(userId))               ?? 3;
          });
          _playSequence();
     }

     Future<void> _playSequence() async {
          await _headerCtrl.forward();
          await Future.delayed(const Duration(milliseconds: 60));
          _sectionsCtrl.forward();
     }

     Future<void> _toggleDarkMode(bool val) async {
          setState(() => _darkMode = val);
          MyApp.of(context).setTheme(val);
     }

     Future<void> _toggleNotifications(bool val) async {
          setState(() => _notificationsEnabled = val);
          final store = ItemsScope.read(context);
          await NotificationService().setNotificationsEnabled(val, store.items);
     }

     Future<void> _setNotifyPreference(int value, String unit) async {
          setState(() {
               _selectedValue = value;
               _selectedUnit  = unit;
          });
          final prefs  = await SharedPreferences.getInstance();
          final userId = prefs.getString(PrefsKeys.currentUserId) ?? '';
          await prefs.setInt(PrefsKeys.notifyValue(userId), value);
          await prefs.setString(PrefsKeys.notifyUnit(userId), unit);
          if (_notificationsEnabled) {
               final store = ItemsScope.read(context);
               await NotificationService().rescheduleAll(store.items);
          }
     }

     @override
     void dispose() {
          _headerCtrl.dispose();
          _sectionsCtrl.dispose();
          super.dispose();
     }

     void _showExportDialog() {
          showDialog(
               context: context,
               builder: (_) => AlertDialog(
                    title: const Text('Export Data'),
                    content: const Text('Your data has been exported successfully.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
               ),
          );
     }

     Future<void> _sendTestNotification() async {
          await NotificationService().sendTestNotification();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                    content: const Row(children: [
                         Icon(Icons.flash_on, color: Colors.white, size: 18),
                         SizedBox(width: 10),
                         Text('Instant test sent — check now!',
                             style: TextStyle(color: Colors.white, fontSize: 13)),
                    ]),
                    backgroundColor: AppColors.teal,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 4),
               ),
          );
     }

     Future<void> _sendScheduledTest() async {
          await NotificationService().sendScheduledTestNotification();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                    content: const Row(children: [
                         Icon(Icons.schedule, color: Colors.white, size: 18),
                         SizedBox(width: 10),
                         Text('Scheduled → 10 sec, exit app!',
                             style: TextStyle(color: Colors.white, fontSize: 13)),
                    ]),
                    backgroundColor: AppColors.purple,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 5),
               ),
          );
     }

     void _showClearDialog() {
          final c     = AppColors.of(context);
          final store = ItemsScope.read(context);

          showDialog(
               context: context,
               builder: (_) => AlertDialog(
                    backgroundColor: c.card,
                    shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(16),
                         side: BorderSide(color: AppColors.teal.withOpacity(0.3)),
                    ),
                    title: Text('Clear All Items',
                        style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold)),
                    content: Text(
                         'Are you sure you want to delete all ${store.totalCount} items? This cannot be undone.',
                         style: TextStyle(color: c.textSecondary),
                    ),
                    actions: [
                         TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel', style: TextStyle(color: c.textSecondary)),
                         ),
                         TextButton(
                              onPressed: () async {
                                   Navigator.pop(context);
                                   await store.clearAll();
                                   widget.onClearAll?.call();
                                   if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                             SnackBar(
                                                  content: const Text('All items cleared'),
                                                  backgroundColor: AppColors.red,
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                             ),
                                        );
                                   }
                              },
                              style: TextButton.styleFrom(foregroundColor: AppColors.red),
                              child: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.bold)),
                         ),
                    ],
               ),
          );
     }

     Widget _animated(int i, Widget child) => FadeTransition(
          opacity: _sectionFades[i],
          child: SlideTransition(
               position: _sectionSlides[i],
               child: ScaleTransition(scale: _sectionScales[i], child: child),
          ),
     );

     @override
     Widget build(BuildContext context) {
          final c      = AppColors.of(context);
          final isDark = c.isDark;

          return Scaffold(
               backgroundColor: c.scaffold,
               body: Container(
                    decoration: !isDark ? const BoxDecoration(
                         gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFD4CDCD), Color(0xFFD3CCCC)],
                         ),
                    ) : null,
                    child: SafeArea(
                         child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                        FadeTransition(
                                             opacity: _headerFade,
                                             child: SlideTransition(
                                                  position: _headerSlide,
                                                  child: Row(
                                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                       crossAxisAlignment: CrossAxisAlignment.start,
                                                       children: [
                                                            Column(
                                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                                 children: [
                                                                      Text('Settings',
                                                                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: c.textPrimary)),
                                                                      const SizedBox(height: 4),
                                                                      Text('Customize your experience',
                                                                          style: TextStyle(fontSize: 14, color: c.textSecondary)),
                                                                 ],
                                                            ),
                                                            Image.asset(
                                                                 'assets/images/1Artboard 1.png',
                                                                 height: 60,
                                                                 fit: BoxFit.contain,
                                                            ),
                                                       ],
                                                  ),
                                             ),
                                        ),

                                        const SizedBox(height: 24),

                                        _animated(0, _SectionCard(
                                             c: c,
                                             header: _sectionHeader(c, Icons.wb_sunny_outlined, 'Appearance'),
                                             children: [
                                                  _SettingsTile(
                                                       c: c,
                                                       title: 'Dark Mode',
                                                       subtitle: 'Switch between light and dark themes',
                                                       trailing: Switch(
                                                            value: _darkMode,
                                                            onChanged: _toggleDarkMode,
                                                            activeColor: Colors.white,
                                                            activeTrackColor: const Color(0xFF7715D1),
                                                            inactiveThumbColor: const Color(0xFF7615D0),
                                                            inactiveTrackColor: isDark ? Colors.red : const Color(0xFF462265),
                                                       ),
                                                  ),
                                             ],
                                        )),

                                        const SizedBox(height: 16),

                                        _animated(1, _SectionCard(
                                             c: c,
                                             header: _sectionHeader(c, Icons.notifications_outlined, 'Notifications'),
                                             children: [
                                                  _SettingsTile(
                                                       c: c,
                                                       title: 'Enable Notifications',
                                                       subtitle: 'Get notified about expiring items',
                                                       trailing: Switch(
                                                            value: _notificationsEnabled,
                                                            onChanged: _toggleNotifications,
                                                            activeColor: Colors.white,
                                                            activeTrackColor: const Color(0xFF7615D0),
                                                            inactiveThumbColor: const Color(0xFF7515CF),
                                                            inactiveTrackColor: isDark ? const Color(0xFF3F3F47) : const Color(0xFF462265),
                                                       ),
                                                  ),
                                                  Divider(height: 1, color: c.divider),
                                                  _buildReminderPicker(c, isDark),
                                                  Divider(height: 1, color: c.divider),
                                                  Padding(
                                                       padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                                                       child: _ActionButton(
                                                            c: c,
                                                            icon: Icons.flash_on_outlined,
                                                            label: 'Test Instant Notification',
                                                            onTap: _sendTestNotification,
                                                       ),
                                                  ),
                                                  Padding(
                                                       padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                                       child: _ActionButton(
                                                            c: c,
                                                            icon: Icons.schedule_outlined,
                                                            label: 'Test Scheduled (10 sec)',
                                                            onTap: _sendScheduledTest,
                                                       ),
                                                  ),
                                             ],
                                        )),

                                        const SizedBox(height: 16),

                                        _animated(2, _SectionCard(
                                             c: c,
                                             header: _sectionHeader(c, Icons.download_outlined, 'Data Management'),
                                             children: [
                                                  Padding(
                                                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                       child: Column(
                                                            children: [
                                                                 _ActionButton(c: c, icon: Icons.download_outlined, label: 'Export Data',     onTap: _showExportDialog),
                                                                 const SizedBox(height: 10),
                                                                 _ActionButton(c: c, icon: Icons.delete_outline,    label: 'Clear All Items', onTap: _showClearDialog, isDestructive: true),
                                                            ],
                                                       ),
                                                  ),
                                             ],
                                        )),

                                        const SizedBox(height: 16),

                                        _animated(3, _SectionCard(
                                             c: c,
                                             header: _sectionHeader(c, Icons.info_outline, 'About'),
                                             children: [
                                                  _InfoRow(c: c, label: 'Version', value: '1.0.0'),
                                                  Divider(height: 1, color: c.divider),
                                                  _InfoRow(c: c, label: 'Storage', value: 'Local Device'),
                                             ],
                                        )),

                                        const SizedBox(height: 16),

                                        _animated(4, Container(
                                             padding: const EdgeInsets.all(16),
                                             decoration: BoxDecoration(
                                                  color: isDark ? const Color(0xFF281C30) : Colors.white,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: AppColors.teal.withOpacity(isDark ? 1.0 : 1.0)),
                                             ),
                                             child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                       Container(
                                                            padding: const EdgeInsets.all(8),
                                                            decoration: BoxDecoration(
                                                                 color: AppColors.purple.withOpacity(0.15),
                                                                 borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: const Icon(Icons.info_outline, size: 18, color: Color(0xFF3ECECE)),
                                                       ),
                                                       const SizedBox(width: 12),
                                                       Expanded(
                                                            child: Column(
                                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                                 children: [
                                                                      Text('Your data is stored locally',
                                                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                                                                      const SizedBox(height: 4),
                                                                      Text(
                                                                           'All your items are saved on your device. Export your data regularly to keep a backup.',
                                                                           style: TextStyle(fontSize: 13, color: c.textSecondary, height: 1.4),
                                                                      ),
                                                                 ],
                                                            ),
                                                       ),
                                                  ],
                                             ),
                                        )),

                                        const SizedBox(height: 24),
                                   ],
                              ),
                         ),
                    ),
               ),
          );
     }


     Widget _buildReminderPicker(AppColors c, bool isDark) {
          final values = _selectedUnit == 'days' ? _dayValues : _monthValues;

          return Padding(
               padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
               child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                         Text(
                              'Remind me before expiry',
                              style: TextStyle(
                                   fontSize: 15,
                                   fontWeight: FontWeight.w500,
                                   color: c.textPrimary,
                              ),
                         ),
                         const SizedBox(height: 4),
                         Text(
                              'Choose how early you want to be notified',
                              style: TextStyle(fontSize: 12, color: c.textSecondary),
                         ),
                         const SizedBox(height: 14),

                         Container(
                              height: 40,
                              decoration: BoxDecoration(
                                   color: isDark ? const Color(0xFF0E0828) : c.filterBg,
                                   borderRadius: BorderRadius.circular(12),
                                   border: Border.all(color: AppColors.teal.withOpacity(0.3)),
                              ),
                              child: Row(
                                   children: ['days', 'months'].map((unit) {
                                        final active = _selectedUnit == unit;
                                        return Expanded(
                                             child: GestureDetector(
                                                  onTap: () {
                                                       final defaultVal = unit == 'days' ? 3 : 1;
                                                       _setNotifyPreference(defaultVal, unit);
                                                  },
                                                  child: AnimatedContainer(
                                                       duration: const Duration(milliseconds: 220),
                                                       margin: const EdgeInsets.all(4),
                                                       decoration: BoxDecoration(
                                                            color: active ? const Color(0xFF7515CF) : Colors.transparent,
                                                            borderRadius: BorderRadius.circular(8),
                                                            boxShadow: active
                                                                ? [BoxShadow(
                                                                 color: AppColors.purple.withOpacity(0.35),
                                                                 blurRadius: 6,
                                                            )]
                                                                : [],
                                                       ),
                                                       child: Center(
                                                            child: Text(
                                                                 unit == 'days' ? '📅  Days' : '🗓  Months',
                                                                 style: TextStyle(
                                                                      fontSize: 13,
                                                                      fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                                                                      color: active ? Colors.white : c.textSecondary,
                                                                 ),
                                                            ),
                                                       ),
                                                  ),
                                             ),
                                        );
                                   }).toList(),
                              ),
                         ),

                         const SizedBox(height: 14),

                         AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(opacity: anim, child: child),
                              child: Wrap(
                                   key: ValueKey(_selectedUnit),
                                   spacing: 8,
                                   runSpacing: 8,
                                   children: values.map((val) {
                                        final active = _selectedValue == val;
                                        final label  = _selectedUnit == 'days'
                                            ? (val == 1 ? '1 day'   : '$val days')
                                            : (val == 1 ? '1 month' : '$val months');

                                        return GestureDetector(
                                             onTap: () => _setNotifyPreference(val, _selectedUnit),
                                             child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 180),
                                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                                                  decoration: BoxDecoration(
                                                       color: active
                                                           ? AppColors.teal.withOpacity(isDark ? 0.18 : 0.10)
                                                           : (isDark
                                                           ? const Color(0xFF0A0A14)
                                                           : Colors.white),
                                                       borderRadius: BorderRadius.circular(24),
                                                       border: Border.all(
                                                            color: active
                                                                ? AppColors.teal
                                                                : AppColors.teal.withOpacity(0.3),
                                                            width: active ? 1.8 : 1.0,
                                                       ),
                                                       boxShadow: active
                                                           ? [BoxShadow(
                                                            color: AppColors.teal.withOpacity(0.2),
                                                            blurRadius: 8,
                                                       )]
                                                           : [],
                                                  ),
                                                  child: Text(
                                                       label,
                                                       style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                                            color: active ? AppColors.teal : c.textSecondary,
                                                       ),
                                                  ),
                                             ),
                                        );
                                   }).toList(),
                              ),
                         ),
                    ],
               ),
          );
     }

     Widget _sectionHeader(AppColors c, IconData icon, String title) {
          return Row(
               children: [
                    Container(
                         padding: const EdgeInsets.all(6),
                         decoration: BoxDecoration(
                              color: AppColors.purple.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                         ),
                         child: Icon(icon, size: 18, color: AppColors.teal),
                    ),
                    const SizedBox(width: 10),
                    Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: c.textPrimary)),
               ],
          );
     }
}


class _SectionCard extends StatelessWidget {
     final AppColors c;
     final Widget header;
     final List<Widget> children;
     const _SectionCard({required this.c, required this.header, required this.children});

     @override
     Widget build(BuildContext context) {
          final isDark = c.isDark;
          return Container(
               decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF261B2E) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.teal.withOpacity(isDark ? 1.0 : 1.0), width: isDark ? 1.8 : 2.0),
                    boxShadow: [BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                        blurRadius: 6, offset: const Offset(0, 2))],
               ),
               child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                         Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: header),
                         Divider(height: 1, color: c.divider),
                         ...children,
                    ],
               ),
          );
     }
}

class _SettingsTile extends StatelessWidget {
     final AppColors c;
     final String title;
     final String subtitle;
     final Widget trailing;
     const _SettingsTile({required this.c, required this.title, required this.subtitle, required this.trailing});

     @override
     Widget build(BuildContext context) {
          return Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
               child: Row(
                    children: [
                         Expanded(
                              child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                        Text(title,    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: c.textPrimary)),
                                        const SizedBox(height: 2),
                                        Text(subtitle, style: TextStyle(fontSize: 13, color: c.textSecondary)),
                                   ],
                              ),
                         ),
                         trailing,
                    ],
               ),
          );
     }
}

class _ActionButton extends StatefulWidget {
     final AppColors c;
     final IconData icon;
     final String label;
     final VoidCallback onTap;
     final bool isDestructive;
     const _ActionButton({required this.c, required this.icon, required this.label, required this.onTap, this.isDestructive = false});

     @override
     State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
     late AnimationController _ctrl;
     late Animation<double> _scale;

     @override
     void initState() {
          super.initState();
          _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
          _scale = Tween<double>(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
     }

     @override
     void dispose() { _ctrl.dispose(); super.dispose(); }

     @override
     Widget build(BuildContext context) {
          final isDark = widget.c.isDark;
          final color  = widget.isDestructive ? AppColors.red : widget.c.textPrimary;
          return GestureDetector(
               onTapDown:   (_) => _ctrl.forward(),
               onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
               onTapCancel: () => _ctrl.reverse(),
               child: ScaleTransition(
                    scale: _scale,
                    child: Container(
                         width: double.infinity,
                         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                         decoration: BoxDecoration(
                              color: widget.isDestructive
                                  ? AppColors.red.withOpacity(isDark ? 0.08 : 0.06)
                                  : Colors.transparent,
                              border: Border.all(
                                  color: widget.isDestructive ? AppColors.red.withOpacity(0.5) : AppColors.teal.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(10),
                         ),
                         child: Row(
                              children: [
                                   Icon(widget.icon, size: 20, color: color),
                                   const SizedBox(width: 10),
                                   Text(widget.label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
                              ],
                         ),
                    ),
               ),
          );
     }
}

class _InfoRow extends StatelessWidget {
     final AppColors c;
     final String label;
     final String value;
     const _InfoRow({required this.c, required this.label, required this.value});

     @override
     Widget build(BuildContext context) {
          return Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
               child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                         Text(label, style: TextStyle(fontSize: 15, color: c.textSecondary)),
                         Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: c.textPrimary)),
                    ],
               ),
          );
     }
}