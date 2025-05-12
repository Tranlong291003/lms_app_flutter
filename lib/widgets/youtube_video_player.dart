import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoPlayer extends StatefulWidget {
  final String videoId;
  final bool autoPlay;
  final VoidCallback? onEnterFullScreen;
  final VoidCallback? onExitFullScreen;
  final YoutubePlayerController? controller;

  const YoutubeVideoPlayer({
    super.key,
    required this.videoId,
    this.autoPlay = false,
    this.onEnterFullScreen,
    this.onExitFullScreen,
    this.controller,
  });

  @override
  State<YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<YoutubeVideoPlayer> {
  late YoutubePlayerController _controller;
  bool _isFullScreen = false;
  bool _isPlaying = false;
  bool _isExternalController = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isExternalController = true;
    } else {
      _controller = YoutubePlayerController(
        initialVideoId: widget.videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: false,
          forceHD: true,
          controlsVisibleAtStart: true,
          showLiveFullscreenButton: true,
          useHybridComposition: true,
        ),
      );
    }
    _controller.addListener(_listener);
  }

  void _listener() {
    // theo dõi trạng thái để bật / tắt widget ngoài
    if (_controller.value.isFullScreen != _isFullScreen) {
      setState(() => _isFullScreen = _controller.value.isFullScreen);
    }
    if (_controller.value.isPlaying != _isPlaying) {
      setState(() => _isPlaying = _controller.value.isPlaying);
    }
  }

  @override
  void didUpdateWidget(covariant YoutubeVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoId != oldWidget.videoId) {
      _controller.load(widget.videoId);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    if (!_isExternalController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onEnterFullScreen: () {
        widget.onEnterFullScreen?.call();
        setState(() => _isFullScreen = true);
      },
      onExitFullScreen: () {
        widget.onExitFullScreen?.call();
        setState(() => _isFullScreen = false);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Theme.of(context).colorScheme.primary,
        progressColors: ProgressBarColors(
          playedColor: Theme.of(context).colorScheme.primary,
          handleColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Colors.grey[300]!,
          bufferedColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
        ),
        bottomActions: [
          CurrentPosition(),
          ProgressBar(isExpanded: true),
          RemainingDuration(),
          const PlaybackSpeedButton(),
          FullScreenButton(),
        ],
        // topActions: []  // Không còn nút cài đặt chất lượng
      ),
      builder:
          (context, player) => AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_isFullScreen ? 0 : 8),
              child: player,
            ),
          ),
    );
  }
}
