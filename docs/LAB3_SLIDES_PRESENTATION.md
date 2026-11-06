# SLIDE THUYẾT TRÌNH BẢO VỆ LAB 3: TÍCH HỢP FLUTTER & FIREBASE
## Môn học: PRM393 — Advanced Mobile Programming
**Dự án:** FPT Alumni Connect (`F-Alumni-Mobile`)  
**Sinh viên trình bày:** Trương Chí Trung (MSSV: SE170000 / GitHub: `chstrg2208`)  
**Firebase Project:** `alumniconnect-295ed`  
**Quy mô Slide:** 14 Trang chuẩn thuyết trình kỹ thuật  

---

<!-- SLIDE 1 -->
# SLIDE 1: TRANG TIÊU ĐỀ
## FPT ALUMNI CONNECT — NỀN TẢNG KẾT NỐI CỘNG ĐỒNG FPT
### Đồ án thực hành Lab 3: Kiến trúc MVVM & Tích hợp 6 Dịch vụ Đám mây Firebase
* **Sinh viên:** Trương Chí Trung (SE170000)
* **Lớp:** PRM393 — Học kỳ Fall 2026
* **Giảng viên hướng dẫn:** Bộ môn Kỹ thuật Phần mềm — Đại học FPT
* **Công nghệ chủ đạo:** Flutter SDK 3.13+, Firebase Core (BaaS), .NET 9 Microservices, Clean Architecture / MVVM

---

<!-- SLIDE 2 -->
# SLIDE 2: MỤC TIÊU VÀ YÊU CẦU TRỌNG TÂM CỦA LAB 3
## Chuyển giao thiết kế Lab 2 thành ứng dụng Flutter hoàn chỉnh với Cloud Backend
1. **Kiến trúc MVVM phân tầng nghiêm ngặt:** Tuyệt đối không cho phép View (Widget) gọi trực tiếp Firebase SDK; toàn bộ thao tác đám mây đi qua Service Layer và Riverpod Notifier.
2. **Hiện thực 3 luồng nghiệp vụ cốt lõi:**
   - Lướt Bảng tin cộng đồng, tạo bài viết và bình luận kỹ thuật.
   - Tra cứu Danh bạ cựu sinh viên và trò chuyện cùng trợ lý AI Mentor.
   - Tìm kiếm cơ hội Việc làm và nộp hồ sơ giới thiệu Referral.
3. **Tích hợp trọn vẹn 6 dịch vụ Firebase:** Authentication, Cloud Storage, FCM, Google Analytics, Crashlytics, Remote Config.
4. **Kiểm chuẩn chất lượng toàn diện:**
   - Kiểm thử tự động ARTEMIS: 14 test cases x 3 lượt chạy = 100% Pass Rate.
   - Rà soát mã nguồn bằng AI: 6 phát hiện, bảng quyết định kỹ thuật và Git commit truy vết.

---

<!-- SLIDE 3 -->
# SLIDE 3: KIẾN TRÚC HỆ THỐNG: MÔ HÌNH MVVM PHÂN TẦNG
## Dòng chảy dữ liệu một chiều (Unidirectional Data Flow) & Ranh giới tích hợp

```text
  ┌─────────────────────────────────────────────────────────────┐
  │                 VIEW (Flutter UI Widgets)                   │
  │    Loading State ── Content State ── Empty ── Error State   │
  └──────────────────────────────┬──────────────────────────────┘
                                 │ Lắng nghe trạng thái UI (State Stream)
                                 ▼
  ┌─────────────────────────────────────────────────────────────┐
  │              VIEWMODEL (Riverpod / StateNotifier)           │
  │     Quản lý logic trạng thái, chuyển đổi dữ liệu DTO        │
  └──────────────────────────────┬──────────────────────────────┘
                                 │ Gọi nghiệp vụ trừu tượng
                                 ▼
  ┌─────────────────────────────────────────────────────────────┐
  │                        SERVICE LAYER                        │
  │  FirebaseAuth, FirebaseStorage, Analytics, Crashlytics...   │
  └──────────────────────────────┬──────────────────────────────┘
                                 │ Firebase API Calls
                                 ▼
  ┌─────────────────────────────────────────────────────────────┐
  │                      FIREBASE SDK CORE                      │
  └─────────────────────────────────────────────────────────────┘
```
* **Nguyên tắc bảo vệ ranh giới:** Tách biệt độc lập giúp ứng dụng dễ dàng viết Unit Test (Mocking), không bị phụ thuộc cứng vào bất kỳ bên thứ ba nào.

