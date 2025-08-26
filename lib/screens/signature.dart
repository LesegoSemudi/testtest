import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../widgets/ui.dart';
import 'confirmation.dart';

class SignatureScreen extends StatefulWidget {
  static const route = '/sign';
  const SignatureScreen({super.key});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen>
    with TickerProviderStateMixin {
  late final SignatureController controller;
  late final AnimationController _intro;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool get _canApprove => !(controller.isEmpty);

  @override
  void initState() {
    super.initState();
    controller = SignatureController(penStrokeWidth: 3, penColor: Colors.black)
      ..addListener(() => setState(() {}));

    _intro = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 520));
    _fade = CurvedAnimation(parent: _intro, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, .04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic));
    WidgetsBinding.instance.addPostFrameCallback((_) => _intro.forward());
  }

  @override
  void dispose() {
    controller.dispose();
    _intro.dispose();
    super.dispose();
  }

  void _approve(Map args) {
    if (!_canApprove) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please sign in the box above before approving.')),
      );
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      ConfirmationScreen.route,
      (r) => r.isFirst,
      arguments: args,
    );
  }

  Widget _infoCard(
      {required IconData icon, required String title, required String body}) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      builder: (context, v, child) {
        final vc = (v).clamp(0.0, 1.0) as double;
        return Opacity(
          opacity: vc,
          child: Transform.translate(
            offset: Offset(0, (1 - vc) * 12),
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Icon(icon, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(body),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments ?? {}) as Map;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('e‑Signature')),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
          child: MaxWidth(
        maxWidth: 880,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),

                  // Step header with progress and Lottie confetti
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Step 3 of 3 • Sign to confirm',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w800)),
                                const SizedBox(height: 8),
                                const LinearProgressIndicator(value: 1.0),
                                const SizedBox(height: 4),
                                Text(
                                    'Please sign inside the box. You can clear and sign again if needed.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: scheme.onSurfaceVariant)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  _infoCard(
                    icon: Icons.draw_outlined,
                    title: 'How to sign',
                    body:
                        'Use your finger or a stylus to draw your signature. Keep your signature within the box for best quality.',
                  ),
                  const SizedBox(height: 8),
                  _infoCard(
                    icon: Icons.verified_user_outlined,
                    title: 'Why this matters',
                    body:
                        'Your signature confirms the payment details are correct. A receipt will be sent and your transaction will be recorded for your protection.',
                  ),

                  const SizedBox(height: 12),
                  // Signature pad with a subtle dotted background hint
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Hint when empty
                        if (controller.isEmpty)
                          Center(
                            child: Opacity(
                              opacity: 0.45,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.gesture_rounded),
                                  SizedBox(width: 8),
                                  Text('Sign here'),
                                ],
                              ),
                            ),
                          ),
                        Signature(
                            controller: controller,
                            backgroundColor: Colors.transparent),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: controller.clear,
                        icon: const Icon(Icons.undo),
                        label: const Text('Clear'),
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _canApprove
                            ? FilledButton.icon(
                                key: const ValueKey('approve'),
                                onPressed: () => _approve(args),
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Approve Payment'),
                              )
                            : FilledButton.icon(
                                key: const ValueKey('approve-disabled'),
                                onPressed: null,
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Approve Payment'),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'By approving, you confirm the payment details are correct and consent to digital record‑keeping.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      )),
    );
  }
}
