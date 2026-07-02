import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/core/widgets/table_widget.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TableWidget renders inside SingleChildScrollView without layout assertion', (
    tester,
  ) async {
    await tester.pumpWidget(
      FluentTheme(
        data: FluentThemeData(extensions: [AppStyle.light]),
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TableWidget<String>(
                columns: const {
                  0: FixedTableWidgetColumnWidth(80),
                },
                header: const ['Name'],
                items: const ['Alice'],
                shrinkWrap: true,
                builder: (context, item, index) {
                  return [Text(item)];
                },
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Alice'), findsOneWidget);
  });
}