---

<!-- SLIDE 4 -->
# SLIDE 4: DỊCH VỤ 1 — FIREBASE AUTHENTICATION
## Quản lý danh tính sinh viên, Google Sign-In & Bảo vệ tuyến đường (Route Guard)
* **Giải pháp kỹ thuật:**
  - Cấu hình chữ ký SHA-1 và SHA-256 trên Firebase Console của dự án `alumniconnect-295ed`.
  - Thực hiện đăng nhập Google bằng `GoogleSignIn.authenticate()`, trích xuất `idToken` và xác thực với Firebase.
  - Đồng bộ phiên: Trao đổi ID Token với User Service (:5001) để lấy JWT quản lý phân quyền Backend.
  - Lắng nghe luồng `authStateChanges()`: Tự động điều hướng giữa màn hình Login và Home, chặn truy cập trái phép vào các màn hình Profile/Settings khi chưa đăng nhập.
* **Xử lý ngoại lệ:** Bắt lỗi hủy chọn tài khoản (User cancelled), mất mạng hoặc lỗi máy chủ an toàn.
* **Minh chứng:** `Console_01_Authentication_Users.png` (Xác nhận UID trên Console) & `Step_04_ManHinh_DangNhap.png`.

---

<!-- SLIDE 5 -->
# SLIDE 5: DỊCH VỤ 2 — FIREBASE CLOUD STORAGE
## Lưu trữ đám mây theo định danh người dùng & Quy tắc bảo mật nhiều tầng
* **Giải pháp kỹ thuật:**
  - Triển khai `FirebaseStorageService` cung cấp luồng Stream cập nhật tiến độ tải lên phần trăm thời gian thực (`StorageUploadProgress`).
  - Cấu trúc thư mục đám mây nghiêm ngặt: `reports/{uid}/{filename}` và `posts/{uid}/{filename}`.
  - Hỗ trợ đa dạng định dạng tệp: Hình ảnh (JPG, PNG, WebP) và Báo cáo tài liệu (PDF, CSV).
  - Tự động lấy Download URL bảo mật sau khi hoàn tất tải lên (`TaskState.success`).
* **Luật bảo mật (`firebase/storage.rules`):**
  - Chỉ cho phép chính chủ sở hữu UID đọc/ghi tệp của họ (`request.auth.uid == userId`).
  - Ràng buộc giới hạn kích thước tối đa `< 10MB` và xác thực MIME-type, ngăn chặn DoS dung lượng.
* **Minh chứng:** `Console_02_Cloud_Storage.png` & `Step_10`, `Step_12`, `Step_13`.

---

<!-- SLIDE 6 -->
# SLIDE 6: DỊCH VỤ 3 — FIREBASE CLOUD MESSAGING (FCM)
## Thông báo đẩy đa trạng thái, Quyền Android 13+ & Hộp thư thông báo
* **Giải pháp kỹ thuật:**
  - Tương thích toàn diện với Android 13+ và Android 14 (API 34): Chủ động xin cấp quyền runtime `POST_NOTIFICATIONS`.
  - Xử lý mượt mà thông báo trên cả **3 trạng thái vòng đời ứng dụng**:
    1. *Foreground:* Bắt sự kiện hiển thị In-app Toast / Notification Card không gây gián đoạn UI.
    2. *Background:* Nhận Push Notification qua trung tâm thông báo của hệ điều hành.
    3. *Terminated:* Ứng dụng tự động bật từ trạng thái tắt hoàn toàn và điều hướng chính xác đến màn hình mục tiêu (Deep Linking).
  - Xây dựng Trung tâm thông báo (Notification Inbox) cục bộ trong app để lưu vết và xem lại lịch sử.
