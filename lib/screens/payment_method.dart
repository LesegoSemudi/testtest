import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/ui.dart';
import 'cash.dart';
import 'card.dart';

class PaymentMethodScreen extends StatefulWidget {
  static const route = '/method';
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen>
    with TickerProviderStateMixin {
  bool _shown = false;
  late final AnimationController _intro;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _fade = CurvedAnimation(parent: _intro, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, .04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Show once after first frame
    if (!_shown) {
      _shown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _intro.forward();
        _showSuccessDialog();
      });
    }
  }

  Future<void> _showSuccessDialog() async {
    // Light notification sound (no extra packages)
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}

    if (!mounted) return;

    await showGeneralDialog(
      context: context,
      barrierLabel: 'Success',
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, a1, a2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (ctx, anim, _, __) {
        final scale = Tween(begin: 0.85, end: 1.0).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        );
        final opacity = CurvedAnimation(parent: anim, curve: Curves.easeIn);
        return Opacity(
          opacity: opacity.value,
          child: Transform.scale(
            scale: scale.value,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated check + smiley row
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 520),
                        curve: Curves.easeOutBack,
                        builder: (context, v, child) => Transform.scale(
                          scale: .8 + .2 * v,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.verified_rounded,
                                  size: 88, color: Colors.green),
                              SizedBox(width: 12),
                              Icon(Icons.sentiment_satisfied_alt_rounded,
                                  size: 76, color: Colors.amber),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Details collected successfully',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'You can now choose a payment method.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.0, vertical: 10),
                          child: Text('Continue'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoCard(
      {required IconData icon, required String title, required String body}) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Icon(icon, color: scheme.onPrimaryContainer)),
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
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments ?? {}) as Map;
    final firstName = (args['firstName'] ?? '').toString();
    final lastName = (args['lastName'] ?? '').toString();
    final policy = (args['policy'] ?? '').toString();
    final name =
        [firstName, lastName].where((s) => s.trim().isNotEmpty).join(' ');

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Payment Method')),
      body: SafeArea(
        child: MaxWidth(
          maxWidth: 840,
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Header with context
                    Row(
                      children: [
                        const Icon(Icons.attach_money_rounded),
                        const SizedBox(width: 8),
                        Text('Select how you want to pay',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name.isNotEmpty && policy.isNotEmpty
                          ? 'For $name • Policy $policy'
                          : name.isNotEmpty
                              ? 'For $name'
                              : policy.isNotEmpty
                                  ? 'Policy $policy'
                                  : 'Proceed to capture payment',
                    ),
                    const SizedBox(height: 16),

                    // Animated informative boxes
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutBack,
                      builder: (context, v, child) {
                        final vc = (v).clamp(0.0, 1.0) as double;
                        return Opacity(
                          opacity: vc,
                          child: Transform.translate(
                              offset: Offset(0, (1 - vc) * 12), child: child),
                        );
                      },
                      child: _infoCard(
                        icon: Icons.lock_outline,
                        title: 'Secure & verified',
                        body:
                            'Cash and card payments are recorded against your policy with an audit trail. Notifications are sent to Admin instantly.',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutBack,
                      builder: (context, v, child) {
                        final vc = (v).clamp(0.0, 1.0) as double;
                        return Opacity(
                          opacity: vc,
                          child: Transform.translate(
                              offset: Offset(0, (1 - vc) * 12), child: child),
                        );
                      },
                      child: _infoCard(
                        icon: Icons.receipt_long_outlined,
                        title: 'Your receipt',
                        body:
                            'You will sign digitally, and a receipt can be sent via SMS/Email/WhatsApp (in production).',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutBack,
                      builder: (context, v, child) {
                        final vc = (v).clamp(0.0, 1.0) as double;
                        return Opacity(
                          opacity: vc,
                          child: Transform.translate(
                              offset: Offset(0, (1 - vc) * 12), child: child),
                        );
                      },
                      child: _infoCard(
                        icon: Icons.help_center_outlined,
                        title: 'Need help?',
                        body:
                            'Ask our clerk to assist you if you are unsure which method to use or if your card supports tap/swipe.',
                      ),
                    ),

                    // Summary chips (policy / name / amount)
                    const SizedBox(height: 12),
                    Builder(builder: (context) {
                      final scheme = Theme.of(context).colorScheme;
                      final int? amountCents = args['amountCents'] is int
                          ? args['amountCents'] as int
                          : null;
                      return Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (policy.isNotEmpty)
                            Chip(
                              avatar: Icon(Icons.confirmation_number_outlined,
                                  size: 18, color: scheme.primary),
                              label: Text('Policy: $policy'),
                            ),
                          if (name.isNotEmpty)
                            Chip(
                              avatar: Icon(Icons.person_outline,
                                  size: 18, color: scheme.primary),
                              label: Text(name),
                            ),
                          if (amountCents != null)
                            Chip(
                              avatar: Icon(Icons.attach_money_rounded,
                                  size: 18, color: scheme.primary),
                              label: Text(
                                  'Amount: R ${((amountCents) / 100).toStringAsFixed(2)}'),
                            ),
                        ],
                      );
                    }),
                    const SizedBox(height: 12),

                    // Payment option blocks (big squares) — responsive with auto-wrap
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final maxW = constraints.maxWidth;
                        final tileWidth = maxW > 720
                            ? (maxW - 16) / 2
                            : maxW; // 2 across when wide
                        return Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: tileWidth,
                              child: _PaymentTile(
                                index: 0,
                                icon: Icons.money_rounded,
                                label: 'Pay with Cash',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  CashScreen.route,
                                  arguments: args,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: tileWidth,
                              child: _PaymentTile(
                                index: 1,
                                icon: Icons.credit_card_rounded,
                                label: 'Pay with Card (Demo)',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  CardScreen.route,
                                  arguments: args,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 8),
                    // Footer hint
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.timer_outlined, size: 18),
                        SizedBox(width: 6),
                        Text('Takes less than a minute'),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int index;
  const _PaymentTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.index,
  });

  @override
  State<_PaymentTile> createState() => _PaymentTileState();
}

class _PaymentTileState extends State<_PaymentTile>
    with SingleTickerProviderStateMixin {
  bool _hovering = false;
  bool _pressed = false;

  late final AnimationController _in;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    // Stagger: 0 + index * 80ms
    final delay = Duration(milliseconds: 120 + widget.index * 80);
    _in = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _in, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _in, curve: Curves.easeOutCubic));
    // Start animation after delay
    Future.delayed(delay, () {
      if (mounted) _in.forward();
    });
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await HapticFeedback.selectionClick();
    widget.onTap();
  }

  void _handleActionIntent() {
    _handleTap();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final scale = _pressed ? 0.98 : (_hovering ? 1.02 : 1.0);
    final elevation = _pressed ? 2.0 : (_hovering ? 6.0 : 0.0);

    return FocusableActionDetector(
      autofocus: false,
      enabled: true,
      onShowHoverHighlight: (v) => setState(() => _hovering = v),
      onShowFocusHighlight: (_) {},
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) => _handleActionIntent(),
        ),
      },
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _pressed = true),
              onTapCancel: () => setState(() => _pressed = false),
              onTapUp: (_) => setState(() => _pressed = false),
              onTap: _handleTap,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                scale: scale,
                child: Card(
                  elevation: elevation,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    height: 180,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: _hovering
                          ? LinearGradient(
                              colors: [
                                scheme.primaryContainer.withOpacity(.55),
                                scheme.secondaryContainer.withOpacity(.45),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(widget.icon, size: 56, color: scheme.primary),
                          const SizedBox(height: 12),
                          Text(
                            widget.label,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
