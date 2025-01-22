import 'package:anihub/firebase_options.dart';
import 'package:anihub/models/wishlist.dart';
import 'package:anihub/providers/wishlistprovider.dart';
import 'package:anihub/services/analytics_services.dart';
import 'package:anihub/services/custom_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:anihub/config.dart';
import 'package:anihub/providers/bannerprovider.dart';
import 'package:anihub/providers/episodeprovider.dart';
import 'package:anihub/providers/searchprovider.dart';
import 'common/constants.dart';
import 'package:anihub/providers/manga_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");

  await setDefaultOrientation();
  setStatusBarColor();
  final docPath = await getApplicationDocumentsDirectory();
  Hive.init(docPath.path);
  Hive.registerAdapter(WishlistAdapter());
   await Firebase.initializeApp(
   options: DefaultFirebaseOptions.currentPlatform,
);
  await Hive.openBox<WishList>('wishlist');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AnalyticsService().appOpen();
    super.initState();
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: BannerProvider()),
          // ChangeNotifierProvider.value(value: AnimeProvider()),
          ChangeNotifierProvider.value(value: SearchProvider()),
          ChangeNotifierProvider.value(value: EpisodeProvider()),
          ChangeNotifierProvider.value(value: WishListProvider()),
          ChangeNotifierProvider(create: (_) => MangaProvider()),
        ],
        child: MaterialApp(
          title: 'AniHub',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.grey,
            appBarTheme: const AppBarTheme(
              color: Colors.black,
            ),
            inputDecorationTheme: const InputDecorationTheme(
              hintStyle: TextStyle(color: Colors.white),
              labelStyle: TextStyle(color: Colors.white),
            ),
            fontFamily: "Ubuntu",
            brightness: Brightness.dark,
            canvasColor: Colors.black,
            colorScheme: const ColorScheme.dark(secondary: Colors.red),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          navigatorObservers: [
            routeObserver,
            AnalyticsService().getAnalyticsObserver()
          ],
          initialRoute: '/',
          onGenerateRoute: CustomRoutes.generateRoute,
        ));
  }
}
