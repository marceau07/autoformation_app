import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaDisplay extends StatefulWidget {
  final String url; // URL de l'image ou de la vidéo

  const MediaDisplay({super.key, required this.url});

  @override
  _MediaDisplayState createState() => _MediaDisplayState();
}

class _MediaDisplayState extends State<MediaDisplay> {
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer() {
    // Vérifier si l'URL est une vidéo (basé sur l'extension)
    if (isVideo(widget.url)) {
      _videoPlayerController = VideoPlayerController.network(widget.url)
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController?.play();
          // Set the video to loop indefinitely
          _videoPlayerController?.setLooping(true);
        });
    }
  }

  bool isVideo(String url) {
    // Liste des extensions courantes de vidéos
    final videoExtensions = ['mp4', 'mov', 'avi', 'mkv'];
    final extension = url.split('.').last.toLowerCase();
    return videoExtensions.contains(extension);
  }

  bool isImage(String url) {
    // Liste des extensions courantes d'images
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    final extension = url.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isImage(widget.url)
          ? Image.network(
              widget.url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircularProgressIndicator();
              },
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
            )
          : _videoPlayerController != null &&
                  _videoPlayerController!.value.isInitialized
              ? ClipRect(
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      // width: double.infinity,
                      height: _videoPlayerController!.value.size.height,
                      child: AspectRatio(
                        aspectRatio: _videoPlayerController!.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController!),
                      ),
                    ),
                  ),
                )
              : const CircularProgressIndicator(), // Affiche un indicateur de chargement pour la vidéo
    );
  }
}
