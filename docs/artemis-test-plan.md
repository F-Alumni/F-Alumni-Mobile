# Báo Cáo Kế Hoạch & Kết Quả Kiểm Thử Tự Động ARTEMIS (E2E Test Report)

**Dự án:** FPT Alumni Connect (`F-Alumni-Mobile`)  
**Nền tảng kiểm thử:** Pixel 7 API 34 (Android 14) Emulator & Physical Device  
**Package Name:** `vn.edu.fpt.alumni_connect`  
**Firebase Project:** `alumniconnect-295ed`  
**Ngày thực hiện:** 06/11/2026  
**Tổng số ca kiểm thử:** 14 Test Cases (Đạt yêu cầu tối thiểu >= 10 cases)  
**Quy cách thực thi:** Lặp lại 3 lần / ca kiểm thử (Total 42 runs)  
**Tỷ lệ thành công (Pass Rate):** 100% (42/42 runs Passed)  

---

## 1. PHẠM VI VÀ BA LUỒNG NGƯỜI DÙNG KẾ THỪA TỪ LAB 2

1. **Luồng 1 (Feed & Discussion):** Lướt bảng tin tin tức/bài viết kỹ thuật, xem danh sách bài viết theo chủ đề, mở chi tiết bài viết và xem thảo luận (`Step_06`, `Step_12`, `Step_13`, `Step_14`).
2. **Luồng 2 (Alumni Directory & Mentorship):** Tìm kiếm cựu sinh viên theo ngành/khoá, xem hồ sơ chi tiết Alumni, kết nối và hỏi đáp với AI Mentor (`Step_15`, `Step_16`, `Step_20`).
3. **Luồng 3 (Jobs & Career Referral):** Tìm kiếm cơ hội việc làm & tuyển dụng từ mạng lưới cựu sinh viên, xem mô tả công việc (Job Detail) và thông tin liên hệ ứng tuyển (`Step_17`, `Step_18`).

Hệ thống kiểm thử kết hợp:
* **Nhánh kiểm thử lỗi (Negative Flows):** Chặn truy cập trái phép khi chưa đăng nhập (ART-01), hủy đăng nhập giữa chừng (ART-02), tìm kiếm không có kết quả (ART-04), tải tệp khi chưa có phiên Firebase (ART-09/ART-14).
* **Tương tác hệ thống Android gốc (Native System Interaction):** Cấp và từ chối quyền thông báo trên Android 13+ runtime permissions (ART-10).

---

## 2. MA TRẬN KỊCH BẢN KIỂM THỬ CHI TIẾT (TEST CASES MATRIX)

### ART-01 — Bảo vệ tuyến đường khi chưa đăng nhập (Negative Flow)
* **Điều kiện tiên quyết:** Cài đặt mới ứng dụng; không có token phiên làm việc hay phiên Firebase.
* **Các bước thực hiện:**
  1. Khởi chạy ứng dụng lần đầu.
  2. Cố gắng điều hướng trực tiếp vào route được bảo vệ (`/home` hoặc `/profile`) từ deep link.
  3. Quan sát màn hình điều hướng.
* **Kết quả mong đợi:** Ứng dụng tự động kích hoạt Route Guard, chặn truy cập và giữ người dùng ở màn hình Onboarding/Login (`Step_01` -> `Step_04`).
* **Trạng thái:** **PASSED** (3/3 runs).

---

### ART-02 — Hủy đăng nhập tài khoản và phục hồi (Negative Flow)
* **Điều kiện tiên quyết:** Màn hình đăng nhập đang mở, Google Sign-In được kích hoạt.
* **Các bước thực hiện:**
  1. Nhấn nút "Đăng nhập với FPT Google (US-01)".
  2. Khi hộp thoại chọn tài khoản Google xuất hiện, nhấn ra ngoài hoặc bấm nút Back để hủy.
  3. Nhấn lại nút đăng nhập hoặc chọn đăng nhập bằng FPT Mail.
* **Kết quả mong đợi:** Ứng dụng bắt ngoại lệ hủy thao tác mà không crash, hiển thị thông báo trạng thái thích hợp và cho phép tiếp tục đăng nhập thành công (`Step_04`, `Step_05`, `Step_06`).
* **Trạng thái:** **PASSED** (3/3 runs).

---

### ART-03 — Lướt bảng tin và mở bài viết chi tiết (User Flow 1)
* **Điều kiện tiên quyết:** Đã đăng nhập tài khoản sinh viên/alumni; có dữ liệu bài viết từ Forum Service (Port 5003).
* **Các bước thực hiện:**
  1. Mở tab "Bảng tin".
  2. Cuộn xem các bài viết kỹ thuật (ví dụ bài "Chia sẻ kinh nghiệm thiết kế kiến trúc Microservices").
  3. Chạm vào bài viết để xem chi tiết.
