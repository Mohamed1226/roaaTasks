import 'package:better_player/better_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AppVideoPlayer {
   late VideoPlayerController controller;

  Widget buildVidePlayer(String url, Function fun) {
    controller = VideoPlayerController.network(url)
      ..setLooping(true)
      ..initialize().then((_) {})
      ..addListener(() {})
      ..play();

    return AspectRatio(aspectRatio: 0.8, child: VideoPlayer(controller));
  }

// Widget buildChewiePlayer(String url) {
//   late ChewieController _chewieController;
//    controller = VideoPlayerController.network(url);
//   _chewieController = ChewieController(
//     looping: true,
//     videoPlayerController: controller,
//     autoPlay: true,
//     aspectRatio: 0.8,
//     errorBuilder: (context, error) {
//       return Center(
//         child: Text(
//           error.toString(),
//         ),
//       );
//     },
//   );
//   return AspectRatio(
//       aspectRatio: 0.8,
//       child: Chewie(
//         controller: _chewieController,
//       ));
// }
//
//
// Widget buildBetterPlayer(
//     String url, {
//       configuration = const BetterPlayerConfiguration(
//           aspectRatio: 0.8, autoPlay: true),
//     }) {
//   return BetterPlayer.network(
//     url,
//     betterPlayerConfiguration: configuration,
//   );
// }
}
