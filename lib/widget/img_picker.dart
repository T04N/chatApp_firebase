import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddImageButton extends StatefulWidget {
  const AddImageButton({
    super.key,
    required this.onPickImage
  });

  final void Function(File pickedImageforAuthen) onPickImage;

  @override
  _AddImageButtonState createState() => _AddImageButtonState();
}

class _AddImageButtonState extends State<AddImageButton> {
  File? _image;
  final ImagePicker picker = ImagePicker(); // Image picker instance

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (_image != null)
          Container(
            width: 100, // Set the width of the container
            height: 100, // Set the height of the container
            child: Image.file(
              _image!,
              fit: BoxFit
                  .cover, // This will cover the container bounds without changing the aspect ratio of the image
            ),
          ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => pickImage(),
          child: Text("Add Image"),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
      ],
    );
  }

  void pickImage() async {

    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        // Optionally you can reduce the image quality and size here as well
        maxWidth: 640, // Maximum width after picking
        maxHeight: 480, // Maximum height after picking
        imageQuality: 85, // Adjust image quality from 0-100
      );

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
        widget.onPickImage(_image!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image picked: ${_image!.path}'),
          ),
        );
      }
      

    );
    } catch (e) {
    print('Failed to pick image: $e');
    }
  }
}
