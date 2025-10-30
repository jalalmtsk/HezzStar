import 'package:flutter/material.dart';
import 'package:hezzstar/IndexPages/Collection/Tools/TableGridWidget.dart';

import '../../../main.dart';
import '../Tools/CurrencyTypeEnum.dart';

class TableSkin extends StatelessWidget {
  const TableSkin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Text(
                  tr(context).tableSkins,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Minimal underline
                Container(
                  height: 3,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.amberAccent,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amberAccent.withOpacity(0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TableSkinGridWidget(
              tableSkins: [
                {"image": "assets/images/Skins/TableSkins/table1.jpg", 'currency': CurrencyType.gold, "cost": 0},
                {"image": "assets/images/Skins/TableSkins/table2.jpg", 'currency': CurrencyType.gems, "cost": 2000},
                {"image": "assets/images/Skins/TableSkins/table3.png", 'currency': CurrencyType.gems, "cost": 2500},
                {"image": "assets/images/Skins/TableSkins/table4.png", 'currency': CurrencyType.gems, "cost": 2500},
                {"image": "assets/images/Skins/TableSkins/table5.png", 'currency': CurrencyType.gold, "cost": 300000000},

              ],
            ),
          ),
        ],
      ),
    );
  }
}
