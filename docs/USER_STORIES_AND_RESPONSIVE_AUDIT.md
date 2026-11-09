# Tài Liệu Đối Chiếu User Stories, Tích Hợp Backend & Nâng Cấp UI/UX Responsive Android

**Dự án:** FPT Alumni Connect (Mobile App - Flutter)  
**Ngày cập nhật:** 09/11/2026  
**Phạm vi:** 41/41 Non-Admin User Stories (`US-01..11`, `CH-01..10`, `FO-01..16`, `AI-01..04`), đồng bộ Microservices Backend (`f-alumni-connect`) & Chuẩn hóa Responsive UI/UX đa thiết bị Android.

---

## 1. Tổng Quan Kiến Trúc & Đồng Bộ Backend

Ứng dụng Mobile được xây dựng theo kiến trúc **Feature-based Clean Architecture** kết hợp với **BLoC/Cubit** quản lý trạng thái và kết nối trực tiếp tới hệ thống Backend Microservices (`f-alumni-connect`):

- **Cấu hình API (`lib/core/config/api_config.dart`)**:
  - Hỗ trợ linh hoạt cả chế độ gọi qua **YARP API Gateway** (`port 5000`) thông qua cờ `--dart-define=USE_API_GATEWAY=true` hoặc gọi trực tiếp từng Microservice khi chạy local development:
    - **Auth Service (`port 5001`)**: Xác thực JWT, Google SSO, OTP Email, quản lý mật khẩu.
    - **User Service (`port 5002`)**: Hồ sơ cá nhân, quyền riêng tư, danh bạ Alumni, chặn người dùng, liên kết Google Calendar.
    - **Forum Service (`port 5003`)**: Bài viết, danh mục, bình luận đa cấp, tương tác (Upvote/Downvote), lưu bài viết, báo cáo vi phạm và **SignalR Hub** (`/hubs/forum`).
    - **Chat Service (`port 5004`)**: Nhắn tin thời gian thực 1-1, quản lý hội thoại, phân trang cursor, tìm kiếm/chỉnh sửa/thu hồi/ghim tin nhắn và **SignalR Hub** (`/hubs/chat`).
    - **AI Service (`port 5005`)**: Trợ lý ảo RAG 24/7, trích dẫn nguồn bài viết (`CitationDto`) và gợi ý cố vấn (`Mentor Matching`).

---

## 2. Bảng Đối Chiếu Chi Tiết 41/41 User Stories (Non-Admin)

> **Lưu ý phạm vi:** Không bao gồm 9 User Story của Quản trị viên (`AD-01` → `AD-09`). Toàn bộ **41/41 User Story của Người dùng / Cựu sinh viên (Alumni / Student)** đã được hoàn thiện 100%.

### 2.1. Quản lý Tài khoản & Hồ sơ (`US-01` → `US-11`: 11/11 Hoàn thành)

