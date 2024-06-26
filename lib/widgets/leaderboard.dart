import 'package:flutter/material.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/utils/size_config.dart';
import 'package:memory_game/widgets/player_widget.dart';

class Leaderboard extends StatefulWidget {
  final int score;
  const Leaderboard({super.key, required this.score});
  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  late List<PlayerWidget> _scores;
  late Player? _currentPlayer;
  late Player? _pb;
  late bool _isLoading;
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _isLoading = true;
    _pb = Database.playerBox?.get("personalBest");
    print(_pb);
    print(_pb?.score);
    _currentPlayer = Database.playerBox?.get("currentPlayer");
    _currentPlayer?.score = widget.score;
    _scores = [];
    if (_pb == null) {
      _pb = _currentPlayer;
      Database.playerBox?.put("personalBest", _currentPlayer!);
    }
    _getLeaderboard();
    super.initState();
  }

  void _getLeaderboard() {
    Database.firebase
        .collection("players")
        .orderBy("score", descending: true)
        .limit(10)
        .get()
        .then((event) => {
              for (var doc in event.docs)
                {
                  setState(() => _scores.add(PlayerWidget(
                      player: Player(
                          name: doc.data()["name"],
                          score: doc.data()["score"]))))
                }
            })
        .whenComplete(() {
      setState(() {
        _scores.add(PlayerWidget(
            player: _currentPlayer!,
            color: const Color.fromRGBO(255, 188, 152, 1)));
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/bg-1.png"), fit: BoxFit.cover)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 80,
                titleSpacing: 20,
                title: Image.asset(
                  "assets/logo-title.png",
                  width: 115,
                ),
                backgroundColor: Colors.transparent),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: SizedBox(
                child: Container(
                  margin:
                      EdgeInsets.only(top: SizeConfig.blockSizeHorizontal * 25),
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/leaderboard.png"))),
                  child: Stack(
                    children: [
                      (_isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.separated(
                              padding: EdgeInsets.fromLTRB(
                                  SizeConfig.blockSizeHorizontal * 16.25,
                                  SizeConfig.blockSizeVertical * 18.75,
                                  SizeConfig.blockSizeHorizontal * 17.5,
                                  0),
                              itemCount: _scores.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 3),
                              itemBuilder: (context, index) {
                                if (_scores[index].player.score! == 0) {
                                  return Container();
                                }

                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          index != 10
                                              ? _scores[index].player.name
                                              : "You",
                                          style: TextStyle(
                                            fontSize: index != 10 ? 18 : 20,
                                            fontFamily: 'MadimiOne',
                                            fontWeight: index != 10
                                                ? FontWeight.normal
                                                : FontWeight.bold,
                                            color: const Color.fromRGBO(
                                                36, 107, 34, 1),
                                          ),
                                        ),
                                        Text(
                                          _scores[index]
                                              .player
                                              .score
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: index != 10 ? 17 : 19,
                                            fontFamily: 'MadimiOne',
                                            fontWeight: index != 10
                                                ? FontWeight.normal
                                                : FontWeight.bold,
                                            color: const Color.fromRGBO(
                                                148, 126, 109, 1),
                                          ),
                                        )
                                      ],
                                    ),
                                    (index == 9 && widget.score == 0) ||
                                            index == 10
                                        ? Container(
                                            margin:
                                                const EdgeInsets.only(top: 20),
                                            decoration: const BoxDecoration(
                                                border: Border(
                                                    top: BorderSide(
                                                        width: 5.0,
                                                        color: Color.fromRGBO(
                                                            69, 141, 67, 1)))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: (Row(children: [
                                                const Text("Personal Best:",
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        fontFamily: "MadimiOne",
                                                        color: Color.fromRGBO(
                                                            69, 141, 67, 1))),
                                                const Spacer(),
                                                Text((_pb?.score!).toString(),
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontFamily: "MadimiOne",
                                                        color: Color.fromRGBO(
                                                            147, 123, 107, 1)))
                                              ])),
                                            ),
                                          )
                                        : const SizedBox()
                                  ],
                                );
                              },
                            )),
                      Positioned(
                        bottom: SizeConfig.blockSizeHorizontal + 40,
                        left: (SizeConfig.screenWidth / 2) - 80 * 0.75,
                        child: SizedBox(
                          height: 90,
                          width: 90,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 40,
                                fontFamily: 'MadimiOne',
                                color: Color.fromRGBO(36, 107, 34, 1),
                                shadows: [
                                  Shadow(
                                    // Adjust offsets and blurRadius for stroke thickness
                                    offset: Offset(3.0, 3.0),
                                    color: Color.fromRGBO(255, 220, 80,
                                        1), // Set your stroke color
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
