import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/snack_bar_text.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/ui_color.dart';


class ImageData {
  String imageFilePath = '';
  Uint8List imageBytes = Uint8List(1);

  ImageData({String? filePath, Uint8List? bytes}) {
    imageFilePath = filePath ?? '';
    imageBytes = bytes ?? Uint8List(1);
  }

  void setFilePath(String filePath) {
    imageFilePath = filePath;
  }

  void setImageBytes(Uint8List bytes) {
    imageBytes = bytes;
  }

  String getFilePath(String filePath) {
    return imageFilePath;
  }

  Uint8List getImageBytes(Uint8List bytes) {
    return imageBytes;
  }
}

class ImageService extends StatefulWidget {
  final BuildContext parentContext;
  final ImageData imageData;

  const ImageService({super.key, required this.parentContext, required this.imageData});

  @override
  State<ImageService> createState() => _ImageServiceState();
}

class _ImageServiceState extends State<ImageService> {
  // image picking and cropping
  File? appFile;
  Uint8List? appImageBytes;

  dynamic _pickImageError;
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  // crop selected image
  Future _cropImage(XFile pickedFile) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        maxHeight: 1080,
        maxWidth: 1080,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 40,
        // aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      );

      appFile = File(croppedFile!.path);
      appImageBytes = await appFile!.readAsBytes();

      widget.imageData.setFilePath(croppedFile.path);
      widget.imageData.setImageBytes(appImageBytes!);

      debugPrint(appFile!.path);
      debugPrint(appFile!.lengthSync().toString());

      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // pick image from gallery
  Future getImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _cropImage(pickedFile);
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  // take picture with camera
  Future getImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        _cropImage(pickedFile);
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  // error handling image
  Widget _previewImages() {
    if (_retrieveDataError != null) {
      //return retrieveError;
      SnackBarText().showBanner(msg: _retrieveDataError.toString(), context: context);
    }
    if (_pickImageError != null) {
      // Pick imageError;
      SnackBarText().showBanner(msg: _pickImageError.toString(), context: context);
    }
    return _pickImageContainer();
  }

  // incase app crashes, previous image data can be retrieved
  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (response.files == null) {
        } else {
          appFile = response.files!.first as File?;
        }
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  // web image picker
  String selectedWebFileStr = '';
  XFile? webFile;
  Uint8List? webImageBytes;
  Uint8List? finalWebImageData;
  Future<void> _selectFile(bool imageFrom) async {
    FilePickerResult? fileResult = await FilePicker.platform.pickFiles();

    if (fileResult != null) {
      selectedWebFileStr = fileResult.files.first.name;
      webImageBytes = fileResult.files.first.bytes;
      finalWebImageData = webImageBytes;
      // SnackBarText().showBanner(msg: "Selected: $selectedWebFileStr", context: widget.parentContext);

      // image compression with flutter_image_compress
      final compressedBytes = await FlutterImageCompress.compressWithList(
        webImageBytes!,
        minHeight: 1080,
        minWidth: 1080,
        quality: 40,
        format: CompressFormat.png, // You can adjust the format as needed
      );

      finalWebImageData = compressedBytes;

      if (mounted && finalWebImageData != null) {
        widget.imageData.setFilePath(selectedWebFileStr);
        widget.imageData.setImageBytes(finalWebImageData!);

        SnackBarText().showBanner(
          msg:
              "Size of image: ${finalWebImageData!.lengthInBytes / 1024 / 1024}MB | "
              "Compression: ${(webImageBytes!.lengthInBytes / finalWebImageData!.lengthInBytes * 100).toStringAsFixed(2)}%",
          context: widget.parentContext,
        );
        // update provider state
        setState(() {});
      }
    }
  }

  // ui component for pick image button
  Widget _pickImageContainer() {
    return appImageBytes == null
        ? Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              height: MediaQuery.of(context).size.width * 0.5,
              width: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text('You have not yet picked an image.', textAlign: TextAlign.center),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: IconButton(
                              onPressed: () async {
                                getImageFromGallery();
                              },
                              tooltip: 'Pick Image from gallery or Camera',
                              icon: const Icon(Icons.photo),
                            ),
                          ),
                          const Text("Gallery"),
                        ],
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: IconButton(
                              onPressed: () async {
                                getImageFromCamera();
                              },
                              icon: const Icon(Icons.camera),
                            ),
                          ),
                          const Text("Camera"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        : Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: Theme.of(context).primaryColor),
                      ),
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                        child:
                            kIsWeb && finalWebImageData != null
                                ? Image.memory(finalWebImageData!)
                                : appImageBytes != null
                                ? Image.memory(appImageBytes!)
                                : const SizedBox.shrink(),
                      ),
                    ),
                    Positioned(
                      top: -12,
                      left: -12,
                      child: IconButton(
                        onPressed: () {
                          appFile = null;
                          appImageBytes = null;
                          finalWebImageData = null; // Reset web image data as well
                          widget.imageData.imageBytes = Uint8List(1);
                          widget.imageData.imageFilePath = '';
                          setState(() {});
                        },
                        icon: Icon(Icons.cancel, color: UIColor().scarlet, size: 25),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
  }

  @override
  Widget build(BuildContext context) {
    double width = min(450, MediaQuery.of(context).size.width);

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child:
          kIsWeb
              ? InkWell(
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onHover: (value) {},
                onTap: () {
                  _selectFile(true);
                },
                child: Align(
                  alignment: Alignment.topCenter,
                  child:
                      finalWebImageData == null
                          ? Container(
                            width: width,
                            height: width / 2,
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1.5, color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.camera_alt_outlined, size: 40),
                          )
                          : Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1.5, color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child:
                                      kIsWeb && finalWebImageData != null
                                          ? Image.memory(finalWebImageData!)
                                          : appImageBytes != null
                                          ? Image.memory(appImageBytes!)
                                          : const SizedBox.shrink(),
                                ),
                                Positioned(
                                  top: -10,
                                  left: -10,
                                  child: IconButton(
                                    onPressed: () {
                                      appFile = null;
                                      appImageBytes = null;
                                      finalWebImageData = null; // Reset web image data as well
                                      widget.imageData.imageBytes = Uint8List(1);
                                      widget.imageData.imageFilePath = '';
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.cancel, color: UIColor().scarlet, size: 25),
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
              )
              : FutureBuilder<void>(
                future: retrieveLostData(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return _pickImageContainer();
                    case ConnectionState.done:
                      return _previewImages();
                    case ConnectionState.active:
                      if (snapshot.hasError) {
                        return _pickImageContainer();
                      } else {
                        return _pickImageContainer();
                      }
                    // default:
                    //   return _pickImageContainer();
                  }
                },
              ),
    );
  }
}
