import 'dart:convert';

import 'package:anihub/config/enum.dart';
import 'package:anihub/models/manga.dart';
import 'package:anihub/screens/all_anime_screen.dart';
import 'package:anihub/screens/all_episodes_page.dart';
import 'package:anihub/screens/detail.dart';
import 'package:anihub/screens/home_page.dart';
import 'package:anihub/screens/manga_screen.dart';
import 'package:anihub/screens/search_screen.dart';
import 'package:anihub/screens/tab_screen.dart';
import 'package:anihub/screens/video_screen.dart';
import 'package:anihub/screens/favourites_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:anihub/screens/manga_detail_screen.dart';

class CustomRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    FirebaseAnalytics.instance.logEvent(
        name: "screen_view", parameters: {"screen": "${settings.name},"});
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const TabScreen());
      case '/homescreen':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/mangascreen':
        return MaterialPageRoute(builder: (_) => const MangaScreen());
      case '/searchscreen':
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case '/wishlist':
        return MaterialPageRoute(builder: (_) => const FavouritesScreen());
      case '/detailscreen':
        final arge = json.decode(settings.arguments.toString());
        final id = arge['id'];
        final type = arge['type'];
        return MaterialPageRoute(
            builder: (_) => DetailScreen(id: id, type: ResultType.values[type]));
      case '/allanimescreen':
        final arge = json.decode(settings.arguments.toString());
        final genra = arge['genra'];
        final query = arge['query'];
        return MaterialPageRoute(
            builder: (_) => AllAnimeScreen(
                  genra: genra,
                  query: query,
                ));
      case '/allepisodescreen':
        final arge = json.decode(settings.arguments.toString());
        final id = arge['id'];
        final title = arge['title'];
        return MaterialPageRoute(
            builder: (_) => AllEpisodesPage(id: id, title: title));
      case '/videoscreen':
        final arge = json.decode(settings.arguments.toString());
        final videoUrl = arge['videoUrl'];
        final title = arge['title'];
        return MaterialPageRoute(
            builder: (_) => VideoScreen(title: title, videoUrl: videoUrl));
      case '/manga-detail':
        return MaterialPageRoute(
          builder: (_) => MangaDetailScreen(
            manga: settings.arguments as Manga,
          ),
        );
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  appBar: AppBar(),
                  body: const Center(
                    child: Text("Page not found"),
                  ),
                ));
    }
  }
}
