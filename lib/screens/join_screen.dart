import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../utils/spacer.dart';

import '../widgets/meeting_controls/meeting_action_button.dart';
import 'meeting_screen.dart';

// Join Screen
class JoinScreen extends StatefulWidget {
  final String meetingId;
  final String token;

  const JoinScreen({
    Key? key,
    required this.meetingId,
    required this.token,
  }) : super(key: key);

  @override
  _JoinScreenState createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  String displayName = "";
  bool isMicOn = true;
  bool isWebcamOn = true;

  CameraController? cameraController;

  @override
  void initState() {
    super.initState();

    // Get available cameras
    availableCameras().then((availableCameras) {
      // stores selected camera id
      int selectedCameraId = availableCameras.length > 1 ? 1 : 0;

      cameraController = CameraController(
        availableCameras[selectedCameraId],
        ResolutionPreset.medium,
      );

      cameraController!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    }).catchError((err) {
      log("Error: $err");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Screen Title
        title: const Text("VideoSDK RTC"),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              verticalSpacer(MediaQuery.of(context).size.height / 7),

              // Camera Preview
              SizedBox(
                width: (MediaQuery.of(context).size.width / 1.5),
                height: (MediaQuery.of(context).size.height / 2.5),
                child: !(cameraController?.value.isInitialized ?? false)
                    ? Container()
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          AspectRatio(
                            aspectRatio: cameraController!.value.aspectRatio,
                            child: isWebcamOn
                                ? CameraPreview(cameraController!)
                                : Container(
                                    color: Colors.black,
                                    child: const Center(
                                      child: Text(
                                        "Camera is turned off",
                                      ),
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,

                            // Meeting ActionBar
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Mic Action Button
                                MeetingActionButton(
                                  icon: isMicOn ? Icons.mic : Icons.mic_off,
                                  backgroundColor: isMicOn
                                      ? Theme.of(context).primaryColor
                                      : Colors.red,
                                  iconColor: Colors.white,
                                  radius: 30,
                                  onPressed: () => setState(
                                    () => isMicOn = !isMicOn,
                                  ),
                                ),

                                // Camera Action Button
                                MeetingActionButton(
                                  backgroundColor: isWebcamOn
                                      ? Theme.of(context).primaryColor
                                      : Colors.red,
                                  iconColor: Colors.white,
                                  radius: 30,
                                  onPressed: () {
                                    if (isWebcamOn) {
                                      cameraController?.pausePreview();
                                    } else {
                                      cameraController?.resumePreview();
                                    }
                                    setState(() => isWebcamOn = !isWebcamOn);
                                  },
                                  icon: isWebcamOn
                                      ? Icons.videocam
                                      : Icons.videocam_off,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              verticalSpacer(16),

              // Display Name TextField
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: TextField(
                  onChanged: ((value) => displayName = value),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Name",
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    prefixIcon: Icon(
                      Icons.keyboard,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              verticalSpacer(20),

              // Join Button
              TextButton(
                onPressed: () async {
                  // By default Guest is used as display name
                  if (displayName.isEmpty) {
                    displayName = "Guest";
                  }

                  // Dispose Camera Controller before leaving screen
                  await cameraController?.dispose();

                  // Open meeting screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MeetingScreen(
                        token: widget.token,
                        meetingId: widget.meetingId,
                        displayName: displayName,
                        micEnabled: isMicOn,
                        webcamEnabled: isWebcamOn,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "JOIN",
                ),
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}
