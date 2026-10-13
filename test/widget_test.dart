import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/widgets/status_chip.dart';
import 'package:taskflow/core/widgets/priority_chip.dart';
import 'package:taskflow/core/widgets/stat_card.dart';

void main() {
  group('TaskFlow Core Widgets Tests', () {
    testWidgets('StatusChip displays correct label for DONE', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(status: 'DONE'),
          ),
        ),
      );

      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('PriorityChip displays correct priority and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriorityChip(priority: 'HIGH'),
          ),
        ),
      );

      expect(find.text('HIGH'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_double_arrow_up_rounded), findsOneWidget);
    });

    testWidgets('StatCard renders title, value, and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: 'Total Projects',
              value: '12',
              icon: Icons.folder,
              accentColor: Colors.indigo,
              subtitle: 'Active workspaces',
            ),
          ),
        ),
      );

      expect(find.text('Total Projects'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Active workspaces'), findsOneWidget);
    });
  });
}
