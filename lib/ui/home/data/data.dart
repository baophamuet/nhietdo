import 'package:flutter/material.dart';
import 'package:mod_do_an/config/colors.dart';
import 'package:mod_do_an/config/constants.dart';
import 'package:mod_do_an/config/images.dart';
import 'package:mod_do_an/storage/secure_storge.dart';

class Course {
  final String text;
  final String lessons;
  final String imageUrl;
  final double percent;
  final String backImage;
  final Color color;
  final Function onTap;

  Course({
    required this.text,
    required this.lessons,
    required this.imageUrl,
    required this.percent,
    required this.backImage,
    required this.color,
    required this.onTap,
  });
}

class Planing {
  final String heading;
  final String subHeading;
  final String icon;
  final Color color;
  final Function onPress;

  Planing(
      {required this.heading,
      required this.subHeading,
      required this.icon,
      required this.color,
      required this.onPress});
}

final List<Course> course = [
  Course(
      onTap: (context) async {
        await SecureStorage().saveIsSaveData(isSaveData: "true");
        Navigator.pushNamed(context, Constants.dashBoardCustomer);
      },
      text: "Bắt Đầu",
      lessons: "Dung lượng pin",
      imageUrl: AppImages.welcome,
      percent: 60,
      backImage: AppImages.box3,
      color: AppColors.kGreen),
  /* Course(
      onTap: (context) {
        Navigator.pushNamed(context, Constants.myBg);
      },
      text: "Giấc ngủ",
      lessons: "26 bài đọc",
      imageUrl: AppImages.sleep,
      percent: 57,
      backImage: AppImages.box1,
      color: AppColors.kDarkBlue),
  Course(
      onTap: (context) {
        Navigator.pushNamed(context, Constants.myBg);
      },
      text: "Osa",
      lessons: "16 video và 12 bài báo",
      imageUrl: AppImages.osa,
      percent: 14,
      backImage: AppImages.box4,
      color: AppColors.kGreen),*/
];

final List<Planing> planing = [
  Planing(
      heading: "Bộ câu hỏi STOP BANG ",
      subHeading: "Phát hiện chẩn đoán lâm sàng",
      color: AppColors.kLightBlue,
      onPress: (context) {
        Navigator.pushNamed(context, Constants.stopbangAll);
      },
      icon: AppImages.stopbangImg),
  Planing(
      heading: "Khám phá Mosa",
      onPress: (context) {},
      subHeading: "8:00 AM - 10:00 AM",
      color: AppColors.kLightBlue,
      icon: AppImages.am_thanh_Img),
  Planing(
      heading: "Chăm sóc khách hàng",
      subHeading: "8:00 AM - 10:00 AM",
      onPress: (context) {},
      color: AppColors.kLightBlue,
      icon: AppImages.cskh),
];
