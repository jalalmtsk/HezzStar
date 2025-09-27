import 'package:flutter/material.dart';
import 'package:hezzstar/IndexPages/Collection/Tools/TableGridWidget.dart';

import '../Tools/CurrencyTypeEnum.dart';

class TableSkin extends StatelessWidget {
  const TableSkin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TableSkinGridWidget(
        tableSkins: [
          {"image": "assets/images/Skins/TableSkins/table1.jpg", 'currency': CurrencyType.gold, "cost": 50},
          {"image": "assets/images/Skins/TableSkins/table2.jpg", 'currency': CurrencyType.gems, "cost": 100},

        ],
      ),
    );
  }
}
