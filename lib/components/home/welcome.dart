import 'package:flutter/material.dart';
import 'package:saber/i18n/strings.g.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return Center(
      child: Padding(
        padding: const .all(8),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Image.asset(
              'assets/icon/icon.png',
              width: 200,
              height: 200,
              excludeFromSemantics: true,
            ),
            const SizedBox(height: 32),
            Text(t.home.welcome, style: textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(t.home.createNewNote, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
