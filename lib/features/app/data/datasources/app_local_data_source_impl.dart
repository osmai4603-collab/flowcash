import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_model.dart';
import 'app_local_data_source.dart';

const appDataCacheKey = 'APP_DATA_CACHE';

class AppLocalDataSourceImpl implements AppLocalDataSource {
  final SharedPreferences sharedPreferences;

  AppLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<AppModel> getAppData() {
    final jsonString = sharedPreferences.getString(appDataCacheKey);
    if (jsonString != null) {
      return Future.value(AppModel.fromJson(jsonDecode(jsonString)));
    } else {
      return Future.value(
        const AppModel(themeMode: ThemeMode.system, locale: Locale('ar', 'YE')),
      );
    }
  }

  @override
  Future<void> saveAppData(AppModel appModel) {
    return sharedPreferences.setString(
      appDataCacheKey,
      jsonEncode(appModel.toJson()),
    );
  }
}
