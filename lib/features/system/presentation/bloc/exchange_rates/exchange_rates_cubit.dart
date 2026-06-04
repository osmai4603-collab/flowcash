import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flowcash/features/system/domain/usecases/exchange_price_usecases.dart';

part 'exchange_rates_state.dart';
part 'exchange_rates_event.dart';

class ExchangeRatesBloc extends Bloc<ExchangeRatesEvent, ExchangeRatesState> {
  final GetExchangePricesUseCase _getExchangePrices;

  ExchangeRatesBloc(this._getExchangePrices) : super(const ExchangeRatesInitial()) {
    on<LoadExchangeRatesEvent>(_onLoad);
  }

  Future<void> _onLoad(LoadExchangeRatesEvent event, Emitter<ExchangeRatesState> emit) async {
    emit(const ExchangeRatesLoading());
    try {
      final res = await _getExchangePrices();
      res.fold(
        (failure) => emit(ExchangeRatesFailure(failure.message)),
        (list) => emit(ExchangeRatesSuccess(list)),
      );
    } catch (e) {
      emit(ExchangeRatesFailure(e.toString()));
    }
  }
}
