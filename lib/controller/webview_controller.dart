// webview_controller.dart

//GetX라는 전역 상태 관리 라이브러리를 통해 컨트롤러 활용
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'fcm_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'location_controller.dart';
import 'image_controller.dart';

class WebviewMainController extends GetxController {
  static String fcmToken = "";
//WebviewMainController 클래스의 인스턴스를 반환
  static WebviewMainController get to => Get.find();

  //controller 객체 선언
  final WebViewController controller = WebViewController()

  //자바스트립트 사용 여부
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //웹뷰 관련 이벤트들
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          debugPrint('progressing $progress');
        },
        onPageStarted: (String url) {
          debugPrint(url);
        },
        onPageFinished: (String url) {
          debugPrint('Page Finished');
        },
        onWebResourceError: (WebResourceError error) {},
      ),

    )
    ..addJavaScriptChannel(
      'Tripcube', // channel 이름
      onMessageReceived: (JavaScriptMessage message) {
        fcmController.sendFCMToken(message.message.toString(), fcmToken);
      },
    )

    ..addJavaScriptChannel(
      'GetImage', // channel 이름
      onMessageReceived: (JavaScriptMessage message) async{
        String file = await imageController.getImage();
        WebviewMainController.to.controller.runJavaScript('window.getImage("$file")');
      },
    )

    ..addJavaScriptChannel(
        'GetLocation',
        onMessageReceived: (JavaScriptMessage message) async{
          print("--------------------GetLocation------------");
          Position pos = await locationController.getCurrentLocation();
          String latitude = pos.latitude.toString();
          String longitude = pos.longitude.toString();
          WebviewMainController.to.controller.runJavaScript('window.getLatitude("$latitude")');
          WebviewMainController.to.controller.runJavaScript('window.getLongitude("$longitude")');
        }
    )

  //접속한 [URL]을 삽입
    ..loadRequest(Uri.parse("http://sw.uos.ac.kr/nonlogin"));

// 다른 파일에서 controller를 불러오기 위함
  WebViewController getController() {
    return controller;
  }
}