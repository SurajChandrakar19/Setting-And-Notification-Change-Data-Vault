import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text('Contact Information', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text('Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('14 (24/3) Albert Street, Richmond Rd, Cross, Bengaluru, Karnataka 560025'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.email, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('info@headsuphrsolutions.com'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text('Phone:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('+91 8618164140'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text('Frequently Asked Questions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          ExpansionTile(
            title: const Text('How do I reset my password?'),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Go to Account Details > Edit Profile. You will see an option to reset your password (coming soon).'),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('How do I contact support?'),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('You can use the button below to email our support team.'),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('How do I update my profile information?'),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Go to Account Details and tap Edit Profile (coming soon).'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // In a real app, use url_launcher to open email
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Launching email to info@headsuphrsolutions.com')),
                );
              },
              icon: const Icon(Icons.email),
              label: const Text('Contact Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
