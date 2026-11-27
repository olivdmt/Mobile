import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final output = Directory('output/evidencias/crud');
  await output.create(recursive: true);

  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('${output.path}/$name.png');
      await file.writeAsBytes(bytes, flush: true);
      return true;
    },
  );
}
