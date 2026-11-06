# PRM393 - HƯỚNG DẪN THỰC HÀNH LAB 3: FLUTTER & FIREBASE INTEGRATION
> **Tài liệu đặc tả kỹ thuật dành cho AI Coding Assistant & Codex CLI**  
> Chuyển đổi toàn bộ nội dung slide hướng dẫn chuẩn bị Lab 3 (25 trang) thành tài liệu cấu trúc Markdown chuẩn để Codex CLI / AI Agents có thể đọc, hiểu ngữ cảnh và thực thi mã nguồn.

---

## 1. TỔNG QUAN DỰ ÁN (OVERVIEW)

* **Mục tiêu:** Mở rộng và chuyển giao thiết kế từ Lab 2 thành ứng dụng Flutter hoàn chỉnh có kết nối nền tảng đám mây Firebase.
* **Yêu cầu cốt lõi:**
  1. Hiện thực đầy đủ các màn hình và **3 luồng người dùng chính (User Flows)** kế thừa từ Lab 2, bao gồm đầy đủ cơ chế xử lý lỗi (Error Handling).
  2. Tích hợp chuẩn chỉ **6 dịch vụ Firebase**: Authentication, Cloud Storage, Cloud Messaging (FCM), Google Analytics, Crashlytics, Remote Config.
  3. Tuân thủ nghiêm ngặt mô hình kiến trúc **MVVM (Model - View - ViewModel)** kết hợp State Management (**Provider** hoặc **Riverpod**). Tuyệt đối **Giao diện (View) KHÔNG được gọi trực tiếp Firebase SDK**.
  4. Thu thập đầy đủ bằng chứng xác minh: Ảnh chụp màn hình Firebase Console, nhật ký kiểm thử ARTEMIS, tài liệu phân tích và lịch sử rà soát mã nguồn (AI Code Review).

---

## 2. MÔI TRƯỜNG & CHUẨN BỊ (ENVIRONMENT & PREREQUISITES)

* **Flutter & Thiết bị:**
  * Flutter SDK bản ổn định (Stable channel).
  * Máy ảo Android (Android Emulator) hoặc thiết bị thật (Android device vật lý, Android 13+ để test FCM runtime permission).
* **Cấu hình Firebase:**
  * Tạo Firebase Project trên Firebase Console.
  * Cài đặt & cấu hình `FlutterFire CLI` (`flutterfire configure`).
  * Khai báo dấu vân tay chứng chỉ SHA-1 và SHA-256 cho Android app trên Firebase Console để hỗ trợ Google Sign-In.
* **Tài liệu kế thừa từ Lab 2:**
  * Figma design, `DESIGN.md`, `flutter-handoff.md`, `User Story`.
* **Môi trường bổ trợ:**
  * Python 3.12+, công cụ `uv`, `adb` và API key mô hình đa phương thức cho khung kiểm thử tự động ARTEMIS.
* **Quy tắc an toàn bảo mật:**
  * Sử dụng tài khoản kiểm thử riêng biệt (Test accounts).
  * **Tuyệt đối không commit API keys bí mật, service account credentials lên GitHub**. Cấu hình `.gitignore` thích hợp cho các file nhạy cảm.

---

## 3. NGUYÊN TẮC KIẾN TRÚC: MVVM INTEGRATION BOUNDARY

Hệ thống phải phân lớp tách biệt theo luồng dữ liệu 1 chiều (Unidirectional data flow):

```text
[ View (UI Widget) ] 
       │ ▲
       ▼ │ (Trạng thái UI: Loading / Content / Empty / Error)
[ ViewModel / Notifier / StateNotifier ]
       │ ▲
       ▼ │ (Data transfer / domain logic)
[ Service Layer (Nghiệp vụ trừu tượng) ]
       │ ▲
       ▼ │ (Firebase APIs)
[ Firebase SDK ]
```

### Các quy tắc bắt buộc:
1. **Lớp Dịch vụ (Service Layer):** Đóng gói toàn bộ logic gọi Firebase SDK (AuthService, StorageService, NotificationService, AnalyticsService, RemoteConfigService, CrashlyticsService).
2. **Quản lý trạng thái (UI States):** Mỗi màn hình/tính năng phải biểu diễn tường minh 4 trạng thái:
   * `Loading`: Đang tải dữ liệu.
   * `Success / Content`: Đã tải xong và có dữ liệu hiển thị.
   * `Empty`: Dữ liệu rỗng.
   * `Error`: Có lỗi phát sinh kèm thông báo trực quan cho người dùng.
3. **Khả năng kiểm thử (Testability):** Thiết kế Service có khả năng mock/giả lập để viết Unit Test và Integration Test.
4. **Tài liệu hóa:** Ghi nhận đầy đủ sơ đồ phụ thuộc vào tệp `docs/architecture.md`.

