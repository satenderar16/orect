
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/AlertDialog/exit_alert.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context,ref) {
    return const Scaffold(
      body: Center(child: Text('Statistics Page')),
    );
  }
}
