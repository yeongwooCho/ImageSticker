import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gesture_detector/component/main_app_bar.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          renderBody(),
          Positioned(
            // MainAppBar를 좌, 우, 위 끝에 정렬
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: MainAppBar(
              onPickImage: onPickImage,
              onSaveImage: onSaveImage,
              onDeleteItem: onDeleteItem,
            ),
          ),
        ],
      ),
    );
  }

  Widget renderBody() {
    if (image != null) {
      return Positioned.fill(
        child: InteractiveViewer(
          child: Image.file(
            File(image!.path),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Center(
        child: TextButton(
          style: TextButton.styleFrom(
            primary: Colors.grey,
          ),
          onPressed: onPickImage,
          child: Text('이미지 선택하기'),
        ),
      );
    }
  }

  void onPickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      this.image = image;
    });
  }

  void onSaveImage() {}

  void onDeleteItem() {}
}
