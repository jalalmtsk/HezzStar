import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../ExperieneManager.dart';

class TableBackground extends StatelessWidget {
  const TableBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final xpManager = Provider.of<ExperienceManager>(context, listen: false);

    return Stack(
      children: [
        // Background Image
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: xpManager.selectedTableSkin != null
                  ? AssetImage(xpManager.selectedTableSkin!)
                  : const AssetImage("assets/images/Skins/TableSkins/table1.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Gradient Overlay (darkens edges, focus on center)
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                Colors.black.withOpacity(0.2), // center focus
                Colors.black.withOpacity(0.7), // edges darker
              ],
              stops: const [0.6, 1],
            ),
          ),
        ),

        // Extra Top/Bottom Overlay for cinematic effect
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black54,
                Colors.transparent,
                Colors.transparent,
                Colors.black54,
              ],
              stops: [0.0, 0.25, 0.75, 1.0],
            ),
          ),
        ),

        // Subtle Blur Overlay (gives depth)
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 1.5),
          child: Container(color: Colors.black.withOpacity(0.1)),
        ),
      ],
    );
  }
}
