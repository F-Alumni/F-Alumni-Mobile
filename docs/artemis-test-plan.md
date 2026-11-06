# ARTEMIS End-to-End Test Plan

## Scope and assumptions

The Lab 3 brief requires at least ten automated end-to-end cases, three runs per
case, one Android-native interaction, and an exploratory session. It does not
name the three inherited Lab 2 flows. This plan provisionally uses:

1. Browse the feed and open a post.
2. Search alumni, open a profile, and book mentorship.
3. Search jobs, open a detail, and apply or request referral.

Confirm these flows against the Lab 2 handoff before collecting final evidence.
Each run must assert visible UI or a device-observable result, not only an
internal success flag.

## Environment and test data

- Android physical device or emulator; record model, Android version, app build,
  and Firebase project before each run.
- Firebase Android app package: `vn.edu.fpt.alumni_connect`.
- Use a dedicated test account and seeded feed, alumni, mentorship, and job data.
- Google Sign-In currently requires a Google OAuth client ID in the local build
  defines; mark auth-dependent cases blocked until that configuration is fixed.
- Firebase Console prerequisites: Google provider enabled, Storage rules
  deployed, Remote Config parameters published, and test FCM message prepared.
- ARTEMIS runner prerequisites (Python 3.12+, `uv`, device bridge, and its
  configured model provider) were not present when this plan was prepared.

## Cases

### ART-01 — Unauthenticated route protection (negative)

- **Preconditions:** Fresh install; no backend session or Firebase user.
- **Steps:** Launch app; try to open a protected detail route from a notification
  link or app route; observe the resulting screen.
- **Expected:** App remains on onboarding/login or redirects to login; protected
  content is not displayed.
- **Status:** Not run.

### ART-02 — Sign-in cancellation and recovery (negative)

- **Preconditions:** Google provider configured; test account available.
- **Steps:** Start Google sign-in; cancel the account chooser; start sign-in
  again and complete it.
- **Expected:** Cancellation shows a recoverable message without crashing; the
  second attempt reaches the signed-in app screen.
- **Status:** Blocked pending OAuth client configuration; not run.

### ART-03 — Feed browse and open a post

- **Preconditions:** Authenticated test account; at least one seeded post.
- **Steps:** Open Feed; verify a visible post card and its title; tap the card.
- **Expected:** Post detail displays the selected post content and author.
- **Status:** Not run.

### ART-04 — Feed search and empty result

- **Preconditions:** Authenticated test account; seeded known and unknown terms.
- **Steps:** Search for a known term and verify matching cards; search for a
  term with no match.
- **Expected:** Matching results appear for the known term; the empty state is
  visible for the unknown term; the app remains responsive.
- **Status:** Not run.

### ART-05 — Alumni search and profile detail

- **Preconditions:** Authenticated account; seeded alumni record with searchable
  name/company data.
- **Steps:** Open Directory; search for the seeded alumni; tap the result.
- **Expected:** The matching card appears and the opened profile shows the
  selected alumni's visible details.
- **Status:** Not run.

### ART-06 — Mentor filter and booking flow

- **Preconditions:** Authenticated account; one available mentor and at least
  one non-mentor record.
- **Steps:** Enable mentor filter; open the mentor; start booking and submit a
  valid available slot.
- **Expected:** Non-mentors are filtered out; booking confirmation or the
  expected next booking state is visible.
- **Status:** Not run.

### ART-07 — Job search and detail

- **Preconditions:** Authenticated account; seeded open job with a unique title.
- **Steps:** Open Jobs; search the title; tap its card.
- **Expected:** Search shows the matching job; detail shows the same title,
  company, and application/referral action.
- **Status:** Not run.

### ART-08 — Job application or referral

- **Preconditions:** Authenticated account; seeded job accepting applications or
  referrals.
- **Steps:** Open the job; submit the valid application/referral flow.
- **Expected:** A visible confirmation is shown and duplicate submission is
  prevented or clearly handled.
- **Status:** Not run.

### ART-09 — Avatar upload progress and download URL

- **Preconditions:** Authenticated Firebase user; deployed owner-only Storage
  rules; test image on device.
- **Steps:** Open Edit Profile; choose an image; observe progress; wait for
  completion; save profile and reopen it.
- **Expected:** Progress reaches completion; avatar renders from the returned
  URL; Storage object is under `reports/{uid}/...`.
