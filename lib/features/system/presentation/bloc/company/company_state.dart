part of 'company_cubit.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();
}

class CompanyInitial extends CompanyState {
  const CompanyInitial();

  @override
  List<Object?> get props => [];
}

class CompanyLoading extends CompanyState {
  const CompanyLoading();

  @override
  List<Object?> get props => [];
}

class CompanySuccess extends CompanyState {
  final dynamic info;

  const CompanySuccess(this.info);

  @override
  List<Object?> get props => [info];
}

class CompanyFailure extends CompanyState {
  final String errorMessage;

  const CompanyFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
