/// The "Web application" OAuth client ID from Google Cloud Console — passed
/// as `serverClientId` to GoogleSignIn.initialize() so the ID token it
/// returns has this as its audience, matching what the backend's
/// GOOGLE_CLIENT_ID verifies against (see authController.googleAuth).
const String kGoogleServerClientId =
    '896270283078-rbdbt5isngcf21t778sauht0caickni9.apps.googleusercontent.com';
