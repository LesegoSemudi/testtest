import 'package:flutter/material.dart';
import '../widgets/ui.dart';
import 'signature.dart';

class CashScreen extends StatefulWidget {
  static const route = '/cash';
  const CashScreen({super.key});

  @override
  State<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> with TickerProviderStateMixin {
  final _amount = TextEditingController();
  bool _handedOver = false;

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
    // Start animation after first frame
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
    final v = double.tryParse(raw) ?? 0;
    return v;
  }

  bool get _isValid => _amountValue > 0 && _handedOver;

  void _continue(Map args) {
    if (!_isValid) {
      final msg = _amountValue <= 0
          ? 'Please enter the cash amount received.'
          : 'Please confirm the client handed the cash to the clerk.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    Navigator.pushNamed(
      context,
      SignatureScreen.route,
      arguments: {
        ...args,
        'method': 'cash',
        'amountCents': (_amountValue * 100).round(),
        'handed': _handedOver,
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
      builder: (context, v, child) => Opacity(
        opacity: v,
        child:
            Transform.translate(offset: Offset(0, (1 - v) * 12), child: child),
      ),
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
      appBar: AppBar(title: const Text('Cash Payment')),
      body: MaxWidth(
        maxWidth: 760,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                // Progress + reassurance
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
                            Icon(Icons.payments_outlined,
                                color: scheme.primary),
                            const SizedBox(width: 8),
                            Text('Step 2 of 3 • Cash',
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
                            'This payment will be captured, and a receipt will be sent after you sign.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                _infoCard(
                  icon: Icons.lock_clock_outlined,
                  title: 'What happens now',
                  body:
                      'Enter the cash amount received and confirm that the client handed the cash to the clerk. Your entry is stored with time, branch and user for a full audit trail.',
                ),
                const SizedBox(height: 8),
                _infoCard(
                  icon: Icons.receipt_long_outlined,
                  title: 'Receipt & notifications',
                  body:
                      'After e‑signature, a digital receipt will be generated. In production, clients can receive this by SMS/Email/WhatsApp and Admin is notified instantly.',
                ),

                const SizedBox(height: 12),
                // Amount input
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
                            helperText: _amountValue > 0
                                ? 'You entered: R ${_amountValue.toStringAsFixed(2)}'
                                : 'Enter the amount received from the client',
                            prefixIcon: const Icon(Icons.attach_money),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          value: _handedOver,
                          onChanged: (v) =>
                              setState(() => _handedOver = v ?? false),
                          title: const Text(
                              'Client confirms they handed cash to the clerk'),
                          subtitle: Text(
                              'Required for fraud prevention and accurate reconciliation',
                              style: Theme.of(context).textTheme.bodySmall),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),
                PrimaryButton(
                  label: 'Continue to e‑Signature',
                  onPressed: _isValid ? () => _continue(args) : null,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
