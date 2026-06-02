import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/core/enums/app_value_type_enum.dart';
import 'package:get_it/get_it.dart';

import '../bloc/settings/settings_bloc.dart';
import '../bloc/settings/settings_event.dart';
import '../bloc/settings/settings_state.dart';
import '../widgets/setting_tile.dart';

class CompanyInfoPage extends StatelessWidget {
  const CompanyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<SettingsBloc>()..add(LoadSettingsEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Company Info')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              if (state.status == SettingsStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == SettingsStatus.failure) {
                return Center(child: Text(state.errorMessage ?? 'Failed to load company info'));
              }
              final companyValues = state.values.where((value) => value.valueType == AppValueType.companyName || value.valueType == AppValueType.companyAddress).toList();
              if (companyValues.isEmpty) {
                return const Center(child: Text('No company settings available.'));
              }
              return ListView(
                children: companyValues.map((value) {
                  return SettingTile(
                    value: value,
                    onSave: (updatedValue) {
                      context.read<SettingsBloc>().add(UpdateSettingEvent(updatedValue));
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
