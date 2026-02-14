import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:oversized_recyclable_items_ecosystem/entities/item_entity.dart';
import 'package:oversized_recyclable_items_ecosystem/services/storage/firestore_service.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/ui_color.dart';
import 'package:intl/intl.dart';

class LargeAdminPage extends StatefulWidget {
  const LargeAdminPage({super.key});

  @override
  State<LargeAdminPage> createState() => _LargeAdminPageState();
}

class _LargeAdminPageState extends State<LargeAdminPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final MapController _mapController = MapController();

  // UTP Coordinates approximately
  final latlong.LatLng _initialCenter = const latlong.LatLng(4.3828, 100.9797);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColor().whiteSmoke,
      body: Row(
        children: [
          // Sidebar / Pending List
          Container(
            width: 350,
            color: UIColor().white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Admin Dashboard", style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 20),
                Text(
                  "Trash Pickup Queue", 
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: UIColor().scarlet, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 10),
                const Text(
                  "Items listed below have expired and are pending pickup for recycling/disposal.",
                  style: TextStyle(fontSize: 12),
                ),
                const Divider(),
                // List of items needing pickup 
                Expanded(
                  child: StreamBuilder<List<ItemEntity>>(
                    stream: _firestoreService.getAllItemsForAdmin(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      
                      // FILTER: Only show items that are available AND have passed their expiry date
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

                      return ListView.builder(
                        itemCount: pendingPickup.length,
                        itemBuilder: (context, index) {
                          final item = pendingPickup[index];
                          return Card(
                            elevation: 0,
                            color: UIColor().whiteSmoke,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(item.imageLink, width: 50, height: 50, fit: BoxFit.cover),
                              ),
                              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Expired: ${DateFormat('dd/MM/yy').format(item.expiryDate!)}"),
                                  Text("Loc: ${item.latitude?.toStringAsFixed(4)}, ${item.longitude?.toStringAsFixed(4)}", style: const TextStyle(fontSize: 10)),
                                ],
                              ),
                              trailing: IconButton(
                                  icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                  tooltip: "Mark Collected",
                                  onPressed: () {
                                      // Mark collected (unavailable)
                                      _firestoreService.updateItemAvailability(item.id, false);
                                  },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          
          // Map View
          Expanded(
            child: StreamBuilder<List<ItemEntity>>(
              stream: _firestoreService.getAllItemsForAdmin(),
              builder: (context, snapshot) {
                List<Marker> markers = [];
                if (snapshot.hasData) {
                  final now = DateTime.now();
                  // Only show markers for expired items on this map
                  final pickupItems = snapshot.data!.where((i) {
                     return i.available && i.latitude != null && (i.expiryDate != null && i.expiryDate!.isBefore(now));
                  }).toList();

                  markers = pickupItems.map((item) {
                    return Marker(
                      point: latlong.LatLng(item.latitude!, item.longitude!),
                      width: 60,
                      height: 60,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("Pickup: ${item.name}"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.network(item.imageLink, height: 150),
                                  const SizedBox(height: 10),
                                  Text("Condition: ${item.condition}"),
                                  Text("Expired on: ${DateFormat('yyyy-MM-dd').format(item.expiryDate!)}"),
                                ],
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
                                ElevatedButton(
                                  onPressed: () {
                                    _firestoreService.updateItemAvailability(item.id, false);
                                    Navigator.pop(context);
                                  }, 
                                  child: const Text("Mark Collected")
                                )
                              ],
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Icon(Icons.delete_forever, color: UIColor().scarlet, size: 40),
                            Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(2),
                                child: Text("Expired", style: TextStyle(color: UIColor().scarlet, fontSize: 10, fontWeight: FontWeight.bold))
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList();
                }

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
              },
            ),
          ),
        ],
      ),
    );
  }
}