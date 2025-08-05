
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../data/model/category_modal.dart';
import '../../../../../main.dart';
import '../category_page.dart';
import 'image_preview_widget.dart';


class CategoryTile extends StatelessWidget {
  final int index;
  final CategoryModal category;
  final Color color;
  final bool isExpanded;
  final bool isSelected;
  final bool isSelectionMode;
  final DateTime timeNow;

  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onInfo;

  const CategoryTile({
    super.key,
    required this.index,
    required this.category,
    required this.color,
    required this.isExpanded,
    required this.isSelected,
    required this.isSelectionMode,
    required this.timeNow,

    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onDelete,
    required this.onInfo,
  });
  String dateFormatter(DateTime? at) {
    if (at == null) return "No data";
    final local = at.toLocal();
    final isToday =
        timeNow.year == local.year &&
            timeNow.month == local.month &&
            timeNow.day == local.day;
    return isToday
        ? DateFormat('hh:mm a').format(local)
        : DateFormat('dd MMM yyyy').format(local);
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,

      child: Card(
        margin: _getTileMargin(),
        elevation: 0,
        color: _getTileColor(theme),
        shape: RoundedRectangleBorder(
          borderRadius: _getTileBorderRadius(),
          side: _getTileBorderSide(theme),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildCategoryLeading(
                        theme,
                        onTapImage: () {
                          if (category.imageUrl == null) return;

                          rootNavigatorKey.currentState!.push(
                            PageRouteBuilder(
                              opaque: false,
                              barrierDismissible: true,
                              pageBuilder:
                                  (_, __, ___) => FullscreenImageViewer(
                                imageUrl: category.imageUrl!,
                              ),
                              transitionsBuilder:
                                  (_, anim, __, child) => FadeTransition(
                                opacity: anim,
                                child: child,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "${category.id} • ${dateFormatter(category.updatedAt)}",
                              style: theme.textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  if (isExpanded && !isSelectionMode) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _cupertinoActionButton(
                          Icons.edit_outlined,
                          'Edit',
                          onEdit,
                          theme,
                        ),
                        _cupertinoActionButton(
                          Icons.delete_outline_outlined,
                          'Delete',
                          onDelete,
                          theme,
                        ),
                        _cupertinoActionButton(
                          Icons.info_outline,
                          'Info',
                          onInfo,
                          theme,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  EdgeInsets _getTileMargin() {
    if (isSelected || isSelectionMode) {
      return const EdgeInsets.symmetric(horizontal: 0);
    }
    return EdgeInsets.symmetric(horizontal: isExpanded ? 8 : 0);
  }

  BorderRadius _getTileBorderRadius() {
    if (isSelected || isSelectionMode) return BorderRadius.zero;
    return isExpanded ? BorderRadius.circular(24) : BorderRadius.zero;
  }

  BorderSide _getTileBorderSide(ThemeData theme) {
    if (isSelected) return BorderSide.none;
    if (isExpanded) {
      return BorderSide(color: theme.colorScheme.outlineVariant, width: 1.0);
    }
    return BorderSide.none;
  }

  Color _getTileColor(ThemeData theme) {
    if (isSelected) return theme.colorScheme.primaryContainer;
    if (isExpanded) return theme.colorScheme.surfaceContainerLowest;//can be changes to cardColor matches with scaffold Color
    return theme.scaffoldBackgroundColor;
  }

  Widget _cupertinoActionButton(
      IconData icon,
      String label,
      VoidCallback onPressed,
      ThemeData theme,
      ) {
    return Expanded(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryLeading(ThemeData theme, {VoidCallback? onTapImage}) {
    const double size = 56;
    return GestureDetector(
      onTap: onTapImage,
      child: Hero(
        tag: category.imageUrl ?? category.id.toString(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
              category.imageUrl != null
                  ? theme.colorScheme.outlineVariant
                  : color.withAlpha(100),
              width: 0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
            category.imageUrl != null && category.imageUrl!.isNotEmpty
                ? Image.network(
              category.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: color.withAlpha(180),
                  size: 20,
                ),
              ),
              loadingBuilder:
                  (_, child, progress) =>
              progress == null
                  ? child
                  : const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                ),
              ),
            )
                : Center(
              child: Text(
                '${category.id ?? index}',
                style: TextStyle(
                  color: color.withAlpha(180),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

