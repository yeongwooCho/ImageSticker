import 'package:flutter/material.dart';

class StickerModel {
  final String id;
  final String imgPath;

  StickerModel({
    required this.id,
    required this.imgPath,
  });

  // == 로 같은지 비교할 때 사용되는 로직
  @override
  bool operator ==(Object other) {
    // ID 값이 같은 인스턴스끼리는 같은 스티커로 인식
    return (other as StickerModel).id == id;
  }

  // Set 에서 중복 여부를 결정하는 속성
  // ID 값이 같으면 Set 안에서 같은 인스턴스로 인식
  @override
  int get hashCode => id.hashCode;
}
