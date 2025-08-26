import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfirmationScreen extends StatefulWidget {
  static const route = '/done';
  const ConfirmationScreen({super.key});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    _playChime();
  }

  Future<void> _playChime() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {
      // ignore if not supported
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        (ModalRoute.of(context)?.settings.arguments ?? {}) as Map? ?? {};
    final first = (args['firstName'] ?? '').toString();
    final last = (args['lastName'] ?? '').toString();
    final name = ('$first $last').trim();
    final method = (args['method'] ?? 'method').toString();

    // Accept either amount (double) or amountCents (int)
    double amount = 0.0;
    if (args['amount'] is double) {
      amount = args['amount'] as double;
    } else if (args['amountCents'] is int) {
      amount = (args['amountCents'] as int) / 100.0;
    }

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated success icon (no external packages)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutBack,
                    builder: (context, v, child) => Opacity(
                      opacity: (((v - 0.8) / 0.2)).clamp(0.0, 1.0) as double,
                      child: Transform.scale(scale: v, child: child),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 112,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Payment Captured',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),

                  // Subtle celebratory accent
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    builder: (context, v, child) => Opacity(
                      opacity: (v).clamp(0.0, 1.0) as double,
                      child: child,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.auto_awesome, size: 16, color: Colors.amber),
                        SizedBox(width: 6),
                        Icon(Icons.celebration_outlined,
                            size: 16, color: Colors.purple),
                        SizedBox(width: 6),
                        Icon(Icons.auto_awesome, size: 16, color: Colors.teal),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: scheme.onSurfaceVariant),
                    child: Text(
                      [
                        if (name.isNotEmpty) name,
                        method.isNotEmpty ? method.toUpperCase() : '',
                        'R ${amount.toStringAsFixed(2)}',
                      ].where((s) => s.isNotEmpty).join(' • '),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: const [
                      _MetaChip(
                          icon: Icons.receipt_long_outlined,
                          label: 'Receipt sent'),
                      _MetaChip(
                          icon: Icons.lock_clock_outlined,
                          label: 'Audit logged'),
                      _MetaChip(
                          icon: Icons.sms_outlined, label: 'Admin notified'),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                          context, '/welcome', (route) => false),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Container(
                          width: 180,
                          height: 180,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.home_rounded,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(height: 12),
                              const Text(
                                'Back to Welcome',
                                style: TextStyle(fontWeight: FontWeight.w800),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(icon, size: 18, color: scheme.primary),
      label: Text(label),
    );
  }
}
