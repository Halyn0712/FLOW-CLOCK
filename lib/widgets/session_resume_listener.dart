import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

/// 监听 App 回到前台，对齐计时会话与预约闹钟
class SessionResumeListener extends ConsumerStatefulWidget {
  const SessionResumeListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SessionResumeListener> createState() =>
      _SessionResumeListenerState();
}

class _SessionResumeListenerState extends ConsumerState<SessionResumeListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(sessionProvider.notifier).reconcileOnResume();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
