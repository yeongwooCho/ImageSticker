import 'package:flutter/material.dart';
import 'package:gesture_detector/component/main_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          Center(
            child: Text('asfd'),
          ),
        ],
      ),
    );
  }

  void onPickImage() {}

  void onSaveImage() {}

  void onDeleteItem() {}
}