| Mã US | Tên chức năng | Mô tả nghiệp vụ | File thực thi trên Mobile | Endpoint Backend | Trạng thái |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **US-01** | Đăng nhập Google SSO | Đăng nhập nhanh bằng tài khoản `@fpt.edu.vn` hoặc `@fe.edu.vn` | `lib/features/auth/presentation/screens/login_screen.dart`<br>`lib/features/auth/presentation/cubit/auth_cubit.dart` | `POST /api/v1/auth/google` | ✅ Hoàn thành |
| **US-02** | Đăng ký Email & Xác thực OTP | Đăng ký bằng email cá nhân và nhập mã OTP xác thực | `lib/features/auth/presentation/screens/register_screen.dart`<br>`lib/features/auth/presentation/cubit/auth_cubit.dart` | `POST /api/v1/auth/register`<br>`POST /api/v1/auth/verify-email` | ✅ Hoàn thành |
| **US-03** | Đăng nhập Email & Mật khẩu | Đăng nhập truyền thống cho tài khoản đã kích hoạt | `lib/features/auth/presentation/screens/login_screen.dart`<br>`lib/features/auth/presentation/cubit/auth_cubit.dart` | `POST /api/v1/auth/login` | ✅ Hoàn thành |
| **US-04** | Cập nhật Hồ sơ Cá nhân | Chỉnh sửa Bio, Khóa (Cohort), Ngành (Major), Cơ sở (Campus), Công việc, Kỹ năng & tải ảnh đại diện (Avatar) | `lib/features/profile/presentation/screens/edit_profile_screen.dart`<br>`lib/features/profile/presentation/cubit/profile_cubit.dart` | `PUT /api/v1/users/me/profile`<br>`PUT /api/v1/users/me/avatar` | ✅ Hoàn thành |
| **US-05** | Tìm kiếm Người dùng | Tìm kiếm cựu sinh viên / sinh viên theo tên trong danh bạ | `lib/features/directory/presentation/screens/directory_screen.dart`<br>`lib/features/directory/presentation/cubit/directory_cubit.dart` | `GET /api/v1/users?search=...` | ✅ Hoàn thành |
| **US-06** | Bộ lọc Danh bạ Đa tiêu chí | Lọc danh bạ theo Cơ sở (Campus), Chuyên ngành (Major) và Khóa (Cohort) qua BottomSheet `ChoiceChip` | `lib/features/directory/presentation/screens/directory_screen.dart`<br>`lib/features/directory/presentation/cubit/directory_cubit.dart` | `GET /api/v1/users?campus=...&major=...&cohort=...` | ✅ Hoàn thành |
| **US-07** | Quên mật khẩu & Đổi mật khẩu | Gửi mã OTP khôi phục mật khẩu qua email hoặc đổi mật khẩu khi đang đăng nhập | `lib/features/auth/presentation/screens/forgot_password_screen.dart`<br>`lib/features/auth/presentation/screens/change_password_screen.dart` | `POST /api/v1/auth/forgot-password`<br>`POST /api/v1/auth/reset-password`<br>`POST /api/v1/auth/change-password` | ✅ Hoàn thành |
| **US-08** | Đăng xuất an toàn | Xóa token lưu trữ cục bộ, ngắt kết nối SignalR và thu hồi phiên đăng nhập | `lib/features/profile/presentation/screens/edit_profile_screen.dart`<br>`lib/features/auth/presentation/cubit/auth_cubit.dart` | `POST /api/v1/auth/logout` | ✅ Hoàn thành |
| **US-09** | Cài đặt Quyền riêng tư | Tuỳ chỉnh ẩn/hiện Email, Số điện thoại, Lịch cá nhân và trạng thái hiển thị với Nhà tuyển dụng | `lib/features/profile/presentation/screens/edit_profile_screen.dart`<br>`lib/features/profile/data/repositories/profile_repository.dart` | `PUT /api/v1/users/me/privacy` | ✅ Hoàn thành |
| **US-10** | Chặn & Bỏ chặn Người dùng | Chặn người dùng từ trang hồ sơ Alumni và quản lý danh sách chặn trong cài đặt | `lib/features/directory/presentation/screens/alumni_profile_screen.dart`<br>`lib/features/profile/presentation/screens/blocked_users_screen.dart` | `GET /api/v1/users/me/blocks`<br>`POST /api/v1/users/me/blocks`<br>`DELETE /api/v1/users/me/blocks/{id}` | ✅ Hoàn thành |
| **US-11** | Liên kết Google Calendar | Cập nhật link lịch hẹn cá nhân để Mentee xem và sao chép đặt lịch hẹn | `lib/features/profile/presentation/screens/edit_profile_screen.dart`<br>`lib/features/profile/presentation/screens/user_profile_screen.dart`<br>`lib/features/directory/presentation/screens/alumni_profile_screen.dart` | `PUT /api/v1/users/me/calendar` | ✅ Hoàn thành |

---

### 2.2. Nhắn tin Thời gian thực (`CH-01` → `CH-10`: 10/10 Hoàn thành)

