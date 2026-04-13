import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme.dart';

class CustomerSupportChatScreen extends StatefulWidget {
  const CustomerSupportChatScreen({super.key});

  @override
  State<CustomerSupportChatScreen> createState() => _CustomerSupportChatScreenState();
}

class _CustomerSupportChatScreenState extends State<CustomerSupportChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_ChatMsg> _messages = [
    _ChatMsg(
      text: 'Hi! Welcome to Ambulao Support 👋\nHow can we help you today?',
      isUser: false,
      time: _fmt(DateTime.now().subtract(const Duration(seconds: 5))),
    ),
  ];

  static const List<String> _quickReplies = [
    'Track my booking',
    'Payment issue',
    'Cancel booking',
    'Report a problem',
    'General enquiry',
  ];

  bool _showQuickReplies = true;

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _showQuickReplies = false;
      _messages.add(_ChatMsg(text: text.trim(), isUser: true, time: _fmt(DateTime.now())));
      _ctrl.clear();
    });
    _scrollDown();
    // Auto-reply after 1s
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMsg(
          text: _autoReply(text),
          isUser: false,
          time: _fmt(DateTime.now()),
        ));
      });
      _scrollDown();
    });
  }

  String _autoReply(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('track')) return 'I can help you track your booking. Please share your Booking ID.';
    if (lower.contains('payment')) return 'Please share your transaction ID and we\'ll investigate the payment issue within 2 hours.';
    if (lower.contains('cancel')) return 'To cancel a booking, go to Activity → View Details → Cancel Booking. Refund takes 3–5 business days.';
    if (lower.contains('report')) return 'Thank you for reporting. Our quality team will review this within 24 hours.';
    return 'Thank you for reaching out! An agent will assist you shortly. Our typical response time is under 2 minutes.';
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  static String _fmt(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
          ),
        ),
        title: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
            child: const Icon(Icons.support_agent, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            const Text('Customer Support', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
            Row(children: [
              Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
              const SizedBox(width: 5),
              const Text('Typically replies in 2 min', style: TextStyle(color: Color(0xFF6B7A99), fontSize: 11)),
            ]),
          ])),
        ]),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildBubble(_messages[i]),
            ),
          ),

          // Quick reply chips
          if (_showQuickReplies)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _quickReplies.map((r) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _send(r),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF4FF),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: const Color(0xFFBFD3FF)),
                        ),
                        child: Text(r, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
            ),
            child: Row(children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    maxLines: 3,
                    minLines: 1,
                    onSubmitted: _send,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _send(_ctrl.text),
                child: Container(
                  width: 44, height: 44,
                  decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(_ChatMsg msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 28, height: 28, margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
              child: const Icon(Icons.support_agent, color: Colors.white, size: 14),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                  decoration: BoxDecoration(
                    color: msg.isUser ? AppColors.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                      bottomRight: Radius.circular(msg.isUser ? 4 : 18),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Text(msg.text, style: TextStyle(color: msg.isUser ? Colors.white : AppColors.textPrimary, fontSize: 14, height: 1.4)),
                ),
                const SizedBox(height: 4),
                Text(msg.time, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMsg {
  final String text, time;
  final bool isUser;
  const _ChatMsg({required this.text, required this.isUser, required this.time});
}