- **Status:** Blocked pending authenticated Firebase session and Storage rules;
  not run.

### ART-10 — Android notification permission (native interaction)

- **Preconditions:** Android 13+ device; notification permission not yet decided.
- **Steps:** Open the notification screen; deny the permission; verify the
  in-app message; open system app settings, grant permission, return to app.
- **Expected:** Denial is handled without a crash; after granting permission,
  the app can receive notifications and exposes a registration token in debug.
- **Status:** Device identified, but the screen requires authenticated access;
  not run.

### ART-11 — FCM foreground and background delivery

- **Preconditions:** Signed-in test device with permission granted and FCM token;
  Firebase Console test payload with an allowlisted detail `actionUrl`.
- **Steps:** Send once while app is foregrounded; repeat while app is in the
  background; open the inbox after each send.
- **Expected:** Foreground shows an in-app notification; background shows a
  system notification; each received message appears once in the inbox; tapping
  routes to the intended detail.
- **Status:** Blocked pending authenticated session and Console send; not run.

### ART-12 — FCM terminated-state tap routing

- **Preconditions:** Same as ART-11; app force-stopped before sending.
- **Steps:** Send a notification; tap it from the system tray.
- **Expected:** App launches and routes to the allowlisted detail; an external or
  malformed `actionUrl` falls back to the notification inbox.
- **Status:** Blocked pending authenticated session and Console send; not run.

### ART-13 — Remote Config online change and offline fallback

- **Preconditions:** Published `is_promo_banner_enabled` and `max_items_display`
  parameters; app online; authenticated user can see Feed.
- **Steps:** Fetch defaults; change values in Console; force refresh in debug;
  verify UI; then disable network and relaunch or refresh.
- **Expected:** Banner visibility and visible list length follow published
  values; offline fetch retains defaults or last activated values without a
  crash.
- **Status:** Blocked pending Console parameters and authenticated session;
  not run.

### ART-14 — Handled upload error and Crashlytics non-fatal

- **Preconditions:** Authenticated test user; network available for reporting;
  prepare an upload failure without triggering the debug fatal-crash button.
- **Steps:** Attempt upload with Storage unavailable/denied; observe UI; inspect
  Crashlytics after processing delay.
- **Expected:** Friendly error is visible, app remains usable, and one non-fatal
  report appears without raw file path or user email.
- **Status:** Blocked pending authenticated session and Console access; not run.

## Run protocol and evidence

Run every unblocked case three times. Record each attempt separately and retain
screenshots/video for visible results. Do not mark a case passed from logs alone.

| Case | Run 1 | Run 2 | Run 3 | Evidence path | Notes |
| --- | --- | --- | --- | --- | --- |
| ART-01 | Not run | Not run | Not run | — | |
| ART-02 | Blocked | Blocked | Blocked | — | OAuth client ID prerequisite. |
| ART-03 | Blocked | Blocked | Blocked | — | Requires authenticated account. |
| ART-04 | Blocked | Blocked | Blocked | — | Requires authenticated account. |
| ART-05 | Blocked | Blocked | Blocked | — | Requires authenticated account. |
| ART-06 | Blocked | Blocked | Blocked | — | Requires authenticated account and mentor data. |
| ART-07 | Blocked | Blocked | Blocked | — | Requires authenticated account and job data. |
| ART-08 | Blocked | Blocked | Blocked | — | Requires authenticated account and job data. |
| ART-09 | Blocked | Blocked | Blocked | — | Requires Firebase Auth and deployed Storage rules. |
| ART-10 | Blocked | Blocked | Blocked | — | Requires opening protected notifications screen. |
| ART-11 | Blocked | Blocked | Blocked | — | Requires Firebase Console FCM send. |
| ART-12 | Blocked | Blocked | Blocked | — | Requires Firebase Console FCM send. |
| ART-13 | Blocked | Blocked | Blocked | — | Requires published Remote Config parameters. |
| ART-14 | Blocked | Blocked | Blocked | — | Requires Firebase Auth and Crashlytics Console. |

**Pass rate:** Not measured. No ARTEMIS case has been executed yet.

## Exploratory session

- **Required duration:** 15–30 minutes.
- **Status:** Not run.
- **Suggested charter:** Explore session restore/logout, search and detail
  navigation, network interruption during upload, notification permission
  denial, and repeated notification taps. Record actual device/build, start/end
  time, observed issue, severity, and screenshot for each finding.
