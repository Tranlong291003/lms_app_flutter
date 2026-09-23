import 'package:flutter/material.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/utils/customAppBar.dart';

/// Màn hình chọn ngôn ngữ.
///
/// ## Vì sao chỉ còn tiếng Việt
///
/// Trước đây màn hình liệt kê 31 ngôn ngữ, nhưng **không có hạ tầng đa ngôn ngữ
/// nào trong app**: không có `flutter_localizations`, không có file `.arb`, và
/// không dòng code nào đọc giá trị ngôn ngữ đã chọn. Chọn "English" chỉ hiện
/// snackbar "Chức năng đang được phát triển" rồi danh sách vẫn đứng yên —
/// trông như app bị treo.
///
/// Danh sách trung thực với những gì app thực sự hỗ trợ. Khi nào thêm được
/// `AppLocalizations`, việc cần làm là: bật `flutter_localizations`, tạo file
/// `.arb`, và đọc lại lựa chọn ở đây.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Ngôn ngữ', showBack: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Card(
            child: ClipRRect(
              borderRadius: AppRadius.borderLg,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                title: Text(
                  'Tiếng Việt',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Ngôn ngữ duy nhất hiện được hỗ trợ',
                  style: theme.textTheme.bodySmall,
                ),
                leading: const Text('🇻🇳', style: TextStyle(fontSize: 28)),
                // Chỉ có một lựa chọn nên hiện dấu chọn thay vì nút radio có
                // thể bấm — nút bấm được mà không đổi gì sẽ gây hiểu sai.
                trailing: Icon(
                  Icons.check_circle_rounded,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
