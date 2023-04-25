import 'package:flutter/material.dart';
import 'package:mod_do_an/config/images.dart';
import 'package:mod_do_an/models/onboarding.dart';
import 'package:mod_do_an/models/user/stopBang.dart';
import 'package:mod_do_an/storage/secure_storge.dart';

@immutable
class Constants {
  static const String baseUrl = "http://3.95.239.60:5003/api/";

  static const String userRoute = "users/";

  static const Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  /* Routing Names */
  static const String login = '/login';
  static const String register = '/register';
  static const String onboardingScreen = '/onboarding';
  static const String signUpScreen = 'sign_up';
  static const String forgotPassword = 'forgot_password';
  static const String dashBoardCustomer = 'dashboard_customer';
  static const String myProfileSreen = 'my_profile';
  static const String quizScreen = 'quiz';
  static const String acclerometerScreen = 'acclerometerScreen';
  static const String stopbangAll = 'stopbangAll';
  static const String analyticScreen = 'analyticScreen';
  static const String settingScreen = 'settingScreen';
  static const String highlowScreen = 'highlowScreen';
  static const String highTemScreen = 'highTemScreen';
  static const String lowTemScreen = 'lowTemScreen';
  static const String settingTemScreen = 'settingTemScreen';
  static const String changeUSer = 'changeUSer';
  static const String myBg = 'myBg';

  //
  static Future<Map<String, String>> requestHeadersToken() async {
    var token = await SecureStorage().getToken();
    print(token);

    Map<String, String> _requestHeaders = {
      'Content-type': 'application/json',
      'Authorization': token ?? ""
    };
    return _requestHeaders;
  }

  static List<OnboardingContent> contentsOnboarding = [
    OnboardingContent(
        title: 'Thiết bị theo dõi nhiệt độ',
        image: 'assets/images/imgOnboarding4.png',
        description: "Theo dõi và cảnh báo thân nhiệt bất thường"),
    OnboardingContent(
        title: 'Phù hợp với trẻ em',
        image: 'assets/images/imgOnboarding5.png',
        description: "Tạo thoải mái,dễ chịu cho trẻ"),
    /*OnboardingContent(
        title: 'Giữ liên lạc',
        image: 'assets/images/imgOnboarding3.png',
        description: "Nhắn tin cho chúng tôi và nhận thông báo của bạn"),*/
  ];

  static List<StopBangQuestionModel> listStopBang = [
    StopBangQuestionModel(
        title: "Ngáy",
        urlImg: AppImages.ngu_ngay_Img,
        content:
            "Ông/bà có ngáy to không? (ngáy to đến mức nghe được từ bên ngoài dù đã đóng kín cửa phòng hay đến mức người ngủ bên cạnh cũng phải phàn nàn vì tiếng ngáy trong đêm)?"),
    StopBangQuestionModel(
        title: "Mệt mỏi",
        urlImg: AppImages.met_moi_Img,
        content:
            "Ông/bà có thường cảm thấy mệt mỏi ,uể oải hay buồn ngủ vào ban ngày không( như là ngủ gật trong khi lái xe hay khi đang nói chuyện với người khác)?"),
    StopBangQuestionModel(
        title: "Quan sát",
        urlImg: AppImages.quan_sat_ngay_Img,
        content:
            "Đã từng có ai nhìn thấy ông/bà ngưng thở hay nghẹt thở/ thở hổn hển trong lúc ngủ chưa?"),
    StopBangQuestionModel(
        title: "Huyết áp",
        urlImg: AppImages.huyet_ap_thap_Img,
        content:
            "Ông/bà có bị tăng huyết áp hay điều trị tăng huyết áp không?"),
    StopBangQuestionModel(
        urlImg: AppImages.chieu_cao_Img,
        title: "Chiều cao",
        content: "Chiều cao của ông/bà là?"),
    StopBangQuestionModel(
        urlImg: AppImages.can_nang_Img,
        title: "Cân nặng",
        content: "Cân nặng của ông/bà là?"),
    StopBangQuestionModel(
        urlImg: AppImages.do_vong_co_Img,
        title: "Kích thước vòng cổ lớn",
        content:
            "Đo xung quanh chỗ lồi nhất của sụn giáp - Kích thước vòng cổ có lớn hơn 40 cm không?")
  ];

  //
  static String ACCLEROMETER = "ACCLEROMETER";

  static String TEMPERATURE = "TEMPERATURE ";

  static String SOUND = "SOUND ";

  // service ble
  static String ACCLEROMETER_SERVICE = "00001821-0000-1000-8000-00805f9b34fb";
  // character ble
  static String ACCLEROMETER_CHARACTION =
      "00002713-0000-1000-8000-00805f9b34fb";
}
