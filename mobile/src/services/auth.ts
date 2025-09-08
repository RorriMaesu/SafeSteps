import auth from '@react-native-firebase/auth';
import { GoogleSignin } from '@react-native-google-signin/google-signin';
import Constants from 'expo-constants';

// Configure Google Sign-In with the Web client ID from app config (via .env)
const WEB_CLIENT_ID = (Constants?.expoConfig?.extra as any)?.googleWebClientId || (Constants as any)?.manifest?.extra?.googleWebClientId;

export function configureGoogleSignIn() {
  if (WEB_CLIENT_ID) {
    GoogleSignin.configure({ webClientId: WEB_CLIENT_ID });
  }
}

export async function signInWithGoogle(): Promise<auth.UserCredential> {
  // Ensure Google services are available and sign in
  await GoogleSignin.hasPlayServices({ showPlayServicesUpdateDialog: true });
  const { idToken } = await GoogleSignin.signIn();
  const googleCredential = auth.GoogleAuthProvider.credential(idToken);
  return auth().signInWithCredential(googleCredential);
}

export function onAuthStateChanged(handler: (user: auth.User | null) => void) {
  return auth().onAuthStateChanged(handler);
}
