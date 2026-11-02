import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:alumni_connect/core/theme/app_theme.dart';
import 'package:alumni_connect/core/router/app_router.dart';
import 'package:alumni_connect/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:alumni_connect/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:alumni_connect/features/feed/data/feed_repository.dart';
import 'package:alumni_connect/features/directory/presentation/cubit/directory_cubit.dart';
import 'package:alumni_connect/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:alumni_connect/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:alumni_connect/features/ai/presentation/cubit/ai_chat_cubit.dart';
import 'package:alumni_connect/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:alumni_connect/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:alumni_connect/core/network/alumni_api.dart';
import 'package:alumni_connect/features/auth/data/auth_repository.dart';
import 'package:alumni_connect/features/directory/data/directory_repository.dart';
import 'package:alumni_connect/features/profile/data/profile_repository.dart';
import 'package:alumni_connect/features/chat/data/chat_repository.dart';
import 'package:alumni_connect/features/ai/data/ai_repository.dart';
import 'package:alumni_connect/features/admin/data/admin_repository.dart';
import 'package:alumni_connect/features/notifications/data/fcm_messaging_service.dart';
import 'package:alumni_connect/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var openedFromNotification = false;
  if (FcmMessagingService.isSupportedPlatform &&
      DefaultFirebaseOptions.isConfigured) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    openedFromNotification = await FcmMessagingService.instance.initialize(
      onNotificationOpened: () => AppRouter.router.go('/notifications'),
    );
  }

  runApp(const FptAlumniConnectApp());
  if (openedFromNotification) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.router.go('/notifications');
    });
  }
}

class FptAlumniConnectApp extends StatelessWidget {
  const FptAlumniConnectApp({super.key});
  static final AlumniApi _api = AlumniApi();

  @override
  Widget build(BuildContext context) {
    final api = _api;
    return MultiBlocProvider(
      providers: [
        // Auth cubit MUST be first so router redirect can read it (US-01, US-02, US-03)
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(AuthRepository(api))..restoreSession(),
        ),
        BlocProvider<FeedCubit>(
          create: (_) => FeedCubit(FeedRepository(api))..loadFeed(),
        ),
        BlocProvider<DirectoryCubit>(
          create: (_) =>
              DirectoryCubit(DirectoryRepository(api), AiRepository(api))
                ..loadDirectory(),
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => ProfileCubit(ProfileRepository(api)),
        ),
        BlocProvider<JobsCubit>(create: (_) => JobsCubit()..loadJobs()),
        BlocProvider<AiChatCubit>(
          create: (_) => AiChatCubit(AiRepository(api))..loadChat(),
        ),
        BlocProvider<ChatCubit>(create: (_) => ChatCubit(ChatRepository(api))),
        BlocProvider<AdminCubit>(
          create: (_) => AdminCubit(AdminRepository(api))..loadAdminData(),
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
          scaffoldMessengerKey: FcmMessagingService.scaffoldMessengerKey,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
