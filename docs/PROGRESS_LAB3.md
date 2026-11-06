# PRM393 Lab 3 — Tiến Độ Thực Hiện & Báo Cáo Hoàn Tất

**Ngày cập nhật:** 06/11/2026  
**Dự án:** `F-Alumni-Mobile` (Alumni Connect - FPT University)  
**Trạng thái chung:** **HOÀN THÀNH 100% (READY FOR SUBMISSION)**  

---

## 1. TỔNG HỢP TIẾN ĐỘ THỰC HIỆN

| Hạng mục | Trạng thái | Chi tiết & Minh chứng |
| :--- | :---: | :--- |
| **Kiến trúc MVVM & Phân tầng Service** | **HOÀN TẤT** | View hoàn toàn tách biệt khỏi Firebase SDK qua `FirebaseServiceProviders` và ViewModels. |
| **Tích hợp 6 Dịch vụ Firebase** | **HOÀN TẤT** | Auth (Google & Backend sync), Cloud Storage, FCM, Analytics, Crashlytics, Remote Config. |
| **Khắc phục lỗi mã nguồn (Code Gaps)** | **HOÀN TẤT** | Thêm `logExportFile`, bổ sung hỗ trợ PDF/CSV trong `FirebaseStorageService` & `storage.rules`, sửa triệt để các lỗi RenderFlex overflow. |
| **Bộ ảnh bằng chứng (Evidence Collection)** | **HOÀN TẤT** | Đầy đủ **25 ảnh chất lượng cao**: 20 ảnh Mobile UI (`Step_01` – `Step_20`) và 5 ảnh Firebase Console (`Console_01` – `Console_05`). |
| **Kiểm thử tự động ARTEMIS** | **HOÀN TẤT** | 14 test cases x 3 runs = 42 runs, đạt tỷ lệ **Pass Rate 100%**, kèm biên bản kiểm thử khám phá 25 phút trong `docs/artemis-test-plan.md`. |
| **Rà soát mã nguồn AI (AI Code Review)** | **HOÀN TẤT** | Báo cáo `docs/ai-code-review.md` gồm 6 findings trên 4 nhóm chủ đề, bảng Accept/Modify/Reject và truy vết commit. |
| **Độ ổn định mã nguồn & Test Suite** | **HOÀN TẤT** | `flutter test` vượt qua 100% không lỗi; `dart analyze` 0 errors. |

---

## 2. CHI TIẾT TÍCH HỢP 6 DỊCH VỤ FIREBASE

### 2.1. Firebase Authentication (Google Sign-In & Session Guard)
* **Thực hiện:**
  - Cấu hình SHA-1 (`84:47:1C:...`) và SHA-256 (`6D:EF:9F:...`) trên Firebase Console (`alumniconnect-295ed`).
  - Đăng nhập Google đồng bộ phiên qua `FirebaseAuthService`, tự động chuyển đổi route giữa `LoginScreen` và `HomeScreen`.
  - Hỗ trợ đăng xuất an toàn, xóa sạch session cache.
* **Minh chứng:** `Console_01_Authentication_Users.png`, `Step_04_ManHinh_DangNhap.png`, `Step_06_DangNhap_ThanhCong_HomeFeed.png`.

### 2.2. Firebase Cloud Storage
* **Thực hiện:**
  - Quy chuẩn đường dẫn tệp nghiêm ngặt: `reports/{uid}/{filename}` và `posts/{uid}/{filename}`.
  - Viết quy tắc bảo mật `firebase/storage.rules` ràng buộc `request.auth.uid == userId`, giới hạn kích thước `< 10MB` và xác thực MIME type (image, pdf, csv).
  - Triển khai `FirebaseStorageService` theo dõi tiến độ tải lên (Upload Progress Stream) và trích xuất Download URL an toàn.
* **Minh chứng:** `Console_02_Cloud_Storage.png`, `Step_08` – `Step_13`.

### 2.3. Firebase Cloud Messaging (FCM)
* **Thực hiện:**
  - Xin quyền runtime `POST_NOTIFICATIONS` trên Android 13+ và Android 14 (API 34).
  - Xử lý tin nhắn đầy đủ 3 trạng thái: Foreground (in-app notification), Background (system notification), Terminated (tap to navigate).
  - Xây dựng Trung tâm thông báo (Notification Inbox) lưu trữ lịch sử tin nhắn.
* **Minh chứng:** `Step_19_HopThu_ThongBao_NotificationInbox.png`.

### 2.4. Google Analytics for Firebase
* **Thực hiện:**
  - Xây dựng tài liệu chiến lược đo lường `docs/analytics-plan.md` với 8 sự kiện chuẩn hóa: `login`, `logout`, `search`, `select_content`, `view_item`, `avatar_upload_complete`, `export_file`, `notification_open`.
  - Gắn định danh `setUserId(user.uid)` sau khi xác thực; loại trừ 100% dữ liệu nhạy cảm cá nhân (No PII) khỏi tham số sự kiện.
  - Bật và kiểm chứng sự kiện qua `adb shell setprop debug.firebase.analytics.app vn.edu.fpt.alumni_connect`.
* **Minh chứng:** `Console_03_Analytics_DebugView.png`.

### 2.5. Firebase Crashlytics
* **Thực hiện:**
  - Bắt lỗi toàn cục qua `FlutterError.onError` và `PlatformDispatcher.instance.onError`.
  - Ghi nhận lỗi có xử lý (Non-fatal error) an toàn mà không làm sập ứng dụng.
  - Thiết lập User Identifier và Custom Diagnostic Keys.
  - Xây dựng nút Test Crash phục vụ kiểm thử và chứng minh trên Console.
* **Minh chứng:** `Console_04_Crashlytics_Dashboard.png` (Xác nhận 184 crashes, 2 users, chẩn đoán chi tiết).

### 2.6. Firebase Remote Config
* **Thực hiện:**
  - Định nghĩa 2 tham số quan sát trực quan trên UI kèm giá trị mặc định (`setDefaults`):
    1. `is_promo_banner_enabled` (boolean): Bật/tắt Banner Sự kiện & Workshop FPTU trên Home Feed.
    2. `max_items_display` (number): Giới hạn số lượng bài viết / alumni hiển thị.
  - Hỗ trợ cập nhật giao diện thời gian thực khi fetch từ Console mà không cần rebuild ứng dụng.
  - Hỗ trợ cơ chế Offline fallback mượt mà khi mất mạng.
* **Minh chứng:** `Console_05_RemoteConfig_Dashboard.png`, `Step_06_DangNhap_ThanhCong_HomeFeed.png`.

---

## 3. DANH SÁCH BẰNG CHỨNG HÌNH ẢNH (25 ẢNH ĐÃ LƯU TRỮ)

Tất cả các hình ảnh đã được chuẩn hóa tên gọi, lưu tại thư mục dự án `docs/evidence/` và sao lưu trên Desktop:
- **Phần A: Giao diện ứng dụng (20 ảnh):**
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
- **Phần B: Firebase Console (5 ảnh):**
  - `docs/evidence/firebase_console/Console_01_Authentication_Users.png`
  - `docs/evidence/firebase_console/Console_02_Cloud_Storage.png`
  - `docs/evidence/firebase_console/Console_03_Analytics_DebugView.png`
  - `docs/evidence/firebase_console/Console_04_Crashlytics_Dashboard.png`
  - `docs/evidence/firebase_console/Console_05_RemoteConfig_Dashboard.png`
