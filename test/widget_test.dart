import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alumni_connect/core/network/alumni_api.dart';
import 'package:alumni_connect/core/theme/app_theme.dart';
import 'package:alumni_connect/features/ai/data/ai_repository.dart';
import 'package:alumni_connect/features/ai/data/models/ai_chat_model.dart';
import 'package:alumni_connect/features/ai/presentation/cubit/ai_chat_cubit.dart';
import 'package:alumni_connect/features/ai/presentation/screens/ai_assistant_screen.dart';
import 'package:alumni_connect/features/directory/data/directory_repository.dart';
import 'package:alumni_connect/features/directory/data/models/alumni_model.dart';
import 'package:alumni_connect/features/directory/presentation/cubit/directory_cubit.dart';
import 'package:alumni_connect/features/directory/presentation/screens/directory_screen.dart';
import 'package:alumni_connect/features/feed/data/feed_repository.dart';
import 'package:alumni_connect/features/feed/data/models/feed_models.dart';
import 'package:alumni_connect/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:alumni_connect/features/feed/presentation/screens/home_screen.dart';
import 'package:alumni_connect/features/jobs/data/models/job_model.dart';
import 'package:alumni_connect/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:alumni_connect/features/jobs/presentation/screens/jobs_screen.dart';
import 'package:alumni_connect/main.dart';

Widget _buildTestHarness({
  required Widget child,
  required FeedCubit feedCubit,
  required DirectoryCubit directoryCubit,
  required JobsCubit jobsCubit,
  required AiChatCubit aiChatCubit,
  bool clampTextScale = true,
}) {
  return ProviderScope(
    child: MultiBlocProvider(
      providers: [
        BlocProvider<FeedCubit>.value(value: feedCubit),
        BlocProvider<DirectoryCubit>.value(value: directoryCubit),
        BlocProvider<JobsCubit>.value(value: jobsCubit),
        BlocProvider<AiChatCubit>.value(value: aiChatCubit),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, appChild) {
          if (!clampTextScale) return appChild ?? const SizedBox.shrink();
          final mediaQuery = MediaQuery.of(context);
          final clamped = mediaQuery.textScaler.clamp(
            minScaleFactor: 0.85,
            maxScaleFactor: 1.15,
          );
          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: clamped),
            child: appChild ?? const SizedBox.shrink(),
          );
        },
        home: child,
      ),
    ),
  );
}

