import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' as sign_in;
import 'package:oversized_recyclable_items_ecosystem/entities/user_entity.dart';
import 'package:oversized_recyclable_items_ecosystem/services/storage/firestore_service.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/snack_bar_text.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/ui_color.dart';

class LargeLoginPage extends StatefulWidget {
  const LargeLoginPage({super.key});

  @override
  State<LargeLoginPage> createState() => _LargeLoginPageState();
}

class _LargeLoginPageState extends State<LargeLoginPage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => isLoading = true);
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // Web Flow
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // Mobile/Desktop Flow using google_sign_in 7.2.0+
        final sign_in.GoogleSignIn googleSignIn = sign_in.GoogleSignIn.instance;
        
        // IMPORTANT: Android requires the Web Client ID to generate an idToken for Firebase.
        // Replace this with your Web client ID from Firebase Console -> Authentication -> Sign-in method -> Google -> Web SDK configuration
        const String serverClientId = '57101567076-9qmp8u0j6qh7ste5ojh0vtaglgrd2mm9.apps.googleusercontent.com';
        
        await googleSignIn.initialize(serverClientId: serverClientId);
        
        final Completer<sign_in.GoogleSignInAccount?> completer = Completer();
        
        final StreamSubscription<sign_in.GoogleSignInAuthenticationEvent> subscription = 
            googleSignIn.authenticationEvents.listen((event) {
          if (event is sign_in.GoogleSignInAuthenticationEventSignIn) {
            if (!completer.isCompleted) completer.complete(event.user);
          } else if (event is sign_in.GoogleSignInAuthenticationEventSignOut) {
            if (!completer.isCompleted) completer.complete(null);
          }
        });

        try {
          // Trigger the authentication flow
          if (googleSignIn.supportsAuthenticate()) {
            await googleSignIn.authenticate();
          } else {
            await googleSignIn.attemptLightweightAuthentication();
          }
        } catch (e) {
          if (!completer.isCompleted) completer.completeError(e);
        }

        // Wait for the user account from the stream
        final sign_in.GoogleSignInAccount? googleUser = await completer.future.timeout(
          const Duration(minutes: 5), // generous timeout in case user idles on the dialog
          onTimeout: () => null,
        );
        
        await subscription.cancel();

        if (googleUser == null) {
          setState(() => isLoading = false);
          return;
        }

        final sign_in.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        // Construct credential using idToken (omitting accessToken as per new API)
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      if (userCredential.user != null) {
        User user = userCredential.user!;
        UserEntity? existingUser = await _firestoreService.getUser(user.uid);
        
        if (existingUser == null) {
            UserEntity newUser = UserEntity(
              id: user.uid,
              name: user.displayName ?? "Unknown",
              contact: {"email": user.email},
              role: "user",
            );
            await _firestoreService.saveUser(newUser);
        }
      }
    } catch (e) {
      if(mounted) SnackBarText().showBanner(msg: "Login Failed: $e", context: context);
    } finally {
      if(mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColor().whiteSmoke,
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: UIColor().white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: UIColor().gray.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Welcome Back",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: UIColor().darkGray,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                "Oversized Recyclable Items Ecosystem",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: UIColor().gray,
                    ),
              ),
              const SizedBox(height: 48),
              
              isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
                onPressed: _signInWithGoogle,
                icon: const Icon(Icons.login),
                label: const Text("Sign in with Google"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: UIColor().primaryColorLight,
                  foregroundColor: UIColor().white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                   SnackBarText().showBanner(msg: "Guest mode not fully implemented yet", context: context);
                },
                child: Text(
                  "Or continue as guest (View Only)",
                   style: TextStyle(color: UIColor().gray, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}