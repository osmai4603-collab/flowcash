import '../models/app_model.dart';

abstract class AppLocalDataSource {
  Future<AppModel> getAppData();
  Future<void> saveAppData(AppModel appModel);
}
