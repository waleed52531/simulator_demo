import 'package:flutter/material.dart';

import '../models/game_content.dart';

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    required this.choice,
    required this.isSelected,
    required this.hasAnswered,
    required this.onTap,
    super.key,
  });

  final ChoiceContent choice;
  final bool isSelected;
  final bool hasAnswered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedColor = choice.isBestChoice ? Colors.green : Colors.red;
    final borderColor = isSelected
        ? selectedColor
        : hasAnswered && choice.isBestChoice
            ? Colors.green
            : colorScheme.outlineVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: hasAnswered ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor.withOpacity(.08) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primary.withOpacity(.12),
                foregroundColor: colorScheme.primary,
                child: Text(choice.id),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      choice.text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${choice.tipMeterChange > 0 ? '+' : ''}${choice.tipMeterChange} · ${choice.tipMeterLabel}',
                      style: TextStyle(
                        color: choice.tipMeterChange >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasAnswered && choice.isBestChoice)
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}
