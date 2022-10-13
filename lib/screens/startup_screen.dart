// ignore_for_file: non_constant_identifier_names, dead_code

import 'dart:convert';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:videosdk_flutter_example/widgets/join_meeting/generate_meeting.dart';
import 'package:videosdk_flutter_example/widgets/meeting_controls/meeting_action_button.dart';

import '../constants/colors.dart';
import '../utils/spacer.dart';
import '../utils/toast.dart';
import 'join_screen.dart';
import 'meeting_screen.dart';

// Startup Screen
class StartupScreen extends StatefulWidget {
  const StartupScreen({Key? key}) : super(key: key);

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  String _token = "";
  String _meetingID = "";

  // Control Status
  bool isMicOn = false;
  bool isCameraOn = false;

  bool isJoinMethodSelected = false;
  bool isCreateMeeting = false;

  // Camera Controller
  CameraController? cameraController;

  final ButtonStyle _buttonStyle = TextButton.styleFrom(
    primary: Colors.white,
    backgroundColor: primaryColor,
    textStyle: const TextStyle(
      fontWeight: FontWeight.bold,
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await fetchToken();
      setState(() => _token = token);
    });

    initCameraPreview();
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPopScope,
        child: Scaffold(
          backgroundColor: primaryColor,
          body: SafeArea(
            child: _token.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(),
                        HorizontalSpacer(12),
                        Text("Initialization"),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: LayoutBuilder(
                      builder: (BuildContext context,
                          BoxConstraints viewportConstraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: viewportConstraints.maxHeight),
                            child: IntrinsicHeight(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Camera Preview
                                  Container(
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          (MediaQuery.of(context).size.height *
                                              .4),
                                      // maxWidth: (MediaQuery.of(context).size.width * .40),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        (cameraController == null) && isCameraOn
                                            ? !(cameraController
                                                        ?.value.isInitialized ??
                                                    false)
                                                ? Container(
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                    decoration: BoxDecoration(
                                                        // color: black800,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12)),
                                                  )
                                                : Container(
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                    decoration: BoxDecoration(
                                                        // color: black800,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12)),
                                                  )
                                            : AspectRatio(
                                                aspectRatio: 1 / 1.55,
                                                // (cameraController == null
                                                //     ? 1.55
                                                //     : cameraController!
                                                //         .value.aspectRatio),
                                                child: isCameraOn
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        child: CameraPreview(
                                                            cameraController!))
                                                    : Container(
                                                        child: const Center(
                                                          child: Text(
                                                            "Camera is turned off",
                                                          ),
                                                        ),
                                                        decoration: BoxDecoration(
                                                            color: black800,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                      ),
                                              ),
                                        Positioned(
                                          bottom: 16,
                                          left: 60,
                                          right: 60,

                                          // Meeting ActionBar
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Mic Action Button
                                              ElevatedButton(
                                                onPressed: () => setState(
                                                  () => isMicOn = !isMicOn,
                                                ),
                                                child: Icon(
                                                    isMicOn
                                                        ? Icons.mic
                                                        : Icons.mic_off,
                                                    color: isMicOn
                                                        ? grey
                                                        : Colors.white),
                                                style: ElevatedButton.styleFrom(
                                                  shape: CircleBorder(),
                                                  padding: EdgeInsets.all(12),
                                                  primary: isMicOn
                                                      ? Colors.white
                                                      : red,
                                                  onPrimary: Colors.black,
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  if (isCameraOn) {
                                                    cameraController?.dispose();
                                                    cameraController = null;
                                                  } else {
                                                    initCameraPreview();
                                                    // cameraController?.resumePreview();
                                                  }
                                                  setState(() =>
                                                      isCameraOn = !isCameraOn);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: CircleBorder(),
                                                  padding: EdgeInsets.all(12),
                                                  primary: isCameraOn
                                                      ? Colors.white
                                                      : red,
                                                ),
                                                child: Icon(
                                                  isCameraOn
                                                      ? Icons.videocam
                                                      : Icons.videocam_off,
                                                  color: isCameraOn
                                                      ? grey
                                                      : Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        if (!isJoinMethodSelected)
                                          MaterialButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              color: purple,
                                              child: const Text(
                                                  "Create Meeting",
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                              onPressed: () => {
                                                    setState(() => {
                                                          isCreateMeeting =
                                                              true,
                                                          isJoinMethodSelected =
                                                              true
                                                        })
                                                  }),
                                        const VerticalSpacer(16),
                                        if (!isJoinMethodSelected)
                                          MaterialButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              color: black750,
                                              child: const Text("Join Meeting",
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                              onPressed: () => {
                                                    setState(() => {
                                                          isCreateMeeting =
                                                              false,
                                                          isJoinMethodSelected =
                                                              true
                                                        })
                                                  }),
                                        if (isJoinMethodSelected)
                                          GenerateMeetingWidget(
                                            isCreateMeeting: isCreateMeeting,
                                            onClickMeetingJoin: (meetingId,
                                                    callType, displayName) =>
                                                _onClickMeetingJoin(meetingId,
                                                    callType, displayName),
                                          ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )),
          ),
        ));
  }

  Future<bool> _onWillPopScope() async {
    if (isJoinMethodSelected) {
      setState(() {
        isJoinMethodSelected = false;
      });
      return false;
    } else {
      return true;
    }
  }

  void initCameraPreview() {
    // Get available cameras
    availableCameras().then((availableCameras) {
      // stores selected camera id
      int selectedCameraId = availableCameras.length > 1 ? 1 : 0;

      cameraController = CameraController(
        availableCameras[selectedCameraId],
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      log("Starting Camera");
      cameraController!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    }).catchError((err) {
      log("Error: $err");
    });
  }

  void _onClickMeetingJoin(meetingId, callType, displayName) async {
    cameraController?.dispose();
    cameraController = null;
    if (displayName.toString().isEmpty) {
      displayName = "Guest";
    }
    if (isCreateMeeting) {
      createAndJoinMeeting(callType, displayName);
    } else {
      joinMeeting(callType, displayName, meetingId);
    }
  }

  Future<String> fetchToken() async {
    if (!dotenv.isInitialized) {
      // Load Environment variables
      await dotenv.load(fileName: ".env");
    }
    final String? _AUTH_URL = dotenv.env['AUTH_URL'];
    String? _AUTH_TOKEN = dotenv.env['AUTH_TOKEN'];

    if ((_AUTH_TOKEN?.isEmpty ?? true) && (_AUTH_URL?.isEmpty ?? true)) {
      showSnackBarMessage(
          message: "Please set the environment variables", context: context);
      throw Exception("Either AUTH_TOKEN or AUTH_URL is not set in .env file");
      return "";
    }

    if ((_AUTH_TOKEN?.isNotEmpty ?? false) &&
        (_AUTH_URL?.isNotEmpty ?? false)) {
      showSnackBarMessage(
          message: "Please set only one environment variable",
          context: context);
      throw Exception("Either AUTH_TOKEN or AUTH_URL can be set in .env file");
      return "";
    }

    if (_AUTH_URL?.isNotEmpty ?? false) {
      final Uri getTokenUrl = Uri.parse('$_AUTH_URL/get-token');
      final http.Response tokenResponse = await http.get(getTokenUrl);
      _AUTH_TOKEN = json.decode(tokenResponse.body)['token'];
    }

    // log("Auth Token: $_AUTH_TOKEN");

    return _AUTH_TOKEN ?? "";
  }

  Future<void> createAndJoinMeeting(callType, displayName) async {
    // final String? _VIDEOSDK_API_ENDPOINT = dotenv.env['VIDEOSDK_API_ENDPOINT'];

    // final Uri getMeetingIdUrl = Uri.parse('$_VIDEOSDK_API_ENDPOINT/rooms');
    // final http.Response meetingIdResponse =
    //     await http.post(getMeetingIdUrl, headers: {
    //   "Authorization": _token,
    // });

    // _meetingID = json.decode(meetingIdResponse.body)['roomId'];

    // log("Meeting ID: $_meetingID");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingScreen(
          token: _token,
          meetingId: "wyea-c8vp-ivt6",
          displayName: displayName,
          micEnabled: isMicOn,
          camEnabled: isCameraOn,
        ),
      ),
    );
  }

  Future<void> joinMeeting(callType, displayName, meetingId) async {
    if (meetingId.isEmpty) {
      showSnackBarMessage(
          message: "Please enter Valid Meeting ID", context: context);
      return;
    }

    final String? _VIDEOSDK_API_ENDPOINT = dotenv.env['VIDEOSDK_API_ENDPOINT'];

    final Uri validateMeetingUrl =
        Uri.parse('$_VIDEOSDK_API_ENDPOINT/rooms/validate/$meetingId');
    final http.Response validateMeetingResponse =
        await http.post(validateMeetingUrl, headers: {
      "Authorization": _token,
    });

    if (validateMeetingResponse.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MeetingScreen(
            token: _token,
            meetingId: meetingId,
            displayName: displayName,
            micEnabled: isMicOn,
            camEnabled: isCameraOn,
          ),
        ),
      );
    } else {
      showSnackBarMessage(message: "Invalid Meeting ID", context: context);
    }
  }

  // @override
  // void dispose() {
  //   // Dispose Camera Controller
  //   cameraController?.dispose();
  //   super.dispose();
  // }
}
