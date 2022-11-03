import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../models/user_settings.dart';
import '../texts/text_pick_image.dart';


class PickImage {

  final UserSettings? userSettings;

  PickImage({ required this.userSettings });

  Future<CroppedFile?> gallery() async {
    //pick stage
    final _picker = ImagePicker();
    final PickedFile _pickedFile = (await _picker.pickImage(source: ImageSource.gallery)) as PickedFile;

    //crop stage
    CroppedFile? _croppedFile = await crop(_pickedFile, userSettings!.color, userSettings!.language);

    //all done
    return _croppedFile;
  }

  Future<CroppedFile?> camera() async {
    //pick stage
    final _picker = ImagePicker();
    final PickedFile _pickedFile = (await _picker.pickImage(source: ImageSource.camera)) as PickedFile;//TODO issue with front camera crash

    //crop stage
    CroppedFile? _croppedFile = await crop(_pickedFile, userSettings!.color, userSettings!.language);

    //all done
    return _croppedFile;
  }
}

Future<CroppedFile?> crop(PickedFile _pickedFile, Color color, String language) async {
  return await ImageCropper().cropImage(
      maxWidth: 800,
      maxHeight: 800,
      sourcePath: _pickedFile.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
        CropAspectRatioPreset.square
      ]
          : [
        CropAspectRatioPreset.square
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: TextPickImage().strings[language]!['T00'] ?? 'Crop the image',
            toolbarColor: Colors.grey[900],
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: color ?? Colors.deepOrangeAccent[400],
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        IOSUiSettings(
          title: TextPickImage().strings[language]!['T00'] ?? 'Crop the image',
        )
      ]);
}
