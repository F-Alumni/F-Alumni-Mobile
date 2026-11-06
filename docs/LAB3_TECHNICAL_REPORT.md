# BÁO CÁO KỸ THUẬT LAB 3: TÍCH HỢP FLUTTER & FIREBASE
## Môn học: PRM393 — Lập trình ứng dụng di động nâng cao
**Dự án:** FPT Alumni Connect (`F-Alumni-Mobile`)  
**Sinh viên thực hiện:** Trương Chí Trung (MSSV: SE170000 / GitHub: `chstrg2208`)  
**Firebase Project:** `alumniconnect-295ed` (Google Cloud Project ID: `260545453641`)  
**Nền tảng kiểm thử:** Pixel 7 (API 34 - Android 14) & Backend Microservices .NET 9 (Ports 5001–5005)  
**Ngày báo cáo:** 06/11/2026  

---

## MỤC LỤC
1. [Tổng Quan Dự Án & Mục Tiêu Kỹ Thuật](#1-tổng-quan-dự-án--mục-tiêu-kỹ-thuật)
2. [Kiến Trúc Phần Mềm: Mô Hình MVVM & Ranh Giới Dịch Vụ](#2-kiến-trúc-phần-mềm-mô-hình-mvvm--ranh-giới-dịch-vụ)
3. [Hiện Thực & Kiểm Chứng 6 Dịch Vụ Firebase](#3-hiện-thực--kiểm-chứng-6-dịch-vụ-firebase)
   - 3.1. Firebase Authentication (Google Sign-In & Session Sync)
   - 3.2. Firebase Cloud Storage & Security Rules
   - 3.3. Firebase Cloud Messaging (FCM & Notification Center)
   - 3.4. Google Analytics for Firebase (8 Events & DebugView)
   - 3.5. Firebase Crashlytics & Global Error Trapping
   - 3.6. Firebase Remote Config & Dynamic UI
4. [Hiện Thực 3 Luồng Nghiệp Vụ Kế Thừa Từ Lab 2](#4-hiện-thực-3-luồng-nghiệp-vụ-kế-thừa-từ-lab-2)
5. [Đảm Bảo Chất Lượng: Khung Kiểm Thử Tự Động ARTEMIS](#5-đảm-bảo-chất-lượng-khung-kiểm-thử-tự-động-artemis)
6. [Rà Soát Mã Nguồn Bằng Trí Tuệ Nhân Tạo (AI Code Review)](#6-rà-soát-mã-nguồn-bằng-trí-tuệ-nhân-tạo-ai-code-review)
7. [Thách Thức Kỹ Thuật & Giải Pháp Khắc Phục](#7-thách-thức-kỹ-thuật--giải-pháp-khắc-phục)
8. [Phụ Lục: Danh Mục Bằng Chứng Minh Xác](#8-phụ-lục-danh-mục-bằng-chứng-minh-xác)

---

## 1. TỔNG QUAN DỰ ÁN & MỤC TIÊU KỸ THUẬT

### 1.1. Bối cảnh dự án
**FPT Alumni Connect** là giải pháp nền tảng di động đa chức năng nhằm kết nối mạng lưới cựu sinh viên, sinh viên và giảng viên thuộc Khối Đại học FPT toàn quốc (Hòa Lạc, TP.HCM, Đà Nẵng, Cần Thơ, Quy Nhơn). Kế thừa thành quả thiết kế UI/UX và kiến trúc sơ bộ từ Lab 2, Lab 3 đặt trọng tâm vào việc hiện thực hóa ứng dụng di động hoàn chỉnh bằng **Flutter SDK**, tích hợp toàn diện **6 dịch vụ đám mây Firebase**, kết nối hệ thống Backend Microservices (.NET 9) và thiết lập quy trình kiểm thử tự động cùng rà soát mã nguồn bằng AI.

### 1.2. Mục tiêu kỹ thuật cốt lõi
1. **Kiến trúc MVVM nghiêm ngặt:** Phân tách hoàn toàn các tầng hiển thị (View), xử lý nghiệp vụ/trạng thái (ViewModel/Notifier) và dịch vụ đám mây (Service Layer). Tuyệt đối không cho phép Widget giao diện tương tác trực tiếp với Firebase SDK.
2. **Tích hợp trọn vẹn 6 dịch vụ Firebase:**
   - *Firebase Authentication:* Google Sign-In, đồng bộ token JWT với Backend, quản lý phiên và bảo vệ tuyến đường (Route Guard).
   - *Firebase Cloud Storage:* Tải tệp tin gắn chặt với UID (`reports/{uid}/...` và `posts/{uid}/...`), theo dõi tiến độ tải lên (Upload Progress Stream), bảo vệ bằng Security Rules đa tầng.
   - *Firebase Cloud Messaging (FCM):* Tương thích quyền Android 13+ (`POST_NOTIFICATIONS`), xử lý tin nhắn đa trạng thái (Foreground, Background, Terminated) và trung tâm thông báo (Inbox).
   - *Google Analytics:* Đo lường 8 sự kiện chuẩn hóa không chứa thông tin PII, kiểm chứng qua công cụ Android DebugView.
   - *Firebase Crashlytics:* Bắt ngoại lệ toàn cục, ghi nhận lỗi non-fatal, gắn khóa chẩn đoán tùy biến (Custom Keys) và khu vực Test Crash.
   - *Firebase Remote Config:* Quản trị tham số từ xa (`is_promo_banner_enabled`, `max_items_display`), cập nhật thời gian thực không cần phát hành lại bản build và fallback ngoại tuyến.
3. **Độ ổn định & Kiểm thử:** Vượt qua 100% bộ kiểm thử tự động ARTEMIS (14 test cases x 3 lượt chạy = 42 lần chạy thành công), thực hiện phiên kiểm thử khám phá (Exploratory Testing) và báo cáo AI Code Review với các commit khắc phục minh bạch.

---

## 2. KIẾN TRÚC PHẦN MỀM: MÔ HÌNH MVVM & RANH GIỚI DỊCH VỤ

### 2.1. Sơ đồ phân tầng luồng dữ liệu một chiều (Unidirectional Data Flow)

```text
┌────────────────────────────────────────────────────────┐
│                      VIEW (UI)                         │
│  - Màn hình Flutter Widgets (Stateless / Stateful)     │
│  - Phản ứng với 4 trạng thái: Loading, Content,        │
│    Empty, Error                                        │
└───────────────────────────┬────────────────────────────┘
                            │ Lắng nghe trạng thái (State Stream)
                            ▼
┌────────────────────────────────────────────────────────┐
│               VIEWMODEL (RIVERPOD / BLOC)              │
│  - StateNotifier / AsyncNotifier                       │
│  - Điều phối logic UI và chuyển đổi dữ liệu DTO        │
│  - Tuyệt đối KHÔNG import package Firebase             │
└───────────────────────────┬────────────────────────────┘
                            │ Gọi nghiệp vụ trừu tượng
                            ▼
┌────────────────────────────────────────────────────────┐
│                     SERVICE LAYER                      │
│  - FirebaseAuthService, FirebaseStorageService         │
│  - FirebaseAnalyticsService, FirebaseRemoteConfig...   │
│  - Đóng gói toàn bộ logic gọi SDK và xử lý ngoại lệ    │
└───────────────────────────┬────────────────────────────┘
                            │ Tương tác API Cloud
                            ▼
┌────────────────────────────────────────────────────────┐
│                   FIREBASE SDK CORE                    │
│  - Google Cloud / Firebase BaaS Endpoints              │
└────────────────────────────────────────────────────────┘
```

### 2.2. Quy chuẩn thiết kế trạng thái giao diện (4 UI States)
Mọi luồng chức năng đều được chuẩn hóa hiển thị thành 4 trạng thái rõ rệt:
* **Loading State:** Sử dụng `CircularProgressIndicator` hoặc hiệu ứng Shimmer tải khung xương giúp nâng cao trải nghiệm thị giác.
* **Content/Success State:** Hiển thị dữ liệu chính xác khi nhận phản hồi từ Backend hoặc Firebase.
* **Empty State:** Hiển thị hình minh họa đồ họa thân thiện và thông điệp hướng dẫn khi danh sách không có dữ liệu (ví dụ: tìm kiếm không khớp bài viết, hộp thư chưa có thông báo mới).
* **Error State:** Hiển thị thông báo ngữ cảnh (Toast / SnackBar / Error Card) kèm nút thao tác thử lại (Retry Button), ghi nhận lỗi phi nghiêm trọng (Non-fatal) về Crashlytics mà không làm sập ứng dụng.

---

## 3. HIỆN THỰC & KIỂM CHỨNG 6 DỊCH VỤ FIREBASE

### 3.1. Firebase Authentication (Google Sign-In & Session Sync)
* **Hiện thực kỹ thuật:**
  - Khai báo dấu vân tay chứng chỉ ký trên máy phát triển:
    - SHA-1: `84:47:1C:8F:72:61:DD:8C:1D:92:1A:57:ED:D8:53:73:AE:DB:B9:F5`
    - SHA-256: `6D:EF:9F:5A:05:BA:61:EB:63:59:C4:C4:76:AE:B8:76:FE:43:35:87:71:E9:97:68:A4:46:63:74:0F:82:24:8C`
  - Đóng gói trong lớp `FirebaseAuthService`. Khi người dùng chọn đăng nhập Google, SDK kích hoạt hộp thoại chọn tài khoản, lấy `idToken` và tạo `GoogleAuthProvider.credential` để đăng nhập vào Firebase Auth. Đồng thời `idToken` được chuyển tiếp đến User Service (.NET API :5001) để lấy JWT phiên làm việc của hệ thống.
  - Lắng nghe luồng `authStateChanges` để tự động kích hoạt Route Guard bảo vệ các tuyến đường `/home`, `/profile`, `/jobs`.
  - Hỗ trợ xử lý trường hợp người dùng hủy bỏ (User cancelled) và ngắt mạng đột ngột mà không gây văng ứng dụng.
* **Bằng chứng xác thực:**
  - `Console_01_Authentication_Users.png`: Xác nhận tài khoản người dùng hiển thị trực tiếp trên Firebase Console với UID định danh và phương thức Google.
  - `Step_04_ManHinh_DangNhap.png` & `Step_06_DangNhap_ThanhCong_HomeFeed.png`: Minh chứng giao diện trước và sau khi xác thực thành công.

---

### 3.2. Firebase Cloud Storage & Security Rules
* **Hiện thực kỹ thuật:**
  - Triển khai trong lớp `FirebaseStorageService` cung cấp luồng theo dõi tiến độ thời gian thực:
    ```dart
    Stream<StorageUploadProgress> uploadReport({
      required String uid,
      required File file,
      required String fileName,
    }) async* { ... }
    ```
  - Cấu trúc thư mục đám mây tuân thủ nghiêm ngặt theo UID: `reports/{uid}/{filename}` và `posts/{uid}/{filename}`.
  - Sau khi tải lên thành công (`TaskState.success`), service gọi `reference.getDownloadURL()` để trích xuất đường dẫn công khai an toàn gán vào thực thể bài viết hoặc hồ sơ.
* **Quy tắc bảo mật Cloud Storage (`firebase/storage.rules`):**
  ```rules
  rules_version = '2';
  service firebase.storage {
    match /b/{bucket}/o {
      match /reports/{userId}/{fileName} {
        allow read, write: if request.auth != null 
          && request.auth.uid == userId
          && request.resource.size < 10 * 1024 * 1024
          && (request.resource.contentType.matches('image/.*')
              || request.resource.contentType == 'application/pdf'
              || request.resource.contentType == 'text/csv');
      }
      match /posts/{userId}/{fileName} {
        allow write: if request.auth != null 
          && request.auth.uid == userId
          && request.resource.size < 10 * 1024 * 1024
          && request.resource.contentType.matches('image/.*');
        allow read: if request.auth != null;
      }
    }
  }
  ```
* **Bằng chứng xác thực:**
  - `Console_02_Cloud_Storage.png`: Bảng điều khiển Cloud Storage trên Firebase Console.
  - `Step_08_ChinhSuaHoSo_GiaoDien.png` đến `Step_13_TaoBaiViet_NhapNoiDung.png`: Minh chứng thao tác chọn ảnh, tải lên và gắn URL vào bài viết.

---

### 3.3. Firebase Cloud Messaging (FCM & Notification Center)
* **Hiện thực kỹ thuật:**
  - Tích hợp lớp `FcmMessagingService` tương thích với hệ điều hành Android 13+ (API 33/34), chủ động yêu cầu quyền runtime `POST_NOTIFICATIONS`.
  - Quản lý và xử lý sự kiện thông báo toàn diện trên 3 trạng thái của ứng dụng:
    1. *Foreground State:* Bắt sự kiện qua `FirebaseMessaging.onMessage`, hiển thị In-app Toast / Notification Banner mà không làm gián đoạn tác vụ hiện tại của người dùng.
    2. *Background State:* Nhận thông báo trên thanh thông báo hệ thống của Android qua dịch vụ nền.
    3. *Terminated State:* Xử lý qua `FirebaseMessaging.instance.getInitialMessage()`, khi người dùng chạm vào thông báo từ trạng thái đóng hoàn toàn, ứng dụng tự động mở và chuyển hướng chính xác đến màn hình bài viết hoặc việc làm tương ứng (Deep Linking).
  - Tích hợp Trung tâm thông báo (Notification Inbox) cục bộ trong app để lưu vết và xem lại lịch sử các thông báo nhận được.
* **Bằng chứng xác thực:**
  - `Step_19_HopThu_ThongBao_NotificationInbox.png`: Giao diện Hộp thư thông báo hiển thị danh sách các thông báo nhận được.

---

### 3.4. Google Analytics for Firebase (8 Events & DebugView)
* **Hiện thực kỹ thuật:**
  - Xây dựng tài liệu chiến lược phân tích `docs/analytics-plan.md` trước khi code.
  - Hiện thực lớp `FirebaseAnalyticsService` đo lường **8 sự kiện chuẩn hóa**:
    1. `login`: Ghi nhận phương thức đăng nhập (`method`: `google` hoặc `email`).
    2. `logout`: Ghi nhận sự kiện kết thúc phiên làm việc.
    3. `search`: Đo lường tìm kiếm với tham số `search_type` và `result_count`.
    4. `select_content`: Đo lường khi chạm vào thẻ nội dung với `content_type`.
    5. `view_item`: Đo lường thời gian xem chi tiết với `item_category`.
    6. `avatar_upload_complete`: Đo lường tỉ lệ upload ảnh hoàn tất (`file_type`: `image`).
    7. `export_file`: Ghi nhận xuất báo cáo (`file_type`: `pdf`/`csv`).
    8. `notification_open`: Ghi nhận tỉ lệ mở thông báo với `notification_type`.
  - Tuân thủ quy định bảo mật thông tin (Privacy & Data Governance): Tuyệt đối không gửi email, số điện thoại, họ tên hoặc dữ liệu nhạy cảm cá nhân vào tham số sự kiện. Sử dụng `setUserId(user.uid)` sau khi đăng nhập thành công.
* **Bằng chứng xác thực:**
  - `Console_03_Analytics_DebugView.png`: Minh chứng kích hoạt chế độ gỡ lỗi `debug.firebase.analytics.app` và theo dõi trực tiếp dòng sự kiện trên Firebase Console DebugView.

---

### 3.5. Firebase Crashlytics & Global Error Trapping
* **Hiện thực kỹ thuật:**
  - Thiết lập bẫy lỗi toàn cục ngay tại hàm khởi chạy ứng dụng:
    ```dart
    FlutterError.onError = (details) {
      service._crashlytics.recordFlutterFatalError(details);
    };
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      service.recordFatalError(error, stackTrace);
      return true;
    };
    ```
  - Bổ sung phương thức `recordHandledError` ghi nhận các lỗi đã được bắt và xử lý an toàn (Non-fatal errors, ví dụ: lỗi tải file khi mạng yếu) mà không làm ngắt ứng dụng của người dùng.
  - Thiết lập định danh người dùng `setUserIdentifier(user.uid)` và gắn các khóa chẩn đoán tùy chỉnh `setCustomKey("environment", "development")`.
  - Tạo nút thử nghiệm sự cố có chủ đích (Test Crash Button) trong khu vực gỡ lỗi nội bộ nhằm xác thực đường truyền dữ liệu lên Crashlytics.
* **Bằng chứng xác thực:**
  - `Console_04_Crashlytics_Dashboard.png`: Bảng điều khiển Crashlytics ghi nhận trực tiếp 184 sự cố đã phân tích, 2 người dùng bị ảnh hưởng kèm chi tiết dòng code gây crash.

---

### 3.6. Firebase Remote Config & Dynamic UI
* **Hiện thực kỹ thuật:**
  - Khai báo 2 tham số cấu hình liên kết trực quan với giao diện người dùng:
    1. `is_promo_banner_enabled` (boolean, mặc định: `true`): Điều khiển bật/tắt hiển thị thẻ quảng bá "Sự kiện & Workshop FPTU mới nhất" trên đỉnh trang chủ Bảng tin.
    2. `max_items_display` (integer, mặc định: `10`): Điều khiển số lượng bài viết hoặc cựu sinh viên tối đa nạp trong một trang tải.
  - Tối ưu hóa chu kỳ bộ nhớ đệm: Trong chế độ `kDebugMode` sử dụng `Duration.zero` để phản ánh tức thì các chỉnh sửa từ Firebase Console; trên môi trường Production sử dụng chu kỳ 1 giờ để tiết kiệm tài nguyên mạng.
  - Hỗ trợ cơ chế Offline Fallback: Khi mất mạng hoặc thiết bị ở chế độ máy bay, ứng dụng tự động tải bộ giá trị mặc định được thiết lập trong mã nguồn mà không gặp bất kỳ lỗi logic nào.
* **Bằng chứng xác thực:**
  - `Console_05_RemoteConfig_Dashboard.png`: Bảng điều khiển tham số trên Firebase Console.
  - `Step_06_DangNhap_ThanhCong_HomeFeed.png`: Giao diện Home Feed hiển thị Banner Sự kiện được điều khiển trực tiếp từ Remote Config.

---

## 4. HIỆN THỰC 3 LUỒNG NGHIỆP VỤ KẾ THỪA TỪ LAB 2

### 4.1. Luồng 1: Khám phá Bảng tin & Tương tác bài viết (Feed Flow)
- Người dùng duyệt danh sách bài viết từ cộng đồng FPT được đồng bộ từ Forum API (:5003).
- Bộ lọc danh mục đa dạng: "Tất cả", "CNTT & Phần mềm", "Việc làm & Referral", "Kinh doanh".
- Bộ lọc cơ sở: "Hòa Lạc", "Đà Nẵng", "TP.HCM".
- Hỗ trợ tạo bài viết mới kèm ảnh tải lên Firebase Storage (`Step_12`, `Step_13`), mở chi tiết bài viết, đọc và gửi bình luận tương tác thời gian thực (`Step_14`).

### 4.2. Luồng 2: Danh bạ Cựu sinh viên & Cố vấn AI (Directory & Mentorship Flow)
- Tìm kiếm cựu sinh viên theo họ tên, khóa học (K14, K15, K16, K17), cơ sở đào tạo và chuyên ngành (`Step_15`).
- Mở xem hồ sơ chi tiết (Alumni Profile) với các thông tin học vấn, kinh nghiệm làm việc, kỹ năng chuyên môn và các nút hành động kết nối (`Step_16`).
- Tích hợp trợ lý trí tuệ nhân tạo **AI Mentor** hỗ trợ tư vấn OJT, định hướng nghề nghiệp và giải đáp thắc mắc chuyên môn 24/7 (`Step_20`).

### 4.3. Luồng 3: Cơ hội Việc làm & Giới thiệu Doanh nghiệp (Jobs & Referral Flow)
- Khám phá các tin tuyển dụng được đăng bởi chính các cựu sinh viên đang làm việc tại các tập đoàn công nghệ hàng đầu (FPT Software, Viettel, Momo, Shopee...) (`Step_17`).
- Xem chi tiết công việc: vị trí, mức lương đãi ngộ, địa điểm làm việc, yêu cầu kỹ thuật và văn hóa doanh nghiệp (`Step_18`).
- Tính năng gửi yêu cầu giới thiệu nội bộ (Employee Referral) giúp gia tăng cơ hội trúng tuyển cho sinh viên FPT.

---

## 5. ĐẢM BẢO CHẤT LƯỢNG: KHUNG KIỂM THỬ TỰ ĐỘNG ARTEMIS

### 5.1. Ma trận kiểm thử E2E (14 Test Cases x 3 Runs)
Quy trình kiểm thử được tự động hóa hoàn toàn với 14 ca kiểm thử chi tiết, mỗi ca được chạy lặp lại 3 lần liên tiếp nhằm kiểm tra độ ổn định và tính nhất quán của trạng thái ứng dụng:

| Mã ca kiểm thử | Mô tả kịch bản | Thể loại | Lượt 1 | Lượt 2 | Lượt 3 | Tỷ lệ đạt |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **ART-01** | Chặn điều hướng trái phép khi chưa xác thực | Negative | PASS | PASS | PASS | **100%** |
| **ART-02** | Xử lý hủy đăng nhập Google và phục hồi an toàn | Negative | PASS | PASS | PASS | **100%** |
| **ART-03** | Duyệt bảng tin và xem chi tiết bài viết kỹ thuật | User Flow 1 | PASS | PASS | PASS | **100%** |
| **ART-04** | Tìm kiếm bài viết và hiển thị trạng thái rỗng | UI State | PASS | PASS | PASS | **100%** |
| **ART-05** | Tìm kiếm danh bạ và mở hồ sơ cựu sinh viên | User Flow 2 | PASS | PASS | PASS | **100%** |
| **ART-06** | Lọc cựu sinh viên theo cơ sở và kết nối AI Mentor | User Flow 2 | PASS | PASS | PASS | **100%** |
| **ART-07** | Tìm kiếm việc làm và mở chi tiết tin tuyển dụng | User Flow 3 | PASS | PASS | PASS | **100%** |
| **ART-08** | Gửi yêu cầu ứng tuyển và giới thiệu Referral | User Flow 3 | PASS | PASS | PASS | **100%** |
| **ART-09** | Theo dõi tiến độ tải ảnh đại diện lên Cloud Storage | Storage | PASS | PASS | PASS | **100%** |
| **ART-10** | Xử lý quyền thông báo hệ điều hành Android 13+ | Android Native | PASS | PASS | PASS | **100%** |
| **ART-11** | Nhận thông báo FCM ở Foreground và Background | Push FCM | PASS | PASS | PASS | **100%** |
| **ART-12** | Điều hướng Deep Link khi ứng dụng tắt hẳn (Terminated)| Push FCM | PASS | PASS | PASS | **100%** |
| **ART-13** | Cập nhật Remote Config trực tiếp và Fallback mất mạng | Remote Config | PASS | PASS | PASS | **100%** |
| **ART-14** | Bắt lỗi Non-fatal và kích hoạt Test Crashlytics | Crashlytics | PASS | PASS | PASS | **100%** |

* **Tổng kết Pass Rate:** 42/42 lượt chạy thành công (**100% Pass Rate**).
* Toàn bộ mã nguồn kiểm thử nội bộ (`flutter test`) vượt qua 100% không phát sinh bất kỳ assertion error nào.

### 5.2. Phiên kiểm thử khám phá (Exploratory Testing Session - 25 Phút)
- **Thiết bị:** Google Pixel 7 (Android 14, API 34).
- **Mục tiêu:** Kiểm tra khả năng phục hồi dữ liệu khi ngắt kết nối mạng bất ngờ, kiểm tra bố cục giao diện khi xoay màn hình và kiểm tra xung đột layout khi hiển thị bàn phím ảo.
- **Kết quả:** Phát hiện và khắc phục dứt điểm 2 lỗi giao diện (RenderFlex overflow trên AppBar của Home Feed và Column trên Onboarding Screen), nâng cao độ mượt mà và tính bền vững của phần mềm.

---

## 6. RÀ SOÁT MÃ NGUỒN BẰNG TRÍ TUỆ NHÂN TẠO (AI CODE REVIEW)

Thực hiện rà soát tự động thông qua công cụ AI Code Review (CodeRabbit & Gemini Assistant) trên Pull Request tích hợp Lab 3. Báo cáo ghi nhận **6 phát hiện cụ thể trên 4 nhóm chủ đề**:

| Mã số | File & Dòng | Nhóm chủ đề | Mức độ | Trạng thái | Hành động khắc phục |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **F-01** | `firebase_storage_service.dart:58-68` | Security & Validation | High | **ACCEPT** | Bổ sung hỗ trợ tải báo cáo định dạng `PDF` và `CSV` khớp với Security Rules. |
| **F-02** | `onboarding_screen.dart:191-255` | UI Stability & Performance| Medium | **ACCEPT** | Bọc widget trong `SingleChildScrollView` tránh lỗi tràn điểm ảnh trên màn hình nhỏ. |
| **F-03** | `firebase_analytics_service.dart:37-41` | Architecture & Compliance | Medium | **ACCEPT** | Bổ sung phương thức `logExportFile` đảm bảo đủ 8 sự kiện theo yêu cầu đề bài. |
| **F-04** | `avatar_upload_view_model.dart:39-45` | Error Handling & UX | Low | **MODIFY** | Giữ vững rào chặn bảo mật, cải thiện thông báo và ghi nhận log Crashlytics an toàn. |
| **F-05** | `firebase/storage.rules:1-15` | Security & Cloud Hardening | High | **ACCEPT** | Thêm ràng buộc kích thước file `< 10MB` và xác thực MIME type tránh tấn công DoS. |
| **F-06** | `firebase_remote_config_service.dart:18-20` | Performance & Network | Low | **MODIFY** | Tự động kích hoạt `Duration.zero` khi ở chế độ `kDebugMode` giúp debug mượt mà. |

* **Truy vết mã Git Commit:** Đã áp dụng 5 commit sửa lỗi nguyên tử (`fix`, `feat`, `sec`, `perf`), đáp ứng vượt mức yêu cầu sửa tối thiểu 3 phát hiện được chấp nhận.

---

## 7. THÁCH THỨC KỸ THUẬT & GIẢI PHÁP KHẮC PHỤC

1. **Thách thức:** Đăng nhập kép giữa Backend Microservices (.NET) và Firebase Authentication.
   - *Giải pháp:* Thiết lập cơ chế trao đổi ID Token: Google Sign-In trên ứng dụng tạo ra Firebase ID Token, sau đó ứng dụng gửi token này lên User Service để xác thực danh tính sinh viên và nhận về JWT token quản lý các API chuyên biệt (Chat, Forum, AI).
2. **Thách thức:** Xung đột phiên bản Dart SDK giữa môi trường máy phát triển và thư viện phụ thuộc.
   - *Giải pháp:* Tinh chỉnh cấu hình dải phiên bản trong `pubspec.yaml` thành `sdk: ">=3.13.2 <4.0.0"`, giúp biên dịch thành công mà không gây phá vỡ tính tương thích ngược.
3. **Thách thức:** Lỗi tràn điểm ảnh RenderFlex trên các thiết bị Android có kích thước hiển thị khác nhau.
   - *Giải pháp:* Chuyển đổi các layout dạng `Column` cố định sang `SingleChildScrollView` kết hợp `Flexible`/`Expanded` và áp dụng kỹ thuật padding linh hoạt theo tỷ lệ màn hình.

---

## 8. PHỤ LỤC: DANH MỤC BẰNG CHỨNG MINH XÁC

### Phần A: Giao diện ứng dụng di động (20 Ảnh)
- `Step_01_Onboarding_KetNoiCongDong.png`: Màn hình Onboarding 1 - Kết nối cộng đồng FPT.
- `Step_02_Onboarding_CoHoiViecLam.png`: Màn hình Onboarding 2 - Cơ hội việc làm & Referral.
- `Step_03_Onboarding_AITroLy.png`: Màn hình Onboarding 3 - Trợ lý AI thông minh.
- `Step_04_ManHinh_DangNhap.png`: Màn hình đăng nhập (Google & FPT Mail).
- `Step_05_Nhap_ThongTin_FPTMail.png`: Form nhập email FPT và mật khẩu.
- `Step_06_DangNhap_ThanhCong_HomeFeed.png`: Giao diện Home Feed sau khi đăng nhập thành công.
- `Step_07_TrangCaNhan_Profile.png`: Màn hình hồ sơ cá nhân và cài đặt tài khoản.
- `Step_08_ChinhSuaHoSo_GiaoDien.png`: Giao diện chỉnh sửa thông tin sinh viên/cựu sinh viên.
- `Step_09_ChinhSuaHoSo_ChiTiet.png`: Chi tiết các trường chuyên ngành, cơ sở, khóa học.
- `Step_10_ThayDoiAvatar_GiaoDien.png`: Thao tác chạm camera để thay đổi ảnh đại diện.
- `Step_11_ThayDoiAvatar_ThongBaoFirebase.png`: Kiểm tra bảo mật phiên xác thực Firebase trước khi tải ảnh.
- `Step_12_TaoBaiViet_ChonAnh_Storage.png`: Thao tác chọn ảnh đính kèm bài viết từ thư viện máy.
- `Step_13_TaoBaiViet_NhapNoiDung.png`: Soạn thảo nội dung bài viết và chọn chủ đề thảo luận.
- `Step_14_ChiTietBaiViet_BinhLuan_FlowFeed.png`: Màn hình chi tiết bài viết và danh sách bình luận.
- `Step_15_DanhBa_Alumni_Directory.png`: Danh bạ cựu sinh viên với bộ lọc cơ sở và khóa học.
- `Step_16_ChiTiet_AlumniProfile.png`: Hồ sơ chi tiết một cựu sinh viên tiêu biểu.
- `Step_17_BangTin_ViecLam_Jobs.png`: Bảng tin tuyển dụng và cơ hội việc làm Alumni.
- `Step_18_ChiTiet_TinTuyenDung_JobDetail.png`: Chi tiết mô tả công việc, mức lương và nút ứng tuyển.
- `Step_19_HopThu_ThongBao_NotificationInbox.png`: Trung tâm thông báo lưu trữ lịch sử push notifications.
- `Step_20_TroLy_AIMentor_Chat.png`: Giao diện trò chuyện và tư vấn nghề nghiệp cùng AI Mentor.

### Phần B: Bảng điều khiển Firebase Console (5 Ảnh)
- `Console_01_Authentication_Users.png`: Danh sách người dùng được quản lý trên Firebase Authentication.
- `Console_02_Cloud_Storage.png`: Bảng điều khiển dịch vụ Cloud Storage.
- `Console_03_Analytics_DebugView.png`: Dòng sự kiện đo lường thời gian thực trên Analytics DebugView.
- `Console_04_Crashlytics_Dashboard.png`: Báo cáo sự cố và chẩn đoán lỗi trên Firebase Crashlytics.
- `Console_05_RemoteConfig_Dashboard.png`: Bảng điều khiển tham số cấu hình động trên Remote Config.

---
*Báo cáo được biên soạn và kiểm chứng hoàn tất trên mã nguồn thực tế của dự án.*
