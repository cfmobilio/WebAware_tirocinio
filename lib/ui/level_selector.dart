import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/content_viewmodel.dart';
import '../../models/content_model.dart';

class LevelSelector extends StatelessWidget {
  final String argomento;
  final int userAssignedLevel; // Livello assegnato dal quiz
  final Function(int)? onLevelChanged;

  const LevelSelector({
    Key? key,
    required this.argomento,
    required this.userAssignedLevel,
    this.onLevelChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentViewModel>(
      builder: (context, contentViewModel, child) {
        if (contentViewModel.availableLevels.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tune,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Livello di Approfondimento',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  if (contentViewModel.selectedLevel != userAssignedLevel)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Personalizzato',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: contentViewModel.availableLevels.map((level) {
                    final isSelected = level == contentViewModel.selectedLevel;
                    final isUserLevel = level == userAssignedLevel;
                    final levelName = contentViewModel.getLevelName(level);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _LevelChip(
                        level: level,
                        levelName: levelName,
                        isSelected: isSelected,
                        isUserAssignedLevel: isUserLevel,
                        onTap: () async {
                          await contentViewModel.changeLevel(argomento, level);
                          onLevelChanged?.call(level);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (contentViewModel.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LevelChip extends StatelessWidget {
  final int level;
  final String levelName;
  final bool isSelected;
  final bool isUserAssignedLevel;
  final VoidCallback onTap;

  const _LevelChip({
    required this.level,
    required this.levelName,
    required this.isSelected,
    required this.isUserAssignedLevel,
    required this.onTap,
  });

  Color _getChipColor(BuildContext context) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getChipIcon() {
    switch (level) {
      case 1:
        return Icons.school;
      case 2:
        return Icons.trending_up;
      case 3:
        return Icons.psychology;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = _getChipColor(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : chipColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: chipColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getChipIcon(),
              size: 16,
              color: isSelected ? Colors.white : chipColor,
            ),
            const SizedBox(width: 6),
            Text(
              levelName,
              style: TextStyle(
                color: isSelected ? Colors.white : chipColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            if (isUserAssignedLevel && !isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.home,
                size: 12,
                color: chipColor,
              ),
            ],
            if (isUserAssignedLevel && isSelected) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.home,
                size: 12,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget helper per mostrare il contenuto
class ContentDisplay extends StatelessWidget {
  final ContentModel content;

  const ContentDisplay({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.titolo,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content.descrizione,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
            if (content.videoUrl != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_filled, size: 48),
                      SizedBox(height: 8),
                      Text('Video Esplicativo'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}