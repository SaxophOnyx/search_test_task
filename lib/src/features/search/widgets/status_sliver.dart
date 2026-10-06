import 'package:flutter/material.dart';

class StatusSliver extends StatelessWidget {
  final String? message;
  final VoidCallback? onPressed;

  const StatusSliver.loading({super.key}) : message = null, onPressed = null;

  const StatusSliver.message({
    super.key,
    required String this.message,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final String? message = this.message;
    final VoidCallback? onPressed = this.onPressed;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: message == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: .min,
                  children: <Widget>[
                    Text(message, textAlign: .center),
                    if (onPressed != null)
                      TextButton(
                        onPressed: onPressed,
                        child: const Text('Retry'),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
