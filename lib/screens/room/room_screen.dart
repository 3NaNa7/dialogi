// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, no_leading_underscores_for_local_identifiers

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/users_mute_list.dart';
import 'widgets/user_profile.dart';
import '../../core/data.dart';
import '../../core/settings.dart';
import '../../models/models.dart';
import '../../utils/app_color.dart';
import '../../widgets/rounded_button.dart';
import '../../widgets/rounded_image.dart';

/// Detail screen of selected room
/// Initialize Agora SDK

class RoomScreen extends StatefulWidget {
  final Room room;
  ClientRoleType role;
  final dynamic docId;
  final dynamic profileData;

  RoomScreen({
    Key key,
    this.room,
    this.role,
    this.docId,
    this.profileData,
  }) : super(key: key);

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final List _users = [];
  String name;
  List<String> userMuteList = [];
  RtcEngine _engine;
  final collection = FirebaseFirestore.instance.collection('rooms');

  /// Initialize agora engine
  Future<void> _initAgoraRtcEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: APP_ID,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    await _engine.enableAudio();
    await _engine.setClientRole(role: widget.role);
  }

  /// Add Agora event handlers
  void _addAgoraEventHandlers() {
    _engine.registerEventHandler(RtcEngineEventHandler(
      onError: (ErrorCodeType code, err) async {
        /* setState(() {
          if (kDebugMode) {
            print('$logString onError: $code $err $logString');
          }
        }); */
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        /*  setState(() {
          if (kDebugMode) {
            print('$logString onLeaveChannel $logString');
          }
          _users.clear();
        }); */
      },
      onUserJoined: (RtcConnection connection, uid, elapsed) {
        /* if (kDebugMode) {
          print('$logString userJoined: $uid $logString');
        }
        setState(() {
          _users.add(uid);
        }); */
      },
    ));
  }

  /// Create Agora SDK instance and initialize
  Future<void> initialize() async {
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.joinChannel(
        token: Token,
        channelId: channelName,
        uid: 0,
        options: ChannelMediaOptions(
            autoSubscribeAudio: true,
            channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
            clientRoleType: ClientRoleType.clientRoleBroadcaster));
  }

  @override
  void initState() {
    super.initState();
    // Initialize Agora SDK
    initialize();
  }

  @override
  void dispose() {
    // Clear users
    _users.clear();
    // Destroy sdk
    _engine.muteAllRemoteAudioStreams(true);
    _engine.muteLocalAudioStream(true);
    _engine.stopAudioFrameDump(
        channelId: channelName, userId: Random().nextInt(100), location: null);
    _engine.disableAudio();
    _engine.stopAllEffects();
    _engine.leaveChannel();
    _engine.release();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: IconButton(
                iconSize: 30,
                icon: Icon(Icons.keyboard_arrow_down),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              flex: 2,
              child: const Text(
                'Inside Room',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: FutureBuilder(
                    future: fetchUser(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.connectionState == ConnectionState.done) {
                        final profile = User.fromJson(snapshot.data);
                        name = profile.name;
                        return GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamed('/profile', arguments: profile),
                          child: Column(
                            children: [
                              RoundedImage(
                                path: profile.profileImage,
                                width: 40,
                                height: 40,
                              ),
                              Text(
                                profile.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),
              ),
            ),
          ],
        ),
      ),
      body: body(),
    );
  }

  Widget body() {
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
      child: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80, top: 20),
          child: Column(
            children: [
              title(widget.room.title),
              SizedBox(height: 20),
              speakers(
                widget.room.users.sublist(0, widget.room.speakerCount),
              ),
              others(
                widget.room.users.sublist(widget.room.speakerCount),
              ),
            ],
          ),
        ),
        Align(alignment: Alignment.bottomCenter, child: bottom(context)),
      ]),
    );
  }

  Widget title(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        /* IconButton(
          onPressed: () {},
          iconSize: 30,
          icon: Icon(Icons.more_horiz),
        ), */
      ],
    );
  }

  Widget speakers(List<User> users) {
    return GridView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: users.length,
      itemBuilder: (gc, index) {
        return UserProfile(
          user: users[index],
          isModerator: index == 0,
          isMute: false,
          size: 50,
        );
      },
    );
  }

  Widget others(List<User> users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Others in the room',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
          itemCount: users.length,
          itemBuilder: (gc, index) {
            userMuteList.add(users[index].name);
            return Consumer<UsersMuteList>(
              builder: (_, __, ___) => UserProfile(
                user: users[index],
                size: 40,
                isMute: userMuteList.contains(users[index].name),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget bottom(BuildContext context) {
    final userMuteListProvider =
        Provider.of<UsersMuteList>(context, listen: false);
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          RoundedButton(
            onPressed: () {
              collection.doc(widget.docId).update({
                'users': FieldValue.arrayRemove([widget.profileData])
              });
              _engine.muteAllRemoteAudioStreams(true);
              _engine.muteLocalAudioStream(true);
              _engine.stopAudioFrameDump(
                  channelId: channelName, userId: 0, location: null);
              _engine.leaveChannel();
              _engine.disableAudio();
              _engine.stopAllEffects();
              _engine.release();
              Navigator.pop(context);
            },
            color: AppColor.LightGrey,
            child: Text(
              '✌️ Exit Room',
              style: TextStyle(
                  color: AppColor.AccentRed,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Spacer(),
          RoundedButton(
            onPressed: () async {
              if (kDebugMode) {
                print(userMuteList);
              }
              if (userMuteList.contains(name)) {
                userMuteList.remove(name);
                userMuteListProvider.userAdded(false);
              } else {
                userMuteList.add(name);
                userMuteListProvider.userAdded(true);
              }

              widget.role = ClientRoleType.clientRoleBroadcaster;
              await _engine.setClientRole(role: widget.role);
            },
            color: AppColor.LightGrey,
            child: Consumer<UsersMuteList>(
              builder: (_, _userMuteList, __) => Text(
                _userMuteList.isUserAdded == true ? '🎤 Unmute' : '🔇 Mute',
                style: TextStyle(
                    color: Color.fromARGB(255, 137, 218, 100),
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
