import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gesture_detector/component/emoticon_sticker.dart';
import 'package:gesture_detector/component/footer.dart';
import 'package:gesture_detector/component/main_app_bar.dart';
import 'package:gesture_detector/model/sticker_model.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

// image byte data
import 'dart:ui' as ui;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? image;
  Set<StickerModel> stickers = {};
  String? selectedId;

  // GlobalKey 를 이용해서 widget의 key에 넣어주면, 사실상 그 위젯은 완전히 소유가 된다.
  // 완전한 소유란 완전한 컨트롤을 의미하며, 그 위젯의 크기, 위치, 변화, 이동, context 등 모든 것을 알 수 있다.
  GlobalKey imgKey = GlobalKey(); // 이미지로 전환할 위젯에 입력해 줄 키값

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
      // 자식 위젯을 이미지로 추출하는 기능이 담긴 RepaintBoundary Widget
      return RepaintBoundary(
        key: imgKey, // 이미지 추출 기능을 사용 하려면 key 값을 사용 해야 함.
        child: Positioned.fill(
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

  void onSaveImage() async {
    // RenderRepaintBoundary 인스턴스는 RepaintBoundary child widget을 이미지로 변환할 수 있는 기능을 제공한다.
    // 그런데 RepaintBoundary Widget이 정확히 어디에 있는지 정보가 없으면 사용할 수 없다.
    // 그래서 이 정보를 포함해 많은 정보를 담고 있는 GlobalKey를 RepaintBoundary에 담아서 생성하는 것이다.
    // 그럼 RepaintBoundary 의 context는 모두 파악 가능하다.
    // 그럼 그 위젯 Object를 가져와서 RenderRepaintBoundary 로 type casting을 진행한다.
    RenderRepaintBoundary boundary =
        imgKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    // RenderRepaintBoundary는 RepaintBoundary위젯이 감싸고 있는 위젯을 이미지로 변환하는 toImage() 기능을 제공한다.
    // 그런데 우리가 저장하는 공간은 스마트폰 갤러리이며 External Storage이다. 즉, 이미지가 바이트 데이터로 변환되어야 한다.
    // ImageGallerySaver 는 바이트 데이터로 들어온 이미지를 갤러리에 저장하는 기능인 플러터 플러그인이다.
    // toImage() 가 반환하는 Image 타입은 material의 Image 가 아닌 dart:ui 패키지의 Image이다.
    // 그리고 ByteData로 변환을 한다.
    // 그런데 ImageGallerySaver의 경우 필수로 바이트 데이터가 8비트 정수형으로 변환된 데이터를 전달 해야한다.
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // 원본 상태 그대로 저장
    ImageGallerySaver.saveImage(
      pngBytes,
      quality: 100,
    );

    // Snackbar 보여주기
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('저장되었습니다. showSnackBar 테스트'),
      ),
    );

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text('showMaterialBanner 테스트'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  Size? _getSize(GlobalKey key) {
    // Global key를 입력한 위젯의 완전한 정보를 담고 있는 key가 들어왔다.
    // 즉, 그 키의 현재 Context로 Tree에서의 위치와 이를 렌더링 하는 Object로 만들어서 사이즈를 파악한다.
    if (key.currentContext != null) {
      final RenderBox renderBox =
          key.currentContext!.findRenderObject() as RenderBox;
      Size size = renderBox.size;
      return size;
    }
    return null;
  }

  void onDeleteItem() {
    // selected sticker 제외한 sticker 만 저장
    setState(() {
      stickers = stickers.where((sticker) => sticker.id != selectedId).toSet();
    });
  }

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
