import 'app_enum.dart';

sealed class BatchStatus extends AppEnum {
  const BatchStatus();

  static const available = AvailableBatchStatus._();
  static const stopped = StoppedBatchStatus._();

  static const List<BatchStatus> values = [available, stopped];

  static BatchStatus of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown BatchStatus: $name'),
    );
  }
}

final class AvailableBatchStatus extends BatchStatus {
  const AvailableBatchStatus._();

  @override
  String get name => 'available';

  @override
  int get index => 0;

  @override
  String displayName() => 'متوفرة';
}

final class StoppedBatchStatus extends BatchStatus {
  const StoppedBatchStatus._();

  @override
  String get name => 'stopped';

  @override
  int get index => 1;

  @override
  String displayName() => 'موقفة';
}
