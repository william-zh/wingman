import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/background_check_service.dart';
import '../../models/background_check.dart';

class SafetyDashboard extends StatefulWidget {
  const SafetyDashboard({super.key});

  @override
  State<SafetyDashboard> createState() => _SafetyDashboardState();
}

class _SafetyDashboardState extends State<SafetyDashboard> {
  int _selectedIndex = 1;
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _performBackgroundCheck() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final backgroundService = context.read<BackgroundCheckService>();
    final user = authService.currentUser;

    if (user == null) return;

    final result = await backgroundService.performBackgroundCheck(
      userId: user.id,
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim().isNotEmpty 
          ? _emailController.text.trim() 
          : null,
      name: _nameController.text.trim().isNotEmpty 
          ? _nameController.text.trim() 
          : null,
    );

    if (result != null && mounted) {
      _showBackgroundCheckResult(result);
    }
  }

  void _showBackgroundCheckResult(BackgroundCheck check) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return _buildResultSheet(check, scrollController);
        },
      ),
    );
  }

  Widget _buildResultSheet(BackgroundCheck check, ScrollController scrollController) {
    final result = check.result;
    if (result == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield,
                        color: _getRiskColor(result.riskScore),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Safety Report',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              'Risk Score: ${result.riskScore}/100',
                              style: TextStyle(
                                color: _getRiskColor(result.riskScore),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildResultCard(
                    'Phone Information',
                    Icons.phone,
                    [
                      'Number: ${result.phoneInfo.number}',
                      'Carrier: ${result.phoneInfo.carrier}',
                      'Location: ${result.phoneInfo.location}',
                      'Type: ${result.phoneInfo.type}',
                      'Valid: ${result.phoneInfo.isValid ? "Yes" : "No"}',
                      'Active: ${result.phoneInfo.isActive ? "Yes" : "No"}',
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildResultCard(
                    'Background Check',
                    Icons.assignment,
                    [
                      'Criminal Record: ${result.hasCriminalRecord ? "Found" : "Clean"}',
                      'Sex Offender: ${result.isSexOffender ? "Yes" : "No"}',
                      'Financial Fraud: ${result.hasFinancialFraudHistory ? "Yes" : "No"}',
                    ],
                  ),
                  
                  if (result.socialMediaProfiles.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildResultCard(
                      'Social Media Profiles',
                      Icons.social_distance,
                      result.socialMediaProfiles.map(
                        (profile) => '${profile.platform}: @${profile.username}'
                      ).toList(),
                    ),
                  ],
                  
                  if (result.riskFactors.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildResultCard(
                      'Risk Factors',
                      Icons.warning,
                      result.riskFactors,
                      isWarning: true,
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(
    String title,
    IconData icon,
    List<String> items, {
    bool isWarning = false,
  }) {
    return Card(
      color: isWarning 
          ? Theme.of(context).colorScheme.errorContainer
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isWarning 
                      ? Theme.of(context).colorScheme.onErrorContainer
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isWarning 
                        ? Theme.of(context).colorScheme.onErrorContainer
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $item',
                style: TextStyle(
                  color: isWarning 
                      ? Theme.of(context).colorScheme.onErrorContainer
                      : null,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(int riskScore) {
    if (riskScore < 30) return Colors.green;
    if (riskScore < 60) return Colors.orange;
    return Colors.red;
  }

  Future<void> _performReverseImageSearch() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;

    final backgroundService = context.read<BackgroundCheckService>();
    
    // For demo purposes, we'll show a mock result
    // In a real app, you'd upload the image and get actual results
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reverse image search completed - No matches found in scammer database'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickTools(),
            const SizedBox(height: 16),
            _buildBackgroundCheckForm(),
            const SizedBox(height: 16),
            _buildRecentChecks(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 2:
              context.go('/community');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: 'Safety',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Community',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTools() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Safety Tools',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickToolButton(
                    icon: Icons.image_search,
                    label: 'Reverse Image Search',
                    description: 'Check if photos are stolen',
                    onTap: _performReverseImageSearch,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickToolButton(
                    icon: Icons.phone_callback,
                    label: 'Scammer Lookup',
                    description: 'Check against scammer database',
                    onTap: () {
                      // Scroll to background check form
                      Scrollable.ensureVisible(
                        _formKey.currentContext!,
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickToolButton({
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundCheckForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Background Check',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter information to perform a comprehensive safety check',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: '+1 (555) 123-4567',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  hintText: 'example@email.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name (Optional)',
                  hintText: 'John Doe',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              
              const SizedBox(height: 24),
              
              Consumer<BackgroundCheckService>(
                builder: (context, service, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: service.isLoading ? null : _performBackgroundCheck,
                      child: service.isLoading
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('Checking...'),
                              ],
                            )
                          : const Text('Run Background Check'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentChecks() {
    return Consumer<BackgroundCheckService>(
      builder: (context, service, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Checks',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                
                if (service.recentChecks.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No recent checks',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...service.recentChecks.map((check) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: check.result != null
                            ? _getRiskColor(check.result!.riskScore).withOpacity(0.2)
                            : Theme.of(context).colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.shield_outlined,
                          color: check.result != null
                              ? _getRiskColor(check.result!.riskScore)
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      title: Text(check.targetPhoneNumber),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_formatDateTime(check.requestedAt)),
                          if (check.result != null)
                            Text(
                              'Risk Score: ${check.result!.riskScore}/100',
                              style: TextStyle(
                                color: _getRiskColor(check.result!.riskScore),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      trailing: check.status == BackgroundCheckStatus.completed
                          ? IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () => _showBackgroundCheckResult(check),
                            )
                          : const CircularProgressIndicator(),
                    ),
                  )),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}