---

## 4. CHI TIẾT TÍCH HỢP 6 DỊCH VỤ FIREBASE

### 4.1. Firebase Authentication (Google Sign-In)
* **Mục tiêu:** Quản lý danh tính người dùng qua Google Sign-In và duy trì phiên đăng nhập.
* **Yêu cầu triển khai:**
  * Bật Sign-in method **Google** trong Firebase Authentication Console.
  * Cấu hình SHA-1 / SHA-256 cho Android build.
  * Lắng nghe stream `authStateChanges()` để tự động điều hướng giữa màn hình `LoginScreen` và `HomeScreen` (Route Guard / Protected Routes).
  * Khi người dùng Đăng xuất (Sign out): Dọn dẹp toàn bộ phiên làm việc và trạng thái cục bộ gắn với người dùng.
* **Kịch bản xử lý lỗi & Kiểm chứng:**
  * Xử lý trường hợp người dùng hủy đăng nhập giữa chừng (User cancelled) -> hiển thị thông báo phù hợp, không crash.
  * Xử lý lỗi mất mạng (Network error) trong quá trình xác thực.
  * Chặn triệt để truy cập trái phép vào các màn hình được bảo vệ khi chưa đăng nhập.
  * *Bằng chứng:* Ảnh chụp màn hình Firebase Console -> Authentication -> Users (thấy UID người dùng) + Ảnh UI trước và sau khi đăng nhập.

---

### 4.2. Firebase Cloud Storage
* **Mục tiêu:** Lưu trữ tệp tin trên đám mây gắn với định danh người dùng.
* **Yêu cầu triển khai:**
  * Triển khai ít nhất 1 chức năng tạo và tải tệp lên Firebase Storage (ví dụ: xuất báo cáo PDF, ảnh đại diện, hóa đơn...).
  * Cấu trúc đường dẫn tệp nghiêm ngặt: `reports/{uid}/{filename}` (gắn chặt với `uid` của người dùng).
  * Theo dõi và hiển thị thanh tiến độ tải lên (Upload Progress percentage).
  * Lấy Download URL công khai/an toàn sau khi upload thành công và hiển thị kết quả.
* **Quy tắc bảo mật (Security Rules):**
  * Viết quy tắc `storage.rules`: Chỉ cho phép chủ sở hữu UID được đọc/ghi tệp của chính họ.
  * **CẤM TUYỆT ĐỐI** quy tắc mở: `allow read, write: if true;`.
* **Kịch bản xử lý lỗi & Kiểm chứng:**
  * Thử nghiệm trường hợp người dùng truy cập trái phép hoặc mất kết nối giữa chừng.
  * *Bằng chứng:* Tệp `firebase/storage.rules` trong GitHub repository + Ảnh chụp Storage Console hiển thị cây thư mục file đã upload kèm tiến độ UI.

---

### 4.3. Firebase Cloud Messaging (FCM)
* **Mục tiêu:** Dịch vụ gửi thông báo đẩy đến ứng dụng để thông báo sự kiện và điều hướng người dùng.
* **Yêu cầu triển khai:**
  * Yêu cầu quyền nhận thông báo (Notification Runtime Permission) trên Android 13+ (`POST_NOTIFICATIONS`).
  * Xử lý trọn vẹn thông báo trên cả **3 trạng thái**:
    1. `Foreground` (Ứng dụng đang mở trên màn hình).
    2. `Background` (Ứng dụng đang chạy nền).
    3. `Terminated` (Ứng dụng đã bị tắt hẳn).
  * Xây dựng **Trung tâm thông báo (Notification Center / Inbox)** bên trong app để lưu lại lịch sử các thông báo nhận được.
  * Xử lý tương tác: Khi người dùng chạm (tap) vào thông báo, ứng dụng tự động mở và điều hướng chính xác đến màn hình chi tiết liên quan (Deep linking / navigation routing).
* **Kịch bản xử lý lỗi & Kiểm chứng:**
  * Xử lý tình huống người dùng từ chối cấp quyền nhận thông báo.
  * Ghi nhận FCM Token của thiết bị phục vụ kiểm thử.
  * Gửi tin nhắn test từ Firebase Console -> Cloud Messaging.
  * *Bằng chứng:* Ảnh chụp push notification nhận được ở 3 trạng thái + Logs FCM Token và thiết bị kiểm thử.

---

