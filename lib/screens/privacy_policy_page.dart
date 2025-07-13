import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: HtmlWidget(_privacyPolicyHtml),
      ),
    );
  }
}

const String _privacyPolicyHtml = '''
<h1>Privacy Policy</h1>
<p><strong>Last updated:</strong> July 13, 2025</p>
<p>Thank you for using <strong>Luma Matcha</strong>!</p>
<p>This Privacy Policy explains how your information is handled when you use our application ("App"). By using the App, you agree to this policy.</p>

<h2>1. No Personal Data Collection</h2>
<p>We respect your privacy. <strong>Luma Matcha</strong> does <strong>not</strong> collect, store, or share any personal data from users.</p>
<ul>
  <li>No account or login is required.</li>
  <li>We do not collect your name, email, location, or any other personally identifiable information.</li>
  <li>We do not access or collect any data from your device (such as contacts, camera, storage, etc.).</li>
</ul>

<h2>2. Internet and External Links</h2>
<p><strong>Luma Matcha</strong> may include links to external websites or social media platforms (e.g., Instagram, WhatsApp, etc.) for informational purposes. When you click these links:</p>
<ul>
  <li>You will be redirected to third-party platforms.</li>
  <li>These third-party platforms may collect personal data as per their own privacy policies, which we do not control.</li>
  <li>We encourage you to review the privacy policies of any external websites or services you visit.</li>
</ul>

<h2>3. Analytics and Tracking</h2>
<p><strong>Luma Matcha</strong> does <strong>not</strong> use any analytics tools or tracking technologies.</p>

<h2>4. Children’s Privacy</h2>
<p>Our App does not knowingly collect any information from children. It is suitable for all age groups.</p>

<h2>5. Changes to This Policy</h2>
<p>We may update this Privacy Policy from time to time. Any changes will be reflected in this document with a new “Last updated” date. You are advised to review this policy periodically.</p>

<h2>6. Contact Us</h2>
<p>If you have any questions or concerns about this Privacy Policy, you can contact us at:</p>
<ul>
  <li><strong>Email:</strong> <a href="mailto:yugaapik@gmail.com">yugaapik@gmail.com</a></li>
  <li><strong>Developer:</strong> Aditya Yuga</li>
</ul>

<p style="text-align:center;">&copy; 2025 Luma Matcha. All rights reserved.</p>
''';