* **Kết quả mong đợi:** Màn hình chi tiết hiển thị toàn bộ nội dung, tác giả Nguyen Van A, danh sách bình luận và khu vực nhập tương tác (`Step_06`, `Step_14`).
* **Trạng thái:** **PASSED** (3/3 runs).

---

### ART-04 — Tìm kiếm bài viết & Xử lý trạng thái rỗng (Empty State)
* **Điều kiện tiên quyết:** Đang ở tab Bảng tin; hệ thống Backend đang chạy.
* **Các bước thực hiện:**
  1. Nhấn biểu tượng tìm kiếm trên thanh tiêu đề.
  2. Nhập từ khóa tồn tại: `"Microservices"` -> Kiểm tra danh sách kết quả.
  3. Nhập từ khóa không tồn tại: `"xyz999nonexistent"` -> Kiểm tra giao diện.
* **Kết quả mong đợi:** Từ khóa đúng hiển thị các bài viết liên quan; từ khóa không khớp hiển thị Empty State ("Không tìm thấy kết quả phù hợp") kèm hình minh họa thân thiện.
* **Trạng thái:** **PASSED** (3/3 runs).

---

### ART-05 — Tìm kiếm danh bạ cựu sinh viên và xem hồ sơ (User Flow 2)
* **Điều kiện tiên quyết:** Đã đăng nhập; User Service (Port 5001) cung cấp danh sách alumni.
* **Các bước thực hiện:**
  1. Chọn tab "Danh bạ" trên thanh điều hướng dưới.
  2. Duyệt danh sách cựu sinh viên các khóa K14, K15, K16, K17.
  3. Nhấn chọn một Alumni card.
* **Kết quả mong đợi:** Mở màn hình Alumni Profile hiển thị đầy đủ avatar, chức danh hiện tại, công ty công tác và nút liên hệ (`Step_15`, `Step_16`).
* **Trạng thái:** **PASSED** (3/3 runs).

---

### ART-06 — Bộ lọc Alumni theo cơ sở và kết nối AI Mentor (User Flow 2)
* **Điều kiện tiên quyết:** Đang ở tab Danh bạ / AI Mentor.
* **Các bước thực hiện:**
  1. Chọn bộ lọc Campus: "Hòa Lạc", "TP.HCM", "Đà Nẵng".
  2. Chuyển sang tab "AI Mentor" để nhận tư vấn OJT / Nghề nghiệp.
  3. Gửi câu hỏi cho trợ lý AI.
* **Kết quả mong đợi:** Danh bạ lọc chính xác theo cơ sở; AI Mentor phản hồi thông minh, hỗ trợ giải đáp thắc mắc cộng đồng FPT 24/7 (`Step_15`, `Step_20`).
* **Trạng thái:** **PASSED** (3/3 runs).

---

### ART-07 — Tìm kiếm và xem cơ hội việc làm (User Flow 3)
* **Điều kiện tiên quyết:** Đã đăng nhập; Forum/Job API trả về các tin tuyển dụng.
* **Các bước thực hiện:**
  1. Chọn tab "Việc làm".
  2. Xem danh sách tin tuyển dụng từ các Alumni tại FPT Software, Viettel, Momo...
  3. Nhấn vào thẻ việc làm "Senior Backend Engineer (.NET/Go)".
* **Kết quả mong đợi:** Mở màn hình chi tiết tin tuyển dụng với mô tả công việc, mức lương, địa điểm và quyền lợi (`Step_17`, `Step_18`).
* **Trạng thái:** **PASSED** (3/3 runs).

---

### ART-08 — Nộp hồ sơ ứng tuyển / Yêu cầu giới thiệu Referral (User Flow 3)
* **Điều kiện tiên quyết:** Đang ở màn hình chi tiết việc làm.
* **Các bước thực hiện:**
  1. Đọc yêu cầu công việc.
  2. Nhấn nút "Ứng tuyển ngay" hoặc "Yêu cầu Referral".
  3. Điền thông tin ghi chú và xác nhận gửi.
* **Kết quả mong đợi:** Hệ thống hiển thị hộp thoại xác nhận thành công, cập nhật trạng thái ứng tuyển và ngăn chặn gửi trùng lặp.
* **Trạng thái:** **PASSED** (3/3 runs).

---

### ART-09 — Tải ảnh đại diện lên Firebase Storage & Theo dõi tiến độ
* **Điều kiện tiên quyết:** Mở màn hình "Chỉnh sửa hồ sơ"; có ảnh trong thư viện thiết bị.
* **Các bước thực hiện:**
  1. Vào Cá nhân -> Chỉnh sửa hồ sơ & Cài đặt.
  2. Nhấn vào biểu tượng camera trên avatar để chọn ảnh từ máy (`Step_08`, `Step_09`).
  3. Quan sát thanh tiến độ upload và thông báo trạng thái.
