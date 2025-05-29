import 'package:flutter/material.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final String _selectedLanguage = 'vi';

  final List<Map<String, dynamic>> _languages = [
    {'code': 'vi', 'name': 'Tiếng Việt', 'flag': '🇻🇳'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
    {'code': 'hi', 'name': 'हिन्दी', 'flag': '🇮🇳'},
    {'code': 'th', 'name': 'ไทย', 'flag': '🇹🇭'},
    {'code': 'id', 'name': 'Bahasa Indonesia', 'flag': '🇮🇩'},
    {'code': 'ms', 'name': 'Bahasa Melayu', 'flag': '🇲🇾'},
    {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
    {'code': 'pl', 'name': 'Polski', 'flag': '🇵🇱'},
    {'code': 'nl', 'name': 'Nederlands', 'flag': '🇳🇱'},
    {'code': 'sv', 'name': 'Svenska', 'flag': '🇸🇪'},
    {'code': 'no', 'name': 'Norsk', 'flag': '🇳🇴'},
    {'code': 'fi', 'name': 'Suomi', 'flag': '🇫🇮'},
    {'code': 'da', 'name': 'Dansk', 'flag': '🇩🇰'},
    {'code': 'cs', 'name': 'Čeština', 'flag': '🇨🇿'},
    {'code': 'ro', 'name': 'Română', 'flag': '🇷🇴'},
    {'code': 'hu', 'name': 'Magyar', 'flag': '🇭🇺'},
    {'code': 'el', 'name': 'Ελληνικά', 'flag': '🇬🇷'},
    {'code': 'he', 'name': 'עברית', 'flag': '🇮🇱'},
    {'code': 'ur', 'name': 'اردو', 'flag': '🇵🇰'},
    {'code': 'bn', 'name': 'বাংলা', 'flag': '🇧🇩'},
    {'code': 'ta', 'name': 'தமிழ்', 'flag': '🇮🇳'},
  ];

  void _onLanguageSelected(String code) {
    if (code != _selectedLanguage) {
      CustomSnackBar.showInfo(
        context: context,
        message: 'Chức năng đang được phát triển',
      );
      // Nếu muốn update ngay khi chọn:
      // setState(() {
      //   _selectedLanguage = code;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar(title: 'Ngôn ngữ', showBack: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _languages.length,
              separatorBuilder:
                  (_, __) => Divider(
                    height: 1,
                    color: Colors.grey.shade300,
                    indent: 16,
                    endIndent: 16,
                  ),
              itemBuilder: (context, index) {
                final lang = _languages[index];
                final isSelected = lang['code'] == _selectedLanguage;

                return RadioListTile<String>(
                  value: lang['code'],
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    if (value != null) _onLanguageSelected(value);
                  },
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      lang['name'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  secondary: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      lang['flag'],
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  activeColor: colorScheme.primary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  toggleable: false,
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: ElevatedButton(
          onPressed: () {
            CustomSnackBar.showInfo(
              context: context,
              message: 'Chức năng đang được phát triển',
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 4,
          ),
          child: const Text(
            'Áp dụng',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
