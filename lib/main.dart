import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/core/theme/app_theme.dart';
import 'package:alumni_connect/core/router/app_router.dart';
import 'package:alumni_connect/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:alumni_connect/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:alumni_connect/features/directory/presentation/cubit/directory_cubit.dart';
import 'package:alumni_connect/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:alumni_connect/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:alumni_connect/features/ai/presentation/cubit/ai_chat_cubit.dart';
import 'package:alumni_connect/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:alumni_connect/features/admin/presentation/cubit/admin_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FptAlumniConnectApp());
}

class FptAlumniConnectApp extends StatelessWidget {
  const FptAlumniConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth cubit MUST be first so router redirect can read it (US-01, US-02, US-03)
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(),
        ),
        BlocProvider<FeedCubit>(
          create: (_) => FeedCubit()..loadFeed(),
        ),
        BlocProvider<DirectoryCubit>(
          create: (_) => DirectoryCubit()..loadDirectory(),
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => ProfileCubit()..loadProfile(),
        ),
        BlocProvider<JobsCubit>(
          create: (_) => JobsCubit()..loadJobs(),
        ),
        BlocProvider<AiChatCubit>(
          create: (_) => AiChatCubit()..loadChat(),
        ),
        BlocProvider<ChatCubit>(
          create: (_) => ChatCubit()..loadChats(),
        ),
        BlocProvider<AdminCubit>(
          create: (_) => AdminCubit()..loadAdminData(),
        ),
      ],
      // BlocListener at root level: refresh router on every auth state change
      // so GoRouter redirect logic re-evaluates after login / logout (US-08)
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          AppRouter.router.refresh();
        },
        child: MaterialApp.router(
          title: 'FPT Alumni Connect',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
