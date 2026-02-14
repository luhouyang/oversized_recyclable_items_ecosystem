import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:oversized_recyclable_items_ecosystem/entities/item_entity.dart';
import 'package:oversized_recyclable_items_ecosystem/services/image/image_service.dart';
import 'package:oversized_recyclable_items_ecosystem/services/storage/firestore_service.dart';
import 'package:oversized_recyclable_items_ecosystem/services/storage/storage_service.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/confetti_overlay.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/snack_bar_text.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/ui_color.dart';

class LargeHomePage extends StatefulWidget {
  const LargeHomePage({super.key});

  @override
  State<LargeHomePage> createState() => _LargeHomePageState();
}

class _LargeHomePageState extends State<LargeHomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  bool _showConfetti = false;

  // --- Location Picker ---
  Future<LatLng?> _pickLocation(BuildContext context, LatLng? initial) async {
    LatLng selected = initial ?? const LatLng(4.3828, 100.9797); // Default UTP
    return showDialog<LatLng>(
      context: context,
      builder: (context) {
        LatLng tempSelected = selected;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Pick Pickup Location"),
            content: SizedBox(
              width: 500,
              height: 400,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: tempSelected,
                  initialZoom: 15.0,
                  onTap: (_, point) {
                    setState(() => tempSelected = point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.oversized.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: tempSelected,
                        width: 40,
                        height: 40,
                        child: Icon(Icons.location_on, color: UIColor().scarlet, size: 40),
                      )
                    ],
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: UIColor().gray))
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, tempSelected),
                child: const Text("Confirm"),
              )
            ],
          );
        });
      },
    );
  }

  // --- Advanced Date & Time Picker ---
  Future<void> _selectDate(
    BuildContext context,
    DateTime initialDate,
    Function(DateTime) onDateSelected,
  ) async {
    ThemeData theme = Theme.of(context);
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(3000),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: UIColor().whiteSmoke,
              headerForegroundColor: UIColor().white,
              headerBackgroundColor: UIColor().primaryColorLight,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return UIColor().white;
                return UIColor().darkGray;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return UIColor().primaryColorLight;
                return null;
              }),
              todayForegroundColor: WidgetStatePropertyAll(UIColor().primaryColorLight),
              todayBackgroundColor: WidgetStatePropertyAll(UIColor().transparentLightCanary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate == null || !context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: UIColor().whiteSmoke,
              hourMinuteColor: UIColor().transparentLightCanary,
              hourMinuteTextColor: UIColor().darkGray,
              dayPeriodColor: UIColor().transparentCeleste,
              dayPeriodTextColor: UIColor().primaryColorLight,
              dialHandColor: UIColor().primaryColorLight,
              dialBackgroundColor: UIColor().white,
              entryModeIconColor: UIColor().primaryColorLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    final DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    onDateSelected(finalDateTime);
  }

  Widget _buildDatePickerButton({required DateTime? date, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: UIColor().springGreen),
          ),
          backgroundColor: UIColor().transparentCeleste,
          elevation: 0,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null 
                ? "Select Expiry Date" 
                : DateFormat('yyyy-MM-dd HH:mm').format(date),
              style: TextStyle(
                color: date == null ? UIColor().primaryColorLight : UIColor().darkGray, 
                fontWeight: date == null ? FontWeight.normal : FontWeight.bold
              ),
            ),
            Icon(Icons.calendar_today, size: 18, color: UIColor().primaryColorLight),
          ],
        ),
      ),
    );
  }

  // --- AI Logic ---

  void _magicWrite(TextEditingController nameCtrl, TextEditingController descCtrl, TextEditingController priceCtrl) {
    if (nameCtrl.text.isEmpty) return;
    
    final List<String> adjectives = ["Lovely", "Reliable", "Vintage-style", "Sturdy", "Well-loved", "Functional"];
    final List<String> endings = ["Looking for a new home.", "Perfect for students.", "Still has plenty of life left!", "Ready for pickup at UTP."];
    
    final random = Random();
    final adj = adjectives[random.nextInt(adjectives.length)];
    final end = endings[random.nextInt(endings.length)];
    
    descCtrl.text = "$adj ${nameCtrl.text}. $end Condition is good. Price is negotiable.";
    
    if (priceCtrl.text.isEmpty) {
        priceCtrl.text = (random.nextInt(50) + 10).toString();
    }
  }

  Future<void> _autoPriceItem(
      TextEditingController nameCtrl,
      TextEditingController descCtrl,
      TextEditingController priceCtrl,
      String condition,
      ImageData imageData) async {
    
    if (imageData.imageBytes.length <= 1) {
      SnackBarText().showBanner(msg: "Please upload an image first for AI pricing.", context: context);
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("AI Agent is analyzing item...")
            ],
          ),
        ),
      ),
    );

    try {
      const apiKey = ""; // API Key provided by environment
      
      String base64Image = base64Encode(imageData.imageBytes);
      
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent?key=$apiKey');

      final prompt = """
      You are an expert appraiser for second-hand items in a Malaysian university setting.
      Analyze the attached image and the following details:
      Title: ${nameCtrl.text}
      Description: ${descCtrl.text}
      Condition: $condition
      
      Instructions:
      1. Identify the Brand, Model, and Item Type from the image visual features.
      2. Estimate a fair second-hand selling price in MYR (Ringgit Malaysia).
      3. Provide a strictly valid JSON response with this structure: { "price": number, "brand": "string", "reasoning": "string" }
      """;

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
                {
                  "inlineData": {
                    "mimeType": "image/jpeg", 
                    "data": base64Image
                  }
                }
              ]
            }
          ],
          "generationConfig": {
            "responseMimeType": "application/json",
            "responseSchema": {
              "type": "OBJECT",
              "properties": {
                "price": {"type": "NUMBER"},
                "brand": {"type": "STRING"},
                "reasoning": {"type": "STRING"}
              }
            }
          }
        }),
      );

      // Dismiss loading dialog
      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]['content']?['parts']?[0]['text'];
        
        if (text != null) {
          final result = jsonDecode(text);
          final price = result['price'];
          final brand = result['brand'];
          final reasoning = result['reasoning'];

          setState(() {
            priceCtrl.text = price.toString();
            // Update title if empty or generic, and we found a brand
            if (brand != null && brand != "Unknown" && brand != "Generic") {
               if (!nameCtrl.text.toLowerCase().contains(brand.toString().toLowerCase())) {
                  nameCtrl.text = "$brand ${nameCtrl.text}";
               }
            }
          });
          
          if (context.mounted) {
            showDialog(
              context: context, 
              builder: (ctx) => AlertDialog(
                title: const Text("AI Pricing Suggestion"),
                content: Text("Suggested Price: RM$price\n\nReasoning: $reasoning"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Use This"))
                ],
              )
            );
          }
        }
      } else {
        debugPrint("API Error: ${response.body}");
        if (context.mounted) SnackBarText().showBanner(msg: "AI Pricing failed. Please try again.", context: context);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Dismiss loading if open
      debugPrint("Error: $e");
      if (context.mounted) SnackBarText().showBanner(msg: "Error connecting to AI Agent.", context: context);
    }
  }

  // --- Add/Edit Item Dialog ---
  void _showItemDialog(BuildContext context, {ItemEntity? existingItem}) {
    final bool isEditing = existingItem != null;
    final TextEditingController nameController = TextEditingController(text: existingItem?.name ?? '');
    final TextEditingController descController = TextEditingController(text: existingItem?.description ?? '');
    final TextEditingController priceController = TextEditingController(text: existingItem?.sellerPrice.toString() ?? '');
    
    String selectedCondition = existingItem?.condition ?? ItemCondition.good.value;
    String selectedCategory = existingItem?.category ?? ItemCategory.others.value;
    DateTime? selectedExpiryDate = existingItem?.expiryDate;
    LatLng? selectedLocation = (existingItem?.latitude != null && existingItem?.longitude != null) 
        ? LatLng(existingItem!.latitude!, existingItem.longitude!) 
        : null;

    ImageData imageData = ImageData();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isEditing ? "Edit Item" : "Add New Item"),
                  if(!isEditing)
                  IconButton(
                    icon: const Icon(Icons.auto_awesome),
                    color: Colors.purple,
                    tooltip: "Magic Fill Description",
                    onPressed: () {
                         _magicWrite(nameController, descController, priceController);
                         setState((){}); // refresh UI
                    },
                  )
                ],
              ),
              backgroundColor: UIColor().whiteSmoke,
              surfaceTintColor: UIColor().whiteSmoke,
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       if (isEditing && imageData.imageBytes.length <= 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(existingItem!.imageLink, height: 150, fit: BoxFit.cover),
                          ),
                        ),

                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: UIColor().gray.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                          color: UIColor().whiteSmoke,
                        ),
                        child: ImageService(
                          parentContext: context,
                          imageData: imageData,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "Item Name"),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(labelText: "Description"),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedCondition,
                              decoration: const InputDecoration(labelText: "Condition"),
                              items: ItemCondition.values.map((e) {
                                return DropdownMenuItem(value: e.value, child: Text(e.value));
                              }).toList(),
                              onChanged: (val) => setState(() => selectedCondition = val!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedCategory,
                              decoration: const InputDecoration(labelText: "Category"),
                              items: ItemCategory.values.map((e) {
                                return DropdownMenuItem(value: e.value, child: Text(e.value));
                              }).toList(),
                              onChanged: (val) => setState(() => selectedCategory = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "Your Price (RM)"),
                            ),
                          ),
                          if (!isEditing)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                            child: ElevatedButton.icon(
                              onPressed: () => _autoPriceItem(nameController, descController, priceController, selectedCondition, imageData),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: UIColor().primaryColorLight,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              icon: const Icon(Icons.currency_exchange, size: 16),
                              label: const Text("Auto-Price"),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Custom Pickers Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildDatePickerButton(
                              date: selectedExpiryDate,
                              onTap: () async {
                                await _selectDate(
                                  context, 
                                  selectedExpiryDate ?? DateTime.now(),
                                  (val) {
                                    setState(() => selectedExpiryDate = val);
                                  }
                                );
                              }
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final loc = await _pickLocation(context, selectedLocation);
                                  if (loc != null) setState(() => selectedLocation = loc);
                                },
                                icon: Icon(Icons.map, color: UIColor().primaryColorLight),
                                label: Text(
                                  selectedLocation == null ? "Pickup Loc" : "Location Set",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: UIColor().primaryColorLight),
                                ),
                                style: OutlinedButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  side: BorderSide(color: UIColor().springGreen),
                                  backgroundColor: UIColor().transparentCeleste,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      if (isLoading) const LinearProgressIndicator(),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: Text("Cancel", style: TextStyle(color: UIColor().gray))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColor().primaryColorLight,
                    foregroundColor: UIColor().white,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (nameController.text.isEmpty || priceController.text.isEmpty) {
                            SnackBarText().showBanner(msg: "Please fill name and price", context: context);
                            return;
                          }
                          
                          if (!isEditing && imageData.imageBytes.length <= 1) {
                             SnackBarText().showBanner(msg: "Please select an image", context: context);
                             return;
                          }

                          setState(() => isLoading = true);

                          try {
                            final user = FirebaseAuth.instance.currentUser!;
                            String imageUrl = existingItem?.imageLink ?? "";

                            // 1. Upload new Image if selected
                            if (imageData.imageBytes.length > 1) {
                               imageUrl = await _storageService.uploadImage(imageData.imageBytes, "items");
                            }

                            double userPrice = double.tryParse(priceController.text) ?? 0;
                            double aiBasePrice = userPrice * 0.8; 

                            ItemEntity item = ItemEntity(
                              id: existingItem?.id ?? "", 
                              userId: user.uid,
                              name: nameController.text,
                              description: descController.text,
                              condition: selectedCondition,
                              category: selectedCategory,
                              sellerPrice: userPrice,
                              basePrice: aiBasePrice,
                              imageLink: imageUrl,
                              available: existingItem?.available ?? true,
                              dateCreated: existingItem?.dateCreated ?? DateTime.now(),
                              expiryDate: selectedExpiryDate,
                              latitude: selectedLocation?.latitude ?? 4.3828,
                              longitude: selectedLocation?.longitude ?? 100.9797,
                            );

                            if (isEditing) {
                               await _firestoreService.updateItem(item);
                            } else {
                               await _firestoreService.addItem(item);
                               // Gamification: Add Points
                               await _firestoreService.addPoints(user.uid, 10);
                               // Trigger Confetti
                               if (context.mounted) {
                                  // Close dialog first
                                  Navigator.pop(context);
                                  _triggerConfetti();
                                  SnackBarText().showBanner(msg: "Item Added! +10 Eco-Points!", context: context);
                                  return; // Exit
                               }
                            }

                            if (context.mounted) {
                               Navigator.pop(context);
                               SnackBarText().showBanner(msg: "Item Updated", context: context);
                            }
                          } catch (e) {
                             if(context.mounted) SnackBarText().showBanner(msg: "Error: $e", context: context);
                          } finally {
                            if (mounted) setState(() => isLoading = false);
                          }
                        },
                  child: Text(isEditing ? "Save Changes" : "Upload Item"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _triggerConfetti() {
    setState(() => _showConfetti = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showConfetti = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    // Wrap entire body in ConfettiOverlay
    return ConfettiOverlay(
      isPlaying: _showConfetti,
      child: Scaffold(
        backgroundColor: UIColor().whiteSmoke,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Inventory",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: UIColor().mediumGray,
                        ),
                  ),
                  if (user != null)
                  ElevatedButton.icon(
                    onPressed: () => _showItemDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text("Add New Item"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIColor().primaryColorLight,
                      foregroundColor: UIColor().white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              Expanded(
                child: user == null 
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 64, color: UIColor().gray),
                      const SizedBox(height: 16),
                      Text(
                        "Please Login via Profile Page to manage your items",
                        style: TextStyle(color: UIColor().gray, fontSize: 16),
                      ),
                    ],
                  ),
                )
                : StreamBuilder<List<ItemEntity>>(
                  stream: _firestoreService.getUserItems(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final items = snapshot.data ?? [];
        
                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: UIColor().gray),
                            const SizedBox(height: 16),
                            Text("You haven't uploaded any items yet.", style: TextStyle(color: UIColor().gray)),
                          ],
                        ),
                      );
                    }
        
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: UIColor().white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        child: Image.network(
                                          item.imageLink,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4, right: 4,
                                      child: IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.white),
                                        style: IconButton.styleFrom(backgroundColor: Colors.black54),
                                        onPressed: () => _showItemDialog(context, existingItem: item),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text("RM ${item.sellerPrice.toStringAsFixed(2)}",
                                        style: TextStyle(color: UIColor().primaryColorLight, fontWeight: FontWeight.bold)),
                                    
                                    const SizedBox(height: 4),
                                    if (item.expiryDate != null)
                                      Text("Expires: ${DateFormat('dd/MM/yyyy HH:mm').format(item.expiryDate!)}", 
                                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
        
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          bool confirm = await showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text("Delete Item?"),
                                              content: const Text("This action cannot be undone."),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
                                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
                                              ],
                                            )
                                          ) ?? false;
        
                                          if (confirm) {
                                            await _storageService.deleteImage(item.imageLink);
                                            await _firestoreService.deleteItem(item.id);
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: UIColor().scarlet,
                                          side: BorderSide(color: UIColor().scarlet),
                                          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                        ),
                                        child: const Text("Remove"),
                                      ),
                                    )
                                  ],
                                ),
                              ),
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
      ),
    );
  }
}