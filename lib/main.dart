import 'package:admin_flutter/app/launch/view.dart';
import 'package:admin_flutter/common/app_data.dart';
import 'package:admin_flutter/state.dart';
import 'package:admin_flutter/theme/my_theme.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'theme/light_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var appData = await LoginData.read();
  var findTheme = themeList.firstWhereOrNull((e)=>e.name() == appData.themeName);
  theme = findTheme?.theme() ?? Light().theme();
  await message.init();

  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(1920, 1080),
    // backgroundColor: Colors.transparent,
    skipTaskbar: false,
    // titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    // await windowManager.show();
    // await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
      return GetMaterialApp(
        translations: message,
        defaultTransition: Transition.noTransition,
        builder: BotToastInit(),
        //1.调用BotToastInit
        navigatorObservers: [BotToastNavigatorObserver()],
        //2.注册路由观察者
        title: 'Flutter Admin',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('zh'), // Chinese
        ],
        locale: const Locale('zh'),
        theme: theme,
        home: LaunchPage(),
      );
  }
}
