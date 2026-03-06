import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:oversized_recyclable_items_ecosystem/entities/item_entity.dart';
import 'package:oversized_recyclable_items_ecosystem/entities/user_entity.dart';
import 'package:oversized_recyclable_items_ecosystem/services/storage/firestore_service.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/snack_bar_text.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/ui_color.dart';
import 'package:url_launcher/url_launcher.dart';

class SmallStorePage extends StatefulWidget {
  const SmallStorePage({super.key});

  @override
  State<SmallStorePage> createState() => _SmallStorePageState();
}

class _SmallStorePageState extends State<SmallStorePage> {
  final FirestoreService _firestoreService = FirestoreService();
  String searchQuery = "";
  String? selectedCategoryFilter;
  bool _isMapView = false;

  final MapController _mapController = MapController();
  final latlong.LatLng _initialCenter = const latlong.LatLng(4.3828, 100.9797); // UTP

  void _contactSeller(BuildContext context, ItemEntity item) async {
    UserEntity? seller = await _firestoreService.getUser(item.userId);

    if (seller == null) {
      if (mounted) SnackBarText().showBanner(msg: "Seller info not found", context: context);
      return;
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: UIColor().white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Contact ${seller.name}", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (seller.contact['email'] != null)
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.grey),
                  title: const Text("Email"),
                  subtitle: Text(seller.contact['email']),
                  onTap: () => _launchUri(Uri(
                      scheme: 'mailto',
                      path: seller.contact['email'],
                      queryParameters: {'subject': 'Inquiry about ${item.name}'})),
                ),
              if (seller.contact['whatsapp'] != null && seller.contact['whatsapp'].toString().isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF25D366).withOpacity(0.3))),
                  child: ListTile(
                    leading: const Icon(Icons.phone_android, color: Color(0xFF25D366)),
                    title: const Text("WhatsApp",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF075E54))),
                    subtitle: Text(seller.contact['whatsapp']),
                    onTap: () => _launchUri(Uri.parse("https://wa.me/${seller.contact['whatsapp']}")),
                  ),
                ),
              if (seller.contact['telegram'] != null && seller.contact['telegram'].toString().isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE1F5FE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF0088cc).withOpacity(0.3))),
                  child: ListTile(
                    leading: const Icon(Icons.send, color: Color(0xFF0088cc)),
                    title: const Text("Telegram",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0088cc))),
                    subtitle: Text("@${seller.contact['telegram']}"),
                    onTap: () => _launchUri(Uri.parse("https://t.me/${seller.contact['telegram']}")),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchUri(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColor().whiteSmoke,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            // Mobile Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Marketplace",
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: UIColor().mediumGray,
                      ),
                ),
                IconButton.filled(
                  onPressed: () => setState(() => _isMapView = !_isMapView),
                  style: IconButton.styleFrom(backgroundColor: UIColor().primaryColorLight),
                  icon: Icon(_isMapView ? Icons.grid_view : Icons.map, color: UIColor().white),
                  tooltip: _isMapView ? "Switch to Grid" : "Switch to Map",
                )
              ],
            ),
            const SizedBox(height: 12),
            // Mobile Search & Filter
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: UIColor().white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: UIColor().white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCategoryFilter,
                        hint: const Text("All", overflow: TextOverflow.ellipsis),
                        items: [
                          const DropdownMenuItem(value: null, child: Text("All")),
                          ...ItemCategory.values.map((cat) {
                            return DropdownMenuItem(value: cat.value, child: Text(cat.value, overflow: TextOverflow.ellipsis));
                          }),
                        ],
                        onChanged: (val) {
                          setState(() {
                            selectedCategoryFilter = val;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: StreamBuilder<List<ItemEntity>>(
                stream: _firestoreService.getStoreItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = (snapshot.data ?? []).where((item) {
                    final matchesSearch = item.name.toLowerCase().contains(searchQuery) ||
                        item.description.toLowerCase().contains(searchQuery);
                    final matchesCategory = selectedCategoryFilter == null || item.category == selectedCategoryFilter;
                    bool isNotExpired = item.expiryDate == null || item.expiryDate!.isAfter(DateTime.now());

                    return matchesSearch && matchesCategory && isNotExpired;
                  }).toList();

                  if (items.isEmpty) {
                    return Center(child: Text("No active items found", style: TextStyle(color: UIColor().gray)));
                  }

                  // MAP VIEW
                  if (_isMapView) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _initialCenter,
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.oversized.app',
                          ),
                          MarkerLayer(
                            markers: items.where((i) => i.latitude != null).map((item) {
                              return Marker(
                                point: latlong.LatLng(item.latitude!, item.longitude!),
                                width: 70,
                                height: 70,
                                child: GestureDetector(
                                  onTap: () => _contactSeller(context, item),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: UIColor().primaryColorLight, width: 2),
                                            boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)]),
                                        child: ClipOval(
                                          child: Image.network(
                                            item.imageLink,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Icon(Icons.inventory_2, size: 24, color: UIColor().gray),
                                          ),
                                        ),
                                      ),
                                      ClipPath(
                                        clipper: _TriangleClipper(),
                                        child: Container(
                                          width: 8,
                                          height: 6,
                                          color: UIColor().primaryColorLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    );
                  }

                  // GRID VIEW (Mobile optimized)
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200, // Reduced for mobile
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: UIColor().white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      item.imageLink,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                            color: UIColor().whiteSmoke,
                                            child: const Icon(Icons.image_not_supported));
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                          color: UIColor().darkGray.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(8)),
                                      child: Text(
                                        item.condition,
                                        style: TextStyle(color: UIColor().white, fontSize: 10),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                          color: UIColor().primaryColorLight,
                                          borderRadius: BorderRadius.circular(8)),
                                      child: Text(
                                        item.category,
                                        style: TextStyle(
                                            color: UIColor().white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        Text(
                                          item.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: UIColor().gray, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "RM ${item.sellerPrice.toStringAsFixed(0)}",
                                          style: TextStyle(
                                            color: UIColor().primaryColorLight,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14,
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () => _contactSeller(context, item),
                                          icon: Icon(Icons.chat_bubble_outline,
                                              color: UIColor().primaryColorLight, size: 20),
                                          tooltip: "Contact Seller",
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}