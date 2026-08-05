import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexcampus_app/features/student/blocs/anonymous_issue_reporting/models/issue_post_model.dart';

class AdminFeedMonitoringScreen extends StatefulWidget {
  const AdminFeedMonitoringScreen({super.key});

  @override
  State<AdminFeedMonitoringScreen> createState() =>
      _AdminFeedMonitoringScreenState();
}

class _AdminFeedMonitoringScreenState extends State<AdminFeedMonitoringScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Question',
    'Academic',
    'Facility',
    'Faculty/Staff',
    'Harassment/Bullying',
    'Mental Health',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Student Feed Monitoring', style: TextStyle(color: Colors.black87)),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = category);
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.purple[100],
                          checkmarkColor: Colors.purple,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.purple[700]
                                : Colors.grey[700],
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Feed List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFeedStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        const Text('Error loading feed'),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data?.docs ?? [];

                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts from students yet',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final doc = posts[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final post = IssuePostModel.fromMap({
                      ...data,
                      'id': doc.id,
                    });
                    return _buildFeedCard(post);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getFeedStream() {
    Query query = FirebaseFirestore.instance
        .collection('anonymous_issue_posts')
        .orderBy('createdAt', descending: true);

    if (_selectedCategory != 'All') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    return query.snapshots();
  }

  String _getAnonymousName(String seed) {
    final animals = [
      'Panther',
      'Tiger',
      'Eagle',
      'Wolf',
      'Falcon',
      'Hawk',
      'Lion',
      'Bear',
      'Fox',
      'Owl',
    ];
    final hash = seed.hashCode.abs();
    final index = hash % animals.length;
    return 'Anonymous ${animals[index]}';
  }

  Widget _buildFeedCard(IssuePostModel post) {
    final anonymousName = _getAnonymousName(post.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Anonymous Name
            Row(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.visibility_off,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      anonymousName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Resolved Badge
                if (post.isResolved)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Resolved',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getCategoryColor(post.category).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getCategoryColor(post.category).withValues(alpha: 0.28),
                ),
              ),
              child: Text(
                post.category,
                style: TextStyle(
                  fontSize: 11,
                  color: _getCategoryColor(post.category),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              post.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Body
            Text(
              post.body,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Stats
            Row(
              children: [
                Icon(Icons.thumb_up, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  '${post.upvoteCount}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.comment, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  '${post.commentsCount}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const Spacer(),
                Text(
                  _formatDate(post.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Moderation Actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _showPostDetailDialog(post),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('View'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _toggleResolved(post.id, post.isResolved),
                  icon: Icon(
                    post.isResolved ? Icons.undo : Icons.check_circle_outline,
                    size: 18,
                    color: post.isResolved ? Colors.black87 : Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: post.isResolved ? Colors.grey[200] : Colors.green,
                    foregroundColor: post.isResolved ? Colors.black87 : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  label: Text(post.isResolved ? 'Unresolve' : 'Resolve'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _confirmAndDeletePost(post.id),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleResolved(String postId, bool currentlyResolved) async {
    try {
      await FirebaseFirestore.instance
          .collection('anonymous_issue_posts')
          .doc(postId)
          .update({'isResolved': !currentlyResolved, 'updatedAt': FieldValue.serverTimestamp()});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentlyResolved ? 'Marked unresolved' : 'Marked resolved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  }

  Future<void> _confirmAndDeletePost(String postId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete post'),
        content: const Text('This will permanently delete the post and its comments.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final postRef = FirebaseFirestore.instance.collection('anonymous_issue_posts').doc(postId);
      final commentsSnap = await FirebaseFirestore.instance.collection('anonymous_issue_comments').where('postId', isEqualTo: postId).get();
      for (final doc in commentsSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(postRef);
      await batch.commit();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post deleted')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  void _showPostDetailDialog(IssuePostModel post) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(post.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.body),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text('Category: ${post.category}')),
                  Chip(label: Text('Upvotes: ${post.upvoteCount}')),
                  Chip(label: Text('Comments: ${post.commentsCount}')),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Question':
        return Colors.blue;
      case 'Academic':
        return Colors.green;
      case 'Facility':
        return Colors.orange;
      case 'Faculty/Staff':
        return Colors.purple;
      case 'Harassment/Bullying':
        return Colors.red;
      case 'Mental Health':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
