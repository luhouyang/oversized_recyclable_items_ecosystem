import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' as sign_in;
import 'package:oversized_recyclable_items_ecosystem/entities/user_entity.dart';
import 'package:oversized_recyclable_items_ecosystem/services/storage/firestore_service.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/snack_bar_text.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/ui_color.dart';

class SmallProfilePage extends StatefulWidget {
  const SmallProfilePage({super.key});

  @override
  State<SmallProfilePage> createState() => _SmallProfilePageState();
}

class _SmallProfilePageState extends State<SmallProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // Web Flow
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // Mobile Flow (Android/iOS) using google_sign_in 7.2.0+
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
          if (googleSignIn.supportsAuthenticate()) {
            await googleSignIn.authenticate();
          } else {
            await googleSignIn.attemptLightweightAuthentication();
          }
        } catch (e) {
          if (!completer.isCompleted) completer.completeError(e);
        }

        final sign_in.GoogleSignInAccount? googleUser = await completer.future.timeout(
          const Duration(minutes: 5),
          onTimeout: () => null,
        );
        
        await subscription.cancel();

        if (googleUser == null) {
          setState(() => _isLoading = false);
          return;
        }

        final sign_in.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
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
            points: 50, // Welcome bonus
          );
          await _firestoreService.saveUser(newUser);
        }

        if (mounted) {
          SnackBarText().showBanner(msg: "Login Successful. Welcome bonus +50pts!", context: context);
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) SnackBarText().showBanner(msg: "Login Failed: $e", context: context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEditProfileDialog(UserEntity userEntity) {
    final TextEditingController nameController = TextEditingController(text: userEntity.name);
    final TextEditingController waController =
        TextEditingController(text: userEntity.contact['whatsapp'] ?? '');
    final TextEditingController tgController =
        TextEditingController(text: userEntity.contact['telegram'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Display Name"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: waController,
                decoration: const InputDecoration(
                  labelText: "WhatsApp Number",
                  hintText: "e.g. 60123456789",
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tgController,
                decoration: const InputDecoration(
                  labelText: "Telegram Username",
                  hintText: "e.g. johndoe",
                  prefixIcon: Icon(Icons.send),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Map<String, dynamic> updatedContact = Map.from(userEntity.contact);
              updatedContact['whatsapp'] = waController.text.trim();
              updatedContact['telegram'] = tgController.text.trim();

              UserEntity updatedUser = UserEntity(
                id: userEntity.id,
                name: nameController.text.trim(),
                contact: updatedContact,
                role: userEntity.role,
                points: userEntity.points,
              );

              await _firestoreService.saveUser(updatedUser);
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return Scaffold(
        backgroundColor: UIColor().whiteSmoke,
        body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
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
                Icon(Icons.eco, size: 64, color: UIColor().primaryColorLight),
                const SizedBox(height: 20),
                Text(
                  "Join the Ecosystem",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: UIColor().darkGray,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Sign in to track your environmental impact, level up your eco-status, and manage your items.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: UIColor().gray, fontSize: 14),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: const Icon(Icons.login),
                        label: const Text("Sign in with Google"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                          backgroundColor: UIColor().primaryColorLight,
                          foregroundColor: UIColor().white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
              ],
            ),
          ),
        ),
      );
    }

    final User user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: UIColor().whiteSmoke,
      body: FutureBuilder<UserEntity?>(
        future: _firestoreService.getUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data ??
              UserEntity(
                  id: user.uid,
                  name: user.displayName ?? "User",
                  contact: {'email': user.email},
                  role: 'user',
                  points: 0);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: UIColor().white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditProfileDialog(userData),
                              tooltip: "Edit Profile",
                            )
                          ],
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: UIColor().springGreen,
                              child: CircleAvatar(
                                radius: 46,
                                backgroundColor: UIColor().primaryColorLight,
                                backgroundImage:
                                    user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                                child: user.photoURL == null
                                    ? Text(userData.name[0],
                                        style: const TextStyle(fontSize: 32, color: Colors.white))
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: UIColor().lightCanary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: UIColor().white, width: 2),
                                ),
                                child: Text(
                                  "Lvl",
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: UIColor().darkGray),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userData.name,
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: UIColor().darkGray,
                                fontSize: 20,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          userData.levelName.toUpperCase(),
                          style: TextStyle(
                            color: UIColor().springGreen,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Gamification Progress Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: userData.levelProgress,
                                  minHeight: 10,
                                  backgroundColor: UIColor().whiteSmoke,
                                  color: UIColor().springGreen,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${userData.points} Eco-Points",
                                style: TextStyle(color: UIColor().gray, fontSize: 11),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          userData.contact['email'] ?? "",
                          style: TextStyle(color: UIColor().gray, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        // Social Links Indicators
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: [
                            if (userData.contact['whatsapp'] != null &&
                                userData.contact['whatsapp'].toString().isNotEmpty)
                              Chip(
                                label: const Text("WhatsApp",
                                    style: TextStyle(
                                        color: Color(0xFF075E54),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11)),
                                avatar: const Icon(Icons.phone_android, size: 14, color: Color(0xFF25D366)),
                                backgroundColor: const Color(0xFFE0F2F1),
                                side: const BorderSide(color: Color(0xFF25D366), width: 0.5),
                              ),
                            if (userData.contact['telegram'] != null &&
                                userData.contact['telegram'].toString().isNotEmpty)
                              Chip(
                                label: const Text("Telegram",
                                    style: TextStyle(
                                        color: Color(0xFF0088cc),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11)),
                                avatar: const Icon(Icons.send, size: 14, color: Color(0xFF0088cc)),
                                backgroundColor: const Color(0xFFE1F5FE),
                                side: const BorderSide(color: Color(0xFF0088cc), width: 0.5),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Impact Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatBox(context, Icons.inventory_2, "Listed", "${userData.points ~/ 10}"),
                            _buildStatBox(context, Icons.recycling, "Recycled", "${userData.points ~/ 50}"),
                            _buildStatBox(context, Icons.cloud, "CO2 Saved",
                                "${(userData.points * 0.5).toStringAsFixed(1)}kg"),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            if (!kIsWeb) {
                              try {
                                await sign_in.GoogleSignIn.instance.disconnect();
                              } catch (e) {
                                debugPrint("Google Sign In Disconnect Error: $e");
                              }
                            }
                            setState(() {});
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text("Sign Out"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: UIColor().scarlet,
                            foregroundColor: UIColor().white,
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatBox(BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: UIColor().transparentCeleste,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: UIColor().primaryColorLight, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(color: UIColor().gray, fontSize: 10),
        ),
      ],
    );
  }
}