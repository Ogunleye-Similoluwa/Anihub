import 'dart:convert';
import 'package:anihub/models/episode.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
class EpisodeTile extends StatelessWidget {
  final Episode episode;
  final VoidCallback? onTap;
  final bool isPlaying;

  const EpisodeTile({
    Key? key,
    required this.episode,
    this.onTap,
    this.isPlaying = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: isPlaying ? Colors.red.withOpacity(0.1) : null,
      leading: episode.image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: episode.image!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: Text(episode.number.toString()),
                ),
              ),
            )
          : CircleAvatar(
              backgroundColor: Colors.red,
              child: Text(
                episode.number.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
      title: Text(
        episode.title?.isNotEmpty == true
            ? episode.title!
            : 'Episode ${episode.number}',
        style: TextStyle(
          fontWeight: isPlaying ? FontWeight.bold : null,
          color: isPlaying ? Colors.red : null,
        ),
      ),
      subtitle: episode.description?.isNotEmpty == true
          ? Text(
              episode.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPlaying)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Playing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(
            Icons.play_arrow,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
