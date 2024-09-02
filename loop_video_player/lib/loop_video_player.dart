import 'dart:io';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';

class LoopVideoPlayerPage extends StatefulWidget {
  LoopVideoPlayerPage({Key? key}) : super(key: key);

  @override
  _LoopVideoPlayerPageState createState() => _LoopVideoPlayerPageState();
}

class _LoopVideoPlayerPageState extends State<LoopVideoPlayerPage> {
  FlickManager? flickManager; // Use nullable type

  @override
  void initState() {
    super.initState();
    _pickVideo();
  }

  Future<void> _pickVideo() async {
    // Use file picker to select video file from local storage
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      // Initialize FlickManager with the selected video file
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.file(
          File(result.files.single.path!),
          // closedCaptionFile: _loadCaptions(),
        ),
      );
      setState(() {});
    }
  }

  // Future<ClosedCaptionFile> _loadCaptions() async {
  //   final String fileContents = await DefaultAssetBundle.of(context)
  //       .loadString('assets/bumble_bee_captions.srt');
  //   flickManager?.flickControlManager?.toggleSubtitle();
  //   return SubRipCaptionFile(fileContents);
  // }

  @override
  void dispose() {
    flickManager?.dispose(); // Check if flickManager is null before disposing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(flickManager),
      onVisibilityChanged: (visibility) {
        if (visibility.visibleFraction == 0 && this.mounted) {
          flickManager?.flickControlManager?.autoPause();
        } else if (visibility.visibleFraction == 1) {
          flickManager?.flickControlManager?.autoResume();
        }
      },
      child: flickManager != null
          ? FlickVideoPlayer(
              flickManager: flickManager!,
              flickVideoWithControls: FlickVideoWithControls(
                closedCaptionTextStyle: TextStyle(fontSize: 8),
                controls: FlickPortraitControls(),
              ),
              flickVideoWithControlsFullscreen: FlickVideoWithControls(
                controls: FlickLandscapeControls(),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
