import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String? error;
  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(error ?? 'Some unexpected error occurred'));
  }
}
