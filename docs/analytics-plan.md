# Firebase Analytics Plan

## Scope and flow assumptions

The Lab 3 brief refers to three Lab 2 flows but does not identify them by name.
This first instrumentation pass assumes the project's main flows are:

1. Browse the feed and open a post.
2. Search alumni and open a mentor profile.
3. Search jobs and open a job detail.

Confirm these against the Lab 2 handoff before treating the plan as final.

## Event plan

| Event | Trigger | Parameters | Product question |
| --- | --- | --- | --- |
| `login` | Backend session established after Google or email login | `method`: `google` or `email` | Which login method is used successfully? |
| `logout` | User confirms logout | None | How often do active users end a session? |
| `search` | Alumni or job search results are applied | `search_type`, optional `result_count` | Are users finding results in directory and jobs? |
| `select_content` | User selects a feed post, alumni, or job item | `content_type` | Which content type attracts selection? |
| `view_item` | A post, alumni profile, or job detail opens | `item_category` | Which detail pages are viewed? |
| `avatar_upload_complete` | Avatar image upload completes in Storage | `file_type=image` | Does profile image upload complete successfully? |
| `notification_open` | User opens a notification action | `notification_type` | Which notification types lead to an in-app action? |

All event parameters are fixed enums or aggregate counts. Search text, email,
names, phone numbers, Firebase UID, backend IDs, and raw notification payloads
must not be attached to events. Firebase user identity is set separately with
`setUserId` after matching a Firebase user to the signed-in app account.

## Verification

Use Firebase Analytics DebugView on an Android test device. For each event,
exercise its trigger and verify the event name and the listed parameters. Take
screenshots for the Lab 3 report. Keep the measurement minimum fetch interval
and device debug configuration out of production behavior.
