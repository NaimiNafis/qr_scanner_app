import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/result/content_card.dart';
import '../../widgets/result/result_action_button.dart';
import '../../widgets/result/safety_indicator.dart';

class ResultContentView extends StatelessWidget {
  final String content;
  final String type;
  final IconData typeIcon;
  final VoidCallback? onOpen;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  
  const ResultContentView({
    super.key,
    required this.content,
    required this.type,
    required this.typeIcon,
    this.onOpen,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Content type heading
        Text(
          type,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 30),
        
        // Content display
        ContentCard(
          type: type,
          content: content,
          icon: typeIcon,
        ),
        
        // Safety check for URLs
        if (type == 'URL')
          const SafetyIndicator(),
        
        const Spacer(),
        
        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              // OPEN button (for URLs)
              if (onOpen != null)
                ResultActionButton(
                  icon: Icons.chevron_right,
                  text: 'OPEN',
                  onTap: onOpen!,
                ),
              
              if (onOpen != null) const SizedBox(height: 15),
              
              // COPY button
              ResultActionButton(
                icon: Icons.copy,
                text: 'COPY',
                onTap: onCopy,
              ),
              
              const SizedBox(height: 15),
              
              // SHARE button
              ResultActionButton(
                icon: Icons.share,
                text: 'SHARE',
                onTap: onShare,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 