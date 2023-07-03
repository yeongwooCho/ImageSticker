import 'package:flutter/material.dart';

// 이모티콘 스티커를 이미지에 붙이는 기능
class EmoticonSticker extends StatefulWidget {
  final VoidCallback onTransform;
  final String imgPath;
  final bool isSelected;

  const EmoticonSticker({
    Key? key,
    required this.onTransform,
    required this.imgPath,
    required this.isSelected,
  }) : super(key: key);

  @override
  State<EmoticonSticker> createState() => _EmoticonStickerState();
}

class _EmoticonStickerState extends State<EmoticonSticker> {
  double scale = 1.0; // 확대/축소 배율 (업데이트 도중 현재의 배율)

  double hTransform = 0.0; // 가로의 움직임

  double vTransform = 0.0; // 세로의 움직임

  double actualScale = 1.0; // 위젯의 초기 크기 기준 확대/축소 배율, 그래서 최근의 크기는 몇 배?
  // (업데이트 도중 바로 이전의 배율)

  @override
  Widget build(BuildContext context) {
    // child 위젯을 변형할 수 있는 위젯
    return Transform(
      transform: Matrix4.identity() // 단위 행렬: 여기서 단위 행렬이 나오네 ㅋㅋㅋㅋㅋ
        ..translate(hTransform, vTransform) // 상 / 하 움직임 정의
        ..scale(scale, scale), // 확대/축소 정의
      child: Container(
        decoration: widget.isSelected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: Colors.blue, width: 1.0),
              )
            : BoxDecoration(
                // TODO: 테두리는 투명이나 너비는 1로 설정해서 스티커가 선택 취소될 때 깜빡이는 현상 제거
                border: Border.all(
                width: 1.0,
                color: Colors.transparent, // TODO: 이것은 무엇 인고??
              )),
        child: GestureDetector(
          // 스티커를 눌렀을 때 실행할 함수
          onTap: () {
            widget.onTransform(); // 스티커의 상태가 변경될 때마다 실행
          },
          onScaleUpdate: (ScaleUpdateDetails details) {
            // 스티커의 확대 비율이 변경 됐을 때 실행
            widget.onTransform();
            setState(() {
              scale = details.scale * actualScale; // 최근 확대 비율 기반으로 실제 확대 비율 계산
              vTransform += details.focalPointDelta.dy; // 세로 이동 거리 계산
              hTransform += details.focalPointDelta.dx; // 가로 이동 거리 계산
            });
          },
          onScaleEnd: (ScaleEndDetails details) {
            actualScale = scale; // 확대 비율 저장
          },
          // 스티커의 확대 비율이 변경이 완료 됐을 때 실행
          child: Image.asset(
            widget.imgPath,
          ),
        ),
      ),
    );
  }
}
