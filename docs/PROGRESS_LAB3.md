# PRM393 Lab 3 — Tiến độ thực hiện

**Cập nhật:** 06/11/2026  
**Phạm vi:** Ứng dụng Flutter trong `Alumni-Connect---FPT-University` và các API trong `D:\Code\PRM\BE\f-alumni-connect`.

Tài liệu này ghi lại trạng thái theo mã nguồn và những lần chạy đã thực hiện. “Đã viết code” không đồng nghĩa với “đã triển khai lên Firebase” hoặc “đã kiểm chứng đủ bằng chứng nộp bài”.

## Tóm tắt

- Đã nối nhiều luồng mobile với các service BE, thêm các tích hợp Firebase và cài các bản APK debug lên điện thoại Android.
- Đã xác nhận một số luồng thật trên thiết bị: đăng nhập/hồ sơ, danh bạ, bài tuyển dụng, chi tiết bài viết và nhận FCM foreground/in-app.
- **Lab 3 chưa hoàn tất để nộp.** Firebase Storage chưa có bucket; Analytics chưa có `export_file` và bằng chứng DebugView; ARTEMIS, AI code review và các sản phẩm báo cáo/demo còn thiếu.

## Đã thực hiện

### Mobile và API

| Khu vực | Trạng thái code | Kiểm chứng đã có |
| --- | --- | --- |
| Auth | Google đăng nhập qua Firebase rồi trao đổi ID token với User API để lấy phiên BE; email auth vẫn qua BE. | Đã dùng app ở trạng thái đăng nhập trên điện thoại. Cần kiểm tra lại cấu hình Google provider đã được Save trong Firebase Console. |
| Hồ sơ và danh bạ | Đọc/cập nhật hồ sơ, privacy, block/unblock, tìm danh bạ và hồ sơ alumni qua User API. | Hồ sơ và dữ liệu danh bạ đã hiển thị từ BE trên thiết bị. |
| Bảng tin | Đọc/tạo/sửa/xóa bài, bình luận, reactions, bookmarks, báo cáo và đánh dấu câu trả lời qua Forum API. | Đã mở nội dung lấy từ BE; chưa kiểm tra hết thao tác ghi và nhánh lỗi. |
| Việc làm | Lấy bài `Recruitment` từ Forum API, chuyển thành job card và mở bài gốc. BE hiện không có Jobs/Application API riêng. | Đã thấy bài tuyển dụng mẫu và mở chi tiết trên điện thoại. |
| Chat | Có repository cho conversations/messages, read state, cài đặt conversation và SignalR hub. | Chưa có biên bản kiểm tra end-to-end đầy đủ giữa hai tài khoản. |
| AI | Có API cho lịch sử hội thoại, chat và gợi ý mentor. | Chưa xác minh toàn bộ luồng với dịch vụ AI đang chạy. |
| Sự kiện | Có API đọc chi tiết/danh sách, attendees, tạo, RSVP và xóa sự kiện. | Chưa kiểm tra end-to-end đầy đủ. |
| Admin | Có API danh sách user, suspend/unsuspend và đổi role. | Dashboard KPI, moderation queue và export CSV chưa được nối đầy đủ vào UI. |

Các base URL cho User/Chat/Forum/AI/Admin lần lượt dùng cổng `5001`–`5005`. APK debug trên điện thoại dùng `firebase.local.json` và cần `adb reverse` cùng các BE service chạy trên máy phát triển.

### Firebase

| Dịch vụ | Đã có trong mã nguồn | Còn thiếu để xác nhận hoàn tất |
| --- | --- | --- |
| Authentication | Firebase Google Sign-In, đồng bộ phiên với BE, route guard/sign-out và xử lý lỗi cơ bản. SHA-1/SHA-256 Android đã được thêm trong Console. | Ảnh Console trước đó cho thấy support email chưa chọn và nút Save chưa bật; cần xác nhận provider được lưu. Chưa hoàn thiện bộ bằng chứng cho đăng nhập/hủy đăng nhập/mất mạng. |
| Cloud Storage | Service tải file có progress/download URL; avatar upload; form bài viết đã có chọn ảnh máy, upload vào `posts/{uid}/...` rồi gửi URL cho BE. Rules hiện có nhánh `reports` và `posts`. | Project chưa có Storage bucket mặc định. Rules chưa deploy và upload ảnh từ điện thoại chưa được xác nhận thành công. BE nhận `imageUrls`, không nhận multipart file trực tiếp. |
| Cloud Messaging | Xin quyền Android 13+, lấy token, xử lý foreground/background/terminated trong code và inbox cục bộ theo tài khoản. | Đã gửi test push; người dùng xác nhận thấy toast và inbox. Chưa lưu token lên BE vì BE không có endpoint đăng ký token; chưa đủ ảnh kiểm chứng background/terminated/deep link. |
| Analytics | Service, `docs/analytics-plan.md`, bảy event hiện có: `login`, `logout`, `search`, `select_content`, `view_item`, `avatar_upload_complete`, `notification_open`; gắn Firebase UID khi khớp tài khoản; event params tránh PII. | Thiếu event `export_file`; chưa bật/xác minh từng event trong DebugView và chưa có ảnh bằng chứng. Ba luồng trong analytics plan hiện là giả định, cần đối chiếu handoff Lab 2. |
| Crashlytics | Service, global error handlers, non-fatal reporting, user identifier/custom key và nút test crash trong debug area. | Chưa thu ảnh Console chứng minh non-fatal, test crash và custom keys. |
| Remote Config | Service có defaults `is_promo_banner_enabled` và `max_items_display`, fetch/activate, fallback offline và ViewModel/UI refresh. | Chưa chứng minh bằng ảnh Console/UI rằng đổi giá trị remote làm UI đổi mà không build lại; cần xác nhận hai parameter đã publish trong Console. |

