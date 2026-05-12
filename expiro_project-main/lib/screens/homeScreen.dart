import 'package:expiro_project/screens/profileScreen.dart';
import 'package:expiro_project/screens/settingScreen.dart';
import 'package:expiro_project/screens/statsScreen.dart';
import 'package:expiro_project/screens/favorites_screen.dart';
import 'package:expiro_project/state/items_store.dart';
import 'package:expiro_project/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../models/items.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int    _currentIndex  = 0;
  String _filter        = 'All';
  bool   _searchVisible = false;
  String _searchQuery   = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode             _searchFocus      = FocusNode();

  late AnimationController _appBarController;
  late AnimationController _cardsController;
  late AnimationController _filterController;
  late AnimationController _listController;
  late AnimationController _navBarController;
  late AnimationController _searchAnim;

  late Animation<double> _appBarFade;
  late Animation<Offset>  _appBarSlide;
  late List<Animation<double>> _cardFades;
  late List<Animation<double>> _cardScales;
  late List<Animation<Offset>>  _cardSlides;
  late Animation<double> _filterFade;
  late Animation<Offset>  _filterSlide;
  late Animation<double> _listFade;
  late Animation<double> _navBarFade;
  late Animation<Offset>  _navBarSlide;
  late Animation<double> _searchFade;
  late Animation<Offset>  _searchSlide;
  late Animation<double> _searchHeight;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _playEntryAnimation();
  }

  void _setupAnimations() {
    _appBarController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _appBarFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _appBarController, curve: Curves.easeOut));
    _appBarSlide = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(CurvedAnimation(parent: _appBarController, curve: Curves.easeOutCubic));

    _cardsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _cardFades = []; _cardScales = []; _cardSlides = [];
    for (int i = 0; i < 3; i++) {
      final s = i * 0.22, e = (s + 0.55).clamp(0.0, 1.0);
      _cardFades.add(Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _cardsController, curve: Interval(s, e, curve: Curves.easeOut))));
      _cardScales.add(Tween<double>(begin: 0.82, end: 1.0).animate(CurvedAnimation(parent: _cardsController, curve: Interval(s, e, curve: Curves.easeOutBack))));
      _cardSlides.add(Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _cardsController, curve: Interval(s, e, curve: Curves.easeOutCubic))));
    }

    _filterController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _filterFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _filterController, curve: Curves.easeOut));
    _filterSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(CurvedAnimation(parent: _filterController, curve: Curves.easeOutCubic));

    _listController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _listFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _listController, curve: Curves.easeOut));

    _navBarController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _navBarFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _navBarController, curve: Curves.easeOut));
    _navBarSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: _navBarController, curve: Curves.easeOutCubic));

    _searchAnim   = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _searchFade   = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _searchAnim, curve: Curves.easeOut));
    _searchSlide  = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(CurvedAnimation(parent: _searchAnim, curve: Curves.easeOutCubic));
    _searchHeight = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _searchAnim, curve: Curves.easeOutCubic));
  }

  Future<void> _playEntryAnimation() async {
    _appBarController.reset(); _cardsController.reset();
    _filterController.reset(); _listController.reset(); _navBarController.reset();
    await _appBarController.forward();
    _cardsController.forward();
    await Future.delayed(const Duration(milliseconds: 320));
    _filterController.forward();
    await Future.delayed(const Duration(milliseconds: 180));
    _listController.forward();
    await Future.delayed(const Duration(milliseconds: 120));
    _navBarController.forward();
  }

  void _toggleSearch() {
    setState(() => _searchVisible = !_searchVisible);
    if (_searchVisible) {
      _searchAnim.forward();
      Future.delayed(const Duration(milliseconds: 150), () => _searchFocus.requestFocus());
    } else {
      _searchAnim.reverse();
      _searchFocus.unfocus();
      setState(() { _searchQuery = ''; _searchController.clear(); });
    }
  }

  @override
  void dispose() {
    _appBarController.dispose(); _cardsController.dispose();
    _filterController.dispose(); _listController.dispose();
    _navBarController.dispose(); _searchAnim.dispose();
    _searchController.dispose(); _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _handleDelete(BuildContext ctx, int id) async {
    final store   = ItemsScope.read(ctx);
    final deleted = await store.deleteItem(id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${deleted.item.name}" deleted',
            style: const TextStyle(color: Colors.red, fontSize: 14)),
        backgroundColor: const Color(0xFF0A0A14),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.teal.withOpacity(0.4)),
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.red,
          onPressed: () => store.undoDelete(deleted.item, deleted.index),
        ),
      ),
    );
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => AddItemSheet(
        onAdd: (n, t, d, q) => ItemsScope.read(context).addItem(n, t, d, q),
      ),
    );
  }

  void _openEditSheet(Item item) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => EditItemSheet(
        item: item,
        onSave: (name, type, expiry, qty) =>
            ItemsScope.read(context).updateItem(item.id, name, type, expiry, qty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c     = AppColors.of(context);
    final store = ItemsScope.of(context);

    if (store.isLoading) {
      return Scaffold(
        backgroundColor: c.scaffold,
        body: Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    final pages = [
      _buildHome(c, store),
      const StatsScreen(),
      const FavoritesScreen(),
      SettingsScreen(
        onClearAll: () => store.clearAll(),
      ),
    ];

    return Scaffold(
      backgroundColor: c.scaffold,
      body: pages[_currentIndex],
      bottomNavigationBar: SlideTransition(
        position: _navBarSlide,
        child: FadeTransition(
          opacity: _navBarFade,
          child: Container(
            decoration: BoxDecoration(
              color: c.navBg,
              border: Border(top: BorderSide(color: AppColors.teal.withOpacity(0.3), width: 0.5)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              backgroundColor: Colors.transparent,
              selectedItemColor: AppColors.teal,
              unselectedItemColor: c.navUnselected,
              showUnselectedLabels: true,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined),      activeIcon: Icon(Icons.home),      label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined),  activeIcon: Icon(Icons.bar_chart), label: 'Stats'),
                BottomNavigationBarItem(icon: Icon(Icons.favorite_border),     activeIcon: Icon(Icons.favorite),  label: 'Favorites'),
                BottomNavigationBarItem(icon: Icon(Icons.settings_outlined),   activeIcon: Icon(Icons.settings),  label: 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHome(AppColors c, ItemsStore store) {
    final isDark = c.isDark;
    final items  = store.filtered(_filter, _searchQuery);

    return Container(
      decoration: !isDark ? const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD6CFCF), Color(0xFFD5CECE)],
        ),
      ) : null,
      child: SafeArea(
        child: Column(
          children: [
            FadeTransition(
              opacity: _appBarFade,
              child: SlideTransition(
                position: _appBarSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Expiro', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: c.textPrimary)),
                            Text('Never let things go to waste', style: TextStyle(fontSize: 12, color: c.textSecondary)),
                          ],
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: IconButton(
                          key: ValueKey(_searchVisible),
                          icon: Icon(_searchVisible ? Icons.close : Icons.search, color: c.textPrimary),
                          onPressed: _toggleSearch,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.person_outline, color: c.textPrimary),
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ProfilePage())),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizeTransition(
              sizeFactor: _searchHeight,
              axisAlignment: -1,
              child: FadeTransition(
                opacity: _searchFade,
                child: SlideTransition(
                  position: _searchSlide,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1040) : const Color(0xFFF0EDF8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.teal.withOpacity(isDark ? 1.0 : 1.0)),
                        boxShadow: [BoxShadow(color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode:  _searchFocus,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: TextStyle(fontSize: 14, color: c.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search items...',
                          hintStyle: TextStyle(color: c.textHint, fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: c.textHint, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? GestureDetector(
                              onTap: () => setState(() { _searchQuery = ''; _searchController.clear(); }),
                              child: Icon(Icons.cancel, color: c.textHint, size: 18))
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatCard(c, 0, store.totalCount,   'Total Items'),
                  const SizedBox(width: 10),
                  _buildStatCard(c, 1, store.soonCount,    'Expire Soon'),
                  const SizedBox(width: 10),
                  _buildStatCard(c, 2, store.expiredCount, 'Expired'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            if (!_searchVisible)
              FadeTransition(
                opacity: _filterFade,
                child: SlideTransition(
                  position: _filterSlide,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: c.filterBg,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.teal),
                      ),
                      child: Row(
                        children: ['All', 'Expired', 'Soon', 'Fresh'].map((f) {
                          final active = _filter == f;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _filter = f),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: active ? AppColors.purple : Colors.transparent,
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: active
                                      ? [BoxShadow(color: AppColors.purple.withOpacity(0.3), blurRadius: 6)]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(f, style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                                    color: active ? Colors.white : c.textSecondary,
                                  )),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),

            if (!_searchVisible) const SizedBox(height: 10),
            if (_searchVisible)  const SizedBox(height: 4),

            Expanded(
              child: FadeTransition(
                opacity: _listFade,
                child: items.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.filter_alt_outlined,
                          size: 60, color: c.textHint),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No results for "$_searchQuery"'
                            : 'No items yet. Add your first item!',
                        style: TextStyle(color: c.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) => _buildItemCard(c, items[i], i),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: GestureDetector(
                onTap: _openAddSheet,
                child: Container(
                  width: double.infinity, height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF281C30), Color(0xFF4C1D77)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: const Color(0xFF7B3BC5).withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 4))],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Add Item', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(AppColors c, int index, int value, String label) {
    final isDark = c.isDark;
    return Expanded(
      child: FadeTransition(
        opacity: _cardFades[index],
        child: SlideTransition(
          position: _cardSlides[index],
          child: ScaleTransition(
            scale: _cardScales[index],
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                    colors: [Color(0xFF431D60), Color(0xFF441D63)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight)
                    : null,
                color: isDark ? null : const Color(0xFFEBEBF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.teal.withOpacity(isDark ? 1.0 : 1.0), width: isDark ? 1.8 : 2.0),
                boxShadow: isDark
                    ? [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _cardsController,
                    builder: (_, __) => Text(
                      '${(_cardFades[index].value * value).round()}',
                      style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF43185A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(label, textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFFFFFFFF) : c.textSecondary)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(AppColors c, Item item, int index) {
    final isDark   = c.isDark;
    final daysText = item.daysLeft < 0
        ? 'Expires ${-item.daysLeft} day(s) ago'
        : item.daysLeft == 0 ? 'Expires today'
        : 'Expires in ${item.daysLeft} day(s)';

    return Dismissible(
      key: Key('dismissible_${item.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _handleDelete(context, item.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.red.withOpacity(0.85),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      child: TweenAnimationBuilder<double>(
        key: ValueKey(item.id),
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 350 + (index * 50).clamp(0, 350)),
        curve: Curves.easeOutCubic,
        builder: (_, v, child) =>
            Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 28 * (1 - v)), child: child)),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF281C30) : const Color(0xFFEAEAF2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.teal.withOpacity(isDark ? 1.0 : 1.0), width: isDark ? 1.8 : 2.0),
            boxShadow: [BoxShadow(color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              // ── Top row ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: item.statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.type.icon, color: item.statusColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHighlightedName(c, item.name),
                          const SizedBox(height: 2),
                          Text(item.type.label, style: TextStyle(color: c.textSecondary, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(daysText, style: TextStyle(color: item.statusColor, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(item.statusLabel,
                          style: TextStyle(color: item.statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => ItemsScope.read(context).toggleFavorite(item.id),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          item.isFavorite ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(item.isFavorite),
                          color: item.isFavorite ? Colors.redAccent : c.textSecondary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bottom row: qty + edit (NO delete button) ────────────────
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withOpacity(0.15) : const Color(0xFFE8E5F5),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.layers_outlined, size: 13, color: c.textSecondary),
                    const SizedBox(width: 4),
                    Text('Qty:', style: TextStyle(color: c.textSecondary, fontSize: 12)),
                    const SizedBox(width: 8),
                    // ── Minus button (bigger) ──────────────────────────────
                    _QtyBtn(
                      icon: Icons.remove,
                      onTap: () => ItemsScope.read(context).updateQuantity(item.id, -1),
                      isDark: isDark,
                      color: c.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: Text(
                        '${item.quantity}',
                        key: ValueKey(item.quantity),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ── Plus button (bigger) ───────────────────────────────
                    _QtyBtn(
                      icon: Icons.add,
                      onTap: () => ItemsScope.read(context).updateQuantity(item.id, 1),
                      isDark: isDark,
                      color: const Color(0xFF332A3A),
                      filled: true,
                    ),
                    const Spacer(),
                    // ── Edit button (bigger, no delete) ───────────────────
                    GestureDetector(
                      onTap: () => _openEditSheet(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withOpacity(isDark ? 0.15 : 0.10),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.purple.withOpacity(0.3)),
                        ),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.edit_outlined, size: 16, color: Color(0xFF2E9B9B)),
                          SizedBox(width: 6),
                          Text('Edit', style: TextStyle(color: Color(0xFF2E9A9A), fontSize: 13, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedName(AppColors c, String name) {
    if (_searchQuery.isEmpty) {
      return Text(name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: c.textPrimary));
    }
    final lowerName  = name.toLowerCase();
    final lowerQuery = _searchQuery.toLowerCase();
    final matchIdx   = lowerName.indexOf(lowerQuery);
    if (matchIdx == -1) {
      return Text(name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: c.textPrimary));
    }
    return RichText(
      text: TextSpan(
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: c.textPrimary),
        children: [
          if (matchIdx > 0) TextSpan(text: name.substring(0, matchIdx)),
          TextSpan(
            text: name.substring(matchIdx, matchIdx + _searchQuery.length),
            style: const TextStyle(backgroundColor: Color(0x306C63FF), color: AppColors.purple, fontWeight: FontWeight.bold),
          ),
          if (matchIdx + _searchQuery.length < name.length)
            TextSpan(text: name.substring(matchIdx + _searchQuery.length)),
        ],
      ),
    );
  }
}


class AddItemSheet extends StatefulWidget {
  final void Function(String, ProductType, DateTime, int) onAdd;
  const AddItemSheet({super.key, required this.onAdd});
  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> with SingleTickerProviderStateMixin {
  ProductType _selectedType = ProductType.food;
  final _nameCtrl  = TextEditingController();
  DateTime? _selectedDate;
  int _quantity = 1;
  final _formKey = GlobalKey<FormState>();
  late AnimationController _sheetCtrl;
  late Animation<double> _sheetFade;
  late Animation<Offset>  _sheetSlide;

  @override
  void initState() {
    super.initState();
    _sheetCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _sheetFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOut));
    _sheetSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOutCubic));
    _sheetCtrl.forward();
  }

  @override
  void dispose() { _nameCtrl.dispose(); _sheetCtrl.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime(2000), lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purple)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an expiration date')));
      return;
    }
    widget.onAdd(_nameCtrl.text.trim(), _selectedType, _selectedDate!, _quantity);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c          = AppColors.of(context);
    final isDark     = c.isDark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final sheetBg    = isDark ? const Color(0xFF020202) : const Color(0xFFE4FCFD);
    final typeCardBg = isDark ? const Color(0xFF291A2F) : const Color(0xFFE2E1EC);

    return FadeTransition(
      opacity: _sheetFade,
      child: SlideTransition(
        position: _sheetSlide,
        child: Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.teal.withOpacity(0.4)),
          ),
          padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4,
                      decoration: BoxDecoration(color: isDark ? Colors.white38 : c.divider, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add New Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.textPrimary)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(width: 30, height: 30,
                            decoration: BoxDecoration(color: isDark ? Colors.white12 : c.cardAlt, shape: BoxShape.circle),
                            child: Icon(Icons.close, size: 16, color: c.textSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Product Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 4, shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.88,
                    children: ProductType.values.map((type) {
                      final selected = _selectedType == type;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: selected ? (isDark ? const Color(0xFF294C54) : AppColors.purple.withOpacity(0.12)) : typeCardBg,
                            border: Border.all(color: selected ? AppColors.teal : (isDark ? AppColors.teal.withOpacity(0.3) : c.border), width: selected ? 1.5 : 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(children: [
                            if (selected) Positioned(top: 5, right: 5, child: Icon(Icons.check, size: 11, color: AppColors.teal)),
                            Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(type.icon, size: 24, color: selected ? AppColors.teal : c.textSecondary),
                              const SizedBox(height: 5),
                              Text(type.label, textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 11, color: selected ? AppColors.teal : c.textSecondary)),
                            ])),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  Text('Item Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrl,
                    style: TextStyle(color: c.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'e.g., Milk, Medicine, Face Cream',
                      hintStyle: TextStyle(color: c.textHint, fontSize: 14),
                      filled: true, fillColor: isDark ? const Color(0xFF2D2E2B) : c.inputBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.teal.withOpacity(0.4))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.teal.withOpacity(0.4))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.teal, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter item name' : null,
                  ),
                  const SizedBox(height: 14),
                  Text('Quantity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: isDark ? const Color(0xFF2D2E2B) : c.inputBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.teal.withOpacity(0.4))),
                    child: Row(children: [
                      GestureDetector(
                        onTap: () { if (_quantity > 1) setState(() => _quantity--); },
                        child: Container(width: 32, height: 32,
                            decoration: BoxDecoration(color: isDark ? const Color(0xFF2E1D30) : c.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.teal.withOpacity(0.3))),
                            child: Icon(Icons.remove, size: 16, color: c.textPrimary)),
                      ),
                      Expanded(child: Center(child: Text('$_quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.textPrimary)))),
                      GestureDetector(
                        onTap: () => setState(() => _quantity++),
                        child: Container(width: 32, height: 32,
                            decoration: const BoxDecoration(color: Color(0xFF2E1D30), borderRadius: BorderRadius.all(Radius.circular(8))),
                            child: const Icon(Icons.add, size: 16, color: Colors.white)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Text('Expiration Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF2D2E2B) : c.inputBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.teal.withOpacity(0.4))),
                      child: Row(children: [
                        Expanded(child: Text(
                          _selectedDate == null ? 'mm/dd/yyyy'
                              : '${_selectedDate!.month.toString().padLeft(2,'0')}/${_selectedDate!.day.toString().padLeft(2,'0')}/${_selectedDate!.year}',
                          style: TextStyle(fontSize: 14, color: _selectedDate == null ? c.textHint : c.textPrimary),
                        )),
                        Icon(Icons.calendar_today_outlined, color: c.textSecondary, size: 18),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                      child: Ink(
                        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2D0B6B), Color(0xFF8B2FC9)], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(14)),
                        child: Container(alignment: Alignment.center, child: const Text('Add Item', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// ── QtyBtn: bigger size ───────────────────────────────────────────────────────
class _QtyBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final Color color;
  final bool filled;

  const _QtyBtn({required this.icon, required this.onTap, required this.isDark, required this.color, this.filled = false});

  @override
  State<_QtyBtn> createState() => _QtyBtnState();
}

class _QtyBtnState extends State<_QtyBtn> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1.0, end: 0.85).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => _ctrl.forward(),
      onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 32,   // ← كان 22، كبّرناه لـ 32
          height: 32,  // ← كان 22، كبّرناه لـ 32
          decoration: BoxDecoration(
            color: widget.filled ? widget.color : (widget.isDark ? Colors.white.withOpacity(0.08) : widget.color.withOpacity(0.10)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.color.withOpacity(widget.filled ? 0 : 0.4), width: 1),
          ),
          child: Icon(widget.icon, size: 18, color: widget.filled ? Colors.white : widget.color),  // ← أيقونة أكبر
        ),
      ),
    );
  }
}


class EditItemSheet extends StatefulWidget {
  final Item item;
  final void Function(String, ProductType, DateTime, int) onSave;
  const EditItemSheet({super.key, required this.item, required this.onSave});
  @override
  State<EditItemSheet> createState() => _EditItemSheetState();
}

class _EditItemSheetState extends State<EditItemSheet> with SingleTickerProviderStateMixin {
  late ProductType _selectedType;
  late TextEditingController _nameCtrl;
  DateTime? _selectedDate;
  late int _quantity;
  final _formKey = GlobalKey<FormState>();
  late AnimationController _sheetCtrl;
  late Animation<double> _sheetFade;
  late Animation<Offset>  _sheetSlide;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.item.type;
    _nameCtrl     = TextEditingController(text: widget.item.name);
    _selectedDate = widget.item.expiryDate;
    _quantity     = widget.item.quantity;
    _sheetCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _sheetFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOut));
    _sheetSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOutCubic));
    _sheetCtrl.forward();
  }

  @override
  void dispose() { _nameCtrl.dispose(); _sheetCtrl.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime(2000), lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purple)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an expiration date')));
      return;
    }
    widget.onSave(_nameCtrl.text.trim(), _selectedType, _selectedDate!, _quantity);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c           = AppColors.of(context);
    final isDark      = c.isDark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final sheetBg     = isDark ? const Color(0xFF180E38) : Colors.white;
    final typeCardBg  = isDark ? const Color(0xFF0A0A14) : const Color(0xFFF5F2FF);

    return FadeTransition(
      opacity: _sheetFade,
      child: SlideTransition(
        position: _sheetSlide,
        child: Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.teal.withOpacity(0.4)),
          ),
          padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4,
                      decoration: BoxDecoration(color: isDark ? Colors.white24 : c.divider, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Container(width: 28, height: 28,
                            decoration: BoxDecoration(color: AppColors.purple.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFFFFFFFF))),
                        const SizedBox(width: 8),
                        Text('Edit Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.textPrimary)),
                      ]),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(width: 30, height: 30,
                            decoration: BoxDecoration(color: isDark ? Colors.white12 : c.cardAlt, shape: BoxShape.circle),
                            child: Icon(Icons.close, size: 16, color: c.textSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Product Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 4, shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.88,
                    children: ProductType.values.map((type) {
                      final selected = _selectedType == type;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: selected ? (isDark ? const Color(0xFF2B4D5B) : AppColors.purple.withOpacity(0.12)) : typeCardBg,
                            border: Border.all(color: selected ? AppColors.teal : (isDark ? AppColors.teal.withOpacity(0.3) : c.border), width: selected ? 1.5 : 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(children: [
                            if (selected) Positioned(top: 5, right: 5, child: Icon(Icons.check, size: 11, color: AppColors.teal)),
                            Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(type.icon, size: 24, color: selected ? AppColors.teal : c.textSecondary),
                              const SizedBox(height: 5),
                              Text(type.label, textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 11, color: selected ? AppColors.teal : c.textSecondary)),
                            ])),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  Text('Item Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrl,
                    style: TextStyle(color: c.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'e.g., Milk, Medicine, Face Cream',
                      hintStyle: TextStyle(color: c.textHint, fontSize: 14),
                      filled: true, fillColor: isDark ? const Color(0xFF2D2E2B) : c.inputBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.teal.withOpacity(0.4))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.teal.withOpacity(0.4))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.teal, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter item name' : null,
                  ),
                  const SizedBox(height: 14),
                  Text('Quantity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: isDark ? const Color(0xFF2E2E2B) : c.inputBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.teal.withOpacity(0.4))),
                    child: Row(children: [
                      GestureDetector(
                        onTap: () { if (_quantity > 1) setState(() => _quantity--); },
                        child: Container(width: 32, height: 32,
                            decoration: BoxDecoration(color: isDark ? const Color(0xFF2D1A2F) : c.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.teal.withOpacity(0.3))),
                            child: Icon(Icons.remove, size: 16, color: c.textPrimary)),
                      ),
                      Expanded(child: Center(child: Text('$_quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.textPrimary)))),
                      GestureDetector(
                        onTap: () => setState(() => _quantity++),
                        child: Container(width: 32, height: 32,
                            decoration: BoxDecoration(color: AppColors.purple, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.add, size: 16, color: Colors.white)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Text('Expiration Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF2E2E2B) : c.inputBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.teal.withOpacity(0.4))),
                      child: Row(children: [
                        Expanded(child: Text(
                          _selectedDate == null ? 'mm/dd/yyyy'
                              : '${_selectedDate!.month.toString().padLeft(2,'0')}/${_selectedDate!.day.toString().padLeft(2,'0')}/${_selectedDate!.year}',
                          style: TextStyle(fontSize: 14, color: _selectedDate == null ? c.textHint : c.textPrimary),
                        )),
                        Icon(Icons.calendar_today_outlined, color: c.textSecondary, size: 18),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                      child: Ink(
                        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2D0B6B), Color(0xFF8B2FC9)], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(14)),
                        child: Container(alignment: Alignment.center, child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
