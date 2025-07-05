import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onEscalate;

  const ChatBubble({
    super.key,
    required this.message,
    this.onEscalate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isFromUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF4CAF50),
              child: Image.network(
                'https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&dpr=1',
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 16,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: message.isFromUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isFromUser
                        ? const Color(0xFF0077CC)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18).copyWith(
                      bottomLeft: message.isFromUser
                          ? const Radius.circular(18)
                          : const Radius.circular(4),
                      bottomRight: message.isFromUser
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMessageContent(),
                      if (!message.isFromUser && message.messageType != null)
                        _buildMessageActions(),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          if (message.isFromUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF0077CC),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    return Text(
      message.message,
      style: TextStyle(
        fontSize: 16,
        color: message.isFromUser ? Colors.white : const Color(0xFF333333),
        height: 1.4,
      ),
    );
  }

  Widget _buildMessageActions() {
    if (message.messageType == null) return const SizedBox.shrink();

    switch (message.messageType) {
      case 'emergency':
        return _buildEmergencyActions();
      case 'symptom_check':
        return _buildSymptomCheckActions();
      case 'escalation':
        return _buildEscalationActions();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmergencyActions() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          const Divider(color: Colors.grey),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Call emergency services
                  },
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Call 199'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Find nearest hospital
                  },
                  icon: const Icon(Icons.local_hospital, size: 16),
                  label: const Text('Find Hospital'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomCheckActions() {
    final metadata = message.metadata;
    if (metadata == null) return const SizedBox.shrink();

    final requiresUrgentCare = metadata['requires_urgent_care'] as bool? ?? false;
    final confidence = metadata['confidence'] as double? ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          const Divider(color: Colors.grey),
          const SizedBox(height: 8),
          // Confidence indicator
          Row(
            children: [
              Icon(
                Icons.psychology,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Confidence: ${(confidence * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (requiresUrgentCare)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'URGENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEscalate,
                  icon: const Icon(Icons.person, size: 16),
                  label: const Text('Talk to Doctor'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0077CC),
                    side: const BorderSide(color: Color(0xFF0077CC)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              if (requiresUrgentCare) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Call emergency
                    },
                    icon: const Icon(Icons.emergency, size: 16),
                    label: const Text('Emergency'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEscalationActions() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          const Divider(color: Colors.grey),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to appointment booking
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text('Book Appointment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077CC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Find doctors
                  },
                  icon: const Icon(Icons.search, size: 16),
                  label: const Text('Find Doctors'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0077CC),
                    side: const BorderSide(color: Color(0xFF0077CC)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF4CAF50),
            child: Image.network(
              'https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&dpr=1',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 16,
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        return Container(
                          margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(
                              0.3 + (0.7 * _animation.value * (index == 0 ? 1 : index == 1 ? 0.7 : 0.4)),
                            ),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'AI is typing...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuickReplyChips extends StatelessWidget {
  final List<String> replies;
  final Function(String) onReplySelected;

  const QuickReplyChips({
    super.key,
    required this.replies,
    required this.onReplySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: replies.map((reply) {
          return ActionChip(
            label: Text(reply),
            onPressed: () => onReplySelected(reply),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF0077CC)),
            labelStyle: const TextStyle(
              color: Color(0xFF0077CC),
              fontWeight: FontWeight.w500,
            ),
          );
        }).toList(),
      ),
    );
  }
}
