import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil package
import 'package:firebase_core/firebase_core.dart'; // Import Firebase
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Urban Gardening Assistant',
          theme: ThemeData(
            primarySwatch: Colors.green,
            fontFamily: 'Roboto',
          ),
          home: SplashScreen(),
          routes: {
            '/login': (context) => LoginScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/home') {
              final args = settings.arguments as Map<String, dynamic>?;

              if (args != null && args.containsKey('username')) {
                return MaterialPageRoute(
                  builder: (context) => HomeScreen(username: args['username']),
                );
              }
            }
            return null;
          },
        );
      },
    );
  }
}
