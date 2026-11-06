# 🎓 FPT Alumni Connect — Mobile Application (PRM393)
## Lab 3: Flutter & Firebase Cloud Services Integration (MVVM Architecture)

[![Flutter](https://img.shields.io/badge/Flutter-3.13+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-6%20Services-FFCA28?logo=firebase)](https://firebase.google.com)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM%20%2F%20Riverpod%20%2B%20BLoC-green)]()
[![Tests](https://img.shields.io/badge/Tests-42%2F42%20Passed%20(100%25)-success)]()
[![Code Review](https://img.shields.io/badge/AI%20Code%20Review-CodeRabbit%20%26%20Gemini-blueviolet)]()

**FPT Alumni Connect** là ứng dụng di động kết nối mạng lưới Cựu sinh viên, Sinh viên và Giảng viên Khối Đại học FPT toàn quốc. Dự án Lab 3 hoàn thiện việc chuyển giao từ thiết kế giao diện (Lab 2) sang một ứng dụng di động hoàn chỉnh có kết nối nền tảng đám mây **Firebase** và hệ thống **Backend Microservices .NET 9**.

---

## 📑 MỤC LỤC
1. [Tổng quan dự án & Điểm mới trong Lab 3](#1-tổng-quan-dự-án--điểm-mới-trong-lab-3)
2. [Kiến trúc phân tầng MVVM & Ranh giới dịch vụ](#2-kiến-trúc-phân-tầng-mvvm--ranh-giới-dịch-vụ)
3. [Tích hợp 6 Dịch vụ Đám mây Firebase](#3-tích-hợp-6-dịch-vụ-đám-mây-firebase)
4. [3 Luồng nghiệp vụ cốt lõi từ Lab 2](#4-3-luồng-nghiệp-vụ-cốt-lõi-từ-lab-2)
5. [Đảm bảo chất lượng: Kiểm thử tự động ARTEMIS (100% Pass)](#5-đảm-bảo-chất-lượng-kiểm-thử-tự-động-artemis-100-pass)
6. [Rà soát mã nguồn bằng AI (AI Code Review)](#6-rà-soát-mã-nguồn-bằng-ai-ai-code-review)
7. [Danh mục bằng chứng hình ảnh (25 Artifacts)](#7-danh-mục-bằng-chứng-hình-ảnh-25-artifacts)
8. [Tài liệu bàn giao & Báo cáo nộp bài](#8-tài-liệu-bàn-giao--báo-cáo-nộp-bài)
9. [Hướng dẫn cài đặt & Khởi chạy ứng dụng](#9-hướng-dẫn-cài-đặt--khởi-chạy-ứng-dụng)

---

## 1. TỔNG QUAN DỰ ÁN & ĐIỂM MỚI TRONG LAB 3

Trong giai đoạn Lab 3, ứng dụng đã được nâng cấp toàn diện từ mô hình UI Mockup sang ứng dụng hoạt động thực tế (Production-grade Mobile App):
- **Firebase Project:** `alumniconnect-295ed` (Google Cloud Project ID: `260545453641`).
- **Nền tảng kiểm thử:** Google Pixel 7 Emulator (API 34 - Android 14) kết hợp hệ thống 5 Backend Microservices (.NET 9) trên các cổng `5001`–`5005`.
- **Độ ổn định mã nguồn:** Sửa dứt điểm các lỗi giao diện `RenderFlex overflow`, đưa bộ kiểm thử `flutter test` đạt **100% Passed** và `dart analyze` đạt **0 errors**.

---

## 2. KIẾN TRÚC PHÂN TẦNG MVVM & RANH GIỚI DỊCH VỤ

Ứng dụng tuân thủ nghiêm ngặt mô hình kiến trúc **MVVM (Model - View - ViewModel)** kết hợp luồng dữ liệu 1 chiều (Unidirectional Data Flow):

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
└───────────────────────────┬────────────────────────────┘
                            │ Trao đổi Token xác thực
                            ▼
┌────────────────────────────────────────────────────────┐
│             BACKEND MICROSERVICES (.NET 9)             │
│  User (:5001) | Chat (:5002) | Forum (:5003)           │
│  AI (:5004)   | Admin (:5005)                          │
└────────────────────────────────────────────────────────┘
```

### Quy tắc bất biến:
- **Nguyên tắc phân lập:** Widget giao diện (View) tuyệt đối **KHÔNG ĐƯỢC** gọi trực tiếp các phương thức của Firebase SDK. Mọi tương tác đám mây phải thông qua `Service Layer` và được cung cấp qua Riverpod Providers (`lib/features/lab3/presentation/providers/`).
- **4 Trạng thái UI chuẩn:** Mọi màn hình đều biểu diễn tường minh 4 trạng thái: `Loading` (shimmer/progress), `Content` (dữ liệu hiển thị), `Empty` (minh họa thân thiện khi không có dữ liệu) và `Error` (thông báo ngữ cảnh kèm nút thử lại).

---

## 3. TÍCH HỢP 6 DỊCH VỤ ĐÁM MÂY FIREBASE

### 3.1. Firebase Authentication (Google Sign-In & Session Sync)
- Khai báo chứng chỉ SHA-1 và SHA-256 trên Firebase Console.
- Thực hiện đăng nhập Google, lấy `idToken` xác thực với Firebase và trao đổi với User Service (:5001) để lấy JWT phiên làm việc.
- Lắng nghe stream `authStateChanges()`: Tự động điều hướng giữa màn hình Login và Home Feed (Route Guard), bảo vệ an toàn các tuyến đường người dùng.
- Bắt lỗi khi người dùng hủy chọn tài khoản (User cancelled) hoặc mất kết nối mạng.
- *Minh chứng:* `Console_01_Authentication_Users.png` & `Step_04` -> `Step_06`.

### 3.2. Firebase Cloud Storage & Security Rules
- Triển khai `FirebaseStorageService` cung cấp luồng theo dõi tiến độ tải lên phần trăm thời gian thực (`StorageUploadProgress`).
- Cấu trúc thư mục đám mây nghiêm ngặt: `reports/{uid}/{filename}` và `posts/{uid}/{filename}`.
- Hỗ trợ đa dạng tệp tin: Hình ảnh (JPG, PNG, WebP) và Báo cáo tài liệu (PDF, CSV).
- Tự động lấy Download URL bảo mật sau khi hoàn tất tải lên.
- **Quy tắc bảo mật (`firebase/storage.rules`):** Chỉ cho phép chính chủ UID đọc/ghi tệp của họ (`request.auth.uid == userId`), giới hạn kích thước `< 10MB` và xác thực MIME-type, ngăn chặn triệt để nguy cơ tấn công DoS dung lượng.
- *Minh chứng:* `Console_02_Cloud_Storage.png` & `Step_08` -> `Step_13`.

### 3.3. Firebase Cloud Messaging (FCM & Notification Inbox)
- Tương thích toàn diện với Android 13+ và Android 14 (API 34): Chủ động xin quyền runtime `POST_NOTIFICATIONS`.
- Xử lý mượt mà thông báo trên cả **3 trạng thái**:
  1. *Foreground:* Bắt sự kiện hiển thị In-app Toast / Notification Card không gây ngắt quãng UI.
  2. *Background:* Nhận Push Notification qua trung tâm thông báo của hệ điều hành.
  3. *Terminated:* Ứng dụng tự động khởi động từ trạng thái tắt hoàn toàn và điều hướng chính xác đến màn hình mục tiêu (Deep Linking).
- Xây dựng Trung tâm thông báo (Notification Inbox) cục bộ trong app để lưu vết lịch sử thông báo.
- *Minh chứng:* `Step_19_HopThu_ThongBao_NotificationInbox.png`.

### 3.4. Google Analytics for Firebase (8 Events & DebugView)
- Xây dựng tài liệu chiến lược `docs/analytics-plan.md` với **8 sự kiện chuẩn hóa**:
  `login`, `logout`, `search`, `select_content`, `view_item`, `avatar_upload_complete`, `export_file`, `notification_open`.
- Gắn định danh `setUserId(user.uid)` sau khi đăng nhập thành công.
- **Chính sách bảo mật (No PII):** Tuyệt đối không gửi email sinh viên, tên thật, số điện thoại hay chuỗi tìm kiếm thô vào tham số sự kiện.
- Kích hoạt chế độ kiểm thử qua `adb shell setprop debug.firebase.analytics.app vn.edu.fpt.alumni_connect` và kiểm chứng trực tiếp trên DebugView.
- *Minh chứng:* `Console_03_Analytics_DebugView.png`.

### 3.5. Firebase Crashlytics & Global Error Trapping
- Thiết lập bẫy lỗi toàn cục qua `FlutterError.onError` và `PlatformDispatcher.instance.onError`.
- Ghi nhận lỗi có xử lý (`recordHandledError` / Non-fatal): Khi xảy ra lỗi mạng trong quá trình upload, ứng dụng hiển thị thông báo thân thiện cho người dùng, đồng thời đẩy stack trace về Crashlytics.
- Gắn khóa chẩn đoán ngữ cảnh: `setUserIdentifier` và `setCustomKey("environment", "development")`.
- Xây dựng nút bấm ẩn thử nghiệm sự cố (**Test Crash Button**) trong khu vực gỡ lỗi để kiểm tra đường truyền.
- Bảng điều khiển ghi nhận trực tiếp **184 sự cố**, 2 người dùng bị ảnh hưởng và phân tích chi tiết dòng mã gây crash.
- *Minh chứng:* `Console_04_Crashlytics_Dashboard.png`.

### 3.6. Firebase Remote Config & Dynamic UI
- Thiết lập 2 tham số cấu hình liên kết trực tiếp với UI kèm giá trị mặc định (`setDefaults`):
  1. `is_promo_banner_enabled` (boolean, mặc định: `true`): Điều khiển bật/tắt hiển thị thẻ quảng bá "Sự kiện & Workshop FPTU mới nhất" trên Home Feed.
  2. `max_items_display` (number, mặc định: `10`): Điều khiển số lượng bài viết / alumni nạp trong danh sách.
- Tối ưu chu kỳ fetch: Áp dụng `Duration.zero` khi ở chế độ `kDebugMode` giúp thay đổi trên Console phản ánh tức thì lên app mà không cần build lại APK.
- Hỗ trợ cơ chế Fallback ngoại tuyến an toàn khi thiết bị mất mạng.
- *Minh chứng:* `Console_05_RemoteConfig_Dashboard.png` & `Step_06_DangNhap_ThanhCong_HomeFeed.png`.

---

## 4. 3 LUỒNG NGHIỆP VỤ CỐT LÕI TỪ LAB 2

1. **Luồng 1 — Bảng tin & Thảo luận kỹ thuật:**
   - Lướt bài viết từ Forum Service (:5003), lọc bài theo chuyên đề (CNTT, Việc làm, Kinh doanh).
   - Đăng bài viết mới kèm ảnh tải lên Cloud Storage; xem chi tiết bài và bình luận thời gian thực (`Step_06`, `Step_12`, `Step_14`).
2. **Luồng 2 — Danh bạ Cựu sinh viên & Cố vấn AI Mentor:**
   - Tìm kiếm alumni theo ngành học, khóa tốt nghiệp (K14–K17), cơ sở đào tạo (Hòa Lạc, TP.HCM, Đà Nẵng).
   - Xem hồ sơ chi tiết Alumni và kết nối trợ lý **AI Mentor** tư vấn OJT 24/7 (`Step_15`, `Step_16`, `Step_20`).
3. **Luồng 3 — Cơ hội Việc làm & Giới thiệu Doanh nghiệp:**
   - Khám phá các tin tuyển dụng từ cựu sinh viên tại FPT Software, Viettel, Momo...
   - Xem chi tiết mô tả công việc, mức lương và gửi yêu cầu Referral nội bộ (`Step_17`, `Step_18`).

---

## 5. ĐẢM BẢO CHẤT LƯỢNG: KIỂM THỬ TỰ ĐỘNG ARTEMIS (100% PASS)

Toàn bộ **14 ca kiểm thử E2E** được thực thi lặp lại 3 lần/ca (tổng cộng 42 lượt chạy), đạt tỷ lệ thành công tuyệt đối:

| Mã kiểm thử | Mô tả kịch bản | Thể loại | Kết quả (3 Runs) | Minh chứng |
| :--- | :--- | :---: | :---: | :--- |
| **ART-01** | Chặn điều hướng trái phép khi chưa xác thực | Negative | PASS (3/3) | `Step_01`, `Step_04` |
| **ART-02** | Xử lý hủy đăng nhập Google và phục hồi an toàn | Negative | PASS (3/3) | `Step_04`, `Step_05`, `Step_06` |
| **ART-03** | Duyệt bảng tin và xem chi tiết bài viết | User Flow 1 | PASS (3/3) | `Step_06`, `Step_14` |
| **ART-04** | Tìm kiếm bài viết và hiển thị trạng thái rỗng | UI State | PASS (3/3) | `Step_06`, `Step_15` |
| **ART-05** | Tìm kiếm danh bạ và mở hồ sơ cựu sinh viên | User Flow 2 | PASS (3/3) | `Step_15`, `Step_16` |
| **ART-06** | Lọc cựu sinh viên theo cơ sở và chat AI Mentor | User Flow 2 | PASS (3/3) | `Step_15`, `Step_20` |
| **ART-07** | Tìm kiếm việc làm và mở chi tiết tin tuyển dụng | User Flow 3 | PASS (3/3) | `Step_17`, `Step_18` |
| **ART-08** | Gửi yêu cầu ứng tuyển và giới thiệu Referral | User Flow 3 | PASS (3/3) | `Step_18` |
| **ART-09** | Theo dõi tiến độ tải ảnh đại diện lên Cloud Storage | Storage | PASS (3/3) | `Step_08`, `Step_11`, `Console_02` |
| **ART-10** | Xử lý quyền thông báo hệ điều hành Android 13+ | Android Native | PASS (3/3) | `Step_19` |
| **ART-11** | Nhận thông báo FCM ở Foreground và Background | Push FCM | PASS (3/3) | `Step_19` |
| **ART-12** | Điều hướng Deep Link khi ứng dụng tắt hẳn (Terminated)| Push FCM | PASS (3/3) | `Step_19`, `Step_18` |
| **ART-13** | Cập nhật Remote Config trực tiếp và Fallback mất mạng | Remote Config | PASS (3/3) | `Step_06`, `Console_05` |
| **ART-14** | Bắt lỗi Non-fatal và kích hoạt Test Crashlytics | Crashlytics | PASS (3/3) | `Step_11`, `Console_04` |

* **Tổng kết Pass Rate:** **42/42 Runs Passed (100%)**.
* **Phiên kiểm thử khám phá (Exploratory Testing Session):** Thực hiện trong 25 phút trên thiết bị Pixel 7, phát hiện và sửa dứt điểm 2 lỗi giao diện overflow.

---

## 6. RÀ SOÁT MÃ NGUỒN BẰNG AI (AI CODE REVIEW)

Quy trình rà soát mã nguồn tự động ghi nhận **6 phát hiện** chuyên sâu trên 4 nhóm chủ đề theo tài liệu [`docs/ai-code-review.md`](docs/ai-code-review.md):

| ID | Vị trí file & dòng | Nhóm chủ đề | Mức độ | Trạng thái | Mã Commit Hash |
| :---: | :--- | :--- | :---: | :---: | :---: |
| **F-01** | `firebase_storage_service.dart:58-68` | Security & Validation | High | **ACCEPT** | `54dac92` |
| **F-02** | `onboarding_screen.dart:191-255` | UI Stability & Performance | Medium | **ACCEPT** | `14d3bf3` |
| **F-03** | `firebase_analytics_service.dart:37-41` | Architecture & Compliance | Medium | **ACCEPT** | `f9fada8` |
| **F-04** | `avatar_upload_view_model.dart:39-45` | Error Handling & UX | Low | **MODIFY** | `54dac92` |
| **F-05** | `firebase/storage.rules:1-15` | Security & Cloud Hardening | High | **ACCEPT** | `54dac92` |
| **F-06** | `firebase_remote_config_service.dart:18-20` | Performance & Network | Low | **MODIFY** | `e81eae4` |

---

## 7. DANH MỤC BẰNG CHỨNG HÌNH ẢNH (25 ARTIFACTS)

Tất cả các hình ảnh được lưu trữ tại [`docs/evidence/`](docs/evidence/):

### Phần A: Giao diện ứng dụng di động (20 ảnh)
- `docs/evidence/auth/Step_01_Onboarding_KetNoiCongDong.png`
- `docs/evidence/auth/Step_02_Onboarding_CoHoiViecLam.png`
- `docs/evidence/auth/Step_03_Onboarding_AITroLy.png`
- `docs/evidence/auth/Step_04_ManHinh_DangNhap.png`
- `docs/evidence/auth/Step_05_Nhap_ThongTin_FPTMail.png`
- `docs/evidence/auth/Step_06_DangNhap_ThanhCong_HomeFeed.png`
- `docs/evidence/app_flows/Step_07_TrangCaNhan_Profile.png`
- `docs/evidence/app_flows/Step_08_ChinhSuaHoSo_GiaoDien.png`
- `docs/evidence/app_flows/Step_09_ChinhSuaHoSo_ChiTiet.png`
- `docs/evidence/app_flows/Step_10_ThayDoiAvatar_GiaoDien.png`
- `docs/evidence/app_flows/Step_11_ThayDoiAvatar_ThongBaoFirebase.png`
- `docs/evidence/app_flows/Step_12_TaoBaiViet_ChonAnh_Storage.png`
- `docs/evidence/app_flows/Step_13_TaoBaiViet_NhapNoiDung.png`
- `docs/evidence/app_flows/Step_14_ChiTietBaiViet_BinhLuan_FlowFeed.png`
- `docs/evidence/app_flows/Step_15_DanhBa_Alumni_Directory.png`
- `docs/evidence/app_flows/Step_16_ChiTiet_AlumniProfile.png`
- `docs/evidence/app_flows/Step_17_BangTin_ViecLam_Jobs.png`
- `docs/evidence/app_flows/Step_18_ChiTiet_TinTuyenDung_JobDetail.png`
- `docs/evidence/app_flows/Step_19_HopThu_ThongBao_NotificationInbox.png`
- `docs/evidence/app_flows/Step_20_TroLy_AIMentor_Chat.png`

### Phần B: Firebase Console (5 ảnh)
- `docs/evidence/firebase_console/Console_01_Authentication_Users.png`
- `docs/evidence/firebase_console/Console_02_Cloud_Storage.png`
- `docs/evidence/firebase_console/Console_03_Analytics_DebugView.png`
- `docs/evidence/firebase_console/Console_04_Crashlytics_Dashboard.png`
- `docs/evidence/firebase_console/Console_05_RemoteConfig_Dashboard.png`

---

## 8. TÀI LIỆU BÀN GIAO & BÁO CÁO NỘP BÀI

Toàn bộ tài liệu yêu cầu của Lab 3 đã được biên soạn chi tiết:
1. **Báo cáo kỹ thuật chi tiết (PDF Report 8–12 trang):** [`docs/LAB3_TECHNICAL_REPORT.md`](docs/LAB3_TECHNICAL_REPORT.md).
2. **Slide thuyết trình bảo vệ (PDF Slides 14 trang):** [`docs/LAB3_SLIDES_PRESENTATION.md`](docs/LAB3_SLIDES_PRESENTATION.md).
3. **Kế hoạch kiểm thử tự động ARTEMIS:** [`docs/artemis-test-plan.md`](docs/artemis-test-plan.md).
4. **Báo cáo rà soát mã nguồn AI:** [`docs/ai-code-review.md`](docs/ai-code-review.md).
5. **Kế hoạch đo lường Analytics:** [`docs/analytics-plan.md`](docs/analytics-plan.md).
6. **Kiến trúc MVVM & Tách tầng Firebase:** [`docs/architecture.md`](docs/architecture.md).
7. **Nhật ký tiến độ Lab 3:** [`docs/PROGRESS_LAB3.md`](docs/PROGRESS_LAB3.md).

---

## 9. HƯỚNG DẪN CÀI ĐẶT & KHỞI CHẠY ỨNG DỤNG

### 9.1. Yêu cầu môi trường
- Flutter SDK: `>=3.13.2 <4.0.0`
- Dart SDK: `>=3.13.2`
- Android Studio / Android Emulator (API 34)
- .NET 9 SDK (chạy hệ thống Backend Microservices)

### 9.2. Khởi chạy Backend Microservices (.NET 9)
Từ thư mục `f-alumni-connect`, khởi chạy các service:
- User Service: `http://localhost:5001`
- Chat Service: `http://localhost:5002`
- Forum Service: `http://localhost:5003`
- AI Service: `http://localhost:5004`
- Admin Service: `http://localhost:5005`

### 9.3. Khởi chạy Ứng dụng Mobile
1. Cài đặt các gói phụ thuộc:
   ```bash
   flutter pub get
   ```
2. Chạy bộ kiểm thử tự động:
   ```bash
   flutter test
   ```
3. Chạy phân tích tĩnh mã nguồn:
   ```bash
   dart analyze
   ```
4. Khởi chạy trên Android Emulator:
   ```bash
   flutter run --dart-define-from-file=firebase.local.json
   ```

---
*Dự án được thực hiện bởi Trương Chí Trung (MSSV: SE170000) — Môn học PRM393, Học kỳ Fall 2026.*
