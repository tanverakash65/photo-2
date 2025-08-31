import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photon/common/widgets/loader.dart';
import 'package:photon/feature/call/controller/call_controller.dart';
import 'package:photon/config/agora_config.dart';
import 'package:photon/models/call.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String channelId;
  final Call call;
  final bool isGroupChat;

  const CallScreen({
    Key? key,
    required this.channelId,
    required this.call,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  RtcEngine? _engine;
  bool _localUserJoined = false;
  int? _remoteUid;
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    // Create RTC engine
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(
      appId: AgoraConfig.appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    // Register event handlers
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user joined: ${connection.localUid}");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user joined: $remoteUid");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("Remote user left: $remoteUid");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    // Enable video
    await _engine!.enableVideo();
    await _engine!.startPreview();

    // Join channel with null token for testing (use real tokens in production)
    await _engine!.joinChannel(
      token: " ", // For testing only - implement token server for production
      channelId: widget.channelId,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> _leaveCall() async {
    await _engine?.leaveChannel();
    await _engine?.release();

    // End call in repository
    ref.read(callControllerProvider).endCall(
      widget.call.callerId,
      widget.call.receiverId,
      context,
    );

    Navigator.pop(context);
  }

  Future<void> _toggleVideo() async {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    await _engine?.enableLocalVideo(_isVideoEnabled);
  }

  Future<void> _toggleAudio() async {
    setState(() {
      _isAudioEnabled = !_isAudioEnabled;
    });
    await _engine?.enableLocalAudio(_isAudioEnabled);
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  Future<void> _dispose() async {
    await _engine?.leaveChannel();
    await _engine?.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _localUserJoined
            ? Stack(
          children: [
            // Remote video (full screen)
            if (_remoteUid != null)
              AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine!,
                  canvas: VideoCanvas(uid: _remoteUid),
                  connection: const RtcConnection(channelId: ''),
                ),
              ),

            // Local video (small view)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _engine!,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  ),
                ),
              ),
            ),

            // Call controls
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Toggle audio
                  FloatingActionButton(
                    onPressed: _toggleAudio,
                    backgroundColor: _isAudioEnabled ? Colors.white : Colors.red,
                    child: Icon(
                      _isAudioEnabled ? Icons.mic : Icons.mic_off,
                      color: _isAudioEnabled ? Colors.black : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // End call
                  FloatingActionButton(
                    onPressed: _leaveCall,
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.call_end, color: Colors.white),
                  ),
                  const SizedBox(width: 20),

                  // Toggle video
                  FloatingActionButton(
                    onPressed: _toggleVideo,
                    backgroundColor: _isVideoEnabled ? Colors.white : Colors.red,
                    child: Icon(
                      _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                      color: _isVideoEnabled ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Call info
            Positioned(
              top: 60,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.call.receiverName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _remoteUid != null ? 'Connected' : 'Calling...',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
            : const Loader(),
      ),
    );
  }
}
