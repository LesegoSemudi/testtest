import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/ui.dart';
import 'signature.dart';

class CardScreen extends StatefulWidget {
  static const route = '/card';
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> with TickerProviderStateMixin {
  final _amount = TextEditingController();
  bool _captured = false;
  String _method = '';
  bool _clientConfirmed = false;

  late final AnimationController _intro;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _fade = CurvedAnimation(parent: _intro, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, .04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic));
    WidgetsBinding.instance.addPostFrameCallback((_) => _intro.forward());
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _intro.dispose();
    _amount.dispose();
    super.dispose();
  }

  double get _amountValue {
    final raw = _amount.text.replaceAll(',', '.');
    return double.tryParse(raw) ?? 0;
  }

  bool get _isValid =>
      _amountValue > 0 && _captured && _clientConfirmed && _method.isNotEmpty;

  void _simulateCapture(String method) {
    HapticFeedback.selectionClick();
    setState(() {
      _method = method;
      _captured = true;
      _clientConfirmed =
          true; // pre-check for demo; the checkbox remains visible to toggle
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mock: ${_methodLabel(method)} payment captured')),
    );
  }

  String _methodLabel(String m) {
    switch (m) {
      case 'nfc':
        return 'Tap to Pay';
      case 'chip':
        return 'Insert (Chip & PIN)';
      case 'swipe':
        return 'Swipe';
      default:
        return 'Card';
    }
  }

  void _continue(Map args) {
    if (!_isValid) {
      String msg = 'Please complete all steps.';
      if (_amountValue <= 0)
        msg = 'Please enter the amount charged.';
      else if (_method.isEmpty)
        msg = 'Select Tap / Insert / Swipe.';
      else if (!_captured)
        msg = 'Simulate a successful capture first.';
      else if (!_clientConfirmed)
        msg = 'Please confirm the client verified the charge.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    Navigator.pushNamed(
      context,
      SignatureScreen.route,
      arguments: {
        ...args,
        'method': 'card - ${_methodLabel(_method)}',
        'amountCents': (_amountValue * 100).round(),
        'handed': true,
      },
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
              offset: Offset(0, (1 - vc) * 12), child: child),
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

  Widget _tile(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          height: 150,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: scheme.primary),
              const SizedBox(height: 10),
              Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
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
    final firstName = (args['firstName'] ?? '').toString();
    final lastName = (args['lastName'] ?? '').toString();
    final policy = (args['policy'] ?? '').toString();
    final name =
        [firstName, lastName].where((s) => s.trim().isNotEmpty).join(' ');

    return Scaffold(
      appBar: AppBar(title: const Text('Card Payment (UI Demo)')),
      body: MaxWidth(
        maxWidth: 820,
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

                  // Step + progress
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.credit_card, color: scheme.primary),
                              const SizedBox(width: 8),
                              Text('Step 2 of 3 • Card',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const LinearProgressIndicator(value: 0.66),
                          const SizedBox(height: 6),
                          Text(
                              'Choose the card method below, enter the amount, and confirm the charge.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  // Summary chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (policy.isNotEmpty)
                        Chip(
                            avatar: Icon(Icons.confirmation_number_outlined,
                                size: 18, color: scheme.primary),
                            label: Text('Policy: $policy')),
                      if (name.isNotEmpty)
                        Chip(
                            avatar: Icon(Icons.person_outline,
                                size: 18, color: scheme.primary),
                            label: Text(name)),
                    ],
                  ),

                  const SizedBox(height: 12),
                  _infoCard(
                    icon: Icons.lock_outline,
                    title: 'Secure & verified',
                    body:
                        'This is a demo. In production, the Yoco/Payfast/Ozow SDK will securely handle card entry and send us a success token. We store an audit trail and notify Admin instantly.',
                  ),
                  const SizedBox(height: 8),
                  _infoCard(
                    icon: Icons.receipt_long_outlined,
                    title: 'Receipt & notifications',
                    body:
                        'After e‑signature, a digital receipt can be sent via SMS/Email/WhatsApp. You will also see the payment in your transaction history.',
                  ),

                  const SizedBox(height: 12),

                  // Payment method tiles (Tap / Insert / Swipe)
                  LayoutBuilder(
                    builder: (context, c) {
                      final maxW = c.maxWidth;
                      final tileW = maxW > 720
                          ? (maxW - 32) / 3
                          : maxW; // 3 across wide; stack narrow
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          SizedBox(
                            width: tileW,
                            child: _tile(
                              icon: Icons.nfc,
                              label: 'Tap to Pay (NFC)',
                              onTap: () => _simulateCapture('nfc'),
                            ),
                          ),
                          SizedBox(
                            width: tileW,
                            child: _tile(
                              icon: Icons.sim_card_outlined,
                              label: 'Insert (Chip & PIN)',
                              onTap: () => _simulateCapture('chip'),
                            ),
                          ),
                          SizedBox(
                            width: tileW,
                            child: _tile(
                              icon: Icons.swipe_outlined,
                              label: 'Swipe',
                              onTap: () => _simulateCapture('swipe'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Amount + confirmation
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _amount,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Amount (ZAR)',
                              prefixText: 'R ',
                              prefixIcon: const Icon(Icons.attach_money),
                              helperText: _amountValue > 0
                                  ? 'You entered: R ${_amountValue.toStringAsFixed(2)}'
                                  : 'Enter the total amount charged on the card',
                            ),
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            value: _clientConfirmed,
                            onChanged: (v) =>
                                setState(() => _clientConfirmed = v ?? false),
                            title: const Text(
                                'Client confirms the card was charged successfully'),
                            subtitle: Text(
                                'Required for audit trail and fraud prevention',
                                style: Theme.of(context).textTheme.bodySmall),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          if (_captured)
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.verified_rounded,
                                      color: Colors.green),
                                  const SizedBox(width: 6),
                                  Text('Captured via ${_methodLabel(_method)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Continue to e‑Signature',
                    onPressed: _isValid ? () => _continue(args) : null,
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