| Mã US | Tên chức năng | Mô tả nghiệp vụ | File thực thi trên Mobile | Endpoint / SignalR Backend | Trạng thái |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **CH-01** | Khởi tạo Trò chuyện 1-1 | Bắt đầu hoặc mở lại cuộc trò chuyện trực tiếp từ trang hồ sơ Alumni | `lib/features/directory/presentation/screens/alumni_profile_screen.dart`<br>`lib/features/chat/presentation/cubit/chat_cubit.dart` | `POST /api/v1/conversations` | ✅ Hoàn thành |
| **CH-02** | Nhắn tin Real-time & Đã xem | Gửi/nhận tin nhắn tức thời qua SignalR và cập nhật trạng thái Đã xem (`Read receipt`) | `lib/features/chat/presentation/screens/direct_messages_screen.dart`<br>`lib/features/chat/data/repositories/chat_repository.dart` | SignalR `/hubs/chat` (`SendMessage`, `MarkRead`, `ReceiveMessage`) | ✅ Hoàn thành |
| **CH-03** | Danh sách Hội thoại & Unread Badge | Hiển thị danh sách hội thoại sắp xếp theo tin nhắn mới nhất kèm số tin nhắn chưa đọc | `lib/features/chat/presentation/screens/chat_list_screen.dart` | `GET /api/v1/conversations` | ✅ Hoàn thành |
| **CH-04** | Phân trang Lịch sử Tin nhắn | Tải thêm tin nhắn cũ hơn theo cơ chế Cursor-based pagination | `lib/features/chat/presentation/screens/direct_messages_screen.dart` | `GET /api/v1/conversations/{id}/messages?cursor=...` | ✅ Hoàn thành |
| **CH-05** | Tìm kiếm Tin nhắn trong Hội thoại | Tìm kiếm nội dung tin nhắn theo từ khóa ngay trong cuộc trò chuyện | `lib/features/chat/presentation/screens/direct_messages_screen.dart` | `GET /api/v1/conversations/{id}/messages/search` | ✅ Hoàn thành |
| **CH-06** | Chỉnh sửa & Thu hồi Tin nhắn | Cho phép người gửi sửa nội dung hoặc thu hồi tin nhắn đã gửi | `lib/features/chat/presentation/screens/direct_messages_screen.dart` | `PUT /api/v1/messages/{id}`<br>`DELETE /api/v1/messages/{id}` | ✅ Hoàn thành |
| **CH-07** | Gửi Hình ảnh & Liên kết | Chọn ảnh từ thiết bị (tải lên Firebase Storage) hoặc đính kèm URL hình ảnh/liên kết | `lib/features/chat/presentation/screens/direct_messages_screen.dart` | `POST /api/v1/conversations/{id}/messages` | ✅ Hoàn thành |
| **CH-08** | Trả lời (Reply) & Ghim (Pin) | Trả lời một tin nhắn cụ thể và ghim tin nhắn quan trọng / ghim hội thoại | `lib/features/chat/presentation/screens/direct_messages_screen.dart`<br>`lib/features/chat/presentation/screens/chat_list_screen.dart` | `POST /api/v1/messages/{id}/pin`<br>`POST /api/v1/conversations/{id}/pin` | ✅ Hoàn thành |
| **CH-09** | Xóa / Ẩn Cuộc trò chuyện | Vuốt sang trái (`Dismissible`) hoặc chọn menu để ẩn hội thoại khỏi danh sách | `lib/features/chat/presentation/screens/chat_list_screen.dart` | `POST /api/v1/conversations/{id}/hide` | ✅ Hoàn thành |
| **CH-10** | Tắt thông báo Hội thoại (Mute) | Bật/tắt thông báo cho từng cuộc trò chuyện cụ thể | `lib/features/chat/presentation/screens/chat_list_screen.dart`<br>`lib/features/chat/presentation/screens/direct_messages_screen.dart` | `POST /api/v1/conversations/{id}/mute` | ✅ Hoàn thành |

---

### 2.3. Diễn đàn Thảo luận (`FO-01` → `FO-16`: 16/16 Hoàn thành)

