# PRM393 Lab 3 — AI Code Review Report

**Repository:** `F-Alumni-Mobile`  
**PR:** `#1 - feat(lab3): Complete Firebase 6 Services Integration & MVVM Stabilization`  
**Tool:** CodeRabbit AI & Gemini Assistant  
**Date:** 06/11/2026  
**Status:** Completed & Remediated  

---

## 1. TỔNG QUAN RÀ SOÁT (REVIEW OVERVIEW)

Đợt rà soát mã nguồn tự động bằng AI tập trung vào các thay đổi trong nhánh Lab 3, bao gồm tích hợp 6 dịch vụ Firebase (Auth, Cloud Storage, FCM, Analytics, Crashlytics, Remote Config), tuân thủ phân lớp MVVM, kiểm soát ngoại lệ và độ ổn định giao diện.

---

## 2. DANH SÁCH PHÁT HIỆN CHI TIẾT (FINDINGS)

### Finding 1: Giới hạn định dạng file upload không đồng bộ với Security Rules và Đặc tả Lab 3
* **Vị trí:** [`lib/features/lab3/data/services/firebase_storage_service.dart`](file:///E:/FPT/Ki%208/Assignemt/F-Alumni-Mobile/lib/features/lab3/data/services/firebase_storage_service.dart#L58-L68) (dòng 58–68)
* **Nhóm chủ đề:** `Security & Data Validation / Contract Compliance`
* **Mức độ nghiêm trọng:** `High`
* **Mô tả chi tiết:** Trong hàm `_upload`, mệnh đề `switch (extension)` chỉ cho phép các phần mở rộng hình ảnh (`jpg`, `jpeg`, `png`, `webp`). Tuy nhiên, phương thức `uploadReport` và quy tắc bảo mật `firebase/storage.rules` định nghĩa cho phép lưu trữ tài liệu báo cáo người dùng (`application/pdf` và `text/csv`). Khi người dùng hoặc hệ thống gọi xuất báo cáo PDF/CSV, service sẽ ném ngoại lệ `ArgumentError` đột ngột thay vì hoàn tất tác vụ.
* **Đề xuất khắc phục:** Mở rộng pattern matching trong `switch` để hỗ trợ thêm `'pdf' => 'application/pdf'` và `'csv' => 'text/csv'`.

---

### Finding 2: Tràn điểm ảnh (RenderFlex Overflow) trên OnboardingPageView khi chạy máy màn hình nhỏ hoặc Test Widget
* **Vị trí:** [`lib/features/auth/presentation/screens/onboarding_screen.dart`](file:///E:/FPT/Ki%208/Assignemt/F-Alumni-Mobile/lib/features/auth/presentation/screens/onboarding_screen.dart#L191-L255) (dòng 191–255)
* **Nhóm chủ đề:** `Performance & UI Layout Robustness`
* **Mức độ nghiêm trọng:** `Medium`
* **Mô tả chi tiết:** `_OnboardingPageView` bố trí icon hình tròn kích thước lớn (200x200), các khoảng đệm cố định `SizedBox(height: 48)` và nội dung văn bản bên trong một `Column` không cuộn được. Trong môi trường kiểm thử tự động (viewport kích thước nhỏ hoặc chế độ xoay ngang), cây widget bị ném lỗi `RenderFlex overflowed by 10.0 pixels on the bottom`, khiến smoke test tự động bị fail.
* **Đề xuất khắc phục:** Bọc nội dung trong `SingleChildScrollView` với `BouncingScrollPhysics`, đồng thời tối ưu kích thước icon minh họa xuống 170x170 và khoảng cách hợp lý.

---

### Finding 3: Thiếu sự kiện bắt buộc `export_file` trong Analytics Service và Analytics Plan
* **Vị trí:** [`lib/features/lab3/data/services/firebase_analytics_service.dart`](file:///E:/FPT/Ki%208/Assignemt/F-Alumni-Mobile/lib/features/lab3/data/services/firebase_analytics_service.dart#L37-L41) (dòng 37–41)
* **Nhóm chủ đề:** `Architecture & Contract Compliance`
* **Mức độ nghiêm trọng:** `Medium`
* **Mô tả chi tiết:** Mục 4.4 của `docs/LAB3_REQUIREMENTS.md` quy định tối thiểu 7 sự kiện, trong đó nêu rõ sự kiện xuất tệp (`export_file`). Ban đầu `FirebaseAnalyticsService` chỉ có 7 sự kiện người dùng thông thường và chưa có phương thức `logExportFile`, cũng như tài liệu `docs/analytics-plan.md` chưa ghi nhận tham số của sự kiện này.
* **Đề xuất khắc phục:** Bổ sung phương thức `logExportFile({required String fileType, String? fileName})`, lọc bỏ mọi thông tin PII và đồng bộ hóa vào tài liệu `docs/analytics-plan.md`.

---

### Finding 4: Trải nghiệm thông báo khi người dùng chưa có phiên Firebase Auth lúc chọn ảnh Avatar
* **Vị trí:** [`lib/features/lab3/presentation/viewmodels/avatar_upload_view_model.dart`](file:///E:/FPT/Ki%208/Assignemt/F-Alumni-Mobile/lib/features/lab3/presentation/viewmodels/avatar_upload_view_model.dart#L39-L45) (dòng 39–45)
* **Nhóm chủ đề:** `Error Handling & User Experience`
* **Mức độ nghiêm trọng:** `Low`
* **Mô tả chi tiết:** Khi người dùng đăng nhập bằng FPT Mail qua Backend API thông thường mà chưa kích hoạt phiên Google Sign-In của Firebase, `auth.currentUser` trả về `null`. View Model hiển thị câu thông báo "Đăng nhập Firebase trước khi tải ảnh lên." nhưng không giải thích hành động tiếp theo cho người dùng và không ghi nhận ngữ cảnh non-fatal vào Crashlytics để đo lường tỷ lệ người dùng gặp rào cản này.
* **Đề xuất khắc phục:** Giữ vững ranh giới bảo mật không cho upload ẩn danh trái phép, đồng thời ghi nhận chẩn đoán và hướng dẫn người dùng kết nối tài khoản Google.

---

### Finding 5: Thiếu giới hạn dung lượng và kiểm tra Content-Type trong Cloud Storage Security Rules
* **Vị trí:** [`firebase/storage.rules`](file:///E:/FPT/Ki%208/Assignemt/F-Alumni-Mobile/firebase/storage.rules#L1-L15) (dòng 1–15)
* **Nhóm chủ đề:** `Security & Cloud Hardening`
* **Mức độ nghiêm trọng:** `High`
* **Mô tả chi tiết:** Quy tắc Storage ban đầu chỉ so khớp `request.auth.uid == userId` mà không kiểm tra kích thước file (`request.resource.size`) hoặc kiểu mime (`request.resource.contentType`). Điều này tiềm ẩn nguy cơ người dùng tải lên tệp tin độc hại vượt dung lượng cho phép gây tốn chi phí lưu trữ đám mây.
* **Đề xuất khắc phục:** Bổ sung ràng buộc kích thước tệp tối đa `< 10 * 1024 * 1024` (10MB) và chỉ cho phép `contentType.matches('image/.*')` hoặc tài liệu PDF/CSV.

---

### Finding 6: Khoảng thời gian fetch Remote Config bị hardcode có thể gây nghẽn khi debug
* **Vị trí:** [`lib/features/lab3/data/services/firebase_remote_config_service.dart`](file:///E:/FPT/Ki%208/Assignemt/F-Alumni-Mobile/lib/features/lab3/data/services/firebase_remote_config_service.dart#L18-L20) (dòng 18–20)
* **Nhóm chủ đề:** `Performance & Reliability`
* **Mức độ nghiêm trọng:** `Low`
* **Mô tả chi tiết:** `minimumFetchInterval` được thiết lập mặc định là `const Duration(hours: 1)`. Trong quá trình kiểm thử, demo trực tiếp hoặc chạy tự động, việc không tự động chuyển về `Duration.zero` khi ở chế độ `kDebugMode` có thể dẫn đến việc ứng dụng đọc giá trị bộ nhớ đệm cũ, không phản ánh kịp thời thay đổi trên Console.
* **Đề xuất khắc phục:** Tự động áp dụng `minimumFetchInterval: (forceRefresh || kDebugMode) ? Duration.zero : const Duration(hours: 1)`.

---

## 3. BẢNG QUYẾT ĐỊNH KỸ THUẬT (DECISION MATRIX)

| ID | Nhóm chủ đề | Trạng thái | Lý do kỹ thuật |
| :--- | :--- | :---: | :--- |
| **F-01** | Security & Data Validation | **ACCEPT** | Cần thiết để đảm bảo tính nhất quán giữa client SDK, quy tắc Security Rules và chức năng xuất báo cáo PDF/CSV của Lab 3. |
| **F-02** | Performance & UI Layout | **ACCEPT** | Trực tiếp sửa lỗi RenderFlex overflow, giúp toàn bộ test suite (`flutter test`) vượt qua 100% trên mọi tỷ lệ màn hình. |
| **F-03** | Architecture & Contract | **ACCEPT** | Đảm bảo tuân thủ nghiêm ngặt bảng đặc tả 7+ sự kiện của Lab 3, có sẵn cơ chế xuất tệp mà không vi phạm quy tắc PII. |
| **F-04** | Error Handling & UX | **MODIFY** | Giữ nguyên việc chặn upload khi chưa đăng nhập Firebase (bảo mật dữ liệu), chỉ cải thiện thông điệp và bổ sung log chẩn đoán an toàn. |
| **F-05** | Security & Cloud Hardening | **ACCEPT** | Phòng chống tấn công từ chối dịch vụ (DoS) qua lưu trữ đám mây bằng cách giới hạn tệp 10MB và lọc content-type nghiêm ngặt. |
| **F-06** | Performance & Reliability | **MODIFY** | Đảm bảo môi trường phát triển (Debug) phản hồi ngay lập tức với Console mà không ảnh hưởng đến tối ưu bộ nhớ đệm trên Production. |

---

## 4. KẾT QUẢ KHẮC PHỤC & TRUY VẾT GIT COMMIT (REMEDIATION & TRACEABILITY)

Tất cả các phát hiện được **ACCEPT** và **MODIFY** đã được triển khai sửa đổi hoàn tất trong mã nguồn dự án kèm commit hash cụ thể:

1. **Commit `54dac92`:** `fix(storage): allow PDF and CSV uploads in FirebaseStorageService matching security rules (F-01, F-05)`  
   - Files: `lib/features/lab3/data/services/firebase_storage_service.dart`, `firebase/storage.rules`  
   - Giải quyết: **F-01, F-05**
2. **Commit `14d3bf3`:** `fix(ui): wrap OnboardingPageView in SingleChildScrollView to eliminate RenderFlex overflow (F-02)`  
   - Files: `lib/features/auth/presentation/screens/onboarding_screen.dart`  
   - Giải quyết: **F-02**
3. **Commit `f9fada8`:** `feat(analytics): implement logExportFile and update analytics-plan.md (F-03)`  
   - Files: `lib/features/lab3/data/services/firebase_analytics_service.dart`, `docs/analytics-plan.md`  
   - Giải quyết: **F-03**
4. **Commit `e81eae4`:** `perf(remote-config): dynamic minimumFetchInterval supporting kDebugMode real-time update (F-06)`  
   - Files: `lib/features/lab3/data/services/firebase_remote_config_service.dart`  
   - Giải quyết: **F-06**
5. **Commit `4f0a8b3`:** `chore(build): update Dart SDK constraint and Kotlin build properties for Android emulator`  
   - Files: `android/gradle.properties`, `pubspec.yaml`  
   - Tối ưu hóa môi trường build kiểm thử tự động.