* **Minh chứng:** `Step_19_HopThu_ThongBao_NotificationInbox.png`.

---

<!-- SLIDE 7 -->
# SLIDE 7: DỊCH VỤ 4 — GOOGLE ANALYTICS FOR FIREBASE
## Đo lường hành vi người dùng, Bảo vệ dữ liệu cá nhân (No PII) & DebugView
* **Giải pháp kỹ thuật:**
  - Soạn thảo tài liệu chiến lược `docs/analytics-plan.md` quy định **8 sự kiện chuẩn hóa**:
    `login`, `logout`, `search`, `select_content`, `view_item`, `avatar_upload_complete`, `export_file`, `notification_open`.
  - Thiết lập định danh người dùng `setUserId(user.uid)` sau khi đăng nhập thành công.
  - **Chính sách bảo mật (No PII):** Tuyệt đối không gửi email sinh viên, tên thật, số điện thoại hay chuỗi tìm kiếm thô vào tham số sự kiện.
* **Kiểm chứng thực tế:**
  - Kích hoạt chế độ kiểm thử: `adb shell setprop debug.firebase.analytics.app vn.edu.fpt.alumni_connect`.
  - Kiểm tra dòng sự kiện trực tiếp trên Firebase Console DebugView.
* **Minh chứng:** `Console_03_Analytics_DebugView.png`.

---

<!-- SLIDE 8 -->
# SLIDE 8: DỊCH VỤ 5 — FIREBASE CRASHLYTICS
## Theo dõi sự cố toàn cục, Ghi nhận lỗi phi nghiêm trọng (Non-fatal) & Diagnostic Keys
* **Giải pháp kỹ thuật:**
  - Thiết lập bẫy lỗi toàn cục qua `FlutterError.onError` và `PlatformDispatcher.instance.onError`.
  - Ghi nhận lỗi có xử lý (`recordHandledError` / Non-fatal): Khi xảy ra lỗi mạng trong quá trình upload, ứng dụng hiển thị thông báo thân thiện cho người dùng, đồng thời tự động đẩy stack trace về Crashlytics.
  - Gắn khóa chẩn đoán ngữ cảnh: `setUserIdentifier` và `setCustomKey("environment", "development")`.
  - Xây dựng nút bấm ẩn thử nghiệm sự cố (Test Crash Button) trong khu vực gỡ lỗi để kiểm tra đường truyền.
* **Minh chứng thực tế:**
  - `Console_04_Crashlytics_Dashboard.png`: Bảng điều khiển ghi nhận trực tiếp **184 sự cố**, 2 người dùng bị ảnh hưởng và phân tích chi tiết dòng mã gây crash.

---

<!-- SLIDE 9 -->
# SLIDE 9: DỊCH VỤ 6 — FIREBASE REMOTE CONFIG
## Cấu hình ứng dụng từ xa thời gian thực & Cơ chế Fallback ngoại tuyến
* **Giải pháp kỹ thuật:**
  - Thiết lập 2 tham số cấu hình liên kết trực tiếp với UI kèm giá trị mặc định (`setDefaults`):
    1. `is_promo_banner_enabled` (boolean, mặc định: `true`): Điều khiển bật/tắt hiển thị thẻ quảng bá "Sự kiện & Workshop FPTU mới nhất" trên Home Feed.
    2. `max_items_display` (number, mặc định: `10`): Điều khiển số lượng bài viết / alumni nạp trong danh sách.
  - Tối ưu chu kỳ fetch: Áp dụng `Duration.zero` khi ở chế độ `kDebugMode` giúp thay đổi trên Console phản ánh tức thì lên app mà không cần build lại APK.
  - Cơ chế Fallback ngoại tuyến an toàn: Khi mất mạng hoặc thiết bị ở chế độ máy bay, ứng dụng tự động dùng bộ giá trị mặc định trong code, không gây vỡ giao diện.
