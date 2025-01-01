// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// // import 'package:anihub/providers/recent_provider.dart';
// // import 'package:anihub/widgets/recent_anime_card.dart';

// class RecentScreen extends StatefulWidget {
//   const RecentScreen({Key? key}) : super(key: key);

//   @override
//   _RecentScreenState createState() => _RecentScreenState();
// }

// class _RecentScreenState extends State<RecentScreen> {
//   String _searchQuery = '';
//   String _filterType = 'all'; // 'all', 'today', 'week', 'month'

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Recent'),
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'Recently Watched'),
//               Tab(text: 'Continue Watching'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             _buildRecentlyWatchedTab(),
//             _buildContinueWatchingTab(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentlyWatchedTab() {
//     return Consumer<RecentProvider>(
//       builder: (context, provider, child) {
//         final recentAnime = provider.getRecentlyWatched();

//         if (recentAnime.isEmpty) {
//           return const Center(
//             child: Text('No recently watched anime'),
//           );
//         }

//         return ListView.builder(
//           itemCount: recentAnime.length,
//           itemBuilder: (context, index) {
//             final anime = recentAnime[index];
//             return RecentAnimeCard(
//               anime: anime,
//               onTap: () {
//                 // Navigate to detail page
//               },
//               onResume: () {
//                 // Resume watching
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildContinueWatchingTab() {
//     return Consumer<RecentProvider>(
//       builder: (context, provider, child) {
//         final continueWatching = provider.getContinueWatching();

//         if (continueWatching.isEmpty) {
//           return const Center(
//             child: Text('No anime to continue watching'),
//           );
//         }

//         return ListView.builder(
//           itemCount: continueWatching.length,
//           itemBuilder: (context, index) {
//             final anime = continueWatching[index];
//             return RecentAnimeCard(
//               anime: anime,
//               onTap: () {
//                 // Navigate to detail page
//               },
//               onResume: () {
//                 // Resume watching
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// } 