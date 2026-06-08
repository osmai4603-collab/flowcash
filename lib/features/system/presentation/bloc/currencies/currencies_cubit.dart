import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flowcash/features/system/domain/usecases/currency_usecases.dart';

part 'currencies_state.dart';
part 'currencies_event.dart';

class CurrenciesBloc extends Bloc<CurrenciesEvent, CurrenciesState> {
  final GetCurrenciesUseCase _getCurrencies;

  CurrenciesBloc(this._getCurrencies) : super(const CurrenciesInitial()) {
    on<LoadCurrenciesEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadCurrenciesEvent event,
    Emitter<CurrenciesState> emit,
  ) async {
    emit(const CurrenciesLoading());
    try {
      final res = await _getCurrencies();
      res.fold(
        (failure) => emit(CurrenciesFailure(failure.message)),
        (list) => emit(CurrenciesSuccess(list)),
      );
    } catch (e) {
      emit(CurrenciesFailure(e.toString()));
    }
  }
}
