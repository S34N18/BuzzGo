import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Icon
            if (category.iconUrl.isNotEmpty)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : _getCategoryColor().withValues(alpha: 0.2),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  size: 12,
                  color: isSelected
                      ? Colors.white
                      : _getCategoryColor(),
                ),
              )
            else
              Icon(
                _getCategoryIcon(),
                size: 16,
                color: isSelected
                    ? Colors.white
                    : _getCategoryColor(),
              ),
            const SizedBox(width: 8),
            // Category Name
            Text(
              category.name,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : colorScheme.onSurface,
                fontSize: 14,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    try {
      // Parse hex color from category.color
      String colorString = category.color.replaceAll('#', '');
      if (colorString.length == 6) {
        colorString = 'FF$colorString'; // Add alpha if not present
      }
      return Color(int.parse(colorString, radix: 16));
    } catch (e) {
      // Return default color if parsing fails
      return Colors.blue;
    }
  }

  IconData _getCategoryIcon() {
    // Map category names to icons
    switch (category.name.toLowerCase()) {
      case 'music':
        return Icons.music_note;
      case 'sports':
        return Icons.sports;
      case 'food':
        return Icons.restaurant;
      case 'art':
        return Icons.palette;
      case 'technology':
        return Icons.computer;
      case 'business':
        return Icons.business;
      case 'education':
        return Icons.school;
      case 'health':
        return Icons.health_and_safety;
      case 'entertainment':
        return Icons.movie;
      case 'travel':
        return Icons.travel_explore;
      case 'fashion':
        return Icons.checkroom;
      case 'photography':
        return Icons.camera_alt;
      case 'gaming':
        return Icons.games;
      case 'fitness':
        return Icons.fitness_center;
      case 'networking':
        return Icons.people;
      case 'charity':
        return Icons.volunteer_activism;
      case 'outdoor':
        return Icons.nature;
      case 'workshop':
        return Icons.build;
      case 'conference':
        return Icons.event_seat;
      case 'party':
        return Icons.celebration;
      default:
        return Icons.event;
    }
  }
}