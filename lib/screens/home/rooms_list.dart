// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/home_bottom_sheet.dart';
import 'widgets/room_card.dart';
import '../../widgets/rounded_button.dart';
import '../room/room_screen.dart';
import '../../models/models.dart' as models;
import '../../core/data.dart';
import '../../providers/users_mute_list.dart';

/// Fetch Rooms list from `Firestore`
/// Use `pull_to_refresh` plugin, which provides pull-up load and pull-down refresh for room list

class RoomsList extends StatefulWidget {
  @override
  State<RoomsList> createState() => _RoomsListState();
}

class _RoomsListState extends State<RoomsList> {
  final customRoomCollection = FirebaseFirestore.instance.collection('rooms');
  final defaultRoomCollection =
      FirebaseFirestore.instance.collection('defaultRooms');
  List<DocumentSnapshot> roomsDocs;
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool showDefaultRooms = true;
  bool showCustomRooms = false;

  Future<void> fetchRoomsDocs() async {
    QuerySnapshot querySnapshot = await defaultRoomCollection.get();
    roomsDocs = querySnapshot.docs;
  }

  Widget roomCard(models.Room room, BuildContext context, String id,
      String title, String roomType) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        child: RoomCard(room: room, title: title),
      ),
      onTap: () async {
        // Add new user to room
        final profileData = await fetchUser();
        if (roomType == 'custom') {
          await customRoomCollection.doc(id).update({
            'users': FieldValue.arrayUnion([profileData]),
          });
        }
        if (roomType == 'default') {
          await defaultRoomCollection.doc(id).update({
            'users': FieldValue.arrayUnion([profileData]),
          });
        }

        // Launch user microphone permission
        await Permission.microphone.request();
        // Open BottomSheet dialog
        if (context.mounted) {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return StreamBuilder<QuerySnapshot>(
                  stream: roomType == 'custom'
                      ? customRoomCollection.snapshots()
                      : defaultRoomCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.none ||
                        snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData) {
                      final document = snapshot.data.docs
                          .firstWhere((element) => element.id == id);
                      return ChangeNotifierProvider(
                        create: (context) => UsersMuteList(),
                        child: RoomScreen(
                          room: models.Room.fromJson(document.data()), //room,
                          // Pass user role
                          role: roomType == 'custom'
                              ? ClientRoleType.clientRoleAudience
                              : ClientRoleType.clientRoleBroadcaster,
                          docId: id,
                          profileData: profileData,
                        ),
                      );
                    }
                    return Center(child: Text('OOPS! Something went wrong!'));
                  });
            },
          );
        }
      },
    );
  }

  Widget startRoomButton(BuildContext context) {
    return FutureBuilder(
        future: fetchUser(),
        builder: (context, snapshot) {
          return snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done
              ? RoundedButton(
                  onPressed: () {
                    setState(() {
                      showDefaultRooms = false;
                    });
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      builder: (context) {
                        return Wrap(
                          children: [
                            HomeBottomSheet(
                              onButtonTap: () async {
                                // Add new data to Firestore collection
                                await customRoomCollection.add(
                                  {
                                    'title':
                                        '${models.User.fromJson(snapshot.data).name}\'s Room',
                                    'users': [snapshot.data],
                                    'speakerCount': 1
                                  },
                                );
                                // Launch user microphone permission
                                await Permission.microphone.request();
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  // Open BottomSheet dialog
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) {
                                      return ChangeNotifierProvider(
                                        create: (context) => UsersMuteList(),
                                        child: RoomScreen(
                                          room: models.Room(
                                            title:
                                                '${models.User.fromJson(snapshot.data).name}\'s Room',
                                            users: [
                                              models.User.fromJson(
                                                  snapshot.data)
                                            ],
                                            speakerCount: 1,
                                          ),
                                          // Pass user role
                                          role: ClientRoleType
                                              .clientRoleBroadcaster,
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  color: Color.fromARGB(255, 197, 130, 6),
                  child: Text('+ Create a room'))
              : CircularProgressIndicator();
        });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 75,
      child: Stack(children: [
        SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder<Object>(
                  future: fetchRoomsDocs(),
                  builder: (context, snapshot) {
                    return snapshot.connectionState == ConnectionState.waiting
                        ? Center(child: CircularProgressIndicator())
                        : ExpansionTile(
                            initiallyExpanded: showDefaultRooms,
                            onExpansionChanged: (expanded) {
                              setState(() {
                                showDefaultRooms = expanded;
                                showCustomRooms = !expanded;
                              });
                            },
                            title: Text('Default Rooms'),
                            children:
                                roomsDocs.map((DocumentSnapshot document) {
                              Map<String, dynamic> data =
                                  document.data() as Map<String, dynamic>;
                              return roomCard(
                                  models.Room.fromJson(document.data()),
                                  context,
                                  document.id,
                                  data['title'],
                                  'default');
                            }).toList());
                  }),
              StreamBuilder<QuerySnapshot>(
                stream: customRoomCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.none ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData) {
                    return ExpansionTile(
                      initiallyExpanded: showCustomRooms,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          showCustomRooms = expanded;
                          showDefaultRooms = !expanded;
                        });
                      },
                      title: Text('Custom Rooms'),
                      children:
                          snapshot.data.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        return Dismissible(
                          key: Key(document.id),
                          direction: DismissDirection.startToEnd,
                          background: Container(
                            color: Colors.red,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Icon(
                                  Icons.delete,
                                  size: 45,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          onDismissed: (direction) {
                            customRoomCollection.doc(document.id).delete();
                          },
                          child: roomCard(
                            models.Room.fromJson(document.data()),
                            context,
                            document.id,
                            data['title'],
                            'custom',
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return Center(child: Text('OOPS! Something went wrong!'));
                },
              ),
            ],
          ),
        ),
        Positioned(bottom: 0, right: 10, child: startRoomButton(context))
      ]),
    );
  }
}
