import 'package:flutter/material.dart';
import 'package:lms/apps/utils/customAppBar.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(showBack: true, title: 'Ngôn ngữ'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLanguageOption(
            title: 'Tiếng Việt',
            subtitle: 'Vietnamese',
            isSelected: true,
            onTap: () {
              // Handle Vietnamese selection
            },
            theme: theme,
          ),
          _buildLanguageOption(
            title: 'English (US)',
            subtitle: 'American English',
            isSelected: false,
            onTap: () {
              // Handle English selection
            },
            theme: theme,
          ),
          _buildLanguageOption(
            title: '中文',
            subtitle: 'Chinese',
            isSelected: false,
            onTap: () {
              // Handle Chinese selection
            },
            theme: theme,
          ),
          _buildLanguageOption(
            title: '日本語',
            subtitle: 'Japanese',
            isSelected: false,
            onTap: () {
              // Handle Japanese selection
            },
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Icon(
          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
          color:
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        onTap: onTap,
      ),
    );
  }
}
