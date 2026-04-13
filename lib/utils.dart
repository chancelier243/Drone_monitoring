import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'theme_provider.dart';

String formatNumber(BuildContext context, double value) {
  final decimals = Provider.of<ThemeProvider>(context, listen: false).decimalPlaces;
  return value.toStringAsFixed(decimals);
}

String formatNumberContext(BuildContext context, double value, {int? decimals}) {
  final places = decimals ?? Provider.of<ThemeProvider>(context, listen: false).decimalPlaces;
  return value.toStringAsFixed(places);
}
