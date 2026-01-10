import 'package:flutter/material.dart';
import 'call_screen.dart';

class VideoCallScreen extends StatelessWidget {
  final String userName;
  final String? userAvatar;

  const VideoCallScreen({
    super.key,
    required this.userName,
    this.userAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return CallScreen(
      userName: userName,
      userAvatar: userAvatar,
      isVideoCall: true,
    );
  }
}

