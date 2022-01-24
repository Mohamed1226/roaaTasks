// // ignore_for_file: implementation_imports
//
// import 'dart:async';
//
// import 'package:chewie/chewie.dart';
// import 'package:chewie/src/helpers/utils.dart';
// import 'package:chewie/src/material/material_progress_bar.dart';
// import 'package:chewie/src/material/widgets/options_dialog.dart';
// import 'package:chewie/src/material/widgets/playback_speed_dialog.dart';
// import 'package:chewie/src/notifiers/index.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import 'package:provider/provider.dart';
// import 'package:video_player/video_player.dart';
//
// class CustomMaterialControls extends StatefulWidget {
//   const CustomMaterialControls({Key? key}) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() {
//     return _CustomMaterialControlsState();
//   }
// }
//
// class _CustomMaterialControlsState extends State<CustomMaterialControls>
//     with SingleTickerProviderStateMixin {
//   late PlayerNotifier notifier;
//   late VideoPlayerValue _latestValue;
//   Timer? _hideTimer;
//   Timer? _initTimer;
//   late var _subtitlesPosition = const Duration();
//   bool _subtitleOn = false;
//   Timer? _showAfterExpandCollapseTimer;
//   bool _dragging = false;
//   bool _displayTapped = false;
//
//   final barHeight = 24.0 * 1.5;
//   final marginSize = 5.0;
//
//   late VideoPlayerController controller;
//   ChewieController? _chewieController;
//
//   // We know that _chewieController is set in didChangeDependencies
//   ChewieController get chewieController => _chewieController!;
//
//   @override
//   void initState() {
//     super.initState();
//     notifier = Provider.of<PlayerNotifier>(context, listen: false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_latestValue.hasError) {
//       return chewieController.errorBuilder?.call(
//             context,
//             chewieController.videoPlayerController.value.errorDescription!,
//           ) ??
//           const Center(
//             child: Icon(
//               Icons.error,
//               color: Colors.white,
//               size: 42,
//             ),
//           );
//     }
//
//     return MouseRegion(
//       onHover: (_) {
//         _cancelAndRestartTimer();
//       },
//       child: Directionality(
//         textDirection: TextDirection.ltr,
//         child: GestureDetector(
//           onTap: () => _cancelAndRestartTimer(),
//           child: AbsorbPointer(
//             absorbing: notifier.hideStuff,
//             child: Stack(
//               children: [
//                 if (_latestValue.isBuffering)
//                   const Center(
//                     child: CircularProgressIndicator(),
//                   )
//                 else
//                   _buildHitArea(),
//                 _buildActionBar(),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: <Widget>[
//                     if (_subtitleOn)
//                       Transform.translate(
//                         offset: Offset(0.0, notifier.hideStuff ? barHeight * 0.8 : 0.0),
//                         child: _buildSubtitles(context, chewieController.subtitle!),
//                       ),
//                     _buildBottomBar(context),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _dispose();
//     super.dispose();
//   }
//
//   void _dispose() {
//     controller.removeListener(_updateState);
//     _hideTimer?.cancel();
//     _initTimer?.cancel();
//     _showAfterExpandCollapseTimer?.cancel();
//   }
//
//   @override
//   void didChangeDependencies() {
//     final _oldController = _chewieController;
//     _chewieController = ChewieController.of(context);
//     controller = chewieController.videoPlayerController;
//
//     if (_oldController != chewieController) {
//       _dispose();
//       _initialize();
//     }
//
//     super.didChangeDependencies();
//   }
//
//   Widget _buildActionBar() {
//     return PositionedDirectional(
//       top: 0,
//       end: 0,
//       child: SafeArea(
//         child: AnimatedOpacity(
//           opacity: notifier.hideStuff ? 0.0 : 1.0,
//           duration: const Duration(milliseconds: 250),
//           child: Row(
//             children: [
//               _buildSubtitleToggle(),
//               if (chewieController.showOptions) _buildOptionsButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOptionsButton() {
//     final options = <OptionItem>[
//       OptionItem(
//         onTap: () async {
//           Navigator.pop(context);
//           _onSpeedButtonTap();
//         },
//         iconData: Icons.speed,
//         title: chewieController.optionsTranslation?.playbackSpeedButtonText ?? 'Playback speed',
//       )
//     ];
//
//     if (chewieController.subtitle != null && chewieController.subtitle!.isNotEmpty) {
//       options.add(
//         OptionItem(
//           onTap: () {
//             _onSubtitleTap();
//             Navigator.pop(context);
//           },
//           iconData: _subtitleOn ? Icons.closed_caption : Icons.closed_caption_off_outlined,
//           title: chewieController.optionsTranslation?.subtitlesButtonText ?? 'Subtitles',
//         ),
//       );
//     }
//
//     if (chewieController.additionalOptions != null &&
//         chewieController.additionalOptions!(context).isNotEmpty) {
//       options.addAll(chewieController.additionalOptions!(context));
//     }
//
//     return AnimatedOpacity(
//       opacity: notifier.hideStuff ? 0.0 : 1.0,
//       duration: const Duration(milliseconds: 250),
//       child: IconButton(
//         onPressed: () async {
//           _hideTimer?.cancel();
//
//           if (chewieController.optionsBuilder != null) {
//             await chewieController.optionsBuilder!(context, options);
//           } else {
//             await showModalBottomSheet<OptionItem>(
//               context: context,
//               isScrollControlled: true,
//               useRootNavigator: true,
//               builder: (context) => OptionsDialog(
//                 options: options,
//                 cancelButtonText: chewieController.optionsTranslation?.cancelButtonText,
//               ),
//             );
//           }
//
//           if (_latestValue.isPlaying) {
//             _startHideTimer();
//           }
//         },
//         icon: const Icon(
//           Icons.more_vert,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSubtitles(BuildContext context, Subtitles subtitles) {
//     if (!_subtitleOn) {
//       return Container();
//     }
//     final currentSubtitle = subtitles.getByPosition(_subtitlesPosition);
//     if (currentSubtitle.isEmpty) {
//       return Container();
//     }
//
//     if (chewieController.subtitleBuilder != null) {
//       return chewieController.subtitleBuilder!(
//         context,
//         currentSubtitle.first!.text,
//       );
//     }
//
//     return Padding(
//       padding: EdgeInsets.all(marginSize),
//       child: Container(
//         padding: const EdgeInsets.all(5),
//         decoration: BoxDecoration(
//           color: const Color(0x96000000),
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         child: Text(
//           currentSubtitle.first!.text,
//           style: const TextStyle(
//             fontSize: 18,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
//
//   AnimatedOpacity _buildBottomBar(
//     BuildContext context,
//   ) {
//     final iconColor = Theme.of(context).textTheme.button!.color;
//
//     return AnimatedOpacity(
//       opacity: notifier.hideStuff ? 0.0 : 1.0,
//       duration: const Duration(milliseconds: 300),
//       child: Container(
//         height: barHeight + (chewieController.isFullScreen ? 10.0 : 0),
//         padding: EdgeInsetsDirectional.only(
//           start: 20,
//           bottom: !chewieController.isFullScreen ? 10.0 : 0,
//         ),
//         child: SafeArea(
//           bottom: chewieController.isFullScreen,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               if (!chewieController.isLive)
//                 Expanded(
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       _buildCurrentDuration(),
//                       const SizedBox(width: 12),
//                       _buildProgressBar(),
//                       const SizedBox(width: 12),
//                       _buildFullDuration(),
//                       const SizedBox(width: 12),
//                       if (chewieController.allowFullScreen) _buildExpandButton(),
//                     ],
//                   ),
//                 )
//               else
//                 Expanded(
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       if (chewieController.allowFullScreen) _buildExpandButton(),
//                     ],
//                   ),
//                 )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   GestureDetector _buildExpandButton() {
//     return GestureDetector(
//       onTap: _onExpandCollapse,
//       child: Padding(
//         padding: const EdgeInsetsDirectional.only(bottom: 6,end: 8),
//         child: AnimatedOpacity(
//           opacity: notifier.hideStuff ? 0.0 : 1.0,
//           duration: const Duration(milliseconds: 300),
//           child: chewieController.isFullScreen
//               ? Icon(Icons.fullscreen_exit, color: Colors.white)
//               : Icon(Icons.fullscreen_exit, color: Colors.blue)
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHitArea() {
//     final bool isFinished = _latestValue.position >= _latestValue.duration;
//
//     return GestureDetector(
//       onTap: () {
//         if (_latestValue.isPlaying) {
//           if (_displayTapped) {
//             setState(() {
//               notifier.hideStuff = true;
//             });
//           } else {
//             _cancelAndRestartTimer();
//           }
//         } else {
//           _playPause();
//
//           setState(() {
//             notifier.hideStuff = true;
//           });
//         }
//       },
//       child: _CenterPlayButton(
//         backgroundColor: Colors.black54,
//         iconColor: Colors.white,
//         isFinished: isFinished,
//         isPlaying: controller.value.isPlaying,
//         show: !_dragging && !notifier.hideStuff,
//         onPressed: _playPause,
//       ),
//     );
//   }
//
//   Future<void> _onSpeedButtonTap() async {
//     _hideTimer?.cancel();
//
//     final chosenSpeed = await showModalBottomSheet<double>(
//       context: context,
//       isScrollControlled: true,
//       useRootNavigator: true,
//       builder: (context) => PlaybackSpeedDialog(
//         speeds: chewieController.playbackSpeeds,
//         selected: _latestValue.playbackSpeed,
//       ),
//     );
//
//     if (chosenSpeed != null) {
//       controller.setPlaybackSpeed(chosenSpeed);
//     }
//
//     if (_latestValue.isPlaying) {
//       _startHideTimer();
//     }
//   }
//
//   Widget _buildPosition(Color? iconColor) {
//     final position = _latestValue.position;
//     final duration = _latestValue.duration;
//
//     return RichText(
//       text: TextSpan(
//         text: '${formatDuration(position)} ',
//         children: <InlineSpan>[
//           TextSpan(
//             text: '/ ${formatDuration(duration)}',
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.white.withOpacity(.75),
//               fontWeight: FontWeight.w500,
//             ),
//           )
//         ],
//         style: const TextStyle(
//           fontSize: 12,
//           color: Colors.white,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSubtitleToggle() {
//     //if don't have subtitle hiden button
//     if (chewieController.subtitle?.isEmpty ?? true) {
//       return Container();
//     }
//     return GestureDetector(
//       onTap: _onSubtitleTap,
//       child: Container(
//         height: barHeight,
//         color: Colors.transparent,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         child: Icon(
//           _subtitleOn ? Icons.closed_caption : Icons.closed_caption_off_outlined,
//           color: _subtitleOn ? Colors.white : Colors.grey[700],
//         ),
//       ),
//     );
//   }
//
//   void _onSubtitleTap() {
//     setState(() {
//       _subtitleOn = !_subtitleOn;
//     });
//   }
//
//   void _cancelAndRestartTimer() {
//     _hideTimer?.cancel();
//     _startHideTimer();
//
//     setState(() {
//       notifier.hideStuff = false;
//       _displayTapped = true;
//     });
//   }
//
//   Future<void> _initialize() async {
//     _subtitleOn = chewieController.subtitle?.isNotEmpty ?? false;
//     controller.addListener(_updateState);
//
//     _updateState();
//
//     if (controller.value.isPlaying || chewieController.autoPlay) {
//       _startHideTimer();
//     }
//
//     if (chewieController.showControlsOnInitialize) {
//       _initTimer = Timer(const Duration(milliseconds: 200), () {
//         setState(() {
//           notifier.hideStuff = false;
//         });
//       });
//     }
//   }
//
//   void _onExpandCollapse() {
//     setState(() {
//       notifier.hideStuff = true;
//
//       chewieController.toggleFullScreen();
//       _showAfterExpandCollapseTimer = Timer(const Duration(milliseconds: 300), () {
//         setState(() {
//           _cancelAndRestartTimer();
//         });
//       });
//     });
//   }
//
//   void _playPause() {
//     final isFinished = _latestValue.position >= _latestValue.duration;
//
//     setState(() {
//       if (controller.value.isPlaying) {
//         notifier.hideStuff = false;
//         _hideTimer?.cancel();
//         controller.pause();
//       } else {
//         _cancelAndRestartTimer();
//
//         if (!controller.value.isInitialized) {
//           controller.initialize().then((_) {
//             controller.play();
//           });
//         } else {
//           if (isFinished) {
//             controller.seekTo(const Duration());
//           }
//           controller.play();
//         }
//       }
//     });
//   }
//
//   void _startHideTimer() {
//     _hideTimer = Timer(const Duration(seconds: 3), () {
//       setState(() {
//         notifier.hideStuff = true;
//       });
//     });
//   }
//
//   void _updateState() {
//     if (!mounted) return;
//     setState(() {
//       _latestValue = controller.value;
//       _subtitlesPosition = controller.value.position;
//     });
//   }
//
//   Widget _buildProgressBar() {
//     return Expanded(
//       flex: 100,
//       child: SizedBox(
//         height: 20,
//         child: MaterialVideoProgressBar(
//           controller,
//           onDragStart: () {
//             setState(() {
//               _dragging = true;
//             });
//
//             _hideTimer?.cancel();
//           },
//           onDragEnd: () {
//             setState(() {
//               _dragging = false;
//             });
//
//             _startHideTimer();
//           },
//           colors: ChewieProgressColors(
//             playedColor: Colors.white,
//             handleColor: Colors.transparent,
//             bufferedColor: Colors.white.withOpacity(0.6),
//             backgroundColor: Colors.white.withOpacity(0.41),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCurrentDuration() {
//     final position = _latestValue.position;
//
//     return Text(
//       '${formatDuration(position)}',
//       style: const TextStyle(
//         fontSize: 12,
//         color: Colors.white,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }
//
//   Widget _buildFullDuration() {
//     final duration = _latestValue.duration;
//
//     return Text(
//       '${formatDuration(duration)}',
//       style: const TextStyle(
//         fontSize: 12,
//         color: Colors.white,
//         fontWeight: FontWeight.w400,
//       ),
//     );
//   }
// }
//
// class _CenterPlayButton extends StatelessWidget {
//   const _CenterPlayButton({
//     Key? key,
//     required this.backgroundColor,
//     this.iconColor,
//     required this.show,
//     required this.isPlaying,
//     required this.isFinished,
//     this.onPressed,
//   }) : super(key: key);
//
//   final Color backgroundColor;
//   final Color? iconColor;
//   final bool show;
//   final bool isPlaying, isFinished;
//   final VoidCallback? onPressed;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.transparent,
//       child: Center(
//         child: AnimatedOpacity(
//           opacity: show ? 1.0 : 0.0,
//           duration: const Duration(milliseconds: 300),
//           child: Container(
//             decoration: BoxDecoration(shape: BoxShape.circle),
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: IconButton(
//                 iconSize: 32,
//                 icon: isFinished
//                     ? Icon(Icons.replay, color: iconColor)
//                     : _AnimatedPlayPause(
//                         color: iconColor,
//                         playing: isPlaying,
//                       ),
//                 onPressed: onPressed,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// A widget that animates implicitly between a play and a pause icon.
// class _AnimatedPlayPause extends StatefulWidget {
//   const _AnimatedPlayPause({
//     Key? key,
//     required this.playing,
//     this.size,
//     this.color,
//   }) : super(key: key);
//
//   final double? size;
//   final bool playing;
//   final Color? color;
//
//   @override
//   State<StatefulWidget> createState() => _AnimatedPlayPauseState();
// }
//
// class _AnimatedPlayPauseState extends State<_AnimatedPlayPause>
//     with SingleTickerProviderStateMixin {
//   late final animationController = AnimationController(
//     vsync: this,
//     value: widget.playing ? 1 : 0,
//     duration: const Duration(milliseconds: 400),
//   );
//
//   @override
//   void didUpdateWidget(_AnimatedPlayPause oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.playing != oldWidget.playing) {
//       if (widget.playing) {
//         animationController.forward();
//       } else {
//         animationController.reverse();
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: AnimatedIcon(
//         color: widget.color,
//         size: widget.size,
//         icon: AnimatedIcons.play_pause,
//         progress: animationController,
//       ),
//     );
//   }
// }
