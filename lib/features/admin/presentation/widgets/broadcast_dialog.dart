import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../admin_theme.dart';

const _primaryAccent = kPrimary;

class BroadcastDialog extends StatefulWidget {
  const BroadcastDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const BroadcastDialog(),
    );
  }

  @override
  State<BroadcastDialog> createState() => _BroadcastDialogState();
}

class _BroadcastDialogState extends State<BroadcastDialog> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _selectedType = 'special offer';
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _sendBroadcast() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both title and body'),
          backgroundColor: kDanger,
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    debugPrint(
      '[ADMIN_DEBUG] BroadcastDialog: Initiating push broadcast (title: "$title", body: "$body", type: "$_selectedType")',
    );

    try {
      final supabaseUrl =
          dotenv.env['SUPABASE_URL'] ??
          'https://jlfgigvfmxuvlixohzli.supabase.co';
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

      final client = SupabaseClient(supabaseUrl, supabaseAnonKey);
      final response = await client.functions.invoke(
        'dynamic-processor',
        body: {'title': title, 'body': body, 'type': _selectedType},
      );

      debugPrint(
        '[ADMIN_DEBUG] BroadcastDialog: Function response status: ${response.status}, data: ${response.data}',
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Broadcast sent successfully! Response: ${response.data}',
            ),
            backgroundColor: kSuccess,
          ),
        );
      }
    } catch (e) {
      debugPrint(
        '[ADMIN_DEBUG] BroadcastDialog: Caught exception during push broadcast: $e',
      );
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send broadcast: $e'),
            backgroundColor: kDanger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildAdminDialog(
      context: context,
      title: 'Broadcast Push Notification',
      icon: Icons.campaign_rounded,
      iconColor: _primaryAccent,
      width: 440,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Notification Title',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: kTitleColor,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 13, color: kTitleColor),
            decoration: const InputDecoration(
              hintText: 'e.g., Special Holiday Offer!',
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Notification Message',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: kTitleColor,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _bodyController,
            maxLines: 3,
            style: const TextStyle(fontSize: 13, color: kTitleColor),
            decoration: const InputDecoration(
              hintText: 'e.g., Express your love with our new premium card collections!',
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Notification Category Type',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: kTitleColor,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            style: const TextStyle(fontSize: 13, color: kTitleColor),
            decoration: const InputDecoration(),
            items: const [
              DropdownMenuItem(
                value: 'special offer',
                child: Text('Special Offer'),
              ),
              DropdownMenuItem(
                value: 'system alert',
                child: Text('System Alert'),
              ),
              DropdownMenuItem(
                value: 'event reminder',
                child: Text('Event Reminder'),
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedType = val);
            },
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: _isSending ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            side: const BorderSide(color: kDashBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Cancel', style: TextStyle(fontSize: 12.5)),
        ),
        const SizedBox(width: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: _isSending ? null : AppColors.primaryButtonGradient,
            color: _isSending ? kMutedColor : null,
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isSending
                ? null
                : [
                    BoxShadow(
                      color: _primaryAccent.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: _isSending ? null : _sendBroadcast,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: _isSending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.send_rounded, size: 15, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Send Broadcast',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
