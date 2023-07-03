import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gesture_detector/component/emoticon_sticker.dart';
import 'package:gesture_detector/component/footer.dart';
import 'package:gesture_detector/component/main_app_bar.dart';
import 'package:gesture_detector/model/sticker_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? image;
  Set<StickerModel> stickers = {};
  String? selectedId;

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
          if (image != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Footer(
                onEmoticonTap: onEmoticonTap,
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
          child: Stack(
            fit: StackFit.expand, // 크기 최대로 늘리기
            children: [
              Image.file(
                File(image!.path),
                fit: BoxFit.cover, // 이미지 최대 공간 차지하도록 하기
              ),
              // stickers의 모든 데이터를 Stack에 뿌려버림
              ...stickers.map(
                // 기본 위치는 중앙
                (sticker) => Center(
                  child: EmoticonSticker(
                    key: ObjectKey(sticker.id),
                    onTransform: () {
                      onTransform(sticker.id);
                    },
                    imgPath: sticker.imgPath,
                    isSelected: selectedId == sticker.id,
                  ),
                ),
              ),
            ],
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
          child: const Text('이미지 선택하기'),
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

  void onEmoticonTap(int index) {
    // TODO: add 하지 않고 굳이 이렇게 하는 이유는 뭘까?
    setState(() {
      stickers = {
        ...stickers,
        StickerModel(
          id: Uuid().v4(), // 스티커의 고유 ID
          imgPath: 'asset/img/emoticon_${index}.png',
        )
      };
    });
  }

  void onTransform(String id) {
    setState(() {
      selectedId = id;
    });
  }
}
