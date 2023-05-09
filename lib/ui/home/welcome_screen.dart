import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mod_do_an/config/colors.dart';
import 'package:mod_do_an/models/user/user.dart';
import 'package:mod_do_an/repositories/profile_repository.dart';
import 'package:mod_do_an/storage/secure_storge.dart';
import 'package:mod_do_an/ui/home/widget/courses_grid.dart';
import 'package:mod_do_an/ui/home/widget/planing_grid.dart';

import '../../component/side_menu/side_menu.dart';

class AnalyticScreen extends StatefulWidget {
  const AnalyticScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticScreen> createState() => _AnalyticScreenState();
}

class _AnalyticScreenState extends State<AnalyticScreen> {
  ProfileUser user = new ProfileUser(
      id: "",
      firstName: "",
      lastName: "",
      email: "",
      phone: "",
      dob: "",
      gender: "",
      nationality: "",
      customerId: "");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      () async {
        try {
          final data = await ProfileRepository().getProfile();
          setState(() {
            user = data;
          });
        } catch (e) {}
      }();
    });
  }

  @override
  Widget build(BuildContext context) {
    print(user?.toString());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.grey, size: 28),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: Colors.grey,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications,
              color: Colors.grey,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5, right: 16, bottom: 5),
            child: const CircleAvatar(
              backgroundImage: NetworkImage(
                  "http://drive.google.com/uc?export=view&id=1C_NsCEZlpWPBgIwlXrtAe4YA4MHh76xX"),
            ),
          )
        ],
      ),
      drawer: const SideMenu(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RichText(
                text: TextSpan(
                  text: "Hello ",
                  style: TextStyle(color: AppColors.kDarkBlue, fontSize: 20),
                  children: [
                    TextSpan(
                      text: user.lastName,
                      style: TextStyle(
                          color: AppColors.kDarkBlue,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ", welcome !",
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const CourseGrid(),
              const SizedBox(
                height: 15,
              ),
              /*
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Service",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "View All",
                    style: TextStyle(color: AppColors.kDarkBlue),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              const PlaningGrid(),*/
            ],
          ),
        ),
      ),
    );
  }
}
