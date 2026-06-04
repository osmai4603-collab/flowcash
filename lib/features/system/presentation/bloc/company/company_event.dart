part of 'company_cubit.dart';

abstract class CompanyEvent extends Equatable {
  const CompanyEvent();

  @override
  List<Object?> get props => [];
}

class LoadCompanyEvent extends CompanyEvent {}
