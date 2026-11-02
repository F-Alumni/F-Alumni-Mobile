import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/profile/presentation/cubit/profile_cubit.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  late Future<List<Map<String, dynamic>>> _blockedUsers;

  @override
  void initState() {
    super.initState();
    _blockedUsers = context.read<ProfileCubit>().loadBlockedUsers();
  }

  Future<void> _unblock(String id) async {
    final error = await context.read<ProfileCubit>().unblockUser(id);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(
      () => _blockedUsers = context.read<ProfileCubit>().loadBlockedUsers(),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tài khoản đã chặn')),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _blockedUsers,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final rows = snapshot.data!;
        if (rows.isEmpty)
          return const Center(child: Text('Bạn chưa chặn tài khoản nào.'));
        return ListView.builder(
          itemCount: rows.length,
          itemBuilder: (context, index) {
            final row = rows[index];
            final id = '${row['blockedTargetUserId'] ?? ''}';
            return ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person_off_outlined),
              ),
              title: Text(id),
              subtitle: Text('${row['reason'] ?? ''}'),
              trailing: TextButton(
                onPressed: () => _unblock(id),
                child: const Text('Bỏ chặn'),
              ),
            );
          },
        );
      },
    ),
  );
}