| Mã US | Tên chức năng | Mô tả nghiệp vụ | File thực thi trên Mobile | Endpoint / SignalR Backend | Trạng thái |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **FO-01** | Tạo Bài viết Mới | Đăng bài thảo luận với tiêu đề, nội dung chi tiết và hình ảnh đính kèm | `lib/features/feed/presentation/screens/create_post_screen.dart` | `POST /api/v1/posts`<br>SignalR `/hubs/forum` (`ReceiveNewPost`) | ✅ Hoàn thành |
| **FO-02** | Phân loại Bài viết | Chọn Danh mục (Category), Cơ sở (Campus), Chuyên ngành (Major) khi tạo bài | `lib/features/feed/presentation/screens/create_post_screen.dart`<br>`lib/features/feed/data/repositories/feed_repository.dart` | `GET /api/v1/categories`<br>`POST /api/v1/posts` | ✅ Hoàn thành |
| **FO-03** | Gắn thẻ Hashtag | Thêm danh sách các thẻ `#hashtag` cho bài viết | `lib/features/feed/presentation/screens/create_post_screen.dart` | `POST /api/v1/posts` (`tags`) | ✅ Hoàn thành |
| **FO-04** | Chỉnh sửa & Xóa Bài viết | Tác giả có quyền sửa nội dung hoặc xóa bài viết của chính mình | `lib/features/feed/presentation/screens/edit_post_screen.dart`<br>`lib/features/feed/presentation/screens/post_detail_screen.dart` | `PUT /api/v1/posts/{id}`<br>`DELETE /api/v1/posts/{id}` | ✅ Hoàn thành |
| **FO-05** | Tương tác Upvote / Downvote | Thả tương tác hữuích (Upvote/Downvote) trên thẻ bài viết và trang chi tiết | `lib/features/feed/presentation/widgets/post_card_widget.dart`<br>`lib/features/feed/presentation/screens/post_detail_screen.dart` | `POST /api/v1/posts/{id}/reactions`<br>SignalR (`ReceiveReaction`) | ✅ Hoàn thành |
| **FO-06** | Bình luận Bài viết | Gửi bình luận trực tiếp vào bài viết và cập nhật tức thì (Silent Refresh / SignalR) | `lib/features/feed/presentation/screens/post_detail_screen.dart` | `POST /api/v1/posts/{id}/comments`<br>SignalR (`ReceiveComment`) | ✅ Hoàn thành |
| **FO-07** | Trả lời Bình luận (Nested Reply) | Phản hồi trực tiếp vào một bình luận có sẵn (hiển thị phân cấp cây bình luận) | `lib/features/feed/presentation/screens/post_detail_screen.dart` | `POST /api/v1/posts/{id}/comments` (`parentCommentId`) | ✅ Hoàn thành |
| **FO-08** | Sửa & Xóa Bình luận | Tác giả bình luận có thể chỉnh sửa hoặc xóa bình luận của mình | `lib/features/feed/presentation/screens/post_detail_screen.dart` | `PUT /api/v1/comments/{id}`<br>`DELETE /api/v1/comments/{id}` | ✅ Hoàn thành |
| **FO-09** | Lưu Bài viết (Bookmark) | Đánh dấu lưu bài viết trên Feed/Detail và xem lại tại màn hình Bài viết đã lưu | `lib/features/feed/presentation/widgets/post_card_widget.dart`<br>`lib/features/feed/presentation/screens/saved_posts_screen.dart`<br>`lib/features/profile/presentation/screens/user_profile_screen.dart` | `POST /api/v1/posts/{id}/bookmarks`<br>`GET /api/v1/users/me/bookmarks` | ✅ Hoàn thành |
| **FO-10** | Xem Bài viết Cá nhân | Xem danh sách các bài viết do chính mình đã đăng ngay trên trang Hồ sơ | `lib/features/profile/presentation/screens/user_profile_screen.dart` | `GET /api/v1/users/me/posts` | ✅ Hoàn thành |
| **FO-11** | Báo cáo Vi phạm (Report) | Gửi báo cáo bài viết hoặc bình luận vi phạm tiêu chuẩn cộng đồng | `lib/features/feed/presentation/screens/post_detail_screen.dart` | `POST /api/v1/reports` | ✅ Hoàn thành |
| **FO-12** | Lọc Bảng tin theo Danh mục | Lọc nhanh bài viết theo từng chủ đề (Học tập, Việc làm, Sự kiện, Thảo luận...) | `lib/features/feed/presentation/screens/home_screen.dart`<br>`lib/features/feed/presentation/cubit/feed_cubit.dart` | `GET /api/v1/posts?category=...` | ✅ Hoàn thành |
| **FO-13** | Lọc theo Cơ sở & Chuyên ngành | Lọc bảng tin theo Campus và Major trong BottomSheet bộ lọc nâng cao | `lib/features/feed/presentation/screens/home_screen.dart` | `GET /api/v1/posts?campus=...&major=...` | ✅ Hoàn thành |
| **FO-14** | Tìm kiếm Từ khóa & Hashtag | Tìm kiếm bài viết theo từ khóa tiêu đề/nội dung hoặc lọc theo thẻ `#hashtag` | `lib/features/feed/presentation/screens/home_screen.dart` | `GET /api/v1/posts?search=...&tag=...` | ✅ Hoàn thành |
| **FO-15** | Sắp xếp & Lọc Câu hỏi Chưa giải đáp | Sắp xếp bài viết Mới nhất / Phổ biến nhất và lọc riêng câu hỏi chưa có lời giải | `lib/features/feed/presentation/screens/home_screen.dart` | `GET /api/v1/posts?sortBy=...&unansweredOnly=...` | ✅ Hoàn thành |
| **FO-16** | Đánh dấu Đã giải đáp & Chọn Best Answer | Tác giả bài viết đánh dấu câu hỏi đã giải quyết hoặc chọn bình luận đúng nhất | `lib/features/feed/presentation/screens/post_detail_screen.dart` | `PATCH /api/v1/posts/{id}/answered`<br>`PATCH /api/v1/comments/{id}/accept` | ✅ Hoàn thành |

