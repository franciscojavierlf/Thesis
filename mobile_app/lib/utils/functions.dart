import 'package:flutter/material.dart';

/// Quickly pushes a view.
goto(BuildContext context, Widget view, {bool replace = false}) {
  if (replace)
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => view),
        (Route<dynamic> route) => false);
  else
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => view));
}
