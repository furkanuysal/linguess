import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

BorderSide settingsContentBorderSide(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return BorderSide(
    color: scheme.outline,
    width: 1.5,
    strokeAlign: BorderSide.strokeAlignCenter,
  );
}

InputDecoration authInputDecoration(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return InputDecoration(
    fillColor: scheme.surface,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: scheme.error, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: scheme.error, width: 2),
    ),
  );
}

InputDecoration accountSettingsInputDecoration(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;

  return InputDecoration(
    filled: true,
    fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.25),
    labelStyle: TextStyle(
      color: scheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: scheme.outlineVariant.withValues(alpha: 0.3),
        width: 1.3,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.primary, width: 2.2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: scheme.outlineVariant.withValues(alpha: 0.1),
        width: 1,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.error, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.error, width: 2),
    ),
  );
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.centerTitle = true,
    this.leading,
    this.actions,
    this.bottom,
    this.titleSpacing,
    this.leadingWidth,
  });

  final String title;
  final String? subtitle;
  final bool centerTitle;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double? titleSpacing;
  final double? leadingWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      titleSpacing: titleSpacing,
      centerTitle: centerTitle,
      leading: leading,
      leadingWidth: leadingWidth,
      actions: actions,
      bottom: bottom,
      title: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: scheme.primary,
              shadows: const [
                Shadow(
                  blurRadius: 2,
                  offset: Offset(0, 1),
                  color: Color(0x33000000),
                ),
              ],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.surface.withValues(alpha: 0.10),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }
}

class WebAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WebAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textColor = scheme.primary;

    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.85),
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title and subtitle on the left side (clickable on web)
          Row(
            children: [
              GestureDetector(
                onTap: kIsWeb
                    ? () {
                        // Navigate to home page on title click
                        context.go('/');
                      }
                    : null,
                child: MouseRegion(
                  cursor: kIsWeb
                      ? SystemMouseCursors.click
                      : SystemMouseCursors.basic,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          shadows: const [
                            Shadow(
                              blurRadius: 2,
                              offset: Offset(0, 1),
                              color: Color(0x33000000),
                            ),
                          ],
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant.withValues(
                              alpha: 0.8,
                            ),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Right actions (e.g. sign-in button, profile)
          Row(mainAxisSize: MainAxisSize.min, children: actions ?? []),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.centerTitle = true,
    this.leading,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final bool centerTitle;
  final Widget? leading;
  final List<Widget>? actions;

  bool _isWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = _isWide(context);

    // Web or wide screens use WebAppBar
    if (kIsWeb || isWide) {
      return WebAppBar(title: title, subtitle: subtitle, actions: actions);
    }

    // Other cases use mobile CustomAppBar
    return CustomAppBar(
      title: title,
      subtitle: subtitle,
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