---

### 2.4. Trợ lý AI & Gợi ý Cố vấn (`AI-01` → `AI-04`: 4/4 Hoàn thành)

| Mã US | Tên chức năng | Mô tả nghiệp vụ | File thực thi trên Mobile | Endpoint Backend | Trạng thái |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **AI-01** | Hỏi đáp AI Assistant 24/7 (RAG) | Trò chuyện với trợ lý AI dựa trên tri thức diễn đàn và xem lại lịch sử hội thoại AI | `lib/features/ai/presentation/screens/ai_assistant_screen.dart`<br>`lib/features/ai/presentation/cubit/ai_cubit.dart` | `POST /api/v1/ai/ask`<br>`GET /api/v1/ai/conversations` | ✅ Hoàn thành |
| **AI-02** | AI Gợi ý Mentor (Mentor Matching) | Phân tích nhu cầu và đề xuất danh sách các Cố vấn (Mentor) phù hợp | `lib/features/directory/presentation/screens/directory_screen.dart`<br>`lib/features/ai/data/repositories/ai_repository.dart` | `POST /api/v1/ai/mentor-recommendations` | ✅ Hoàn thành |
| **AI-03** | Trích dẫn Nguồn Bài viết (Citations) | Hiển thị danh sách nguồn tham khảo kèm đoạn trích (`snippet`) và mở trực tiếp bài viết gốc | `lib/features/ai/presentation/screens/ai_assistant_screen.dart` (`_openCitation`) | Dữ liệu `sources` (`CitationDto`) từ `POST /api/v1/ai/ask` | ✅ Hoàn thành |
| **AI-04** | Gợi ý Câu hỏi Tiếp theo (Follow-up) | Hiển thị các chip câu hỏi gợi ý theo ngữ cảnh ngay dưới câu trả lời của AI | `lib/features/ai/presentation/screens/ai_assistant_screen.dart` | Dữ liệu `followUpQuestions` từ `POST /api/v1/ai/ask` | ✅ Hoàn thành |

