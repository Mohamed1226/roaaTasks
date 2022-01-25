import 'dart:async';
import 'dart:developer';
import 'package:collection/collection.dart' show IterableExtension;

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'video_player_control.dart';

const _DEFAULT_ASPECT_RATIO = (4 / 3);

class AppVideoPlayer extends StatefulWidget {
  // final VideoItemData item;
  final url;
  final VideoPlayerController? videoPlayerController;

  const AppVideoPlayer(
      {Key? key, required this.url, required this.videoPlayerController})
      : super(key: key);

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  ChewieController? _controller;

  double? _aspectRatio;

  @override
  void initState() {
    final _ctrl = widget.videoPlayerController;
    _initPlayer(_ctrl!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('${widget.url}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: _controller == null
          ? AspectRatio(
              aspectRatio: _DEFAULT_ASPECT_RATIO,
              child: Container(
                  color: Colors.white,
                  child: Stack(
                    children: const [
                      Center(child: CircularProgressIndicator()),
                    ],
                  )))
          : SizedBox(
              key: Key('$_aspectRatio,${widget.url} _aspectRatio'),
              width: double.maxFinite,
              child: LimitedBox(
                maxHeight: 450,
                child: AspectRatio(
                    aspectRatio: 0.8,
                    child: Container(
                        color: Colors.red,
                        child: SizedBox.expand(
                            child: Chewie(controller: _controller!)))),
              ),
            ),
    );
  }

  Future<void> _initPlayer(VideoPlayerController ctrl) async {
    try {
      await ctrl.initialize();
    } catch (e) {
      print(e.toString());
    }

    _controller = ChewieController(
        videoPlayerController: ctrl,
        autoPlay: true,
        autoInitialize: true,
        isLive: true,
        allowFullScreen: true,
        showControls: true,
        placeholder: Stack(
          children: const [
            Center(child: CircularProgressIndicator()),
          ],
        ),
        // customControls: const CustomMaterialControls(),
        showOptions: false,
        looping: false,
        fullScreenByDefault: false,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        materialProgressColors: ChewieProgressColors(
            playedColor: Colors.red, handleColor: Colors.transparent));
    if (mounted) setState(() {});

    /// Init refresh for aspect ratio
    Future.delayed(const Duration(seconds: 1), () {
      _refreshAspectRation();
    });

    /// Refresh until get real aspect ratio
    Future.doWhile(
      () async {
        await Future.delayed(const Duration(seconds: 2));
        _aspectRatio = _controller?.videoPlayerController.value.aspectRatio;
        final doAgain = _aspectRatio == null || _aspectRatio == 1.0;
        if (!doAgain) setState(() {});
        return doAgain;
      },
    );
  }

  void _refreshAspectRation() {
    final newAspectRation =
        _controller?.videoPlayerController.value.aspectRatio;
    _aspectRatio = newAspectRation;
    if (newAspectRation != _aspectRatio) {
      setState(() {
        _aspectRatio = newAspectRation;
      });
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction >= 0.9) {
      if (_aspectRatio == null || _aspectRatio == 1.0) {
        _refreshAspectRation();
      }
      if (!(_controller?.isPlaying == true)) _controller?.play();
    } else {
      _controller?.pause();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    widget.videoPlayerController!.dispose();
    print("dispose");
    super.dispose();
  }
}
