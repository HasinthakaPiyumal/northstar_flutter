import 'package:flutter/material.dart';

class Colors {

  Color _deepYellow = Color(0xFFFFA335);
  Color _deepGrey = Color(0xFF313131);
  Color _darkGrey = Color(0xFF434343);

  Color _lightBlack = Color(0xFF161616);
  Color _lightWhite = Color(0xFFF2F2F2);

  Color get selectedCardBG => Color(0xFFD8D8D8);
  Color get lightCardBG => Color(0xFFE5E5E5);

  Color deepYellow(double opacity) {
    return this._deepYellow.withOpacity(opacity);
  }

  Color darkGrey(double opacity) {
    return this._darkGrey.withOpacity(opacity);
  }

  Color deepGrey(double opacity) {
    return this._deepGrey.withOpacity(opacity);
  }

  Color lightBlack(double opacity){
    return this._lightBlack.withOpacity(opacity);
  }

  Color lightWhite(double opacity){
    return this._lightWhite.withOpacity(opacity);
  }

}