---

## 3. Nâng Cấp UI/UX & Chuẩn Hóa Responsive Đa Thiết Bị Android

Hệ thống giao diện đã được thiết kế lại và tối ưu hóa để thích ứng mượt mà trên mọi phân khúc thiết bị Android:

1. **Quản lý Tỷ lệ Phông chữ & Edge-to-Edge (`lib/main.dart`)**:
   - Kích hoạt `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)`.
   - Cấu hình `MediaQuery` với `textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.15)` ở tầng ứng dụng, đồng thời thiết kế toàn bộ thành phần con chịu được mức phóng đại phông chữ hệ thống lên tới `1.3x` và `2.0x` mà không tràn bố cục (`RenderFlex overflow`).
2. **Khung Điều Hướng Thích Ứng (`lib/features/shared/main_scaffold_wrapper.dart`)**:
   - **Màn hình nhỏ & tiêu chuẩn (`< 600dp`)**: Sử dụng `NavigationBar` đáy màn hình.
   - **Màn hình lớn, máy tính bảng, điện thoại gập (`>= 600dp`)**: Tự động chuyển sang `NavigationRail` bên trái và giới hạn chiều rộng nội dung trung tâm (`ConstrainedBox(maxWidth: 720)`) để tối ưu khả năng đọc.
3. **Nâng cấp Trải nghiệm Màn hình Chi tiết Bài viết (`PostDetailScreen`)**:
   - Thêm cơ chế **Silent Refresh** (`silent: true`) khi gửi/sửa/xóa bình luận hoặc bấm chọn câu trả lời đúng nhất, giữ nguyên vị trí cuộn của người dùng thay vì bật lại vòng xoay tải trang.
   - Thiết kế lại cấu trúc thẻ bài viết gốc và cây bình luận phân cấp có đường kẻ dọc dẫn hướng trực quan, thanh nhập bình luận ghim đáy (`SafeArea`) kèm banner trả lời bình luận mượt mà.
4. **Tối ưu Bộ lọc Bảng tin (`HomeScreen`) & Danh bạ (`DirectoryScreen`)**:
   - Gom nhóm bộ lọc vào `ModalBottomSheet` gọn gàng sử dụng `ChoiceChip` dễ bấm bằng một tay.
   - Tự động đẩy nội dung lên theo chiều cao bàn phím ảo (`MediaQuery.viewInsetsOf(context).bottom`) và hỗ trợ kéo cuộn để ẩn bàn phím (`ScrollViewKeyboardDismissBehavior.onDrag`).

---

## 4. Kiểm Thử Widget Thực Tế (`test/widget_test.dart`)

Bộ kiểm thử tự động trong `test/widget_test.dart` kiểm tra nghiêm ngặt các lỗi bố cục thực tế thông qua `tester.takeException()` và hook `FlutterError.onError` bắt lỗi `RenderFlex overflowed`:

- **Kịch bản 1 (`320x568` @ Font Scale `1.3x` & `2.0x`)**: Kiểm tra toàn bộ các màn hình (`LoginScreen`, `HomeScreen`, `DirectoryScreen`, `JobsScreen`, `AiAssistantScreen`) trên màn hình siêu nhỏ với cỡ chữ phóng đại gấp đôi.
- **Kịch bản 2 (Xoay màn hình & Chiều cao thấp `360x320`)**: Kiểm tra chuyển đổi từ dọc (`360x800`) sang ngang (`800x360`), chế độ chia đôi màn hình (`360x320`) và chế độ Tablet (`840x600` với `NavigationRail`).
- **Kịch bản 3 (BottomSheet khi bàn phím xuất hiện `viewInsets.bottom = 280`)**: Kiểm tra mở bộ lọc nâng cao trên `HomeScreen` và `DirectoryScreen` khi bàn phím ảo chiếm hơn nửa màn hình, đảm bảo cuộn tới và nhấn được nút *"Áp dụng"* mà không phát sinh bất kỳ ngoại lệ tràn khung hình nào.
