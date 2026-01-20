import 'package:flutter/material.dart';

/// Wrapper widget that unfocuses text fields when tapping outside
class UnfocusWrapper extends StatelessWidget {
  final Widget child;

  const UnfocusWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Unfocus when tapping outside of text fields
        FocusScope.of(context).unfocus();
      },
      child: child,
    );
  }
}
