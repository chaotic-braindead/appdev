import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/widgets/game.dart';
import 'package:memory_game/widgets/home_page.dart';
import 'package:memory_game/widgets/player_widget.dart';

class Leaderboard extends StatefulWidget {
  int score;
  Leaderboard({super.key, required this.score});
  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  late List<PlayerWidget> scores;
  late Player? currentPlayer;
  @override
  void setState(fn){
    if(mounted){
      super.setState(fn);
    }
  }

  void initState(){
    super.initState();
    setState(() { 
      currentPlayer = Database.playerBox?.get("currentPlayer", defaultValue: Player(name: "Guest")); 
      currentPlayer?.score = widget.score;
    });
    scores = [];
    _addScore();
  }

  void _addScore(){
    if(currentPlayer?.name == "Guest"){
      _getLeaderboard();
      //setState(() => scores.add(PlayerWidget(player: currentPlayer!, color: Colors.blue)));
      return;
    }
    Database.firebase.collection("players").doc(currentPlayer?.name).get()
      .then((value) {
        if(value.exists){
          if((currentPlayer?.score!)! > value.data()?["score"]){
            Database.firebase.collection("players").doc(currentPlayer?.name).update(currentPlayer!.toJson());
          }
        }
        else{
           Database.firebase.collection("players").doc(currentPlayer?.name).set(currentPlayer!.toJson());
        }
      }).whenComplete(() => _getLeaderboard());
    // Database.instance.collection("players").doc(widget.player.name).set(widget.player.toJson());
    
  }
  void _getLeaderboard(){
    Database.firebase.collection("players").orderBy("score", descending: true).limit(10).get().then((event) => {
      for(var doc in event.docs){
        setState(() => scores.add(PlayerWidget(player: Player(name: doc.data()["name"], score: doc.data()["score"]))))
      }
    }).whenComplete((){ 
      for(var wid in scores){
        if(wid.player == currentPlayer!){
          wid.color = Colors.blue;
          return;
        }
      }
      setState(() => scores.add(PlayerWidget(player: currentPlayer!, color: Colors.blue))); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("High Scores")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [Column(children: scores),
              const Spacer(), 
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Game())), 
                      child: const Text("Play Again")),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage())),
                      child: const Text("Back to Home"),
                    )
                ]
              )
            ]
          )
        ),
    );
  }
  
}