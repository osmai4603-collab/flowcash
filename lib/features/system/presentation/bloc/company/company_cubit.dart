import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'company_state.dart';
part 'company_event.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  CompanyBloc() : super(const CompanyInitial()) {
    on<LoadCompanyEvent>(_onLoad);
  }

  Future<void> _onLoad(LoadCompanyEvent event, Emitter<CompanyState> emit) async {
    emit(const CompanyLoading());
    await Future.delayed(const Duration(milliseconds: 50));
    emit(const CompanySuccess(null));
  }
}
