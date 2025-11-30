// lib/features/admin/presentation/pages/admin_panel_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class AdminPanelPage extends ConsumerStatefulWidget {
  const AdminPanelPage({super.key});

  @override
  ConsumerState<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends ConsumerState<AdminPanelPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final adminItems = [
      _AdminItem(
        title: l10n.addWordTitle,
        description: l10n.addWordDesc,
        icon: Icons.add_circle_outline,
        color: Colors.teal,
        route: '/admin/words/add',
      ),
      _AdminItem(
        title: l10n.wordsListText,
        description: l10n.wordsListDesc,
        icon: Icons.list_alt,
        color: Colors.indigo,
        route: '/admin/words',
      ),
      _AdminItem(
        title: l10n.dailyListText,
        description: l10n.dailyListDesc,
        icon: Icons.today,
        color: Colors.orange,
        route: '/admin/daily',
      ),
      _AdminItem(
        title: l10n.categoriesText,
        description: l10n.categoryListDesc,
        icon: Icons.category,
        color: Colors.purple,
        route: '/admin/categories',
      ),
      _AdminItem(
        title: l10n.shopManagementTitle,
        description: l10n.shopManagementDesc,
        icon: Icons.storefront,
        color: Colors.green,
        route: '/admin/shop',
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: l10n.adminPanelTitle,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.primary),
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;

                  // Responsive aspect ratio logic similar to HomeWeb
                  double aspect = 0.95;
                  if (screenWidth < 700) {
                    aspect = 1.1;
                  } else if (screenWidth < 1000) {
                    aspect = 1.0;
                  } else if (screenWidth < 1300) {
                    aspect = 0.9;
                  } else {
                    aspect = 0.85;
                  }

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 300,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: aspect,
                        ),
                        shrinkWrap: true,
                        itemCount: adminItems.length,
                        itemBuilder: (context, index) {
                          final item = adminItems[index];
                          return _AdminWebCard(
                            title: item.title,
                            description: item.description,
                            icon: item.icon,
                            color: item.color,
                            onTap: () => context.push(item.route),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  _AdminItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _AdminWebCard extends StatefulWidget {
  const _AdminWebCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_AdminWebCard> createState() => _AdminWebCardState();
}

class _AdminWebCardState extends State<_AdminWebCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 600;
    final titleFont = isNarrow ? 16.0 : 18.0;
    final descFont = isNarrow ? 13.0 : 14.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _hovered ? 1.03 : 1.0,
        child: Card(
          elevation: _hovered ? 6 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              constraints: const BoxConstraints(minHeight: 180),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [scheme.surface, scheme.surfaceContainerHigh],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(widget.icon, size: 38, color: widget.color),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: titleFont,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: descFont,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.fade,
                      maxLines: isNarrow ? 2 : 3,
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
