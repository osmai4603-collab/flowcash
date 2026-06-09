import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class ProceedsView extends StatelessWidget {
  const ProceedsView({super.key});

  @override
  Widget build(BuildContext context) {
    return fluent.ScaffoldPage(
      header: const fluent.PageHeader(
        title: Row(
          children: [
            fluent.Icon(fluent.FluentIcons.money, size: 20),
            SizedBox(width: 10),
            fluent.Text('إسناد القبض'),
          ],
        ),
      ),
      content: const Center(
        child: fluent.Text('هنا سيتم عرض صفحة إسناد القبض.'),
      ),
    );
  }
}
