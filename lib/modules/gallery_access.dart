
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:exif/exif.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class GalleryAccess extends StatefulWidget {
  @override
  _GalleryAccessState createState() => _GalleryAccessState();
}

class _GalleryAccessState extends State<GalleryAccess> {
  File? _image;
  Map<String, IfdTag>? _exifData;

  Future<void> getImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      await readExifData(_image!);
      setState(() {});
    } else {
      logger.d('No image selected.');
    }
  }

  Future<void> readExifData(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final data = await readExifFromBytes(bytes);

    _exifData = data;

    if (data.isEmpty) {
      logger.d("No EXIF data found");
      return;
    }

    logger.d("EXIF DATA:");
    data.forEach((key, value) {
      logger.d("$key: $value");
    });
  }

  Future<void> saveImage() async {
    if (_image == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final newImage = await _image!.copy('$path/image1.png');

    final result = await ImageGallerySaver.saveFile(newImage.path);
    logger.d("File Saved: $result");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gallery Access"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null ? Text("No image selected.") : Image.file(_image!),
            if (_exifData != null)
              Expanded(
                child: ListView(
                  children: _exifData!.entries.map((entry) {
                    return ListTile(
                      title: Text("${entry.key}: ${entry.value}"),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: getImage,
            tooltip: 'Pick Image',
            child: Icon(Icons.add_a_photo),
          ),
          SizedBox(width: 20),
          FloatingActionButton(
            onPressed: saveImage,
            tooltip: "Save Image",
            child: Icon(Icons.save),
          ),
        ],
      ),
    );
  }
}
