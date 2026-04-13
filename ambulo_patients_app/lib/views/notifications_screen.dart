import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Each notification: id, type, title, body, time, isRead
  final List<Map<String, dynamic>> _notifications = [
    {'id': 1, 'type': 'booking', 'title': 'Booking confirmed', 'body': 'Your BLS ambulance has been booked.', 'time': '9:45 AM', 'isRead': false, 'group': 'Today'},
    {'id': 2, 'type': 'emergency', 'title': 'Emergency alert', 'body': 'Emergency booking dispatched successfully.', 'time': '7:12 AM', 'isRead': false, 'group': 'Today'},
    {'id': 3, 'type': 'completed', 'title': 'Trip completed', 'body': 'Your trip to Apollo Hospital is complete.', 'time': 'Yesterday', 'isRead': true, 'group': 'Earlier'},
    {'id': 4, 'type': 'payment', 'title': 'Payment received', 'body': 'Payment of â‚¹499 received. Thank you!', 'time': 'Yesterday', 'isRead': true, 'group': 'Earlier'},
    {'id': 5, 'type': 'info', 'title': 'Ambulao update', 'body': 'Keep your emergency contacts updated for faster dispatch.', 'time': '2 days ago', 'isRead': true, 'group': 'Earlier'},
  ];

  void _markAllRead() => setState(() { for (final n in _notifications) { n['isRead'] = true; } });

  void _markRead(int id) => setState(() {
    final n = _notifications.firstWhere((n) => n['id'] == id);
    n['isRead'] = true;
  });

  Color _iconColor(String type) {
    switch (type) {
      case 'booking': return const Color(0xFF1A6FE8);
      case 'completed': return const Color(0xFF10B981);
      case 'emergency': return const Color(0xFFEF4444);
      case 'payment': return const Color(0xFFF59E0B);
      default: return const Color(0xFF9CA3AF);
    }
  }

  IconData _iconData(String type) {
    switch (type) {
      case 'booking': return Icons.local_hospital_outlined;
      case 'completed': return Icons.check_circle_outline;
      case 'emergency': return Icons.warning_amber_rounded;
      case 'payment': return Icons.payments_outlined;
      default: return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = ['Today', 'Earlier'];
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Color(0xFF0A0F1E), size: 20),
          ),
        ),
        title: const Text('Notifications', style: TextStyle(color: Color(0xFF0A0F1E), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text('Mark all read', style: TextStyle(color: Color(0xFF1A6FE8), fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: groups.length,
        itemBuilder: (context, gi) {
          final group = groups[gi];
          final items = _notifications.where((n) => n['group'] == group).toList();
          if (items.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (gi > 0) const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 4),
                child: Text(group.toUpperCase(), style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
              ),
              ...items.map((n) => _buildNotifRow(n)),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotifRow(Map<String, dynamic> n) {
    final bool isRead = n['isRead'] as bool;
    final Color iconColor = _iconColor(n['type'] as String);
    return GestureDetector(
      onTap: () => _markRead(n['id'] as int),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFF5F8FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isRead ? const Color(0xFFEEEEEE) : const Color(0xFFD6E4FF), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Center(child: Icon(_iconData(n['type'] as String), color: iconColor, size: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(n['title'] as String, style: TextStyle(fontSize: 14, fontWeight: isRead ? FontWeight.w500 : FontWeight.bold, color: const Color(0xFF0A0F1E))),
            const SizedBox(height: 3),
            Text(n['body'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7A99), height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(n['time'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          ])),
          if (!isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF1A6FE8), shape: BoxShape.circle)),
        ]),
      ),
    );
  }
}
