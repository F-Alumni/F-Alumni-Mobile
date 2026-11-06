# Mobile API integration

The Flutter client talks directly to the backend microservices. Each base URL
can be overridden with a Dart define; Android emulator defaults use
`10.0.2.2`, and the USB phone setup is documented in
`04_Dev_Guide/Firebase-Setup.md`.

| API | Default port | Mobile features |
| --- | ---: | --- |
| User | 5001 | Google/backend session exchange, email auth, profile, directory, privacy, blocks |
| Chat | 5002 | Conversations, messages, read state, conversation settings |
| Forum | 5003 | Feed, recruitment posts, comments, reactions, bookmarks, events |
| AI | 5004 | Chat history, AI chat, mentor recommendations |
| Admin | 5005 | Admin user directory and account suspension |

The backend has no standalone jobs endpoint. It represents job and referral
opportunities as Forum posts with `PostType=Recruitment`, so the Jobs tab reads
those posts and opens the original post for comments and bookmarks. There is
no separate application-submission API.

The backend does not expose an FCM device-token registration endpoint. The app
obtains and displays its FCM token for Firebase Console test messages; push
delivery initiated by the backend is not wired to a token store.

Firebase Storage upload code and UID-scoped rules are present, but the Firebase
project has no Storage bucket yet. Deploying rules is blocked until the project
owner provisions the bucket.
