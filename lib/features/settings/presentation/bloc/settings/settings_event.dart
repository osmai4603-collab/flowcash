import 'package:equatable/equatable.dart';
import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import '../../../domain/entities/app_value_entity.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class LoadCompanyInfoEvent extends SettingsEvent {}

class UpdateSettingEvent extends SettingsEvent {
  final AppValueEntity value;

  const UpdateSettingEvent(this.value);

  @override
  List<Object?> get props => [value];
}

class LoadCounterEvent extends SettingsEvent {
  final ValueCounterType counterType;

  const LoadCounterEvent(this.counterType);

  @override
  List<Object?> get props => [counterType];
}

class IncrementCounterEvent extends SettingsEvent {
  final ValueCounterType counterType;

  const IncrementCounterEvent(this.counterType);

  @override
  List<Object?> get props => [counterType];
}

class BackupDatabaseEvent extends SettingsEvent {
  final String destinationPath;

  const BackupDatabaseEvent(this.destinationPath);

  @override
  List<Object?> get props => [destinationPath];
}

class RestoreDatabaseEvent extends SettingsEvent {
  final String sourcePath;

  const RestoreDatabaseEvent(this.sourcePath);

  @override
  List<Object?> get props => [sourcePath];
}