### 4.4. Google Analytics for Firebase
* **Mục tiêu:** Ghi nhận sự kiện tương tác để đo lường hành vi người dùng trong luồng nghiệp vụ.
* **Yêu cầu triển khai:**
  * Soạn thảo tài liệu kế hoạch đo lường: `docs/analytics-plan.md` trước khi code.
  * Định nghĩa tối thiểu **7 sự kiện (Events)** bao gồm: Đăng nhập (`login`), Đăng xuất (`logout`), các thao tác chính trong 3 luồng Lab 2, xem chi tiết (`view_item`), xuất tệp (`export_file`), v.v.
  * Ưu tiên dùng sự kiện chuẩn được Firebase khuyến nghị; các sự kiện tùy biến phải đặt theo chuẩn `snake_case`.
  * Sau khi đăng nhập, gắn định danh người dùng: `setUserId(user.uid)`.
  * **Quy định bảo mật thông tin (Privacy):** Tuyệt đối **KHÔNG** đưa thông tin định danh cá nhân (PII - email, tên thật, số điện thoại) vào tham số sự kiện (event parameters).
* **Kiểm chứng:**
  * Bật chế độ `DebugView` (`adb shell setprop debug.firebase.analytics.app <package_name>`).
  * Mỗi sự kiện phải nêu rõ: thời điểm kích hoạt, danh sách tham số và câu hỏi sản phẩm (Product question) mà sự kiện đó giải quyết.
  * *Bằng chứng:* Chụp ảnh màn hình Analytics DebugView hiển thị trực tiếp từng sự kiện tương ứng với từng bước trong luồng Lab 2.

---

### 4.5. Firebase Crashlytics
* **Mục tiêu:** Theo dõi, báo cáo sự cố sập ứng dụng (crashes) và lỗi ngoại lệ phi fatal (non-fatal errors).
* **Yêu cầu triển khai:**
  * Khởi tạo Crashlytics và bắt lỗi toàn cục bằng `FlutterError.onError` và `PlatformDispatcher.instance.onError`.
  * Ghi nhận ít nhất **1 lỗi đã được xử lý (Non-fatal error)** từ luồng lỗi thực tế trong ứng dụng (sử dụng `FirebaseCrashlytics.instance.recordError(...)`).
  * Thiết lập định danh người dùng (`setUserIdentifier`) và ít nhất 1 khóa chẩn đoán tùy chỉnh (`setCustomKey`).
  * Xây dựng một nút bấm/thao tác ẩn tạo Crash có chủ đích (**Test Crash Button**) đặt riêng trong khu vực kiểm thử/demo (Debug Area).
* **Quy tắc an toàn & Kiểm chứng:**
  * Đảm bảo luồng lỗi thực tế không làm sập app mà vẫn hiển thị thông báo lỗi thân thiện cho người dùng.
  * Tuyệt đối không để crash thử nghiệm xuất hiện trong quá trình sử dụng thông thường của người dùng cuối.
  * *Bằng chứng:* Ảnh chụp bảng điều khiển Firebase Crashlytics hiển thị cả lỗi non-fatal và crash test cùng các custom keys và user ID.

---

### 4.6. Firebase Remote Config
* **Mục tiêu:** Cung cấp tham số cấu hình từ xa để thay đổi hành vi hoặc giao diện ứng dụng theo thời gian thực mà không cần phát hành bản cập nhật mới.
* **Yêu cầu triển khai:**
  * Định nghĩa tối thiểu **2 tham số cấu hình (Parameters)** trong ứng dụng kèm giá trị mặc định (`setDefaults`).
  * Tách riêng một lớp dịch vụ `RemoteConfigService` để fetch và activate giá trị.
  * Hai tham số phải liên kết trực tiếp với hành vi quan sát được trên giao diện, ví dụ:
    1. Tham số boolean: Bật/tắt một tính năng mới (Feature Flag: `is_promo_banner_enabled`).
    2. Tham số number: Giới hạn số mục hiển thị trên danh sách (Page Size: `max_items_display`).
* **Kịch bản xử lý lỗi & Kiểm chứng:**
  * Kiểm tra tính sẵn sàng khi ngoại tuyến (Offline): Khi mất mạng hoặc fetch thất bại, ứng dụng vẫn hoạt động ổn định với giá trị mặc định ban đầu.
  * Trình diễn thay đổi giá trị trên Firebase Console, sau đó fetch lại và chứng minh giao diện ứng dụng thay đổi trực quan mà không cần re-build code.
  * *Bằng chứng:* Ảnh chụp màn hình Console và UI ứng dụng Before & After; giải thích cơ chế bộ nhớ đệm (cache duration) khi demo.

---

## 5. ĐẢM BẢO CHẤT LƯỢNG: KIỂM THỬ TỰ ĐỘNG ARTEMIS

* **Yêu cầu kịch bản kiểm thử:**
  * Viết ít nhất **10 ca kiểm thử (Test Cases)** tự động đầu cuối (End-to-End).
  * Cấu trúc mỗi ca kiểm thử: Điều kiện tiên quyết (Pre-conditions), Các bước thực hiện (Test steps), Kết quả mong đợi (Expected results).
  * Độ bao phủ (Coverage):
    * Bao phủ toàn bộ 3 luồng người dùng từ Lab 2.
    * Tối thiểu 1 nhánh kiểm thử lỗi (Negative flow / Error branch).
    * Tối thiểu 1 tương tác với hệ thống Android gốc (ví dụ: cấp quyền hệ thống, bật/tắt kết nối...).
