import 'package:anihub/config/shimmer.dart';
import 'package:anihub/providers/episodeprovider.dart';
import 'package:anihub/screens/all_episodes_page.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'episode_tile.dart';

class EpisodesList extends StatefulWidget {
  final int id;
  final String title;

  const EpisodesList({Key? key, required this.id, required this.title})
      : super(key: key);

  @override
  _EpisodesListState createState() => _EpisodesListState();
}

class _EpisodesListState extends State<EpisodesList> {
  late EpisodeProvider episodesProvider;
  bool loading = false;
  List<Widget> loader = List.generate(
    5,
    (index) => const LoaderWidget.rectangular(
      height: 50,
      borderRadius: Radius.circular(0),
    ),
  );

  @override
  void initState() {
    super.initState();
    episodesProvider = Provider.of<EpisodeProvider>(context, listen: false);
    _initializeEpisodes();
  }

  Future<void> _initializeEpisodes() async {
    if (episodesProvider.episodes.isEmpty) {
      try {
        setState(() => loading = true);
        await episodesProvider.fetchEpisodes(widget.id.toString());
      } catch (err) {
        setState(() {
          loader = [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(err.toString()),
                  ElevatedButton(
                    onPressed: _initializeEpisodes,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ];
        });
      } finally {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EpisodeProvider>(
      builder: (context, provider, child) {
        if (loading) {
          return Column(children: loader);
        }

        if (provider.episodes.isEmpty) {
          return const Center(
            child: Text('No episodes available'),
          );
        }

        final episodes = provider.episodes;
        final displayCount = episodes.length > 10 ? 10 : episodes.length;

        return Column(
          children: [
            ...List.generate(
              displayCount,
              (index) => EpisodeTile(
                episode: episodes[index],
                onTap: () {
                  // Handle episode tap
                  provider.playEpisode(episodes[index]);
                },
              ),
            ),
            if (episodes.length > 10)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllEpisodesPage(
                          id: widget.id,
                          title: widget.title,
                        ),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      "Show More",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
