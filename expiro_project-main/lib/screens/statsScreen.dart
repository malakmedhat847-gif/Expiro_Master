import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:expiro_project/state/items_store.dart';
import 'package:expiro_project/theme/app_colors.dart';
import '../models/items.dart';


class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late AnimationController _gridCtrl;
  late AnimationController _pieCtrl;
  late AnimationController _barsCtrl;

  late Animation<double> _headerFade;
  late Animation<Offset>  _headerSlide;

  late List<Animation<double>> _cardFades;
  late List<Animation<double>> _cardScales;
  late List<Animation<Offset>>  _cardSlides;

  late Animation<double> _pieSweep;
  late Animation<double> _pieFade;
  late Animation<double> _barsProgress;
  late Animation<double> _barsFade;

  @override
  void initState() {
    super.initState();
    _setup();
    _play();
  }

  void _setup() {
    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _headerFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

    _gridCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _cardFades = []; _cardScales = []; _cardSlides = [];
    for (int i = 0; i < 5; i++) {
      final s = i * 0.15, e = (s + 0.50).clamp(0.0, 1.0);
      _cardFades.add(Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _gridCtrl, curve: Interval(s, e, curve: Curves.easeOut))));
      _cardScales.add(Tween<double>(begin: 0.85, end: 1.0).animate(
          CurvedAnimation(parent: _gridCtrl, curve: Interval(s, e, curve: Curves.easeOutBack))));
      _cardSlides.add(Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(parent: _gridCtrl, curve: Interval(s, e, curve: Curves.easeOutCubic))));
    }

    _pieCtrl     = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _pieSweep    = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _pieCtrl, curve: Curves.easeInOut));
    _pieFade     = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _pieCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));

    _barsCtrl     = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _barsProgress = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _barsCtrl, curve: Curves.easeOutCubic));
    _barsFade     = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _barsCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
  }

  Future<void> _play() async {
    await _headerCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 60));
    _gridCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 350));
    _pieCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _barsCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose(); _gridCtrl.dispose();
    _pieCtrl.dispose();    _barsCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _catData(List<Item> items) =>
      ProductType.values
          .where((t) => items.any((i) => i.type == t))
          .map((t) {
        final catItems = items.where((i) => i.type == t).toList();
        final e = catItems.where((i) => i.status == ItemStatus.expired).length;
        final s = catItems.where((i) => i.status == ItemStatus.soon).length;
        final List<Color> colors;
        if (e >= s && e > 0)   colors = [AppColors.red,    AppColors.orange];
        else if (s > 0)        colors = [AppColors.orange,  const Color(0xFFFFB300)];
        else                   colors = [AppColors.purple,  AppColors.teal];
        return {'label': t.label, 'value': catItems.length, 'colors': colors};
      }).toList();

  @override
  Widget build(BuildContext context) {
    final c     = AppColors.of(context);
    final isDark = c.isDark;
    final store = ItemsScope.of(context);
    final items = store.items;

    final total      = items.length;
    final expired    = store.expiredCount;
    final soon       = store.soonCount;
    final fresh      = store.freshCount;
    final cats       = ProductType.values.where((t) => items.any((i) => i.type == t)).length;
    final catData    = _catData(items);

    return Scaffold(
      backgroundColor: c.scaffold,
      body: Container(
        decoration: !isDark ? const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD3CCCC), Color(0xFFD2CBCB)],
          ),
        ) : null,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(c),
                const SizedBox(height: 20),
                _buildGrid(c, total, cats, soon, expired, fresh),
                const SizedBox(height: 20),
                _buildPie(c, expired, soon, fresh),
                const SizedBox(height: 20),
                _buildBars(c, catData),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors c) {
    return FadeTransition(
      opacity: _headerFade,
      child: SlideTransition(
        position: _headerSlide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistics',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: c.textPrimary)),
            const SizedBox(height: 4),
            Text('Track your inventory insights',
                style: TextStyle(fontSize: 13, color: c.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(AppColors c, int total, int cats, int soon, int expired, int fresh) {
    final gridItems = [
      {'icon': Icons.inventory_2_outlined,     'value': total,   'label': 'Total Items'},
      {'icon': Icons.trending_up_rounded,      'value': cats,    'label': 'Categories'},
      {'icon': Icons.hourglass_bottom_rounded, 'value': soon,    'label': 'Expire Soon'},
      {'icon': Icons.timer_off_outlined,       'value': expired, 'label': 'Expired'},
      {'icon': Icons.check_circle_outline,     'value': fresh,   'label': 'Fresh Items'},
    ];

    return Column(
      children: [
        Row(children: [
          _gridCard(c, gridItems[0], 0),
          const SizedBox(width: 12),
          _gridCard(c, gridItems[1], 1),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _gridCard(c, gridItems[2], 2),
          const SizedBox(width: 12),
          _gridCard(c, gridItems[3], 3),
        ]),
        const SizedBox(height: 12),
        _gridCard(c, gridItems[4], 4, fullWidth: true),
      ],
    );
  }

  Widget _gridCard(AppColors c, Map<String, dynamic> item, int i, {bool fullWidth = false}) {
    final isDark = c.isDark;

    return Expanded(
      flex: fullWidth ? 0 : 1,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        child: FadeTransition(
          opacity: _cardFades[i],
          child: SlideTransition(
            position: _cardSlides[i],
            child: ScaleTransition(
              scale: _cardScales[i],
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                      colors: [const Color(0xFF452260), const Color(0xFF3D2481)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : null,
                  color: isDark ? null : const Color(0xFFEEECF6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.teal.withOpacity(isDark ? 1.0 : 1.0), width: isDark ? 1.8 : 2.0),
                  boxShadow: [BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.05),
                      blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Row(
                  mainAxisAlignment: fullWidth ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(item['icon'] as IconData, color: Color(
                            0xFF000000), size: 22),
                        const SizedBox(height: 12),
                        AnimatedBuilder(
                          animation: _gridCtrl,
                          builder: (_, __) => Text(
                            '${(_cardFades[i].value * (item['value'] as int)).round()}',
                            style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0A0010),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('${item['label']}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white : const Color(
                                  0xFF000000),
                            )),
                      ],
                    ),
                    if (fullWidth)
                      Icon(Icons.check_circle_outline,
                          color: AppColors.teal.withOpacity(isDark ? 1.0 : 1.0), size: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPie(AppColors c, int expired, int soon, int fresh) {
    final isDark = c.isDark;
    final total      = expired + soon + fresh;
    final expiredPct = total == 0 ? 0.0 : expired / total;
    final soonPct    = total == 0 ? 0.0 : soon    / total;
    final freshPct   = total == 0 ? 0.0 : fresh   / total;

    return FadeTransition(
      opacity: _pieFade,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
              colors: [const Color(0xFF442263), const Color(0xFF3E247D)],
              begin: Alignment.topLeft, end: Alignment.bottomRight)
              : null,
          color: isDark ? null : const Color(0xFFF0EDF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.teal.withOpacity(isDark ? 1.0 : 1.0), width: isDark ? 1.8 : 2.0),
          boxShadow: [BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
              blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status Distribution',
                style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0A0010),
                )),
            const SizedBox(height: 24),
            Row(
              children: [
                SizedBox(
                  width: 140, height: 140,
                  child: AnimatedBuilder(
                    animation: _pieSweep,
                    builder: (_, __) => CustomPaint(
                      painter: _PiePainter(
                        expiredPct: expiredPct,
                        soonPct: soonPct,
                        freshPct: freshPct,
                        progress: _pieSweep.value,
                        holeColor: isDark ? const Color(0xFF1C1040) :Color(
                            0xFFE2E1EC),
                        textColor: isDark ? Colors.white : const Color(0xFF0A0010),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (freshPct > 0)   _legend(c, AppColors.teal,   'Fresh',       freshPct),
                    if (freshPct > 0)   const SizedBox(height: 10),
                    if (soonPct > 0)    _legend(c, AppColors.orange, 'Expire Soon', soonPct),
                    if (soonPct > 0)    const SizedBox(height: 10),
                    if (expiredPct > 0) _legend(c, AppColors.red,    'Expired',     expiredPct),
                    if (total == 0)
                      Text('No data', style: TextStyle(color: c.textSecondary, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(AppColors c, Color color, String label, double pct) {
    final isDark = c.isDark;
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label  ${(pct * 100).toStringAsFixed(0)}%',
            style: TextStyle(color: isDark ? Colors.white70 : c.textSecondary, fontSize: 13)),
      ],
    );
  }

  Widget _buildBars(AppColors c, List<Map<String, dynamic>> data) {
    final isDark = c.isDark;

    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0010) : c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.teal.withOpacity(0.4)),
        ),
        child: Center(child: Text('No data yet', style: TextStyle(color: c.textSecondary, fontSize: 13))),
      );
    }

    final maxVal = data.map((e) => e['value'] as int).reduce((a, b) => a > b ? a : b);

    return FadeTransition(
      opacity: _barsFade,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
              colors: [const Color(0xFF442264), const Color(0xFF3E247A)],
              begin: Alignment.topLeft, end: Alignment.bottomRight)
              : null,
          color: isDark ? null : const Color(0xFFEEECF6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.teal.withOpacity(isDark ? 1.0 : 1.0), width: isDark ? 1.8 : 2.0),
          boxShadow: [BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
              blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items by Category',
                style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0A0010),
                )),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(4, (i) => Text(
                      '${((maxVal / 3) * (3 - i)).round()}',
                      style: TextStyle(color: isDark ? Colors.white38 : c.textHint, fontSize: 10),
                    )),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _barsProgress,
                      builder: (_, __) => Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: data.map((item) {
                          final pct    = maxVal == 0 ? 0.0 : (item['value'] as int) / maxVal;
                          final animH  = 120 * pct * _barsProgress.value;
                          final colors = item['colors'] as List<Color>;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_barsProgress.value > 0.6)
                                Opacity(
                                  opacity: ((_barsProgress.value - 0.6) / 0.4).clamp(0.0, 1.0),
                                  child: Text('${item['value']}',
                                      style: TextStyle(
                                          color: isDark ? Colors.white60 : c.textSecondary, fontSize: 10)),
                                )
                              else
                                const SizedBox(height: 14),
                              const SizedBox(height: 4),
                              Container(
                                width: 36,
                                height: animH,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                    colors: colors,
                                  ),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                  boxShadow: [BoxShadow(
                                      color: colors[0].withOpacity(0.35), blurRadius: 6, offset: const Offset(0, 3))],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(item['label'],
                                  style: TextStyle(
                                      color: isDark ? Colors.white54 : c.textSecondary, fontSize: 9)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  final double expiredPct, soonPct, freshPct, progress;
  final Color holeColor;
  final Color textColor;

  _PiePainter({
    required this.expiredPct, required this.soonPct, required this.freshPct,
    required this.progress, required this.holeColor, required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect   = Rect.fromCircle(center: center, radius: radius);
    double angle = -math.pi / 2;

    final segments = [
      {'pct': freshPct,   'color': AppColors.teal},
      {'pct': soonPct,    'color': AppColors.orange},
      {'pct': expiredPct, 'color': AppColors.red},
    ];

    for (final seg in segments) {
      final pct = seg['pct'] as double;
      if (pct <= 0) continue;
      final sweep = pct * 2 * math.pi * progress;
      canvas.drawArc(rect, angle, sweep, true,
          Paint()..color = seg['color'] as Color..style = PaintingStyle.fill);
      angle += sweep;
    }

    canvas.drawCircle(center, radius * 0.54, Paint()..color = holeColor);

    if (progress > 0.85) {
      final segs = [
        {'pct': freshPct,   'label': 'Fresh'},
        {'pct': soonPct,    'label': 'Soon'},
        {'pct': expiredPct, 'label': 'Expired'},
      ];
      final dom = segs.reduce((a, b) =>
      (a['pct'] as double) > (b['pct'] as double) ? a : b);

      if ((dom['pct'] as double) > 0) {
        final pct   = dom['pct'] as double;
        final label = dom['label'] as String;
        final tp = TextPainter(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          text: TextSpan(children: [
            TextSpan(
              text: '${(pct * 100).toStringAsFixed(0)}%\n',
              style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: label,
              style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 9),
            ),
          ]),
        )..layout(maxWidth: radius);
        tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) =>
      old.progress != progress || old.expiredPct != expiredPct ||
          old.soonPct  != soonPct  || old.freshPct   != freshPct  ||
          old.holeColor != holeColor;
}