* **Thực thi và báo cáo:**
  * Chạy lặp lại mỗi ca kiểm thử tối thiểu **3 lần** liên tiếp.
  * Đo lường và báo cáo tỷ lệ thành công (Pass rate) kèm tệp nhật ký thực thi chi tiết (Execution logs).
  * Tiêu chí đánh giá: Phải kiểm tra giá trị thực tế quan sát được trên màn hình, không chỉ dựa vào tín hiệu trạng thái `SUCCESS` giả định.
  * Thực hiện 1 phiên kiểm thử khám phá (Exploratory Testing Session) độc lập kéo dài từ 15 – 30 phút.

---

## 6. RÀ SOÁT MÃ NGUỒN BẰNG TRÍ TUỆ NHÂN TẠO (AI CODE REVIEW)

* **Quy trình thực hiện:**
  * Mở một Pull Request (PR) đại diện cho các thay đổi lớn của Lab 3 trên GitHub.
  * Sử dụng công cụ AI Code Review (GitHub Copilot, CodeRabbit, hoặc Cursor/Codex PR review tool).
* **Yêu cầu về phát hiện (Findings):**
  * Ghi nhận tối thiểu **5 phát hiện (Findings)** cụ thể gắn liền với từng dòng mã nguồn, trải đều trên ít nhất **2 nhóm chủ đề** (ví dụ: Security & Privacy, Performance & Memory leak, Architecture & Code smell, Error handling).
  * Lập bảng quyết định kỹ thuật: Với từng phát hiện, ghi rõ trạng thái: **Chấp nhận (Accept)**, **Điều chỉnh (Modify)**, hoặc **Bác bỏ (Reject)** kèm giải thích lý do kỹ thuật chi tiết.
  * Tiến hành chỉnh sửa và fix mã nguồn cho ít nhất **3 phát hiện được chấp nhận**, kèm mã hash commit trên Git để đối soát và truy vết.

---

## 7. CHECKLIST SẴN SÀNG VÀ DANH MỤC SẢN PHẨM NỘP

### 7.1. Bảng kiểm tra tính năng (Feature Checklist)
- [ ] Tích hợp đủ 6 dịch vụ Firebase:
  - [ ] Firebase Authentication (Google Sign-In, Session state, Protected Routes, Logout)
  - [ ] Firebase Cloud Storage (Upload progress, `reports/{uid}/...`, Download URL, UID-based security rules)
  - [ ] Firebase Cloud Messaging (Android 13+ permission, 3 trạng thái, In-app notification center, Tap-to-navigate)
  - [ ] Google Analytics for Firebase (>= 7 events, `docs/analytics-plan.md`, `setUserId`, No PII, DebugView verified)
  - [ ] Firebase Crashlytics (Non-fatal error logging, Test crash trigger, Custom Keys, `setUserIdentifier`)
  - [ ] Firebase Remote Config (>= 2 visible params, UI update without rebuild, Offline fallback defaults)
- [ ] Xử lý đầy đủ trường hợp lỗi (Error cases) cho cả 6 dịch vụ Firebase.
- [ ] Tuân thủ MVVM: View tách biệt hoàn toàn khỏi Firebase SDK qua Service Layer.
- [ ] Hoàn thành tài liệu:
  - [ ] `docs/architecture.md` (Sơ đồ kiến trúc & ranh giới tích hợp)
  - [ ] `docs/analytics-plan.md` (Kế hoạch sự kiện Analytics)
  - [ ] `firebase/storage.rules` (Luật bảo mật Cloud Storage)
- [ ] Kiểm thử tự động ARTEMIS: >= 10 test cases, 3 runs/case, nhật ký thực thi + phiên exploratory test 15-30m.
- [ ] AI Code Review: PR review report với >= 5 findings (>= 2 categories), fix >= 3 findings có Git commit hash.

### 7.2. Danh mục sản phẩm nộp cuối cùng (Final Deliverables)
1. **GitHub Repository:** Mã nguồn hoàn chỉnh, cấu trúc MVVM, các file rules và docs nằm đúng vị trí.
2. **Báo cáo kỹ thuật (PDF Report):** Dung lượng từ **8 – 12 trang**.
3. **Slide thuyết trình (PDF Slides):** Số lượng từ **12 – 15 trang**.
4. **Video trình diễn (Demo Video):** Thời lượng từ **5 – 10 phút** quay rõ ràng 3 luồng người dùng, 6 dịch vụ Firebase và bằng chứng thực tế trên Firebase Console.
