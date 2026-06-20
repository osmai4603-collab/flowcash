import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get_it/get_it.dart';

import 'package:flowcash/core/theme/color_schemes.dart';
import 'package:flowcash/features/app/presentation/bloc/app_bloc.dart';
import 'package:flowcash/features/app/presentation/bloc/app_event.dart';
import 'package:flowcash/features/app/presentation/bloc/app_state.dart';
import '../bloc/settings/settings_bloc.dart';
import '../bloc/settings/settings_event.dart';
import '../bloc/settings/settings_state.dart';
import '../widgets/setting_tile.dart';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Color _lightPrimaryColor;
  late Color _lightSecondaryColor;
  late Color _lightTertiaryColor;
  late Color _darkPrimaryColor;
  late Color _darkSecondaryColor;
  late Color _darkTertiaryColor;

  @override
  void initState() {
    super.initState();
    _lightPrimaryColor = ColorSchemes.lightPrimaryColor;
    _lightSecondaryColor = ColorSchemes.lightSecondaryColor;
    _lightTertiaryColor = ColorSchemes.lightTertiaryColor;
    _darkPrimaryColor = ColorSchemes.darkPrimaryColor;
    _darkSecondaryColor = ColorSchemes.darkSecondaryColor;
    _darkTertiaryColor = ColorSchemes.darkTertiaryColor;
  }

  Future<void> _pickColor(
    String title,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
  ) async {
    Color selectedColor = currentColor;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return fluent.ContentDialog(
          title: fluent.Text(title),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) => selectedColor = color,
              showLabel: true,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: false,
            ),
          ),
          actions: [
            fluent.Button(
              onPressed: () => Navigator.of(context).pop(),
              child: const fluent.Text('إلغاء'),
            ),
            fluent.FilledButton(
              onPressed: () {
                onColorChanged(selectedColor);
                Navigator.of(context).pop();
              },
              child: const fluent.Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateLightPrimaryColor(Color color) async {
    await ColorSchemes.setLightPrimaryColor(color);
    setState(() => _lightPrimaryColor = color);
    _refreshTheme();
  }

  Future<void> _updateLightSecondaryColor(Color color) async {
    await ColorSchemes.setLightSecondaryColor(color);
    setState(() => _lightSecondaryColor = color);
    _refreshTheme();
  }

  Future<void> _updateLightTertiaryColor(Color color) async {
    await ColorSchemes.setLightTertiaryColor(color);
    setState(() => _lightTertiaryColor = color);
    _refreshTheme();
  }

  Future<void> _updateDarkPrimaryColor(Color color) async {
    await ColorSchemes.setDarkPrimaryColor(color);
    setState(() => _darkPrimaryColor = color);
    _refreshTheme();
  }

  Future<void> _updateDarkSecondaryColor(Color color) async {
    await ColorSchemes.setDarkSecondaryColor(color);
    setState(() => _darkSecondaryColor = color);
    _refreshTheme();
  }

  Future<void> _updateDarkTertiaryColor(Color color) async {
    await ColorSchemes.setDarkTertiaryColor(color);
    setState(() => _darkTertiaryColor = color);
    _refreshTheme();
  }

  void _refreshTheme() {
    final appBloc = context.read<AppBloc>();
    final currentTheme = appBloc.state.appData.themeMode;
    appBloc.add(ThemeChanged(themeMode: currentTheme));
  }

  void _onThemeModeChanged(ThemeMode? mode) {
    if (mode == null) return;
    context.read<AppBloc>().add(ThemeChanged(themeMode: mode));
  }

  void _onLocaleChanged(Locale locale) {
    context.read<AppBloc>().add(LocaleChanged(locale: locale));
  }

  Future<void> _backupDatabase(BuildContext context) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'اختر مكان حفظ النسخة الاحتياطية',
        fileName: 'flowcash_backup_${DateTime.now().millisecondsSinceEpoch}.db',
        type: FileType.any,
      );

      if (result != null) {
        if (context.mounted) {
          context.read<SettingsBloc>().add(BackupDatabaseEvent(result));
        }
      }
    } catch (e) {
      if (context.mounted) {
        String message = 'حدث خطأ أثناء النسخ الاحتياطي: $e';
        if (e.toString().contains('zenity')) {
          message =
              'يرجى تثبيت حزمة zenity لاستخدام منتقي الملفات:\nsudo apt install zenity';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 7),
          ),
        );
      }
    }
  }

  Future<void> _restoreDatabase(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'اختر ملف قاعدة البيانات للاستعادة',
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        if (context.mounted) {
          context.read<SettingsBloc>().add(
            RestoreDatabaseEvent(result.files.single.path!),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        String message = 'حدث خطأ أثناء الاستعادة: $e';
        if (e.toString().contains('zenity')) {
          message =
              'يرجى تثبيت حزمة zenity لاستخدام منتقي الملفات:\nsudo apt install zenity';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 7),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<SettingsBloc>()..add(LoadSettingsEvent()),
      child: ScaffoldMessenger(
        child: Scaffold(
          appBar: AppBar(title: const fluent.Text('الإعدادات')),
          body: BlocListener<SettingsBloc, SettingsState>(
            listenWhen: (previous, current) =>
                previous.backupStatus != current.backupStatus ||
                previous.restoreStatus != current.restoreStatus,
            listener: (context, state) {
              if (state.backupStatus == SettingsStatus.loading) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('جاري النسخ الاحتياطي...')),
                );
              } else if (state.backupStatus == SettingsStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم النسخ الاحتياطي لقاعدة البيانات بنجاح'),
                  ),
                );
              } else if (state.backupStatus == SettingsStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.databaseErrorMessage ??
                          'فشل النسخ الاحتياطي لقاعدة البيانات',
                    ),
                  ),
                );
              }

              if (state.restoreStatus == SettingsStatus.loading) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جاري استعادة قاعدة البيانات...'),
                  ),
                );
              } else if (state.restoreStatus == SettingsStatus.success) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => fluent.ContentDialog(
                    title: const Text('نجاح الاستعادة'),
                    content: const Text(
                      'تم استعادة قاعدة البيانات بنجاح. يرجى إعادة تشغيل التطبيق لتطبيق التغييرات.',
                    ),
                    actions: [
                      fluent.FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('موافق'),
                      ),
                    ],
                  ),
                );
              } else if (state.restoreStatus == SettingsStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.databaseErrorMessage ??
                          'فشل استعادة قاعدة البيانات',
                    ),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  if (state.status == SettingsStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == SettingsStatus.failure) {
                    return Center(
                      child: fluent.Text(
                        state.errorMessage ?? 'فشل تحميل الإعدادات',
                      ),
                    );
                  }

                  return BlocBuilder<AppBloc, AppState>(
                    builder: (context, appState) {
                      return ListView(
                        children: [
                          const fluent.Text(
                            'المظهر',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          RadioListTile<ThemeMode>(
                            title: const fluent.Text('وضع النظام'),
                            value: ThemeMode.system,
                            groupValue: appState.appData.themeMode,
                            onChanged: _onThemeModeChanged,
                          ),
                          RadioListTile<ThemeMode>(
                            title: const fluent.Text('الوضع الفاتح'),
                            value: ThemeMode.light,
                            groupValue: appState.appData.themeMode,
                            onChanged: _onThemeModeChanged,
                          ),
                          RadioListTile<ThemeMode>(
                            title: const fluent.Text('الوضع الداكن'),
                            value: ThemeMode.dark,
                            groupValue: appState.appData.themeMode,
                            onChanged: _onThemeModeChanged,
                          ),
                          const SizedBox(height: 24),
                          const fluent.Text(
                            'اللغة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          DropdownButtonFormField<Locale>(
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            value: appState.appData.locale,
                            items: const [
                              DropdownMenuItem(
                                value: Locale('ar', 'YE'),
                                child: fluent.Text('العربية'),
                              ),
                              DropdownMenuItem(
                                value: Locale('en', 'US'),
                                child: fluent.Text('English'),
                              ),
                            ],
                            onChanged: (locale) {
                              if (locale != null) {
                                _onLocaleChanged(locale);
                              }
                            },
                          ),
                          // const SizedBox(height: 24),
                          // const fluent.Text(
                          //   'ألوان المظهر',
                          //   style: TextStyle(
                          //     fontSize: 18,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                          // const SizedBox(height: 12),
                          // const fluent.Text(
                          //   'الوضع الفاتح',
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.w600,
                          //   ),
                          // ),
                          // const SizedBox(height: 8),
                          // _buildColorTile(
                          //   title: 'اللون الأساسي الفاتح',
                          //   color: _lightPrimaryColor,
                          //   onTap: () => _pickColor(
                          //     'اختر اللون الأساسي للوضع الفاتح',
                          //     _lightPrimaryColor,
                          //     _updateLightPrimaryColor,
                          //   ),
                          // ),
                          // _buildColorTile(
                          //   title: 'اللون الثانوي الفاتح',
                          //   color: _lightSecondaryColor,
                          //   onTap: () => _pickColor(
                          //     'اختر اللون الثانوي للوضع الفاتح',
                          //     _lightSecondaryColor,
                          //     _updateLightSecondaryColor,
                          //   ),
                          // ),
                          // _buildColorTile(
                          //   title: 'اللون الثالثي الفاتح',
                          //   color: _lightTertiaryColor,
                          //   onTap: () => _pickColor(
                          //     'اختر اللون الثالثي للوضع الفاتح',
                          //     _lightTertiaryColor,
                          //     _updateLightTertiaryColor,
                          //   ),
                          // ),
                          // const SizedBox(height: 16),
                          // const fluent.Text(
                          //   'الوضع الداكن',
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.w600,
                          //   ),
                          // ),
                          // const SizedBox(height: 8),
                          // _buildColorTile(
                          //   title: 'اللون الأساسي الداكن',
                          //   color: _darkPrimaryColor,
                          //   onTap: () => _pickColor(
                          //     'اختر اللون الأساسي للوضع الداكن',
                          //     _darkPrimaryColor,
                          //     _updateDarkPrimaryColor,
                          //   ),
                          // ),
                          // _buildColorTile(
                          //   title: 'اللون الثانوي الداكن',
                          //   color: _darkSecondaryColor,
                          //   onTap: () => _pickColor(
                          //     'اختر اللون الثانوي للوضع الداكن',
                          //     _darkSecondaryColor,
                          //     _updateDarkSecondaryColor,
                          //   ),
                          // ),
                          // _buildColorTile(
                          //   title: 'اللون الثالثي الداكن',
                          //   color: _darkTertiaryColor,
                          //   onTap: () => _pickColor(
                          //     'اختر اللون الثالثي للوضع الداكن',
                          //     _darkTertiaryColor,
                          //     _updateDarkTertiaryColor,
                          //   ),
                          // ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 12),
                          const fluent.Text(
                            'قاعدة البيانات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            leading: const Icon(
                              Icons.backup,
                              color: Colors.blue,
                            ),
                            title: const Text(
                              'النسخ الاحتياطي لقاعدة البيانات',
                            ),
                            subtitle: const Text(
                              'حفظ نسخة احتياطية من بياناتك الحالية',
                            ),
                            onTap: () => _backupDatabase(context),
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.restore,
                              color: Colors.green,
                            ),
                            title: const Text('استعادة قاعدة البيانات'),
                            subtitle: const Text(
                              'استعادة البيانات من نسخة احتياطية سابقة',
                            ),
                            onTap: () => _restoreDatabase(context),
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 12),
                          if (state.values.isEmpty)
                            const Center(
                              child: fluent.Text('لا توجد إعدادات إضافية.'),
                            )
                          else
                            ...state.values.map((value) {
                              return SettingTile(
                                value: value,
                                onSave: (updatedValue) {
                                  context.read<SettingsBloc>().add(
                                    UpdateSettingEvent(updatedValue),
                                  );
                                },
                              );
                            }),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorTile({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(backgroundColor: color),
      title: fluent.Text(title),
      trailing: const fluent.Icon(Icons.chevron_right),
    );
  }
}
