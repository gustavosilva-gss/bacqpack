import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';
import 'login_page.dart';
import '../utils/session_variables.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    loadSvg();

    FirebaseDatabase.instance.setPersistenceEnabled(true);
  }

  bool svgLoaded = false;

  @override
  Widget build(BuildContext context) {
    SessionVariables.initializeSession(context);

    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && svgLoaded) {
          SharedPreferences.getInstance().then((prefs) {
            if (prefs.getString("UserUid") != null) {
              Navigator.pop(context);

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return HomePage();
                  },
                ),
              );
            } else {
              Navigator.pop(context);

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return LoginPage();
                  },
                ),
              );
            }
          });
        }

        return _loadSplashScreen(context);
      },
    );
  }

  Widget _loadSplashScreen(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/svg/logo.svg',
        width: MediaQuery.of(context).size.width,
      ),
    );
  }

  void loadSvg() async {
    List<Future<dynamic>> futures = [];

    var manifestContent =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    var manifestMap = json.decode(manifestContent);

    for (var key in manifestMap.keys) {
      if (key.contains('svg/')) {
        futures.add(precachePicture(
          ExactAssetPicture(SvgPicture.svgStringDecoder, key),
          null,
        ));
      }
    }

    Future.wait(futures);

    setState(() {
      svgLoaded = true;
    });
  }
}
