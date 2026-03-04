import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'qr_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _labIdController = TextEditingController();
  final _pcNoController = TextEditingController();
  final _secretKeyController = TextEditingController();
  bool _isLoading = false;
  bool _obscureKey = true;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ── Design Tokens (same as QRScreen) ──
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
  static const Color _error = Color(0xFFFF5A6E);

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _labIdController.dispose();
    _pcNoController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveSetup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lab_id', _labIdController.text.trim());
    await prefs.setString('pc_no', _pcNoController.text.trim());
    await prefs.setString('secret_key', _secretKeyController.text.trim());
    await prefs.setBool('isSetupComplete', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const QRScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final isCompact = h < 600 || w < 400;
          final isWide = w > 700;
          final cardMaxWidth = isWide ? 480.0 : double.infinity;
          final hPad = isWide ? math.max((w - cardMaxWidth) / 2, 24.0) : 24.0;

          return Stack(
            children: [
              // ── Background ──
              Positioned.fill(child: _buildBackground(w, h)),

              // ── Content ──
              SafeArea(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: h),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: hPad,
                        vertical: isCompact ? 16 : 32,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: isCompact ? 8 : 0),

                          // ── Header ──
                          _buildHeader(isCompact),

                          SizedBox(height: isCompact ? 24 : 40),

                          // ── Card ──
                          _buildCard(isCompact),

                          SizedBox(height: isCompact ? 20 : 32),

                          // ── Footer ──
                          _buildFooter(isCompact),

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
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.4, -0.4),
              radius: 1.4,
              colors: [Color(0xFF0A1929), Color(0xFF060B14)],
            ),
          ),
        ),
        Positioned(
          bottom: -h * 0.2,
          right: -w * 0.2,
          child: Container(
            width: w * 0.75,
            height: w * 0.75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_accent.withOpacity(0.05), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (_, __) => Positioned(
            top: h * _pulseAnimation.value,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _accent.withOpacity(0.10),
                    _accent.withOpacity(0.16),
                    _accent.withOpacity(0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────
  Widget _buildHeader(bool isCompact) {
    final iconBoxSize = isCompact ? 36.0 : 44.0;
    final iconSize = isCompact ? 18.0 : 22.0;
    final titleSize = isCompact ? 13.0 : 15.0;
    final subSize = isCompact ? 9.0 : 10.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: iconBoxSize,
          height: iconBoxSize,
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
                fontSize: titleSize,
                fontFamily: 'monospace',
              ),
            ),
            Text(
              "SECURE TERMINAL  v2.4",
              style: TextStyle(
                color: _accentDim,
                letterSpacing: 3,
                fontWeight: FontWeight.w400,
                fontSize: subSize,
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
  Widget _buildCard(bool isCompact) {
    final pad = isCompact ? 20.0 : 32.0;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          color: _surfaceElevated,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Color.lerp(
              _borderSubtle,
              _accent.withOpacity(0.25),
              _pulseAnimation.value,
            )!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(0.03 + _pulseAnimation.value * 0.05),
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
      ),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Card Title ──
              _buildCardTitle(isCompact),

              SizedBox(height: isCompact ? 24 : 32),

              // ── Divider ──
              _buildDivider(label: "TERMINAL CONFIG"),

              SizedBox(height: isCompact ? 20 : 28),

              // ── Fields ──
              _buildField(
                controller: _labIdController,
                label: "LAB IDENTIFIER",
                hint: "e.g.  LAB-01",
                icon: Icons.science_rounded,
              ),
              SizedBox(height: isCompact ? 14 : 18),
              _buildField(
                controller: _pcNoController,
                label: "UNIT NUMBER",
                hint: "e.g.  PC-12",
                icon: Icons.desktop_windows_rounded,
              ),
              SizedBox(height: isCompact ? 14 : 18),
              _buildField(
                controller: _secretKeyController,
                label: "SECRET KEY",
                hint: "Enter auth token",
                icon: Icons.vpn_key_rounded,
                obscure: _obscureKey,
                toggleObscure: () => setState(() => _obscureKey = !_obscureKey),
              ),

              SizedBox(height: isCompact ? 24 : 36),

              // ── Submit Button ──
              _buildSubmitButton(isCompact),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardTitle(bool isCompact) {
    return Row(
      children: [
        Container(
          width: isCompact ? 36 : 44,
          height: isCompact ? 36 : 44,
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _accent.withOpacity(0.2)),
          ),
          child: Icon(
            Icons.settings_input_component_rounded,
            color: _accent,
            size: isCompact ? 18 : 22,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PC SETUP",
              style: TextStyle(
                color: _textPrimary,
                fontSize: isCompact ? 16 : 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                fontFamily: 'monospace',
              ),
            ),
            Text(
              "Configure attendance terminal",
              style: TextStyle(
                color: _textSecondary,
                fontSize: isCompact ? 10 : 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider({required String label}) {
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _borderSubtle),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 9,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    VoidCallback? toggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 10,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(
            color: _textPrimary,
            fontFamily: 'monospace',
            fontSize: 14,
            letterSpacing: 1,
          ),
          cursorColor: _accent,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: _textSecondary.withOpacity(0.4),
              fontFamily: 'monospace',
              fontSize: 13,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, color: _accentDim, size: 18),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0),
            suffixIcon: toggleObscure != null
                ? GestureDetector(
                    onTap: toggleObscure,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Icon(
                        obscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: _textSecondary,
                        size: 18,
                      ),
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 0),
            filled: true,
            fillColor: _surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _error, width: 1.5),
            ),
            errorStyle: const TextStyle(
              color: _error,
              fontSize: 10,
              letterSpacing: 1,
              fontFamily: 'monospace',
            ),
          ),
          validator: (v) => v == null || v.trim().isEmpty ? 'REQUIRED' : null,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isCompact) {
    return SizedBox(
      width: double.infinity,
      height: isCompact ? 48 : 54,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (_, child) => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _accent.withOpacity(0.12 + _pulseAnimation.value * 0.10),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveSetup,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isLoading
                    ? [_surface, _surface]
                    : [const Color(0xFF0099CC), const Color(0xFF00D4FF)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isLoading ? _borderSubtle : _accent.withOpacity(0.4),
              ),
            ),
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: _accent,
                        strokeWidth: 1.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.qr_code_2_rounded,
                          color: _bg,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "SAVE  &  GENERATE QR",
                          style: TextStyle(
                            color: _bg,
                            fontSize: isCompact ? 12 : 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.5,
                            fontFamily: 'monospace',
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

  // ─────────────────────────────────────────
  // FOOTER
  // ─────────────────────────────────────────
  Widget _buildFooter(bool isCompact) {
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
