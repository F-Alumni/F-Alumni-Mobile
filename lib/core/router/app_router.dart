import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:alumni_connect/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:alumni_connect/features/auth/presentation/screens/login_screen.dart';
import 'package:alumni_connect/features/shared/main_scaffold_wrapper.dart';
import 'package:alumni_connect/features/feed/presentation/screens/home_screen.dart';
import 'package:alumni_connect/features/feed/presentation/screens/post_detail_screen.dart';
import 'package:alumni_connect/features/feed/presentation/screens/create_post_screen.dart';
import 'package:alumni_connect/features/directory/presentation/screens/directory_screen.dart';
import 'package:alumni_connect/features/directory/presentation/screens/alumni_profile_screen.dart';
import 'package:alumni_connect/features/mentorship/presentation/screens/booking_screen.dart';
import 'package:alumni_connect/features/profile/presentation/screens/user_profile_screen.dart';
import 'package:alumni_connect/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:alumni_connect/features/jobs/presentation/screens/jobs_screen.dart';
import 'package:alumni_connect/features/jobs/presentation/screens/job_detail_screen.dart';
import 'package:alumni_connect/features/ai/presentation/screens/ai_assistant_screen.dart';
import 'package:alumni_connect/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:alumni_connect/features/chat/presentation/screens/direct_messages_screen.dart';
import 'package:alumni_connect/features/admin/presentation/screens/admin_dashboard_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  // Track login state for redirect logic (US-01, US-02, US-03)
  static String? _redirectBasedOnAuth(BuildContext context, GoRouterState state) {
    final authState = context.read<AuthCubit>().state;
    final isAuthenticated = authState is AuthAuthenticated;

    final publicRoutes = {'/onboarding', '/login'};
    final isPublicRoute = publicRoutes.contains(state.matchedLocation);

    if (!isAuthenticated && !isPublicRoute) {
      // Not logged in → go to onboarding
      return '/onboarding';
    }
    if (isAuthenticated && isPublicRoute) {
      // Already logged in → skip auth screens
      return '/';
    }
    return null; // No redirect needed
  }

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding',
    redirect: _redirectBasedOnAuth,
    routes: [
      // ── Auth Routes (US-01, US-02, US-03) ─────────────────────────────────
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),

      // ── Main App Shell (5 tabs) ────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffoldWrapper(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Feed
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Tab 2: Mentors / Directory
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/directory',
                builder: (context, state) => const DirectoryScreen(),
              ),
            ],
          ),
          // Tab 3: Jobs (Career & OJT Opportunities)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/jobs',
                builder: (context, state) => const JobsScreen(),
              ),
            ],
          ),
          // Tab 4: AI Assistant (Alumni AI Knowledge Assistant)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ai-assistant',
                builder: (context, state) => const AiAssistantScreen(),
              ),
            ],
          ),
          // Tab 5: Profile (Student Profile Tab)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const UserProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Admin Management Hub Route (AD-01 to AD-08) ────────────────────────
      GoRoute(
        path: '/admin',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // ── Standalone Detail Routes ───────────────────────────────────────────
      GoRoute(
        path: '/chats',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'chat_thao';
          return DirectMessagesScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: '/job-detail/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'job_1';
          return JobDetailScreen(jobId: id);
        },
      ),
      GoRoute(
        path: '/post-detail/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'post_thao';
          return PostDetailScreen(postId: id);
        },
      ),
      GoRoute(
        path: '/create-post',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/alumni-profile/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'alumni_1';
          return AlumniProfileScreen(alumniId: id);
        },
      ),
      GoRoute(
        path: '/booking/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'alumni_1';
          return BookingScreen(alumniId: id);
        },
      ),
    ],
  );
}
