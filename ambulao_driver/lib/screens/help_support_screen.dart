import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0A1F44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Help & Support',
            style: TextStyle(color: Color(0xFF0A1F44), fontSize: 18, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: const Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Driver Support', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  SizedBox(height: 8),
                  Text('Available Mon–Sat · 8AM–10PM', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ])),
                Icon(Icons.support_agent, color: Colors.white, size: 48),
              ]),
            ),
            const SizedBox(height: 32),
            const Text('Quick Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _ContactCard(
                icon: Icons.phone_in_talk,
                title: 'Call Support',
                subtitle: 'Usually 1 min wait',
                onTap: () => _showCallSheet(context),
              )),
              const SizedBox(width: 16),
              Expanded(child: _ContactCard(
                icon: Icons.chat_bubble_outline,
                title: 'Chat Support',
                subtitle: 'Usually instant',
                onTap: () => _showChatSheet(context),
              )),
            ]),
            const SizedBox(height: 32),
            const Text('Frequently Asked Questions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
            const SizedBox(height: 16),
            _FaqItem(question: 'My account is inactive'),
            _FaqItem(question: 'How is payout calculated?'),
            _FaqItem(question: 'Update vehicle or insurance'),
            _FaqItem(question: 'Feedback about a passenger'),
            _FaqItem(question: 'Dispute a trip fare'),
          ],
        ),
      ),
    );
  }

  void _showCallSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 48, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFDDE3EE), borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFE8F2FF), shape: BoxShape.circle),
              child: const Icon(Icons.phone, color: AppTheme.primaryBlue, size: 44),
            ),
            const SizedBox(height: 20),
            const Text('Call AMBULAO Support?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0040A0))),
            const SizedBox(height: 10),
            const Text('1800-262-5226',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
            const SizedBox(height: 6),
            const Text('Monday – Saturday · 8AM – 10PM',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.phone, color: Colors.white),
                label: const Text('Call Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF34C759), elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 50,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChatSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AIChatSheet(),
    );
  }
}

// ── Contact Card Widget ───────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0F4FF)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFE8F2FF), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ]),
      ),
    );
  }
}

// ── FAQ Item ──────────────────────────────────────────────────────────────────

class _FaqItem extends StatefulWidget {
  final String question;
  const _FaqItem({required this.question});
  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _expanded ? AppTheme.primaryBlue : const Color(0xFFF0F4FF)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(widget.question,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: _expanded ? AppTheme.primaryBlue : const Color(0xFF0A1F44)))),
                Icon(_expanded ? Icons.keyboard_arrow_up : Icons.chevron_right, color: AppTheme.textSecondary),
              ]),
              if (_expanded) ...[
                const SizedBox(height: 10),
                const Text(
                  'Our support team is here to help. Please contact us via chat or call for immediate assistance with this issue.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

// ── AI Chat Sheet ─────────────────────────────────────────────────────────────

class _AIChatSheet extends StatefulWidget {
  const _AIChatSheet();
  @override
  State<_AIChatSheet> createState() => _AIChatSheetState();
}

class _AIChatSheetState extends State<_AIChatSheet> {
  final List<_ChatMsg> _messages = [];
  final TextEditingController _inputCtrl = TextEditingController();
  bool _isTyping = false;
  bool _connecting = false;
  final ScrollController _scrollCtrl = ScrollController();

  final _quickReplies = [
    "My payment is delayed 💰",
    "Trip issue 🚑",
    "Account problem 👤",
    "Document help 📄",
    "Something else",
  ];

  final _botReplies = {
    "My payment is delayed 💰": "I understand your concern. Payments are processed within 3–5 business days. Your last payment was on Mar 8, 2026. Would you like me to raise a ticket?",
    "Trip issue 🚑": "I'm sorry about that. Can you tell me the trip ID or approximate time of the trip so I can look into it?",
    "Account problem 👤": "I can help with account issues. Is this regarding your login, documents, or vehicle registration?",
    "Document help 📄": "Sure! You can upload or update documents from Menu → Manage → Documents. Would you like me to guide you there?",
    "Something else": "Of course! Please describe your issue and I'll do my best to help or connect you with a human agent.",
  };

  @override
  void initState() {
    super.initState();
    _showBotTyping("Hi Syed Rayan! 👋 I'm Ambi, your AMBULAO support assistant. How can I help you today?");
  }

  @override
  void dispose() { _inputCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  void _showBotTyping(String reply) {
    setState(() => _isTyping = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMsg(text: reply, isUser: false));
      });
      _scrollToBottom();
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() => _messages.add(_ChatMsg(text: text.trim(), isUser: true)));
    _inputCtrl.clear();
    _scrollToBottom();
    final reply = _botReplies[text.trim()] ?? "Thank you for reaching out! I'll connect you to a specialist for further assistance.";
    _showBotTyping(reply);
  }

  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Center(child: Container(width: 48, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFDDE3EE), borderRadius: BorderRadius.circular(10)))),
          ),
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F4FF)))),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
                child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('AMBULAO Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
                Row(children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF34C759), shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  const Text('Online', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ]),
              ]),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() => _connecting = true);
                  Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _connecting = false); });
                },
                child: const Text('Talk to Human', style: TextStyle(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: AppTheme.textSecondary),
              ),
            ]),
          ),

          // Connecting overlay or chat
          if (_connecting)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFE8F2FF), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue)),
                const SizedBox(width: 12),
                const Expanded(child: Text('Connecting you to a human agent...\nAverage wait time: 8 minutes',
                    style: TextStyle(fontSize: 13, color: Color(0xFF0040A0)))),
                GestureDetector(onTap: () => setState(() => _connecting = false),
                    child: const Text('Cancel', style: TextStyle(color: AppTheme.criticalRed, fontWeight: FontWeight.w700))),
              ]),
            ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length) return _TypingBubble();
                final msg = _messages[i];
                return _ChatBubble(msg: msg);
              },
            ),
          ),

          // Quick replies (shown only if no messages sent yet besides bot greeting)
          if (_messages.length <= 1)
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _quickReplies.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _sendMessage(_quickReplies[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: const Color(0xFFDDE3EE)),
                    ),
                    child: Text(_quickReplies[i], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0A1F44))),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),

          // Input row
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 24),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _inputCtrl,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: const Color(0xFFF5F8FF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _sendMessage(_inputCtrl.text),
                child: Container(
                  width: 46, height: 46,
                  decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_upward, color: Colors.white, size: 22),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _ChatMsg {
  final String text;
  final bool isUser;
  const _ChatMsg({required this.text, required this.isUser});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMsg msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: msg.isUser ? AppTheme.primaryBlue : const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 18),
                ),
              ),
              child: Text(msg.text,
                  style: TextStyle(fontSize: 14, color: msg.isUser ? Colors.white : const Color(0xFF0A1F44), height: 1.4)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          width: 32, height: 32,
          decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
          child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(18)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _dot(), const SizedBox(width: 4), _dot(), const SizedBox(width: 4), _dot(),
          ]),
        ),
      ]),
    );
  }

  Widget _dot() => Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle));
}
