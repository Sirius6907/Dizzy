import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_theme.dart';

/// Dizzy standard section header with optional subtitle & action button
class DizzySectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final IconData? icon;

  const DizzySectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceM,
        vertical: AppTheme.spaceS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 22,
                    color: AppTheme.current.primaryColor,
                  ),
                  const SizedBox(width: AppTheme.spaceS),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onActionTap != null)
            TextButton(
              onPressed: onActionTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceM,
                  vertical: AppTheme.spaceXS,
                ),
                foregroundColor: AppTheme.current.accentColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Unified media poster/card with hover glow and focus support
class DizzyCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final String? badgeText;
  final VoidCallback onTap;
  final double width;
  final double height;
  final double aspectRatio;
  final IconData placeholderIcon;

  const DizzyCard({
    super.key,
    required this.title,
    required this.onTap,
    this.imageUrl,
    this.subtitle,
    this.badgeText,
    this.width = 140,
    this.height = 210,
    this.aspectRatio = 2 / 3,
    this.placeholderIcon = Icons.movie_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableControl(
      onTap: onTap,
      borderRadius: AppTheme.radiusM,
      glowColor: AppTheme.current.primaryColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.current.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image / Fallback
            if (imageUrl != null && imageUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.current.bgCard,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.current.bgCard,
                  child: Icon(
                    placeholderIcon,
                    color: Colors.white24,
                    size: 36,
                  ),
                ),
              )
            else
              Container(
                color: AppTheme.current.bgCard,
                child: Icon(
                  placeholderIcon,
                  color: Colors.white24,
                  size: 36,
                ),
              ),

            // Gradient Overlay for Text Readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.9),
                    ],
                    stops: const [0.5, 0.75, 1.0],
                  ),
                ),
              ),
            ),

            // Title & Subtitle at bottom
            Positioned(
              left: AppTheme.spaceS,
              right: AppTheme.spaceS,
              bottom: AppTheme.spaceS,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Badge / Tag (top right)
            if (badgeText != null && badgeText!.isNotEmpty)
              Positioned(
                top: AppTheme.spaceS,
                right: AppTheme.spaceS,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.current.primaryColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    badgeText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Dizzy Styled Action Button
class DizzyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isPrimary;
  final bool isFullWidth;

  const DizzyButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isPrimary = true,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isPrimary
        ? AppTheme.current.primaryColor
        : AppTheme.current.bgCard;
    final fg = isPrimary ? Colors.white : Colors.white70;

    Widget child = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceL,
        vertical: AppTheme.spaceM - 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: isPrimary
            ? null
            : Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: fg, size: 18),
            const SizedBox(width: AppTheme.spaceS),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );

    return FocusableControl(
      onTap: onTap,
      borderRadius: AppTheme.radiusM,
      glowColor: isPrimary ? AppTheme.current.primaryColor : Colors.white30,
      child: child,
    );
  }
}

/// Standardized Empty State View across all content tabs
class DizzyEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const DizzyEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceL),
            decoration: BoxDecoration(
              color: AppTheme.current.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: AppTheme.current.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spaceL),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spaceS),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white54,
                ),
          ),
          if (actionLabel != null && onActionTap != null) ...[
            const SizedBox(height: AppTheme.spaceXL),
            DizzyButton(
              label: actionLabel!,
              onTap: onActionTap!,
              icon: Icons.refresh_rounded,
            ),
          ],
        ],
      ),
    ),
  );
  }
}
