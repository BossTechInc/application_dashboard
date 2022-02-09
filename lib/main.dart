import 'package:concise_dashboard/provider/business_api.dart';
import 'package:concise_dashboard/provider/entertainment_api.dart';
import 'package:concise_dashboard/provider/health_api.dart';
import 'package:concise_dashboard/provider/politics_api.dart';
import 'package:concise_dashboard/provider/science_and_tech_api.dart';
import 'package:concise_dashboard/provider/sports_api.dart';
import 'package:concise_dashboard/provider/world_api.dart';
import 'package:concise_dashboard/screens/categories.dart';
import 'package:concise_dashboard/screens/categories/entertainment.dart';
import 'package:concise_dashboard/screens/categories/finance.dart';
import 'package:concise_dashboard/screens/categories/health.dart';
import 'package:concise_dashboard/screens/categories/international_affairs.dart';
import 'package:concise_dashboard/screens/categories/politics.dart';
import 'package:concise_dashboard/screens/categories/sports.dart';
import 'package:concise_dashboard/widgets/web_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/categories/science_and_tech.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScienceAndTechProvider()),
        ChangeNotifierProvider(create: (_) => InternationalProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => EntertainmentProvider()),
        ChangeNotifierProvider(create: (_)=>PoliticsProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_)=>SportsProvider()),
      ],
      child: MaterialApp(
        title: 'Concise Dashboard',
        theme: ThemeData(
          primaryColor: Colors.black,
        ),
        home: Categories(),
        routes: {
          Web.routeName: (ctx) => Web(),
          ScienceAndTech.routeName: (ctx) => ScienceAndTech(),
          Entertainment.routeName: (ctx) => Entertainment(),
          Politics.routeName: (ctx) => Politics(),
          Finance.routeName: (ctx) => Finance(),
          Sports.routeName: (ctx) => Sports(),
          InternationalAffairs.routeName: (ctx) => InternationalAffairs(),
          Health.routeName: (ctx) => Health(),
        },
      ),
    );
  }
}
