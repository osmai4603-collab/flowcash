import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/core/enums/user_type_enum.dart';
import 'package:flowcash/features/auth/domain/entities/program_user_entity.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../widgets/user_card.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class UsersManagementPage extends StatelessWidget {
  const UsersManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return fluent.ScaffoldPage(
      header: fluent.PageHeader(
        title: const fluent.Text('إدارة المستخدمين'),
        commandBar: fluent.CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            fluent.CommandBarButton(
              icon: const fluent.Icon(fluent.FluentIcons.add),
              label: const fluent.Text('إضافة مستخدم'),
              onPressed: () {
                final newUser = ProgramUserEntity(
                  id: 0,
                  userName: 'New User',
                  password: 'pass123',
                  userType: UserType.user,
                  warehouseId: 1,
                );
                context.read<AuthBloc>().add(AddUserEvent(newUser));
              },
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.status == AuthStatus.loading) {
              return const Center(child: fluent.ProgressRing());
            }
            if (state.status == AuthStatus.failure) {
              return Center(
                child: fluent.Text(
                  state.errorMessage ?? 'Failed to load users',
                ),
              );
            }
            if (state.users.isEmpty) {
              return const Center(child: fluent.Text('No users found.'));
            }
            return ListView(
              children: state.users.map((user) {
                return UserCard(user: user);
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
