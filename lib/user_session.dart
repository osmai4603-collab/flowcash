import 'package:flowcash/core/entities/accounting_period_entity.dart';
import 'package:flowcash/core/enums/accounting_inventory_type_enum.dart';
import 'package:flowcash/core/usecases/accounting_period_repository_usecases.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'package:flutter/foundation.dart';
import 'package:flowcash/features/auth/domain/entities/program_user_entity.dart';

class UserSession extends ChangeNotifier {
  final GetWarehouseByIdUseCase _getWarehouse;
  final GetAccountingPeriodWhereIdOpenUseCase _getAccountPeriodWhereIdOpen;

  UserSession(this._getAccountPeriodWhereIdOpen, this._getWarehouse);

  ProgramUserEntity? _currentUser;
  AccountingPeriodEntity? _currentPeriod;
  WarehouseEntity? _currentWarehouse;

  ProgramUserEntity? get currentUser => _currentUser;
  AccountingPeriodEntity? get currentPeriod => _currentPeriod;
  WarehouseEntity? get currentWarehouse => _currentWarehouse;

  int get currentWarehouseId {
    final w = _currentWarehouse;
    if (w == null) {
      throw Exception('لم يتم تحديد المستودع الحالي.');
    }
    return w.id;
  }

  int get currentPeriodId {
    final p = _currentPeriod;
    if (p == null) {
      throw Exception('لم يتم تحديد الفترة المحاسبية الحالية.');
    }
    return p.id;
  }

  String get currentPeriodCurrencyId {
    final p = _currentPeriod;
    if (p == null) {
      throw Exception('لم يتم تحديد الفترة المحاسبية الحالية.');
    }
    return p.currencyId;
  }

  DateTime get currentPeriodStartDate {
    final p = _currentPeriod;
    if (p == null) {
      throw Exception('لم يتم تحديد الفترة المحاسبية الحالية.');
    }
    return p.dateOfStartPeriod;
  }

  bool get isAuthenticated => _currentUser != null;

  AccountingInventoryType? get accountingsPatternType {
    return currentPeriod?.inventoryType;
  }

  Future<void> initSession(ProgramUserEntity user) async {
    notifyListeners();

    _currentUser = user;
    _currentPeriod = null;
    _currentWarehouse = null;
    debugPrint('User ${user.userName} logged in.');
    debugPrint('Initializing session for user ${user.userName}...');
    final periodResult = await _getAccountPeriodWhereIdOpen();

    _currentPeriod = periodResult.fold(
      (failure) => throw Exception(failure.message),
      (period) {
        if (period == null) {
          throw Exception('لا توجد فترة محاسبية مفتوحة.');
        }
        return period;
      },
    );

    final warehouseResult = await _getWarehouse(user.warehouseId);
    warehouseResult.fold((failure) => throw Exception(failure.message), (
      warehouse,
    ) {
      if (warehouse == null) {
        throw Exception('المستودع المرتبط بالمستخدم غير موجود.');
      }
      _currentWarehouse = warehouse;
    });

    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _currentPeriod = null;
    _currentWarehouse = null;
    notifyListeners();
  }
}
