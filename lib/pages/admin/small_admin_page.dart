import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:oversized_recyclable_items_ecosystem/entities/item_entity.dart';
import 'package:oversized_recyclable_items_ecosystem/services/storage/firestore_service.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/ui_color.dart';
import 'package:intl/intl.dart';

class SmallAdminPage extends StatefulWidget {
  const SmallAdminPage({super.key});

  @override
  State<SmallAdminPage> createState() => _SmallAdminPageState();
}

class _SmallAdminPageState extends State<SmallAdminPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final MapController _mapController = MapController();
  bool _isMapView = false;

  final latlong.LatLng _initialCenter = const latlong.LatLng(4.3828, 100.9797); // UTP

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColor().whiteSmoke,
      body: Column(
        children: [
          // Mobile Admin Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Admin Dashboard",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold, color: UIColor().mediumGray)),
                    Text("Trash Pickup Queue",
                        style: TextStyle(color: UIColor().scarlet, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                IconButton.filled(
                  onPressed: () => setState(() => _isMapView = !_isMapView),
                  style: IconButton.styleFrom(backgroundColor: UIColor().primaryColorLight),
                  icon: Icon(_isMapView ? Icons.list : Icons.map, color: UIColor().white),
                  tooltip: _isMapView ? "View List" : "View Map",
                )
              ],
            ),
          ),
          const Divider(height: 1),

          // Main Content
          Expanded(
            child: StreamBuilder<List<ItemEntity>>(
              stream: _firestoreService.getAllItemsForAdmin(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final now = DateTime.now();
                final pendingPickup = snapshot.data!.where((i) {
                  return i.available && (i.expiryDate != null && i.expiryDate!.isBefore(now));
                }).toList();

                if (pendingPickup.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: UIColor().springGreen),
                        const SizedBox(height: 16),
                        const Text("No pending pickups.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                if (_isMapView) {
                  // MAP VIEW for Admin
                  List<Marker> markers = pendingPickup.where((i) => i.latitude != null).map((item) {
                    return Marker(
                      point: latlong.LatLng(item.latitude!, item.longitude!),
                      width: 60,
                      height: 60,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("Pickup: ${item.name}", style: const TextStyle(fontSize: 16)),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.network(item.imageLink, height: 120),
                                  const SizedBox(height: 10),
                                  Text("Condition: ${item.condition}", style: const TextStyle(fontSize: 12)),
                                  Text("Expired: ${DateFormat('yyyy-MM-dd').format(item.expiryDate!)}",
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
                                ElevatedButton(
                                    onPressed: () {
                                      _firestoreService.updateItemAvailability(item.id, false);
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Mark Collected"))
                              ],
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Icon(Icons.delete_forever, color: UIColor().scarlet, size: 36),
                            Container(
                                color: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Text("Expired",
                                    style: TextStyle(
                                        color: UIColor().scarlet, fontSize: 9, fontWeight: FontWeight.bold)))
                          ],
                        ),
                      ),
                    );
                  }).toList();

                  return FlutterMap(
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
                      MarkerLayer(markers: markers),
                    ],
                  );
                } else {
                  // LIST VIEW for Admin
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: pendingPickup.length,
                    itemBuilder: (context, index) {
                      final item = pendingPickup[index];
                      return Card(
                        elevation: 1,
                        color: UIColor().white,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(item.imageLink, width: 60, height: 60, fit: BoxFit.cover),
                          ),
                          title: Text(item.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Expired: ${DateFormat('dd/MM/yy').format(item.expiryDate!)}",
                                  style: const TextStyle(fontSize: 11)),
                              Text(
                                  "Loc: ${item.latitude?.toStringAsFixed(3)}, ${item.longitude?.toStringAsFixed(3)}",
                                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                            tooltip: "Mark Collected",
                            onPressed: () {
                              _firestoreService.updateItemAvailability(item.id, false);
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}