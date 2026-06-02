import 'package:flowcash/features/auth/domain/entities/program_user_entity.dart';
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final ProgramUserEntity user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(user.userName),
        subtitle: Text(user.userType.name),
        trailing: Text('Branch ${user.warehouseId}'),
      ),
    );
  }
}
