# Firebase Analytics Plan

## Scope and flow assumptions

The Lab 3 brief requires instrumentation for measuring user interaction, session lifecycles, and business workflows across the 3 core flows inherited from Lab 2:

1. **Feed & Post Interaction Flow:** Browse the feed, filter topics, and open post detail.
2. **Directory & Mentorship Flow:** Search alumni directory, view alumni profile, and connect/mentor.
3. **Jobs & Career Opportunities Flow:** Search job listings, open job detail, and view application/referral info.

## Event plan (8 Defined Events)

| Event | Trigger | Parameters | Product question |
| --- | --- | --- | --- |
| `login` | Backend session established after Google or email login | `method`: `google` or `email` | Which login method is used successfully? |
| `logout` | User confirms logout from profile settings | None | How often do active users end a session? |
| `search` | Alumni or job search query/filter is applied | `search_type` (`alumni` or `jobs`), `result_count` (integer) | Are users finding relevant results in directory and job listings? |
| `select_content` | User taps on a feed post card, alumni card, or job card | `content_type` (`post`, `alumni`, or `job`) | Which content type attracts the most user interest? |
| `view_item` | A post detail, alumni profile, or job detail screen opens | `item_category` (`post`, `alumni_profile`, or `job_detail`) | Which detail pages retain user attention? |
| `avatar_upload_complete` | Avatar or profile image upload completes successfully in Cloud Storage | `file_type`: `image` | Does profile image upload complete without errors? |
| `export_file` | User exports a report, profile summary, or data file | `file_type` (`pdf` or `csv`), optional `file_name` | How frequently do users export reports and summaries? |
| `notification_open` | User opens an in-app or system push notification | `notification_type` | Which notification categories drive active re-engagement? |

## Privacy and Data Governance

- **No PII:** All event parameters are restricted to fixed enums, categories, and aggregate counts. User full names, email addresses (`@fpt.edu.vn`), phone numbers, cleartext search keywords, and exact database record identifiers are strictly stripped before event dispatch.
- **User Identifier Binding:** Firebase user identity is mapped solely through `FirebaseAnalytics.instance.setUserId(user.uid)` once a verified Firebase session is confirmed.

## Verification & DebugView

- **Device Debug Activation:**
  ```shell
  adb shell setprop debug.firebase.analytics.app vn.edu.fpt.alumni_connect
  ```
- **Console Validation:**
  Events are verified live in the Firebase Console -> Analytics -> DebugView stream, showing timestamped events and exact payload parameters (`Console_03_Analytics_DebugView.png`).