### Tài liệu và bản cài

- Đã có `docs/LAB3_REQUIREMENTS.md`, `docs/architecture.md`, `docs/api-integration.md`, `docs/analytics-plan.md`, `docs/artemis-test-plan.md` và hướng dẫn cấu hình Firebase/ADB.
- Đã build APK debug và cài/mở trên thiết bị Android qua USB. Bản hiện tại chứa các sửa lỗi dropdown campus `HCM`, callback `setState` khi tải lại bình luận, nút đăng cố định và luồng chọn ảnh bài viết.
- `dart analyze` trên các file vừa sửa không có lỗi; còn cảnh báo mức info. Flutter debug APK build thành công. Không có nghĩa là toàn bộ test case đã chạy.

## Việc còn dang dở

### Ưu tiên 1 — Firebase và kiểm chứng trên máy

- [ ] Xác nhận Google provider đã Save và support email đã cấu hình trong Firebase Authentication.
- [ ] Chủ project tạo Firebase Storage bucket (vị trí bucket cần chọn theo yêu cầu dự án); sau đó deploy `firebase/storage.rules`.
- [ ] Thử upload avatar và ảnh bài viết trên điện thoại, xác nhận progress, URL, rules chặn user khác và lưu URL bài viết qua Forum API.
- [ ] Hoàn thiện Analytics: thêm luồng `export_file` nếu chức năng export được đưa vào mobile, cập nhật event plan, bật DebugView và chụp đủ ảnh từng event/luồng. BE có endpoint export CSV cho Admin nhưng UI mobile chưa tích hợp.
- [ ] Xác nhận ba luồng Lab 2 chính xác để chỉnh `docs/analytics-plan.md` và ARTEMIS plan.
- [ ] Xác minh FCM ở foreground/background/terminated, điều hướng tap notification; quyết định cách cấp token cho BE nếu cần push do BE gửi.
- [ ] Xác minh Crashlytics và Remote Config trên Firebase Console, lưu bằng chứng.

### Ưu tiên 2 — API/feature còn thiếu

- [ ] Mentorship booking: mobile hiện báo BE chưa có API đặt lịch; cần bổ sung API BE hoặc ghi rõ ngoài phạm vi.
- [ ] Admin KPI/moderation: nối các API hiện có nếu response/authorization đáp ứng, hoặc ghi rõ API chưa có.
- [ ] Admin CSV export: BE có `audit-logs` và `users-summary`, nhưng app chưa có UI gọi/tải file và chưa log `export_file`.
- [ ] Job application/referral: BE hiện không có API nộp đơn riêng.
- [ ] FCM token registration: BE chưa có endpoint/lưu trữ token cho notification gửi từ server.
- [ ] Kiểm tra đủ loading/content/empty/error cho từng luồng và các thao tác ghi API trên thiết bị.

### Ưu tiên 3 — Nộp Lab 3

- [ ] Chạy tối thiểu 10 ARTEMIS E2E cases, mỗi case 3 lần; lưu logs, pass rate và bằng chứng quan sát UI.
- [ ] Thực hiện exploratory test 15–30 phút và ghi kết quả.
- [ ] AI code review: tối thiểu 5 findings trên 2 nhóm, bảng Accept/Modify/Reject, sửa ít nhất 3 findings và ghi commit hash.
- [ ] Chuẩn bị PDF report 8–12 trang, slides PDF 12–15 trang và demo video 5–10 phút.

## Thứ tự đề xuất để tiếp tục

1. Hoàn tất cấu hình Authentication/Storage trong Firebase Console và kiểm tra upload thật.
2. Chốt ba luồng Lab 2; hoàn thiện Analytics events, bao gồm `export_file` nếu có thao tác export trong phạm vi mobile, rồi chụp DebugView.
3. Kiểm chứng FCM, Crashlytics và Remote Config trên thiết bị/Console.
4. Rà các API/feature thiếu, sau đó chạy ARTEMIS và hoàn thiện AI review cùng deliverables.

