import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {

  final Color color;

  const Loading({Key? key, required this.color }) : super(key: key);


  @override
  Widget build(BuildContext context) {

    //double _s = MediaQuery.of(context).size.width / 3;

    return Container(
      color: Colors.grey[900],
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SpinKitDualRing(
            color: Colors.grey[600]!,
            size: MediaQuery.of(context).size.width / 3,//160
          ),
          SpinKitCubeGrid(
            color: color,
            size: MediaQuery.of(context).size.width / 3 / 1.7778,
          ),
        ],
      ),
    );
  }
}