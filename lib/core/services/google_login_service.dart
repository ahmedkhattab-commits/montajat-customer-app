// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class GoogleSignInApi {
//   static User? user = FirebaseAuth.instance.currentUser;
//
//   Future<OAuthCredential> googleSignIn() async {
//     final googleSignIn = await GoogleSignIn().signIn();
//     final googleAuth = await googleSignIn?.authentication;
//
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth?.accessToken,
//       idToken: googleAuth?.idToken,
//     );
//     await FirebaseAuth.instance.signInWithCredential(credential);
//     return credential;
//   }
//
//   Future<void> logout() async {
//     await GoogleSignIn().disconnect();
//     await FirebaseAuth.instance.signOut();
//   }
// }
