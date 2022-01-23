import 'package:flutter/material.dart';
import 'package:task_roaa/app_video_player.dart';
import 'package:task_roaa/constant.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _style = const TextStyle(fontWeight: FontWeight.bold, fontSize: 20);

  late AppVideoPlayer appVideoPlayer = AppVideoPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hello With This Task"),
      ),
      body: Center(
        child: ListView.separated(
          itemCount: listOfModel.length,
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 1,
            );
          },
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  userLayout(index),
                  buildVideo(index),
                  reactionLayout(context)
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  buildVideo(index) {
    return appVideoPlayer.buildVidePlayer(listOfModel[index]["url"] as String, (){});
  }

  userLayout(index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.close),
        Row(
          children: [
            Column(
              children: [
                Text(
                  listOfModel[index]["title"] as String,
                  style: _style,
                ),
                Text(
                  " 16 hours ",
                  style: _style,
                ),
              ],
            ),
            const CircleAvatar(
              child: FlutterLogo(),
              radius: 30,
            ),
          ],
        ),
      ],
    );
  }

  reactionLayout(context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        const Divider(
          thickness: 1,
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: Card(
            elevation: 0.1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "مشاركه",
                  style: _style,
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.grey,
                ),
                Text(
                  "تعليق",
                  style: _style,
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.grey,
                ),
                Text(
                  "اعجبني",
                  style: _style,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


}
