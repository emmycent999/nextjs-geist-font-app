import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Emergency Services'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Emergency Alert Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emergency,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Emergency Services',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Get immediate help when you need it most',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Emergency Hotlines
            const Text(
              'Emergency Hotlines',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            _EmergencyContactCard(
              title: 'National Emergency',
              subtitle: 'Police, Fire, Medical',
              phoneNumber: '199',
              icon: Icons.local_hospital,
              color: Colors.red,
              onCall: () => _makePhoneCall('199'),
            ),
            const SizedBox(height: 12),
            _EmergencyContactCard(
              title: 'Police Emergency',
              subtitle: 'Law enforcement',
              phoneNumber: '199',
              icon: Icons.local_police,
              color: Colors.blue,
              onCall: () => _makePhoneCall('199'),
            ),
            const SizedBox(height: 12),
            _EmergencyContactCard(
              title: 'Fire Service',
              subtitle: 'Fire emergencies',
              phoneNumber: '199',
              icon: Icons.local_fire_department,
              color: Colors.orange,
              onCall: () => _makePhoneCall('199'),
            ),
            const SizedBox(height: 12),
            _EmergencyContactCard(
              title: 'Lagos State Emergency',
              subtitle: 'Lagos emergency services',
              phoneNumber: '767',
              icon: Icons.emergency,
              color: Colors.purple,
              onCall: () => _makePhoneCall('767'),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    title: 'Request Ambulance',
                    subtitle: 'Emergency transport',
                    icon: Icons.local_hospital,
                    color: const Color(0xFFFF5722),
                    onTap: () => _requestAmbulance(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    title: 'Find Hospital',
                    subtitle: 'Nearest emergency room',
                    icon: Icons.location_on,
                    color: const Color(0xFF2196F3),
                    onTap: () => _findNearestHospital(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    title: 'Emergency Chat',
                    subtitle: 'Chat with operator',
                    icon: Icons.chat,
                    color: const Color(0xFF4CAF50),
                    onTap: () => _startEmergencyChat(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    title: 'First Aid Guide',
                    subtitle: 'Emergency procedures',
                    icon: Icons.medical_services,
                    color: const Color(0xFF9C27B0),
                    onTap: () => _showFirstAidGuide(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Emergency Tips
            const Text(
              'Emergency Tips',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            _EmergencyTipCard(
              title: 'Stay Calm',
              content: 'Take deep breaths and try to remain calm. This will help you think clearly and communicate effectively with emergency services.',
              icon: Icons.self_improvement,
            ),
            const SizedBox(height: 12),
            _EmergencyTipCard(
              title: 'Provide Clear Information',
              content: 'When calling emergency services, clearly state your location, the nature of the emergency, and any immediate dangers.',
              icon: Icons.info,
            ),
            const SizedBox(height: 12),
            _EmergencyTipCard(
              title: 'Follow Instructions',
              content: 'Listen carefully to the emergency operator and follow their instructions. They are trained to help you through the situation.',
              icon: Icons.hearing,
            ),
            const SizedBox(height: 24),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Important Notice',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This app provides emergency contact information and basic guidance. In case of a real emergency, always call official emergency services immediately. The app is not a substitute for professional emergency response.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _requestAmbulance(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Ambulance'),
        content: const Text(
          'This will connect you to emergency services to request an ambulance. Make sure you have your location ready.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _makePhoneCall('199');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _findNearestHospital(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Find Nearest Hospital'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Major Hospitals in Lagos:'),
            SizedBox(height: 12),
            Text('• Lagos University Teaching Hospital (LUTH)'),
            Text('• Lagos State University Teaching Hospital'),
            Text('• National Orthopaedic Hospital'),
            Text('• Gbagada General Hospital'),
            Text('• Ikorodu General Hospital'),
            SizedBox(height: 12),
            Text(
              'For immediate directions, call emergency services at 199.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _makePhoneCall('199');
            },
            child: const Text('Call Emergency'),
          ),
        ],
      ),
    );
  }

  void _startEmergencyChat(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency chat feature coming soon. Please call emergency services for immediate help.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showFirstAidGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Basic First Aid'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CPR (Cardiopulmonary Resuscitation):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('1. Check responsiveness\n2. Call for help\n3. 30 chest compressions\n4. 2 rescue breaths\n5. Repeat'),
              SizedBox(height: 16),
              Text(
                'Choking:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('1. Encourage coughing\n2. 5 back blows\n3. 5 abdominal thrusts\n4. Repeat until clear'),
              SizedBox(height: 16),
              Text(
                'Bleeding:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('1. Apply direct pressure\n2. Elevate if possible\n3. Use clean cloth\n4. Seek medical help'),
              SizedBox(height: 16),
              Text(
                'Remember: These are basic guidelines. Always seek professional medical help in emergencies.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _EmergencyContactCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String phoneNumber;
  final IconData icon;
  final Color color;
  final VoidCallback onCall;

  const _EmergencyContactCard({
    required this.title,
    required this.subtitle,
    required this.phoneNumber,
    required this.icon,
    required this.color,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              phoneNumber,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onCall,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Call'),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyTipCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _EmergencyTipCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0077CC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0077CC),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
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
