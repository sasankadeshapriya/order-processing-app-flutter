import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class AleartBox {
  static Future<dynamic> showAleart(BuildContext context, DialogType dialogType,
      String title, String desc) async {
    return AwesomeDialog(
      context: context,
      animType: AnimType.scale,
      dialogType: dialogType,
      title: title,
      desc: desc,
      btnOkOnPress: () {},
    ).show();
  }
}
