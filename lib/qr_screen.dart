import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen>
    with SingleTickerProviderStateMixin {
  String _labId = '';
  String _pcNo = '';
  String _secretKey = '';
  bool _isLoading = true;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  // Design tokens
  static const Color _bg = Color(0xFF060B14);
  static const Color _surface = Color(0xFF0D1825);
  static const Color _surfaceElevated = Color(0xFF111E2E);
  static const Color _accent = Color(0xFF00D4FF);
  static const Color _accentDim = Color(0xFF0099CC);
  static const Color _accentGlow = Color(0x2200D4FF);
  static const Color _textPrimary = Color(0xFFE8F4FC);
  static const Color _textSecondary = Color(0xFF6B8CA8);
  static const Color _borderSubtle = Color(0xFF1A2D42);
  static const Color _green = Color(0xFF00E5B0);

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _loadData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _labId = prefs.getString('lab_id') ?? 'LAB-01';
      _pcNo = prefs.getString('pc_no') ?? 'PC-07';
      _secretKey = prefs.getString('secret_key') ?? 'N/A';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: CircularProgressIndicator(color: _accent, strokeWidth: 1.5),
        ),
      );
    }

    final String qrData = jsonEncode({
      "a": "E",
      "l": _labId,
      "p": _pcNo,
      "k": _secretKey,
      "t": DateTime.now().millisecondsSinceEpoch,
    });

    return Scaffold(
      backgroundColor: _bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          // Responsive sizing
          final isCompact = h < 600 || w < 400;
          final isWide = w > 700;

          final qrSize = isCompact
              ? math.min(w * 0.45, 200.0)
              : isWide
              ? math.min(w * 0.28, 300.0)
              : math.min(w * 0.58, 280.0);

          final cardPadding = isCompact ? 20.0 : 32.0;
          final titleSize = isCompact ? 10.0 : 12.0;
          final badgeFontSize = isCompact ? 14.0 : 18.0;
          final headerIconSize = isCompact ? 18.0 : 24.0;
          final headerTextSize = isCompact ? 9.0 : 11.0;

          return Stack(
            children: [
              // ── Atmospheric Background ──
              Positioned.fill(child: _buildBackground(w, h)),

              // ── Main Content ──
              SafeArea(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: h),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? w * 0.15 : 24.0,
                        vertical: isCompact ? 16.0 : 32.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ── Top Header ──
                          _buildHeader(headerIconSize, headerTextSize),

                          SizedBox(height: isCompact ? 24 : 44),

                          // ── Main Card ──
                          _buildMainCard(
                            qrData: qrData,
                            qrSize: qrSize,
                            cardPadding: cardPadding,
                            badgeFontSize: badgeFontSize,
                            titleSize: titleSize,
                            isCompact: isCompact,
                          ),

                          SizedBox(height: isCompact ? 20 : 36),

                          // ── Status Footer ──
                          _buildStatusFooter(isCompact),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────
  // BACKGROUND
  // ─────────────────────────────────────────
  Widget _buildBackground(double w, double h) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.3, -0.5),
              radius: 1.4,
              colors: [Color(0xFF0A1929), Color(0xFF060B14)],
            ),
          ),
        ),

        // Glow orb top-left
        Positioned(
          top: -h * 0.2,
          left: -w * 0.2,
          child: Container(
            width: w * 0.75,
            height: w * 0.75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_accent.withOpacity(0.06), Colors.transparent],
              ),
            ),
          ),
        ),

        // Subtle grid lines
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),

        // Scan line animation
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (_, __) {
            return Positioned(
              top: h * _pulseAnimation.value,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      _accent.withOpacity(0.12),
                      _accent.withOpacity(0.18),
                      _accent.withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────
  Widget _buildHeader(double iconSize, double textSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon with glow ring
        Container(
          width: iconSize + 16,
          height: iconSize + 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _accentGlow,
            border: Border.all(color: _accent.withOpacity(0.25), width: 1),
          ),
          child: Icon(
            Icons.fingerprint_rounded,
            color: _accent,
            size: iconSize,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ENTRIXO",
              style: TextStyle(
                color: _textPrimary,
                letterSpacing: 5,
                fontWeight: FontWeight.w700,
                fontSize: textSize + 4,
                fontFamily: 'monospace',
              ),
            ),
            Text(
              "SECURE TERMINAL  v2.4",
              style: TextStyle(
                color: _accentDim,
                letterSpacing: 3,
                fontWeight: FontWeight.w400,
                fontSize: textSize,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // MAIN CARD
  // ─────────────────────────────────────────
  Widget _buildMainCard({
    required String qrData,
    required double qrSize,
    required double cardPadding,
    required double badgeFontSize,
    required double titleSize,
    required bool isCompact,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, child) {
        final glow = _pulseAnimation.value;
        return Container(
          decoration: BoxDecoration(
            color: _surfaceElevated,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Color.lerp(_borderSubtle, _accent.withOpacity(0.3), glow)!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _accent.withOpacity(0.04 + glow * 0.06),
                blurRadius: 60,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          children: [
            // ── Info Badge Row ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoChip(
                  icon: Icons.science_rounded,
                  label: "LAB",
                  value: _labId,
                ),
                Container(
                  width: 1,
                  height: 36,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: _borderSubtle,
                ),
                _buildInfoChip(
                  icon: Icons.computer_rounded,
                  label: "UNIT",
                  value: _pcNo,
                ),
              ],
            ),

            SizedBox(height: isCompact ? 20 : 30),

            // ── Divider ──
            _buildDividerLine(),

            SizedBox(height: isCompact ? 20 : 30),

            // ── QR Code ──
            _buildQrContainer(qrData: qrData, qrSize: qrSize),

            SizedBox(height: isCompact ? 20 : 28),

            // ── Scan Instruction ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _green,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "SCAN TO MARK ATTENDANCE",
                  style: TextStyle(
                    color: _textSecondary,
                    letterSpacing: 2.5,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: _accentDim, size: 12),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 9,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: _accent,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildDividerLine() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, _borderSubtle],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.qr_code_2_rounded, color: _accentDim, size: 16),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_borderSubtle, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQrContainer({required String qrData, required double qrSize}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (_, __) => Container(
            width: qrSize + 40,
            height: qrSize + 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _accent.withOpacity(0.04 * _pulseAnimation.value),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // QR white frame
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _accent.withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Colors.black38,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: qrSize,
            foregroundColor: const Color(0xFF060B14),
            backgroundColor: Colors.white,
          ),
        ),

        // Corner brackets overlay
        SizedBox(
          width: qrSize + 40,
          height: qrSize + 40,
          child: CustomPaint(painter: _CornerBracketPainter()),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // STATUS FOOTER
  // ─────────────────────────────────────────
  Widget _buildStatusFooter(bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 24,
        vertical: isCompact ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Online dot
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, __) => Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(
                  _green.withOpacity(0.5),
                  _green,
                  _pulseAnimation.value,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _green.withOpacity(0.5 * _pulseAnimation.value),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "SYSTEM ONLINE",
            style: TextStyle(
              color: _green,
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 14, color: _borderSubtle),
          const SizedBox(width: 16),
          Text(
            "ENCRYPTED  •  AES-256",
            style: TextStyle(
              color: _textSecondary.withOpacity(0.7),
              fontSize: 10,
              letterSpacing: 1.5,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CUSTOM PAINTERS
// ─────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A2D42).withOpacity(0.25)
      ..strokeWidth = 0.5;

    const spacing = 48.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 18.0;
    const r = 6.0;
    final w = size.width;
    final h = size.height;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(r, len)
        ..lineTo(r, r)
        ..arcToPoint(Offset(r + r, 0), radius: const Radius.circular(r))
        ..lineTo(len + r, 0),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(w - r - len, 0)
        ..lineTo(w - r - r, 0)
        ..arcToPoint(Offset(w - r, r), radius: const Radius.circular(r))
        ..lineTo(w - r, len),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(r, h - len)
        ..lineTo(r, h - r)
        ..arcToPoint(Offset(r + r, h), radius: const Radius.circular(r))
        ..lineTo(len + r, h),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(w - r - len, h)
        ..lineTo(w - r - r, h)
        ..arcToPoint(Offset(w - r, h - r), radius: const Radius.circular(r))
        ..lineTo(w - r, h - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CornerBracketPainter old) => false;
}
