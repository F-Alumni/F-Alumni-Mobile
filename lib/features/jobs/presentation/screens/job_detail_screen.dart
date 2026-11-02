import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key, required this.jobId});
  final String jobId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: const Text('Chi tiết công việc'),
    ),
    body: const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Backend hiện chưa có API việc làm, ứng tuyển hoặc referral.',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