* **Minh chứng:** `Console_05_RemoteConfig_Dashboard.png` & `Step_06_DangNhap_ThanhCong_HomeFeed.png`.

---

<!-- SLIDE 10 -->
# SLIDE 10: BA LUỒNG NGHIỆP VỤ KẾ THỪA TỪ LAB 2
## Trải nghiệm người dùng mượt mà, tích hợp Backend Microservices
1. **Luồng 1 — Bảng tin & Thảo luận kỹ thuật:**
   - Lướt bài viết từ Forum Service (:5003), lọc bài theo chuyên đề (CNTT, Việc làm, Kinh doanh).
   - Đăng bài viết mới kèm ảnh tải lên Cloud Storage; xem chi tiết bài và bình luận thời gian thực (`Step_06`, `Step_12`, `Step_14`).
2. **Luồng 2 — Danh bạ Cựu sinh viên & Cố vấn AI Mentor:**
   - Tìm kiếm alumni theo ngành học, khóa tốt nghiệp (K14–K17), cơ sở đào tạo (Hòa Lạc, TP.HCM, Đà Nẵng).
   - Xem hồ sơ chi tiết Alumni và kết nối trợ lý **AI Mentor** tư vấn OJT 24/7 (`Step_15`, `Step_16`, `Step_20`).
3. **Luồng 3 — Cơ hội Việc làm & Giới thiệu Doanh nghiệp:**
   - Khám phá các tin tuyển dụng hot từ cựu sinh viên tại FPT Software, Momo, Viettel...
   - Xem chi tiết mô tả công việc, mức lương, văn hóa doanh nghiệp và gửi yêu cầu Referral nội bộ (`Step_17`, `Step_18`).

---

<!-- SLIDE 11 -->
# SLIDE 11: ĐẢM BẢO CHẤT LƯỢNG — KIỂM THỬ TỰ ĐỘNG ARTEMIS
## 14 Ca kiểm thử E2E x 3 Lượt chạy = 42/42 Lượt Passed (Tỷ lệ 100%)
* **Đặc điểm kiểm thử nổi bật:**
  - Bao phủ trọn vẹn cả 3 luồng nghiệp vụ Lab 2.
  - Nhánh kiểm thử lỗi (Negative Flows): Chặn truy cập trái phép (ART-01), hủy đăng nhập Google (ART-02), tìm kiếm rỗng (ART-04), tải ảnh khi chưa có phiên (ART-09/ART-14).
  - Tương tác hệ thống Android gốc (Native System Interaction): Xử lý cấp/từ chối quyền thông báo Android 13+ (ART-10).
* **Phiên kiểm thử khám phá (Exploratory Testing Session - 25 Phút):**
  - Thực hiện trên thiết bị Pixel 7 Emulator (Android 14).
  - Phát hiện và khắc phục dứt điểm 2 lỗi giao diện (RenderFlex overflow trên Home AppBar và Onboarding Column).
  - Kết quả: Toàn bộ bộ test suite (`flutter test`) vượt qua 100% không phát sinh lỗi layout.

---

<!-- SLIDE 12 -->
# SLIDE 12: RÀ SOÁT MÃ NGUỒN BẰNG TRÍ TUỆ NHÂN TẠO (AI CODE REVIEW)
## Đánh giá tự động chuyên sâu theo chuẩn CodeRabbit với 6 phát hiện trên 4 nhóm
* **Bảng ma trận quyết định kỹ thuật (Decision Matrix):**
  - **F-01 (Security & Validation):** Hỗ trợ tệp PDF/CSV trong Storage Service -> **ACCEPT** (Đã commit).
  - **F-02 (Performance & UI):** Bọc Onboarding trong SingleChildScrollView chống overflow -> **ACCEPT** (Đã commit).
  - **F-03 (Architecture):** Thêm sự kiện bắt buộc `export_file` vào Analytics -> **ACCEPT** (Đã commit).
  - **F-04 (Error Handling):** Cải thiện thông báo và ghi nhận log an toàn khi thiếu phiên Firebase -> **MODIFY** (Đã commit).
  - **F-05 (Cloud Security):** Ràng buộc kích thước file < 10MB và mime-type trong Storage Rules -> **ACCEPT** (Đã commit).
  - **F-06 (Performance):** Tự động chuyển interval về Duration.zero trong kDebugMode cho Remote Config -> **MODIFY** (Đã commit).
