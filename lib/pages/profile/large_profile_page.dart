import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oversized_recyclable_items_ecosystem/entities/user_entity.dart';
import 'package:oversized_recyclable_items_ecosystem/services/storage/firestore_service.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/snack_bar_text.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/ui_color.dart';

class LargeProfilePage extends StatefulWidget {
  const LargeProfilePage({super.key});

  @override
  State<LargeProfilePage> createState() => _LargeProfilePageState();
}

class _LargeProfilePageState extends State<LargeProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);

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
      if(mounted) SnackBarText().showBanner(msg: "Login Failed: $e", context: context);
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _showEditProfileDialog(UserEntity userEntity) {
    final TextEditingController nameController = TextEditingController(text: userEntity.name);
    final TextEditingController waController = TextEditingController(text: userEntity.contact['whatsapp'] ?? '');
    final TextEditingController tgController = TextEditingController(text: userEntity.contact['telegram'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
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
                hintText: "e.g. johndoe (without @)",
                prefixIcon: Icon(Icons.send),
              ),
            ),
          ],
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
                setState(() {}); // Rebuild to show changes
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
    // 1. Not Logged In View
    if (FirebaseAuth.instance.currentUser == null) {
      return Scaffold(
        backgroundColor: UIColor().whiteSmoke,
        body: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: UIColor().white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: UIColor().gray.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco, size: 80, color: UIColor().primaryColorLight),
                const SizedBox(height: 24),
                Text(
                  "Join the Ecosystem",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: UIColor().darkGray,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Sign in to track your environmental impact, level up your eco-status, and manage your items.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: UIColor().gray),
                ),
                const SizedBox(height: 32),
                _isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                  onPressed: _signInWithGoogle,
                  icon: const Icon(Icons.login),
                  label: const Text("Sign in with Google"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
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

    // 2. Logged In View
    final User user = FirebaseAuth.instance.currentUser!;
    
    return Scaffold(
      backgroundColor: UIColor().whiteSmoke,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: FutureBuilder<UserEntity?>(
            future: _firestoreService.getUser(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              
              final userData = snapshot.data ?? UserEntity(
                id: user.uid, 
                name: user.displayName ?? "User", 
                contact: {'email': user.email}, 
                role: 'user',
                points: 0
              );

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: UIColor().white,
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
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
                                  radius: 64,
                                  backgroundColor: UIColor().springGreen,
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: UIColor().primaryColorLight,
                                    backgroundImage: user.photoURL != null 
                                        ? NetworkImage(user.photoURL!) 
                                        : null,
                                    child: user.photoURL == null 
                                        ? Text(userData.name[0], style: const TextStyle(fontSize: 40, color: Colors.white))
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: UIColor().lightCanary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: UIColor().white, width: 2),
                                    ),
                                    child: Text(
                                      "Lvl",
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: UIColor().darkGray),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              userData.name,
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: UIColor().darkGray,
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              userData.levelName.toUpperCase(),
                              style: TextStyle(
                                color: UIColor().springGreen,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Gamification Progress Bar
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: userData.levelProgress,
                                      minHeight: 12,
                                      backgroundColor: UIColor().whiteSmoke,
                                      color: UIColor().springGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "${userData.points} Eco-Points",
                                    style: TextStyle(color: UIColor().gray, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
              
                            const SizedBox(height: 8),
                            Text(
                              userData.contact['email'] ?? "",
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: UIColor().gray),
                            ),
                             const SizedBox(height: 16),
                            // Social Links Indicators (Brand Colors)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if(userData.contact['whatsapp'] != null && userData.contact['whatsapp'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Chip(
                                      label: const Text("WhatsApp", style: TextStyle(color: Color(0xFF075E54), fontWeight: FontWeight.bold)),
                                      avatar: const Icon(Icons.phone_android, size: 16, color: Color(0xFF25D366)),
                                      backgroundColor: const Color(0xFFE0F2F1), // Light green
                                      side: const BorderSide(color: Color(0xFF25D366), width: 0.5),
                                    ),
                                  ),
                                if(userData.contact['telegram'] != null && userData.contact['telegram'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Chip(
                                      label: const Text("Telegram", style: TextStyle(color: Color(0xFF0088cc), fontWeight: FontWeight.bold)),
                                      avatar: const Icon(Icons.send, size: 16, color: Color(0xFF0088cc)),
                                      backgroundColor: const Color(0xFFE1F5FE), // Light blue
                                      side: const BorderSide(color: Color(0xFF0088cc), width: 0.5),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            
                            // Impact Stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatBox(context, Icons.inventory_2, "Listed", "${userData.points ~/ 10}"),
                                _buildStatBox(context, Icons.recycling, "Recycled", "${userData.points ~/ 50}"),
                                _buildStatBox(context, Icons.cloud, "CO2 Saved", "${(userData.points * 0.5).toStringAsFixed(1)}kg"),
                              ],
                            ),
              
                            const SizedBox(height: 40),
                            const Divider(),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () async {
                                 await FirebaseAuth.instance.signOut();
                                 setState(() {});
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text("Sign Out"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: UIColor().scarlet,
                                foregroundColor: UIColor().white,
                                minimumSize: const Size(200, 50),
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
        ),
      ),
    );
  }

  Widget _buildStatBox(BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: UIColor().transparentCeleste,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: UIColor().primaryColorLight, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          label,
          style: TextStyle(color: UIColor().gray, fontSize: 12),
        ),
      ],
    );
  }
}