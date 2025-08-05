import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../models/safety_report.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with TickerProviderStateMixin {
  int _selectedIndex = 2;
  late TabController _tabController;

  // Mock data for demo
  final List<CommunityWarning> _warnings = [
    CommunityWarning(
      id: '1',
      userId: 'user1',
      title: 'Fake modeling scout on Instagram',
      content: 'Got contacted by someone claiming to be a modeling scout. Asked for photos and personal info right away. Classic scam - they wanted me to pay for a "portfolio shoot". Block and report!',
      tags: ['instagram', 'modeling', 'scam'],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      upvotes: 23,
      views: 145,
    ),
    CommunityWarning(
      id: '2',
      userId: 'user2',
      title: 'Romance scammer using stolen military photos',
      content: 'Matched with someone using military photos. Story kept changing, claimed to be deployed but had inconsistent details. Reverse image search revealed photos stolen from a real soldier\'s social media.',
      tags: ['military', 'catfish', 'photos'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      upvotes: 87,
      views: 532,
    ),
    CommunityWarning(
      id: '3',  
      userId: 'user3',
      title: 'Crypto investment scheme',
      content: 'Met someone who seemed perfect, then gradually started talking about crypto investments. Wanted me to invest in their "guaranteed returns" platform. Classic romance scam combo.',
      tags: ['crypto', 'investment', 'romance'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      upvotes: 156,
      views: 892,
    ),
  ];

  final List<String> _safetyTips = [
    'Never send money, gift cards, or cryptocurrency to someone you haven\'t met in person',
    'Trust your gut - if something feels off, it probably is',
    'Use reverse image search to verify profile photos',
    'Meet in public places for first dates and tell someone where you\'re going',
    'Be wary of people who refuse video calls or phone calls',
    'Look out for grammar mistakes or inconsistent stories',
    'Don\'t share personal information like your address or financial details',
    'Be suspicious of people who profess love very quickly',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.warning), text: 'Warnings'),
            Tab(icon: Icon(Icons.lightbulb), text: 'Tips'),
            Tab(icon: Icon(Icons.report), text: 'Report'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWarningsTab(),
          _buildSafetyTipsTab(),
          _buildReportTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _showCreateWarningDialog,
              icon: const Icon(Icons.add),
              label: const Text('Share Warning'),
            )
          : null,
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
            case 1:
              context.go('/safety');
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

  Widget _buildWarningsTab() {
    return RefreshIndicator(
      onRefresh: _refreshWarnings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _warnings.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCommunityStats();
          }
          
          final warning = _warnings[index - 1];
          return _buildWarningCard(warning);
        },
      ),
    );
  }

  Widget _buildCommunityStats() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Community Impact',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('12.5K', 'Members Protected', Icons.shield),
                ),
                Expanded(
                  child: _buildStatItem('1,247', 'Scammers Reported', Icons.report),
                ),
                Expanded(
                  child: _buildStatItem('98.2%', 'Accuracy Rate', Icons.verified),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWarningCard(CommunityWarning warning) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showWarningDetails(warning),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Anonymous Wingman',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatDateTime(warning.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.verified,
                    size: 16,
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                warning.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                warning.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: warning.tags.map((tag) => Chip(
                  label: Text(
                    '#$tag',
                    style: const TextStyle(fontSize: 12),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInteractionButton(
                    Icons.thumb_up_outlined,
                    '${warning.upvotes}',
                    onTap: () => _upvoteWarning(warning.id),
                  ),
                  const SizedBox(width: 24),
                  _buildInteractionButton(
                    Icons.visibility_outlined,
                    '${warning.views}',
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _shareWarning(warning),
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionButton(
    IconData icon,
    String text, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTipsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _safetyTips.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Safety Guidelines',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn from the community\'s collective experience',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final tipIndex = index - 1;
        final tip = _safetyTips[tipIndex];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                '${tipIndex + 1}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(tip),
            trailing: IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareTip(tip),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.report,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Report a Scammer',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help protect the community by reporting suspicious profiles and scammers',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildReportOption(
            icon: Icons.phone,
            title: 'Report Phone Number',
            description: 'Report a suspicious phone number',
            onTap: () => _showReportDialog(ReportType.scammer),
          ),
          
          _buildReportOption(
            icon: Icons.person,
            title: 'Report Fake Profile',
            description: 'Report catfish or fake dating profiles',
            onTap: () => _showReportDialog(ReportType.catfish),
          ),
          
          _buildReportOption(
            icon: Icons.attach_money,
            title: 'Report Financial Scam',
            description: 'Report investment or money scams',
            onTap: () => _showReportDialog(ReportType.financialFraud),
          ),
          
          _buildReportOption(
            icon: Icons.psychology,
            title: 'Report Manipulation',
            description: 'Report emotional manipulation or love bombing',
            onTap: () => _showReportDialog(ReportType.emotionalManipulation),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Future<void> _refreshWarnings() async {
    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // In a real app, you'd fetch fresh data here
    });
  }

  void _upvoteWarning(String warningId) {
    setState(() {
      final index = _warnings.indexWhere((w) => w.id == warningId);
      if (index != -1) {
        // In a real app, you'd call an API here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanks for your feedback!')),
        );
      }
    });
  }

  void _shareWarning(CommunityWarning warning) {
    // In a real app, you'd implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Warning shared with your contacts')),
    );
  }

  void _shareTip(String tip) {
    // In a real app, you'd implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Safety tip shared!')),
    );
  }

  void _showWarningDetails(CommunityWarning warning) {
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
                        Text(
                          warning.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Text(warning.content),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          children: warning.tags.map((tag) => Chip(
                            label: Text('#$tag'),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreateWarningDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Community Warning'),
        content: const Text(
          'Help protect fellow wingmen by sharing your experience. Your identity will remain anonymous.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In a real app, you'd show a form to create a warning
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Warning creation form would open here')),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(ReportType type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report ${type.toString().split('.').last}'),
        content: const Text(
          'This will open a detailed reporting form to help us investigate and protect the community.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In a real app, you'd show a detailed reporting form
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reporting form would open here')),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}