* **Kết quả:** Đã áp dụng 5 commit sửa lỗi nguyên tử trên Git, vượt xa yêu cầu tối thiểu (fix >= 3 findings).

---

<!-- SLIDE 13 -->
# SLIDE 13: THÁCH THỨC KỸ THUẬT VÀ GIẢI PHÁP TỐI ƯU
## Các bài học kinh nghiệm thu được trong quá trình triển khai thực tế
1. **Đồng bộ xác thực đa nền tảng (Dual Authentication):**
   - *Vấn đề:* Ứng dụng vừa dùng Firebase Auth (Google Sign-In) vừa kết nối hệ thống Microservices .NET (JWT).
   - *Giải pháp:* Dùng cơ chế Token Exchange: Đăng nhập Firebase lấy ID Token -> Chuyển tiếp lên User API :5001 đổi lấy JWT phiên làm việc để gọi các service Forum, Chat, AI.
2. **Quy tắc bảo mật Cloud Storage không phụ thuộc vào trạng thái giả định:**
   - *Vấn đề:* Mặc định Storage Rules nếu viết lỏng lẻo sẽ gây nguy cơ lộ dữ liệu cá nhân giữa các sinh viên.
   - *Giải pháp:* Ràng buộc đường dẫn nghiêm ngặt theo `request.auth.uid == userId`, loại bỏ hoàn toàn quy tắc mở.
3. **Thích ứng đa kích thước màn hình Android:**
   - *Vấn đề:* Layout bị overflow khi hiển thị bàn phím hoặc chạy trên các dòng máy có độ phân giải khác nhau.
   - *Giải pháp:* Triển khai `SingleChildScrollView` với `BouncingScrollPhysics` kết hợp `LayoutBuilder` thích ứng linh hoạt.

---

<!-- SLIDE 14 -->
# SLIDE 14: TỔNG KẾT & ĐỊNH HƯỚNG PHÁT TRIỂN
## Đánh giá mức độ hoàn thiện sản phẩm nộp Lab 3
* **Tổng kết thành quả:**
  - Đạt 100% tất cả các tiêu chí trong Đề bài Lab 3 (`docs/LAB3_REQUIREMENTS.md`).
  - Kiến trúc MVVM phân tầng sạch sẽ, tách biệt hoàn toàn giao diện khỏi Firebase SDK.
  - Thu thập trọn vẹn bộ 25 ảnh bằng chứng (20 ảnh Mobile UI + 5 ảnh Firebase Console).
  - Khung kiểm thử ARTEMIS và AI Code Review hoàn thành với báo cáo minh bạch, truy vết rõ ràng.
* **Định hướng phát triển cho Lab 4 / Dự án tốt nghiệp:**
  - Tích hợp thêm kênh thanh toán học bổng và quỹ khuyến học Alumni qua VNPay / MoMo.
  - Nâng cấp gọi video/audio 1-1 với cựu sinh viên thông qua WebRTC / Agora SDK.
  - Mở rộng mô hình AI RAG trên dữ liệu đề cương bài giảng và tài liệu hướng dẫn OJT của Đại học FPT.

---
### XIN CHÂN THÀNH CẢM ƠN THẦY CÔ VÀ CÁC BẠN ĐÃ LẮNG NGHE!
*(Mọi câu hỏi và trao đổi kỹ thuật xin vui lòng phản hồi)*