* **Kết quả mong đợi:** Nếu chưa có phiên Firebase Auth, hiển thị cảnh báo bảo mật chính xác (`Step_11`). Khi có phiên, tiến độ đạt 100%, ảnh được lưu tại thư mục quy chuẩn `reports/{uid}/...` và trả về Download URL an toàn (`Console_02`).
* **Trạng thái:** **PASSED** (3/3 runs).

---

### ART-10 — Quản lý quyền thông báo Android 13+ (Native System Interaction)
* **Điều kiện tiên quyết:** Thiết bị Android 14 (API 34); chưa cấp quyền thông báo cho ứng dụng.
* **Các bước thực hiện:**
  1. Mở màn hình Hộp thư thông báo.
  2. Khi hệ điều hành Android hiển thị hộp thoại cấp quyền `POST_NOTIFICATIONS`:
     - Run 1 & 2: Chọn "Don't allow" -> Kiểm tra ứng dụng hiển thị giải thích và không bị crash.
     - Run 3: Vào Cài đặt hệ thống cấp quyền hoặc chọn "Allow".
* **Kết quả mong đợi:** Ứng dụng ứng xử chuẩn mực với quyền hệ thống, không crash khi bị từ chối; khi được cấp quyền, FCM Token được khởi tạo thành công (`Step_19`).
* **Trạng thái:** **PASSED** (3/3 runs).

---

### ART-11 — Nhận thông báo FCM ở Foreground và Background
* **Điều kiện tiên quyết:** Thiết bị đã cấp quyền thông báo; Firebase Console có chiến dịch gửi tin nhắn test.
* **Các bước thực hiện:**
  1. Gửi tin nhắn FCM test từ Firebase Console -> Cloud Messaging.
  2. Gửi lần 1 khi ứng dụng đang mở (Foreground).
  3. Gửi lần 2 khi ứng dụng đang chạy nền (Background).
* **Kết quả mong đợi:** Foreground hiển thị In-app Toast / Notification Card; Background nhận Push Notification từ thanh trạng thái Android; thông báo được lưu vào Hộp thư thông báo (`Step_19`).
* **Trạng thái:** **PASSED** (3/3 runs).

---

### ART-12 — Điều hướng từ thông báo khi ứng dụng đã tắt hẳn (Terminated State)
* **Điều kiện tiên quyết:** Ứng dụng đã bị đóng hoàn toàn (Force Stop / Swipe away).
* **Các bước thực hiện:**
  1. Gửi tin nhắn FCM kèm dữ liệu điều hướng (`actionUrl: "/jobs/detail"`).
  2. Chạm vào thông báo trên thanh thông báo hệ thống của Android.
* **Kết quả mong đợi:** Ứng dụng khởi động từ trạng thái tắt và tự động điều hướng thẳng đến đúng màn hình chi tiết được chỉ định.
* **Trạng thái:** **PASSED** (3/3 runs).

---

### ART-13 — Thay đổi cấu hình Remote Config thời gian thực và Fallback ngoại tuyến
* **Điều kiện tiên quyết:** Đã xuất bản 2 tham số `is_promo_banner_enabled` (boolean) và `max_items_display` (number) trên Firebase Console.
* **Các bước thực hiện:**
  1. Khởi chạy app với giá trị mặc định (`is_promo_banner_enabled = true`).
  2. Đổi giá trị trên Firebase Console thành `false` và Publish (`Console_05`).
  3. Gọi fetch/activate trong app để kiểm tra giao diện cập nhật ngay lập tức mà không cần rebuild app.
  4. Ngắt kết nối mạng (Airplane mode) và khởi động lại app.
* **Kết quả mong đợi:** Banner sự kiện ẩn/hiện theo đúng giá trị cấu hình Console; khi mất mạng, ứng dụng fallback mượt mà về bộ nhớ đệm cục bộ mà không bị lỗi trắng màn hình.
* **Trạng thái:** **PASSED** (3/3 runs).

---

### ART-14 — Ghi nhận lỗi có xử lý (Non-fatal Error) & Bẫy kiểm thử Crashlytics
* **Điều kiện tiên quyết:** Ứng dụng kết nối Firebase Crashlytics; bật ghi nhận lỗi toàn cục.
* **Các bước thực hiện:**
  1. Kích hoạt thao tác tải ảnh khi chưa có phiên để phát sinh lỗi xử lý an toàn (Non-fatal).
  2. Vào khu vực kiểm thử chẩn đoán (Debug Area) nhấn nút Test Crash có chủ đích.
  3. Mở Firebase Console -> Crashlytics kiểm tra báo cáo (`Console_04`).
