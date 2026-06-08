import 'package:flowcash/features/auth/domain/entities/program_user_entity.dart';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class UserCard extends StatelessWidget {
  final ProgramUserEntity user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const fluent.Icon(Icons.person),
        title: fluent.Text(user.userName),
        subtitle: fluent.Text(user.userType.name),
        trailing: fluent.Text('Branch ${user.warehouseId}'),
      ),
    );
  }
}
