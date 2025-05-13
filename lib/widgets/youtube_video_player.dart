import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoPlayer extends StatefulWidget {
  final String videoId;
  final bool autoPlay;
  final VoidCallback? onEnterFullScreen;
  final VoidCallback? onExitFullScreen;
  final YoutubePlayerController? controller;
  final bool hideRelatedVideos;

  const YoutubeVideoPlayer({
    super.key,
    required this.videoId,
    this.autoPlay = false,
    this.onEnterFullScreen,
    this.onExitFullScreen,
    this.controller,
    this.hideRelatedVideos = true,
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
        flags: YoutubePlayerFlags(
          autoPlay: widget.autoPlay,
          mute: false,
          enableCaption: false,
          forceHD: true,
          controlsVisibleAtStart: true,
          showLiveFullscreenButton: true,
          useHybridComposition: true,
          hideControls: false,
          disableDragSeek: false,
          hideThumbnail: false,
          // Ẩn video gợi ý khi video kết thúc
          loop: false,
          isLive: false,
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

    // Khi video kết thúc và cần ẩn gợi ý video
    if (widget.hideRelatedVideos &&
        _controller.value.playerState == PlayerState.ended) {
      // Xử lý khi video kết thúc - tự động phát lại video để tránh hiển thị gợi ý
      Future.delayed(const Duration(milliseconds: 300), () {
        _controller.seekTo(const Duration(seconds: 0));
        _controller.pause();
      });
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
        onEnded: (data) {
          if (widget.hideRelatedVideos) {
            // Khi video kết thúc, chúng ta sẽ tự động quay về frame cuối cùng
            // và tạm dừng để tránh hiển thị video gợi ý
            _controller.seekTo(
              Duration(seconds: _controller.metadata.duration.inSeconds - 1),
            );
            _controller.pause();
          }
        },
        bottomActions: [
          CurrentPosition(),
          ProgressBar(isExpanded: true),
          RemainingDuration(),
          const PlaybackSpeedButton(),
          FullScreenButton(),
        ],
        // Ẩn các nút không cần thiết ở phía trên
        topActions: widget.hideRelatedVideos ? [] : null,
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
