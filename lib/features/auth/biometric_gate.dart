import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/biometric_service.dart';

/// Wraps a child widget. If biometric unlock is enabled, prompts on first
/// build; only renders the child after a successful auth. If the user cancels,
/// they get a "Try again" button. Falls open if biometrics are unsupported.
class BiometricGate extends ConsumerStatefulWidget {
  const BiometricGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends ConsumerState<BiometricGate> {
  bool _checked = false;
  bool _passed = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_check);
  }

  Future<void> _check() async {
    final svc = ref.read(biometricServiceProvider);
    if (!await svc.isEnabled() || !await svc.supported) {
      setState(() {
        _checked = true;
        _passed = true;
      });
      return;
    }
    final ok = await svc.authenticate();
    if (mounted) {
      setState(() {
        _checked = true;
        _passed = ok;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checked && _passed) return widget.child;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fingerprint, size: 64, color: Colors.black54),
              const SizedBox(height: 16),
              Text(
                _checked ? 'Authentication required' : 'Authenticating…',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              if (_checked)
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _checked = false;
                      _passed = false;
                    });
                    _check();
                  },
                  child: const Text('Try again'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
