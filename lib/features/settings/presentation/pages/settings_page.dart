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

import 'package:fluent_ui/fluent_ui.dart' show ContentDialog, ProgressRing;
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

  Future<void> _pickColor(String title, Color currentColor, ValueChanged<Color> onColorChanged) async {
    Color selectedColor = currentColor;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: Text(title),
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                onColorChanged(selectedColor);
                Navigator.of(context).pop();
              },
              child: const Text('حفظ'),
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<SettingsBloc>()..add(LoadSettingsEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('الإعدادات')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
                if (state.status == SettingsStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == SettingsStatus.failure) {
                return Center(
                  child: Text(state.errorMessage ?? 'فشل تحميل الإعدادات'),
                );
              }

              return BlocBuilder<AppBloc, AppState>(
                builder: (context, appState) {
                  return ListView(
                    children: [
                      const Text(
                        'المظهر',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('وضع النظام'),
                        value: ThemeMode.system,
                        groupValue: appState.appData.themeMode,
                        onChanged: _onThemeModeChanged,
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('الوضع الفاتح'),
                        value: ThemeMode.light,
                        groupValue: appState.appData.themeMode,
                        onChanged: _onThemeModeChanged,
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('الوضع الداكن'),
                        value: ThemeMode.dark,
                        groupValue: appState.appData.themeMode,
                        onChanged: _onThemeModeChanged,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'اللغة',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      DropdownButtonFormField<Locale>(
                        decoration: const InputDecoration(
                          
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        value: appState.appData.locale,
                        items: const [
                          DropdownMenuItem(
                            value: Locale('ar', 'YE'),
                            child: Text('العربية'),
                          ),
                          DropdownMenuItem(
                            value: Locale('en', 'US'),
                            child: Text('English'),
                          ),
                        ],
                        onChanged: (locale) {
                          if (locale != null) {
                            _onLocaleChanged(locale);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'ألوان المظهر',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'الوضع الفاتح',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      _buildColorTile(
                        title: 'اللون الأساسي الفاتح',
                        color: _lightPrimaryColor,
                        onTap: () => _pickColor('اختر اللون الأساسي للوضع الفاتح', _lightPrimaryColor, _updateLightPrimaryColor),
                      ),
                      _buildColorTile(
                        title: 'اللون الثانوي الفاتح',
                        color: _lightSecondaryColor,
                        onTap: () => _pickColor('اختر اللون الثانوي للوضع الفاتح', _lightSecondaryColor, _updateLightSecondaryColor),
                      ),
                      _buildColorTile(
                        title: 'اللون الثالثي الفاتح',
                        color: _lightTertiaryColor,
                        onTap: () => _pickColor('اختر اللون الثالثي للوضع الفاتح', _lightTertiaryColor, _updateLightTertiaryColor),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'الوضع الداكن',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      _buildColorTile(
                        title: 'اللون الأساسي الداكن',
                        color: _darkPrimaryColor,
                        onTap: () => _pickColor('اختر اللون الأساسي للوضع الداكن', _darkPrimaryColor, _updateDarkPrimaryColor),
                      ),
                      _buildColorTile(
                        title: 'اللون الثانوي الداكن',
                        color: _darkSecondaryColor,
                        onTap: () => _pickColor('اختر اللون الثانوي للوضع الداكن', _darkSecondaryColor, _updateDarkSecondaryColor),
                      ),
                      _buildColorTile(
                        title: 'اللون الثالثي الداكن',
                        color: _darkTertiaryColor,
                        onTap: () => _pickColor('اختر اللون الثالثي للوضع الداكن', _darkTertiaryColor, _updateDarkTertiaryColor),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),
                      if (state.values.isEmpty)
                        const Center(child: Text('لا توجد إعدادات إضافية.'))
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
                        }).toList(),
                    ],
                  );
                },
              );
            },
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
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
