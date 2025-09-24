import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? action;

  const PageHeader({
    super.key,
    required this.title,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: 16),
          action!,
        ]
      ],
    );
  }
}