* **Kết quả mong đợi:** Lỗi non-fatal không làm sập ứng dụng, hiển thị toast thông báo thân thiện; sự cố test crash gửi lên server Crashlytics đầy đủ stack trace, Custom Keys và User Identifier (`Console_04_Crashlytics_Dashboard.png` xác nhận 184 crashes, 2 users).
* **Trạng thái:** **PASSED** (3/3 runs).

---

## 3. BẢNG TỔNG HỢP KẾT QUẢ THỰC THI (EXECUTION LOGS & PASS RATE)

| Case ID | Run 1 | Run 2 | Run 3 | Tỷ lệ đạt | Minh chứng hình ảnh (Evidence) |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **ART-01** | PASS | PASS | PASS | **100%** | `Step_01`, `Step_04` (Route guard chặn) |
| **ART-02** | PASS | PASS | PASS | **100%** | `Step_04`, `Step_05`, `Step_06` (Hủy & login lại) |
| **ART-03** | PASS | PASS | PASS | **100%** | `Step_06`, `Step_14` (Lướt feed & mở bài viết) |
| **ART-04** | PASS | PASS | PASS | **100%** | `Step_06`, `Step_15` (Tìm kiếm & empty state) |
| **ART-05** | PASS | PASS | PASS | **100%** | `Step_15`, `Step_16` (Danh bạ & profile alumni) |
| **ART-06** | PASS | PASS | PASS | **100%** | `Step_15`, `Step_20` (Lọc cơ sở & chat AI Mentor) |
| **ART-07** | PASS | PASS | PASS | **100%** | `Step_17`, `Step_18` (Tìm kiếm việc làm & chi tiết) |
| **ART-08** | PASS | PASS | PASS | **100%** | `Step_18` (Ứng tuyển & Referral) |
| **ART-09** | PASS | PASS | PASS | **100%** | `Step_08`, `Step_09`, `Step_11`, `Console_02` |
| **ART-10** | PASS | PASS | PASS | **100%** | `Step_19` (Hộp thư thông báo & quyền Android 13+) |
| **ART-11** | PASS | PASS | PASS | **100%** | `Step_19` (FCM Foreground & Background) |
| **ART-12** | PASS | PASS | PASS | **100%** | `Step_19`, `Step_18` (Terminated tap-to-navigate) |
| **ART-13** | PASS | PASS | PASS | **100%** | `Step_06`, `Console_05` (Remote Config Promo Banner) |
| **ART-14** | PASS | PASS | PASS | **100%** | `Step_11`, `Console_04` (Crashlytics 184 crashes, non-fatal) |

* **Tổng kết thực thi:** 14/14 Test Cases Passed.
* **Tổng lượt chạy:** 42/42 Runs Passed (**100% Pass Rate**).

---

## 4. BIÊN BẢN PHIÊN KIỂM THỬ KHÁM PHÁ (EXPLORATORY TESTING SESSION)

* **Thời gian thực hiện:** 25 phút (từ 22:45 đến 23:10 ngày 05/11/2026).
* **Thiết bị:** Google Pixel 7 Emulator (API 34, Android 14) kết hợp Backend Microservices cục bộ.
* **Mục tiêu phiên:** Rà soát toàn bộ các góc khuất giao diện, khả năng chịu lỗi khi mất mạng đột ngột, phản ứng giao diện khi bàn phím ảo xuất hiện và khả năng phục hồi phiên làm việc.
* **Nhật ký phát hiện & Xử lý:**
  1. *Phát hiện 1 (Giao diện):* Tiêu đề `FPT Alumni Connect` trên thanh AppBar của `home_screen.dart` xuất hiện vạch sọc vàng báo lỗi `RenderFlex overflowed by 5 pixels` khi màn hình có thanh thông báo hệ thống.
     - *Hành động khắc phục:* Đã bổ sung `Flexible` và tinh chỉnh `spacing` tiêu đề, lỗi tràn điểm ảnh biến mất hoàn toàn.
  2. *Phát hiện 2 (Kiểm thử Widget):* `onboarding_screen.dart` bị lỗi tràn 10 pixel chiều dọc khi chạy trong môi trường test tiêu chuẩn.
     - *Hành động khắc phục:* Đã bọc `_OnboardingPageView` trong `SingleChildScrollView(physics: BouncingScrollPhysics())`, đưa kết quả `flutter test` đạt 100% thành công.
  3. *Phát hiện 3 (Ngoại tuyến):* Khi ngắt kết nối mạng tại màn hình chỉnh sửa hồ sơ, ứng dụng hiển thị thông báo lỗi rõ ràng và nút Retry, không bị đơ hoặc văng ứng dụng.
  4. *Phát hiện 4 (Bảo mật phiên):* Khi đăng xuất khỏi hồ sơ cá nhân (`Step_07` -> Đăng xuất), ứng dụng xóa sạch phiên làm việc bộ nhớ đệm và quay trở về màn hình đăng nhập an toàn.
