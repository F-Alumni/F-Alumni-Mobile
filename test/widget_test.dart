import 'package:flutter/material.dart' show Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:alumni_connect/main.dart';

void main() {
  testWidgets('App smoke test on a phone-sized viewport', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FptAlumniConnectApp());
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
