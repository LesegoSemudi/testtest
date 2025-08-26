import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> setupFirestore() async {
  final firestore = FirebaseFirestore.instance;

  // 1. Clients Collection
  final clients = firestore.collection('clients');
  await clients.doc('template_client').set({
    'first_name': 'John',
    'last_name': 'Doe',
    'phone': '0123456789',
    'email': 'john@example.com',
    'id_number': '1234567890123',
    'policy_number': 'POL123456',
    'branch': 'Main',
    'created_at': FieldValue.serverTimestamp(),
  });

  // 2. Transactions Collection
  final transactions = firestore.collection('transactions');
  await transactions.doc('template_transaction').set({
    'client_id': 'template_client',
    'amount': 1000,
    'method': 'cash',
    'status': 'completed',
    'branch': 'Main',
    'timestamp': FieldValue.serverTimestamp(),
  });

  // 3. Policies Collection
  final policies = firestore.collection('policies');
  await policies.doc('template_policy').set({
    'policy_number': 'POL123456',
    'main_member': 'John Doe',
    'status': 'active',
    'created_at': FieldValue.serverTimestamp(),
  });

  // 4. Claims Collection
  final claims = firestore.collection('claims');
  await claims.doc('template_claim').set({
    'policy_number': 'POL123456',
    'claimant': 'John Doe',
    'status': 'pending',
    'created_at': FieldValue.serverTimestamp(),
  });

  // 5. Documents Collection
  final documents = firestore.collection('documents');
  await documents.doc('template_document').set({
    'policy_number': 'POL123456',
    'file_url': 'https://example.com/sample.pdf',
    'created_at': FieldValue.serverTimestamp(),
  });

  // 6. Notifications Collection
  final notifications = firestore.collection('notifications');
  await notifications.doc('template_notification').set({
    'title': 'Payment Due',
    'body': 'Your policy payment is due.',
    'client_id': 'template_client',
    'created_at': FieldValue.serverTimestamp(),
  });

  // 7. Audit Logs Collection
  final auditLogs = firestore.collection('audit_logs');
  await auditLogs.doc('template_log').set({
    'action': 'setup_firestore',
    'user_id': 'admin_001',
    'timestamp': FieldValue.serverTimestamp(),
  });

  // 8. Devices Collection
  final devices = firestore.collection('devices');
  await devices.doc('template_device').set({
    'device_id': 'device_001',
    'type': 'tablet',
    'branch': 'Main',
    'status': 'online',
    'last_seen': FieldValue.serverTimestamp(),
  });

  print('Firestore setup complete!');
}
