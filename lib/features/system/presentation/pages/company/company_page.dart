import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/system/presentation/bloc/company/company_cubit.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
class CompanyPage extends StatelessWidget {
  const CompanyPage({super.key});
 
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyBloc, CompanyState>(
      builder: (context, state) {
        if (state is CompanyLoading) {
          return const Center(child: fluent.ProgressRing());
        }
        if (state is CompanyFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Text(state.errorMessage),
                const SizedBox(height: 8),
                fluent.FilledButton(
                  onPressed: () => context.read<CompanyBloc>().add(LoadCompanyEvent()),
                  child: const fluent.Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        if (state is CompanySuccess) {
          final company = state.info;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                fluent.Text(company?.name ?? 'اسم الشركة', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                fluent.Text(company?.address ?? ''),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
