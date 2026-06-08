import 'dart:io';

import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flowcash/core/theme/styles.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

void error({
  required BuildContext context,
  String title = 'خطأ',
  required String toast,
}) async {
  await showDialog(
    context: context,
    builder: (c) {
      return fluent.ContentDialog(
        content: SizedBox(
          width: 500.0,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const SizedBox(width: 5.0),
                            fluent.Icon(
                              fluent.FluentIcons.error,
                              size: 25,
                              color: Colors.red.shade500,
                            ),
                            const SizedBox(width: 10),
                            fluent.Text(
                              title,
                              style: Styles.titleMedium.copyWith(
                                color: Colors.red.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      fluent.IconButton(
                        icon: fluent.Icon(fluent.FluentIcons.chrome_close),
                        onPressed: () => Navigator.pop(c),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    alignment: RegExp(r'[A-Za-z]').hasMatch(toast[0])
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: TextWidget(
                      text: toast,
                      style: Styles.titleSmall,
                      textDirection: RegExp(r'[A-Za-z]').hasMatch(toast[0])
                          ? TextDirection.ltr
                          : TextDirection.rtl,
                      selectable: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

void successMessage({
  required BuildContext context,
  String title = 'نجاح',
  required String toast,
}) async {
  await showDialog(
    context: context,
    builder: (c) {
      return fluent.ContentDialog(
        content: SizedBox(
          width: 500.0,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const SizedBox(width: 5.0),
                            fluent.Icon(
                              fluent.FluentIcons.task_list,
                              size: 25,
                              color: ColorScheme.of(context).primary,
                            ),
                            const SizedBox(width: 10),
                            fluent.Text(
                              title,
                              style: Styles.titleMedium.copyWith(
                                color: ColorScheme.of(context).primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      fluent.IconButton(
                        icon: fluent.Icon(fluent.FluentIcons.chrome_close),
                        onPressed: () => Navigator.pop(c),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: fluent.Text(toast, style: Styles.titleSmall),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

void messageWithPath({
  required BuildContext context,
  String title = 'نجاح',
  required String toast,
  required String path,
}) async {
  await showDialog(
    context: context,
    builder: (c) {
      return fluent.ContentDialog(
        content: SizedBox(
          width: 500.0,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const SizedBox(width: 5.0),
                            fluent.Icon(
                              fluent.FluentIcons.task_list,
                              size: 25,
                              color: ColorScheme.of(context).primary,
                            ),
                            const SizedBox(width: 10),
                            fluent.Text(
                              title,
                              style: Styles.titleMedium.copyWith(
                                color: ColorScheme.of(context).primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      fluent.IconButton(
                        icon: fluent.Icon(fluent.FluentIcons.chrome_close),
                        onPressed: () => Navigator.pop(c),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        fluent.Text(
                          toast,
                          style: Styles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextWidget(
                          text: path,
                          style: Styles.titleSmall,
                          textDirection: TextDirection.ltr,
                          selectable: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: OutlinedButton.icon(
                      icon: fluent.Icon(fluent.FluentIcons.copy, size: 20),
                      label: fluent.Text(
                        'نسخ المسار',
                        style: Styles.bodyMedium,
                      ),
                      onPressed: () async {
                        Navigator.pop(c);
                        await Clipboard.setData(ClipboardData(text: path));
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> errorToast({
  required BuildContext context,
  String title = 'خطأ',
  required String toast,
}) async {
  if (Platform.isWindows || Platform.isLinux) {
    error(title: title, context: context, toast: toast);
    return;
  }
  final colors = ColorScheme.of(context);
  await Fluttertoast.showToast(
    msg: toast,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: colors.error,
    textColor: colors.surface,
    fontSize: 16.0,
  );
  return;
}

Future<void> successToast({
  required BuildContext context,
  String title = 'نجاح',
  required String toast,
}) async {
  if (Platform.isWindows || Platform.isLinux) {
    successMessage(title: title, context: context, toast: toast);
    return;
  }
  final colors = ColorScheme.of(context);
  await Fluttertoast.showToast(
    msg: toast,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: colors.primary,
    textColor: colors.surface,
    fontSize: 16.0,
  );
  return;
}

Future<void> successToastWithPath({
  required BuildContext context,
  String title = 'نجاح',
  required String toast,
  required String path,
}) async {
  if (Platform.isWindows || Platform.isLinux) {
    messageWithPath(title: title, path: path, context: context, toast: toast);
    return;
  }
  final colors = ColorScheme.of(context);
  await Fluttertoast.showToast(
    msg: '$toast\n$path',
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: colors.primary,
    textColor: colors.surface,
    fontSize: 16.0,
  );
  return;
}

Future<bool> makeSure({
  required BuildContext context,
  required String title,
  required String content,
  TextDirection? textDirection,
  bool okAutoFocus = false,
  bool cancelAutoFocus = false,
}) async {
  final colors = ColorScheme.of(context);
  final textTheme = TextTheme.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (c) {
          return fluent.ContentDialog(
            content: SizedBox(
              width: 400,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const SizedBox(width: 5.0),
                                fluent.Icon(
                                  fluent.FluentIcons.warning,
                                  size: 25,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 10),
                                fluent.Text(
                                  title,
                                  style: Styles.titleMedium.copyWith(
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          fluent.IconButton(
                            icon: fluent.Icon(
                              fluent.FluentIcons.chrome_close,
                              color: colors.onSurfaceVariant,
                            ),
                            onPressed: () => Navigator.pop(c),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: fluent.Text(
                          content,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.error,
                          ),
                          textDirection: textDirection,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        height: 40,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 300,
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: colors.secondaryContainer,
                                    foregroundColor:
                                        colors.onSecondaryContainer,
                                  ),
                                  autofocus: okAutoFocus,
                                  onPressed: () => Navigator.pop(c, true),

                                  child: const Align(
                                    child: fluent.Text('تأكيد'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: colors.secondaryContainer,
                                    foregroundColor:
                                        colors.onSecondaryContainer,
                                  ),
                                  autofocus: cancelAutoFocus,
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Align(
                                    child: fluent.Text('إلغاء'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ) ??
      false;
}

Future<void> process({
  required BuildContext context,
  bool dismissible = true,
}) async {
  showDialog(
    barrierDismissible: dismissible,
    context: context,
    builder: (_) {
      return Align(
        child: const SizedBox(
          width: 35,
          height: 35,
          child: Material(
            color: Colors.transparent,
            elevation: 2.0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            child: fluent.ProgressRing(),
          ),
        ),
      );
    },
    barrierColor: Colors.transparent,
  );
  await Future.delayed(const Duration(seconds: 1));
}
