import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      // Create a new provider
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Trigger the auth flow
      UserCredential userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);

      if (userCredential.user != null) {
        User user = userCredential.user!;
        
        // Check if user exists, if not create new
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
        
        // Navigation is usually handled by the auth state listener in NavigatorPage/Main
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
              
              // Google Login Button
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
                   // If guest mode is allowed, navigate manually or handle state
                   // For now, this is just a placeholder action
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