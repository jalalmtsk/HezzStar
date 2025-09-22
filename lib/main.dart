import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:hezzstar/tools/AudioManager/AudioManager.dart';
import 'package:hezzstar/tools/ConnectivityManager/ConnectivityManager.dart';
import 'package:hezzstar/tools/LifeCycleManager.dart';

import 'ExperieneManager.dart';
import 'MainScreenIndex.dart';
import 'l10n/AmazighMaterialLocalizations.dart';
import 'l10n/app_localizations.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
AppLocalizations tr(BuildContext context) => AppLocalizations.of(context)!;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExperienceManager()),
        ChangeNotifierProvider(create: (_) => AudioManager()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: AppLifecycleManager(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExperienceManager>(
      builder: (context, xpManager, child) {
        final currentLocale = Locale(xpManager.userProfile.preferredLanguage);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          home: const MainScreen(),
          locale: currentLocale,

          // ✅ Add localization support
          localizationsDelegates: const [
            AppLocalizations.delegate,
            AmazighMaterialLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          supportedLocales: const [
            Locale("en"), // English
            Locale("ar"), // Arabic
            Locale("fr"), // French
            Locale("es"), // Spanish
            Locale("zgh"), // Amazigh (standard code)
          ],

          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) return const Locale('en');

            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
            return const Locale('en'); // fallback
          },
        );
      },
    );
  }
}
