import 'package:agrivoltaics_flutter_app/app_constants.dart';
import 'package:agrivoltaics_flutter_app/pages/dashboard/dashboard_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential> signInWithGoogleWeb() async {
  getIt = GetIt.instance;
  GoogleAuthProvider googleAuthProvider = getIt.get<GoogleAuthProvider>();

  return await FirebaseAuth.instance.signInWithPopup(googleAuthProvider);
}

// Future<UserCredential> signInWithGoogleMobile() async {
//   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//   final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

//   final credential = GoogleAuthProvider.credential(
//     accessToken: googleAuth?.accessToken,
//     idToken: googleAuth?.idToken
//   );

//   return await FirebaseAuth.instance.signInWithCredential(credential);
// }

bool authorizeUser(UserCredential userCredential) {
  var userEmail = userCredential.user?.email;
  // TODO: remove admin email
  return userEmail == AppConstants.ownerEmail || userEmail == AppConstants.adminEmail;
}