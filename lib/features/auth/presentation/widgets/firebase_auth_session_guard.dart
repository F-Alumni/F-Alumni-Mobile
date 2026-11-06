import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alumni_connect/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:alumni_connect/features/lab3/data/services/firebase_auth_service.dart';

class FirebaseAuthSessionGuard extends StatefulWidget {
  const FirebaseAuthSessionGuard({
    required this.service,
    required this.child,
    super.key,
  });

  final FirebaseAuthService? service;
  final Widget child;

  @override
  State<FirebaseAuthSessionGuard> createState() =>
      _FirebaseAuthSessionGuardState();
}

class _FirebaseAuthSessionGuardState extends State<FirebaseAuthSessionGuard> {
  StreamSubscription<bool>? _subscription;
  bool _hadFirebaseSession = false;

  @override
  void initState() {
    super.initState();
    _subscription = widget.service?.signedInChanges.listen(_onAuthChanged);
  }

  void _onAuthChanged(bool isSignedIn) {
    if (isSignedIn) {
      _hadFirebaseSession = true;
      return;
    }
    if (!_hadFirebaseSession) return;

    _hadFirebaseSession = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authCubit = context.read<AuthCubit>();
      if (authCubit.state is AuthAuthenticated) {
        unawaited(_clearAppSession(authCubit));
      }
    });
  }

  Future<void> _clearAppSession(AuthCubit authCubit) async {
    try {
      await authCubit.logout();
    } on Object {
      // AuthCubit emits the unauthenticated state in its logout finally block.
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