void main() {
  late AlumniApi api;
  late FeedCubit feedCubit;
  late DirectoryCubit directoryCubit;
  late JobsCubit jobsCubit;
  late AiChatCubit aiChatCubit;

  setUp(() {
    api = AlumniApi();
    feedCubit = FeedCubit(FeedRepository(api));
    directoryCubit = DirectoryCubit(DirectoryRepository(api), AiRepository(api));
    jobsCubit = JobsCubit(FeedRepository(api));
    aiChatCubit = AiChatCubit(AiRepository(api));

    feedCubit.emit(
      FeedLoaded(
        stories: const [
          MentorStory(
            id: 's1',
            name: 'Nguyễn Hoàng Phương Trang',
            role: 'Senior Architect',
            avatarUrl: '',
            isUser: true,
          ),
        ],
        posts: const [
          PostItem(
            id: 'p1',
            authorName: 'Trần Minh Hoàng Phúc (K14 SE)',
            authorRole: 'Tech Lead @ FPT Software',
            authorAvatar: '',
            timeAgo: '15 phút trước',
            title:
                'Chia sẻ kinh nghiệm phỏng vấn OJT & Fresher ngành Kỹ thuật phần mềm tại FPT Software Hòa Lạc',
            content:
                'Tổng hợp lộ trình ôn tập cấu trúc dữ liệu, giải thuật và kiến trúc hệ thống microservices.',
            campus: 'FU-HL',
            major: 'SE',
            category: 'Việc làm & Referral',
            tags: ['#OJT', '#Referral', '#SoftwareEngineering', '#FPTU'],
            likes: 128,
            comments: 42,
            shares: 19,
            isLiked: true,
            isSaved: true,
            isAnswered: true,
            isJobPost: true,
            jobTitle: 'Senior / Junior .NET & Flutter Developer (Referral)',
            jobSalary: '18.000.000đ - 35.000.000đ / tháng',
            jobPerks: 'Hỗ trợ mentor 1-1, xét tăng lương 2 lần/năm',
          ),
        ],
        selectedCategory: 'Tất cả',
      ),
    );

    directoryCubit.emit(
      DirectoryLoaded(
        alumni: const [
          AlumniModel(
            id: 'a1',
            name: 'Lê Nguyễn Bảo Ngọc (Mentor K13)',
            mssv: 'SE130123',
            cohort: 'K13',
            major: 'Kỹ thuật phần mềm (SE)',
            campus: 'TP.HCM (FU-HCM)',
            currentRole: 'Principal Solutions Architect',
            company: 'FPT Smart Cloud & AI',
            avatarUrl: '',
            isVerified: true,
            isAvailableForMentoring: true,
            rating: 4.9,
            reviewsCount: 156,
            completedSessions: 240,
            skills: ['Flutter', 'Microservices', 'Clean Architecture', 'RAG'],
            bio: 'Đồng hành cùng sinh viên FPT chuẩn bị OJT và Capstone.',
          ),
        ],
        filterOnlyMentors: true,
        campus: 'HCM',
        major: 'SE',
      ),
    );

    jobsCubit.emit(
      JobsLoaded(
        jobs: const [
          JobModel(
            id: 'j1',
            title: 'Thực tập sinh OJT Mobile Flutter & Backend .NET 8',
            companyName: 'FPT Software Hồ Chí Minh & Hòa Lạc',
            companyLogo: '',
            location: 'Khu Công Nghệ Cao Quận 9, TP.HCM & Hòa Lạc',
            salary: 'Trợ cấp 8.000.000đ - 15.000.000đ',
            jobType: 'OJT / Thực tập',
            experienceLevel: 'Sinh viên kỳ 6',
            hasReferral: true,
            referralAlumniName: 'Nguyễn Văn An (K14 SE)',
            referralAlumniRole: 'Senior Project Manager',
            referralAlumniAvatar: '',
            postedTime: '2 giờ trước',
            description: 'Cơ hội thực tập thực chiến dự án quốc tế.',
            requirements: [],
            benefits: [],
            tags: ['#OJT', '#Flutter', '#DotNet8'],
          ),
        ],
      ),
    );

    aiChatCubit.emit(
      AiChatLoaded(
        messages: [
          ChatMessage(
            id: 'm1',
            content: 'Làm sao để chuẩn bị OJT kỳ 6 hiệu quả nhất?',
            isUser: true,
            timestamp: DateTime(2026, 1, 1),
          ),
          ChatMessage(
            id: 'm2',
            content:
                'Bạn nên chuẩn bị CV kèm dự án thực tế và kết nối sớm với Mentor cựu sinh viên FPT.',
            isUser: false,
            timestamp: DateTime(2026, 1, 1),
            sources: const [
              CitationSource(
                postId: '',
                title: 'Cẩm nang thực tập OJT kỳ 6 tại FPT Software',
                author: 'CLB Cựu sinh viên SE Hòa Lạc',
                timeAgo: '1 ngày trước',
                snippet: 'Hướng dẫn chi tiết chuẩn bị CV và phỏng vấn kỹ thuật.',
              ),
            ],
            followUpQuestions: const [
              'Cách viết CV chuẩn ứng tuyển OJT FPT Software?',
              'Gợi ý Mentor ngành SE tại TP.HCM?',
            ],
          ),
        ],
        isGenerating: true,
      ),
    );
  });

  Future<void> runWithoutLayoutErrors(
    WidgetTester tester,
    Future<void> Function() body,
  ) async {
    final layoutErrors = <FlutterErrorDetails>[];
    final previousHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.exceptionAsString();
      if (text.contains('overflowed') ||
          text.contains('RenderFlex') ||
          text.contains('RenderBox was not laid out') ||
          text.contains('Vertical viewport was given unbounded height')) {
        layoutErrors.add(details);
      }
    };
    try {
      await body();
      expect(tester.takeException(), isNull);
      expect(
        layoutErrors,
        isEmpty,
        reason: layoutErrors.map((e) => e.exceptionAsString()).join('\n\n'),
      );
    } finally {
      FlutterError.onError = previousHandler;
    }
  }

  testWidgets(
    '1. Font scale 1.3x & 2.0x on narrow 320x568 viewport (zero RenderFlex overflow)',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await runWithoutLayoutErrors(tester, () async {
        for (final scale in [1.3, 2.0]) {
          tester.platformDispatcher.textScaleFactorTestValue = scale;

          // App root (LoginScreen with clamped scaler)
          await tester.pumpWidget(
            const ProviderScope(child: FptAlumniConnectApp()),
          );
          await tester.pump();

          // HomeScreen (even with raw 1.3x & 2.0x text scale!)
          await tester.pumpWidget(
            _buildTestHarness(
              child: const HomeScreen(),
              feedCubit: feedCubit,
              directoryCubit: directoryCubit,
              jobsCubit: jobsCubit,
              aiChatCubit: aiChatCubit,
              clampTextScale: false,
            ),
          );
          await tester.pump();

          // DirectoryScreen (raw 1.3x & 2.0x text scale)
          await tester.pumpWidget(
            _buildTestHarness(
              child: const DirectoryScreen(),
              feedCubit: feedCubit,
              directoryCubit: directoryCubit,
              jobsCubit: jobsCubit,
              aiChatCubit: aiChatCubit,
              clampTextScale: false,
            ),
          );
          await tester.pump();

          // JobsScreen (raw 1.3x & 2.0x text scale)
          await tester.pumpWidget(
            _buildTestHarness(
              child: const JobsScreen(),
              feedCubit: feedCubit,
              directoryCubit: directoryCubit,
              jobsCubit: jobsCubit,
              aiChatCubit: aiChatCubit,
              clampTextScale: false,
            ),
          );
          await tester.pump();

          // AiAssistantScreen (raw 1.3x & 2.0x text scale)
          await tester.pumpWidget(
            _buildTestHarness(
              child: const AiAssistantScreen(),
              feedCubit: feedCubit,
              directoryCubit: directoryCubit,
              jobsCubit: jobsCubit,
              aiChatCubit: aiChatCubit,
              clampTextScale: false,
            ),
          );
          await tester.pump();
        }
      });
    },
  );

  testWidgets(
    '2. Screen rotation (Portrait 360x800 -> Landscape 800x360) & Low screen height (360x320)',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await runWithoutLayoutErrors(tester, () async {
        // Portrait
        tester.view.physicalSize = const Size(360, 800);
        await tester.pumpWidget(
          _buildTestHarness(
            child: const HomeScreen(),
            feedCubit: feedCubit,
            directoryCubit: directoryCubit,
            jobsCubit: jobsCubit,
            aiChatCubit: aiChatCubit,
          ),
        );
        await tester.pump();

        // Rotate to Landscape (low height 360)
        tester.view.physicalSize = const Size(800, 360);
        await tester.pump();

        // Ultra-low split-screen height (360x320)
        tester.view.physicalSize = const Size(360, 320);
        await tester.pump();
      });
    },
  );

  testWidgets(
    '3. BottomSheet when keyboard appears (viewInsets.bottom = 280 on low height screen)',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 520);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);

      await runWithoutLayoutErrors(tester, () async {
        // Open HomeScreen Filter BottomSheet then trigger keyboard (280px)
        await tester.pumpWidget(
          _buildTestHarness(
            child: const HomeScreen(),
            feedCubit: feedCubit,
            directoryCubit: directoryCubit,
            jobsCubit: jobsCubit,
            aiChatCubit: aiChatCubit,
          ),
        );
        await tester.pump();

        await tester.ensureVisible(find.textContaining('Bộ lọc'));
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining('Bộ lọc'));
        await tester.pumpAndSettle();
        expect(find.text('Bộ lọc & Sắp xếp bảng tin'), findsOneWidget);

        // Simulate Android soft keyboard appearing while BottomSheet is open
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Áp dụng'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Áp dụng'));
        await tester.pumpAndSettle();

        // Open DirectoryScreen Filter BottomSheet with keyboard already active
        await tester.pumpWidget(
          _buildTestHarness(
            child: const DirectoryScreen(),
            feedCubit: feedCubit,
            directoryCubit: directoryCubit,
            jobsCubit: jobsCubit,
            aiChatCubit: aiChatCubit,
          ),
        );
        await tester.pump();

        await tester.tap(find.byIcon(Icons.tune));
        await tester.pumpAndSettle();
        expect(find.text('Lọc danh bạ Cựu sinh viên (US-06)'), findsOneWidget);
      });
    },
  );
}
