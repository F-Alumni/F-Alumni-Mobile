import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:alumni_connect/core/theme/app_theme.dart';
import 'package:alumni_connect/core/router/app_router.dart';
import 'package:alumni_connect/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:alumni_connect/features/auth/presentation/widgets/firebase_auth_session_guard.dart';
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
import 'package:alumni_connect/features/notifications/data/models/notification_model.dart';
import 'package:alumni_connect/features/lab3/data/services/firebase_crashlytics_service.dart';
import 'package:alumni_connect/features/lab3/data/services/firebase_auth_service.dart';
import 'package:alumni_connect/features/lab3/data/services/firebase_analytics_service.dart';
import 'package:alumni_connect/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  NotificationItem? initialNotification;
  if (DefaultFirebaseOptions.isConfigured) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (FcmMessagingService.isSupportedPlatform) {
        final crashlyticsService =
            FptAlumniConnectApp._firebaseCrashlyticsService;
        if (crashlyticsService != null) {
          FirebaseCrashlyticsService.installGlobalErrorHandlers(
            crashlyticsService,
          );
        }
        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );
        initialNotification = await FcmMessagingService.instance.initialize(
          onNotificationOpened: (notification) => AppRouter.router.go(
            FcmMessagingService.destinationFor(notification),
          ),
        );
      }
    } on Object catch (error, stackTrace) {
      debugPrint('Firebase initialization failed: $error\n$stackTrace');
    }
  }

  runApp(const ProviderScope(child: FptAlumniConnectApp()));
  if (initialNotification != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.router.go(
        FcmMessagingService.destinationFor(initialNotification!),
      );
    });
  }
}

class FptAlumniConnectApp extends StatelessWidget {
  const FptAlumniConnectApp({super.key});
  static final AlumniApi _api = AlumniApi();
  static final FirebaseAuthService? _firebaseAuthService = Firebase.apps.isEmpty
      ? null
      : FirebaseAuthService(FirebaseAuth.instance);
  static final FirebaseCrashlyticsService? _firebaseCrashlyticsService =
      Firebase.apps.isEmpty || !FcmMessagingService.isSupportedPlatform
      ? null
      : FirebaseCrashlyticsService(FirebaseCrashlytics.instance);
  static final FirebaseAnalyticsService? _firebaseAnalyticsService =
      Firebase.apps.isEmpty || !FcmMessagingService.isSupportedPlatform
      ? null
      : FirebaseAnalyticsService(FirebaseAnalytics.instance);

  @override
  Widget build(BuildContext context) {
    final api = _api;
    return MultiBlocProvider(
      providers: [
        // Auth cubit MUST be first so router redirect can read it (US-01, US-02, US-03)
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(
            AuthRepository(
              api,
              firebaseAuthService: _firebaseAuthService,
              analyticsService: _firebaseAnalyticsService,
              crashlyticsService: _firebaseCrashlyticsService,
            ),
          )..restoreSession(),
        ),
        BlocProvider<FeedCubit>(
          create: (_) => FeedCubit(
            FeedRepository(api),
            analyticsService: _firebaseAnalyticsService,
          )..loadFeed(),
        ),
        BlocProvider<DirectoryCubit>(
          create: (_) => DirectoryCubit(
            DirectoryRepository(api),
            AiRepository(api),
            analyticsService: _firebaseAnalyticsService,
          )..loadDirectory(),
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => ProfileCubit(ProfileRepository(api)),
        ),
        BlocProvider<JobsCubit>(
          create: (_) => JobsCubit(
            FeedRepository(api),
            analyticsService: _firebaseAnalyticsService,
          )..loadJobs(),
        ),
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
      child: FirebaseAuthSessionGuard(
        service: _firebaseAuthService,
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
      ),
    );
  }
}
