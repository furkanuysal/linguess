import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({
    super.key,
    required this.onPressed,
    this.text = 'Sign in with Google',
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final l10n = AppLocalizations.of(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Light (neutral)
    const lightBg = Color(0xFFF2F2F2);
    const lightText = Color(0xFF1F1F1F);

    // Dark (neutral)
    const darkBg = Color(0xFF131314);
    const darkText = Color(0xFFE3E3E3);
    const darkStroke = Color(0xFF8E918F); // 1px

    final bg = isDark ? darkBg : lightBg;
    final textColor = isDark ? darkText : lightText;
    final border = isDark ? Border.all(color: darkStroke, width: 1) : null;
    final logoAsset = 'assets/auth/google_g_logo.svg';

    final btn = Material(
      color: bg,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: enabled ? onPressed : null,
        // tap effects
        splashColor: (isDark ? Colors.white : Colors.black).withValues(
          alpha: 0.08,
        ),
        highlightColor: (isDark ? Colors.white : Colors.black).withValues(
          alpha: 0.06,
        ),
        hoverColor: (isDark ? Colors.white : Colors.black).withValues(
          alpha: 0.04,
        ),
        focusColor: (isDark ? Colors.white : Colors.black).withValues(
          alpha: 0.06,
        ),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: border,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 14),
              // Logo
              SizedBox(
                width: 24,
                height: 24,
                child: SvgPicture.asset(logoAsset, fit: BoxFit.contain),
              ),
              Expanded(
                child: Text(
                  isLoading ? l10n!.loadingText : text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    letterSpacing: .2,
                  ),
                ),
              ),
              const SizedBox(width: 24),
            ],
          ),
        ),
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: enabled ? 1 : 0.6, child: btn),
        if (isLoading)
          const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}
