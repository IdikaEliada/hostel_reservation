import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:hostel_reservation/app_theme.dart';
import 'package:hostel_reservation/widgets/app_footer.dart';

import 'package:hostel_reservation/features/cancel/cancel_button.dart';

// ─── Derived palette from AppTheme ───────────────────────────────────────────
// Primary  : AppTheme.primaryColor  = Color(0xFF008000)  – FUTO Green
// Light    : _kGreenLight           = Color(0xFF4CAF50)  – lighter accent
// Pale bg  : _kGreenPale            = Color(0xFFE8F5E9)  – tinted background
// Dark bg  : AppTheme.backgroundDark                     – deep header gradient start
// Surface  : AppTheme.surfaceLight  = Colors.white
// BG       : AppTheme.backgroundLight                    – scaffold bg
const _kGreenLight = Color(0xFF4CAF50);
const _kGreenPale = Color(0xFFE8F5E9);
const _kGreyText = Color(0xFF757575);
const _kDark = Color(0xFF1A1A1A);

// ─── Main Screen ──────────────────────────────────────────────────────────────

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot> _userStream;
  late Stream<QuerySnapshot> _transactionsStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _userStream = _user != null
        ? _firestore.collection('users').doc(_user!.uid).snapshots()
        : const Stream.empty();

    _transactionsStream = _user != null
        ? _firestore
              .collection('transactions')
              .where('userId', isEqualTo: _user!.uid)
              .orderBy('createdAt', descending: true)
              .limit(5)
              .snapshots()
        : const Stream.empty();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  User? get _user => _auth.currentUser;

  // ── Logout ──────────────────────────────────────────────────────────────────

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: _kGreyText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _auth.signOut();
      if (mounted) context.go('/signin');
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      bottomNavigationBar: const AppFooter(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder: (context, userSnap) {
          final userData = userSnap.data?.data() as Map<String, dynamic>?;

          return CustomScrollView(
            slivers: [
              _buildAppBar(userData),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTabBar(),
                    _buildTabContent(userData),
                    AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, _) {
                        if (_tabController.index == 0) {
                          return const SizedBox.shrink();
                        }
                        return _buildTransactionSection();
                      },
                    ),
                    _buildMenuSection(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Sliver App Bar / Header ──────────────────────────────────────────────────

  SliverAppBar _buildAppBar(Map<String, dynamic>? userData) {
    final displayName =
        userData?['firstName'] ?? _user?.displayName ?? 'User Name';
    final email = userData?['email'] ?? _user?.email ?? '';
    final photoUrl = userData?['avatarUrl'] ?? _user?.photoURL;

    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // Uses AppTheme.backgroundDark for the deep end of the gradient
              colors: [AppTheme.backgroundDark, AppTheme.primaryColor],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white24,
                        backgroundImage: photoUrl != null
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl == null
                            ? Text(
                                displayName.isNotEmpty
                                    ? displayName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Name & Email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification bell
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: navigate to notifications screen
                        },
                        icon: const Icon(
                          Icons.notifications_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab Bar ──────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: _kGreyText,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'User Details'),
          Tab(text: 'Hostel Details'),
        ],
        onTap: (_) => setState(() {}),
      ),
    );
  }

  // ── Tab Content ──────────────────────────────────────────────────────────────

  Widget _buildTabContent(Map<String, dynamic>? userData) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        if (_tabController.index == 0) {
          return _UserDetailsTab(
            userData: userData,
            userId: _user?.uid,
            firestore: _firestore,
          );
        } else {
          return _HostelDetailsTab(userId: _user?.uid, firestore: _firestore);
        }
      },
    );
  }

  // ── Transaction Section ──────────────────────────────────────────────────────

  Widget _buildTransactionSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Transaction History',
            icon: Icons.receipt_long_rounded,
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: _transactionsStream,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const _LoadingCard();
              }
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return const _EmptyCard(
                  icon: Icons.receipt_outlined,
                  message: 'No transactions yet',
                );
              }
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final bookingId = doc.id;
                  final paymentReference = data['paymentReference'] ?? '';
                  final status = data['status'] ?? 'confirmed';
                  final isCancelled = status == 'cancelled';
                  return _TransactionTile(data: data);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Menu Section ─────────────────────────────────────────────────────────────

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _MenuTile(
            icon: Icons.feedback_rounded,
            label: 'Complain / Feedback',
            color: AppTheme.primaryColor,
            onTap: () => _showFeedbackSheet(context),
          ),
          const SizedBox(height: 8),
          // ── Admin Info Card ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kGreenPale,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _kDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'admin@hostel.com  •  +234 000 000 0000',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ────────────────────────────────────────────────────────────────
          const SizedBox(height: 8),
          _MenuTile(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            color: Colors.red[700]!,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  // ── Feedback Bottom Sheet ─────────────────────────────────────────────────────

  void _showFeedbackSheet(BuildContext context) {
    final controller = TextEditingController();
    String? selectedType = 'Feedback';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Submit Feedback',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _kDark,
                ),
              ),
              const SizedBox(height: 14),
              // Type chips
              Row(
                children: ['Feedback', 'Complaint'].map((type) {
                  final selected = selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setSheetState(() => selectedType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primaryColor : _kGreenPale,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              // Uses AppTheme inputDecorationTheme via Theme.of(context)
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe your issue or feedback...',
                  hintStyle: const TextStyle(color: _kGreyText, fontSize: 14),
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                // Inherits ElevatedButtonThemeData from AppTheme
                child: ElevatedButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;
                    await _firestore.collection('feedback').add({
                      'userId': _user?.uid,
                      'type': selectedType,
                      'message': controller.text.trim(),
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Feedback submitted, thank you!'),
                          backgroundColor: AppTheme.primaryColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── User Details Tab ─────────────────────────────────────────────────────────

class _UserDetailsTab extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final String? userId;
  final FirebaseFirestore firestore;

  const _UserDetailsTab({
    required this.userData,
    required this.userId,
    required this.firestore,
  });

  @override
  State<_UserDetailsTab> createState() => _UserDetailsTabState();
}

class _UserDetailsTabState extends State<_UserDetailsTab> {
  bool _isEditing = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _locationCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text:
          '${widget.userData?['lastName'] ?? ''} ${widget.userData?['firstName'] ?? ''}'
              .trim(),
    );
    _phoneCtrl = TextEditingController(text: widget.userData?['phone'] ?? '');
    _locationCtrl = TextEditingController(
      text: widget.userData?['location'] ?? '',
    );
  }

  @override
  void didUpdateWidget(_UserDetailsTab old) {
    super.didUpdateWidget(old);
    if (!_isEditing) {
      _nameCtrl.text =
          '${widget.userData?['lastName'] ?? ''} ${widget.userData?['firstName'] ?? ''}'
              .trim();
      _phoneCtrl.text = widget.userData?['phone'] ?? '';
      _locationCtrl.text = widget.userData?['location'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (widget.userId == null) return;
    await widget.firestore.collection('users').doc(widget.userId).set({
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
    }, SetOptions(merge: true));
    setState(() => _isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated!'),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Info',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _kDark,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_isEditing) {
                    _save();
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _isEditing ? AppTheme.primaryColor : _kGreenPale,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                        size: 14,
                        color: _isEditing
                            ? Colors.white
                            : AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isEditing ? 'Save' : 'Edit',
                        style: TextStyle(
                          color: _isEditing
                              ? Colors.white
                              : AppTheme.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isEditing) ...[
            _editField(_nameCtrl, 'Full Name', Icons.person_outline_rounded),
            const SizedBox(height: 10),
            _editField(_phoneCtrl, 'Phone Number', Icons.phone_outlined),
            const SizedBox(height: 10),
            _editField(_locationCtrl, 'Location', Icons.location_on_outlined),
          ] else ...[
            _infoRow(
              Icons.person_rounded,
              'Name',
              widget.userData?['name'] ?? 'Not set',
            ),
            _infoRow(
              Icons.email_rounded,
              'Email',
              widget.userData?['email'] ?? 'Not set',
            ),
            _infoRow(
              Icons.phone_rounded,
              'Phone',
              widget.userData?['phone'] ?? 'Not set',
            ),
            _infoRow(
              Icons.location_on_rounded,
              'Location',
              widget.userData?['location'] ?? 'Not set',
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: _kGreenPale,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _kGreyText),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _kDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Edit fields defer to AppTheme.inputDecorationTheme for base styling,
  /// then only override what differs (label colour, prefix icon colour).
  Widget _editField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.primaryColor, fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 18),
        isDense: true,
        filled: true,
        fillColor: AppTheme.backgroundLight,
      ),
    );
  }
}

// ── Widget that shows Hostel + Room from the user's latest active booking ─────
// Kept as a separate StatefulWidget so it has its own StreamBuilder lifecycle
// and does NOT cause the parent UserDetailsTab to flicker or collapse.

class _ActiveBookingInfoRow extends StatefulWidget {
  final String? userId;
  final FirebaseFirestore firestore;

  const _ActiveBookingInfoRow({required this.userId, required this.firestore});

  @override
  State<_ActiveBookingInfoRow> createState() => _ActiveBookingInfoRowState();
}

class _ActiveBookingInfoRowState extends State<_ActiveBookingInfoRow> {
  // Cache hostel names to avoid repeated Firestore reads on rebuild.
  final Map<String, String> _hostelNameCache = {};
  late Stream<QuerySnapshot> _activeBookingStream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    _activeBookingStream = widget.userId != null
        ? widget.firestore
              .collection('bookings')
              .where('userId', isEqualTo: widget.userId)
              .where('status', isEqualTo: 'confirmed')
              .orderBy('createdAt', descending: true)
              .limit(1)
              .snapshots()
        : const Stream.empty();
  }

  @override
  void didUpdateWidget(_ActiveBookingInfoRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _initStream();
    }
  }

  Future<String> _getHostelName(String hostelId) async {
    if (_hostelNameCache.containsKey(hostelId)) {
      return _hostelNameCache[hostelId]!;
    }
    final doc = await widget.firestore
        .collection('hostels')
        .doc(hostelId)
        .get();
    final name = (doc.data()?['name'] as String?) ?? 'Unknown Hostel';
    _hostelNameCache[hostelId] = name;
    return name;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userId == null) {
      return _buildRow(context, 'Hostel', 'Not set', 'Room', 'Not set');
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _activeBookingStream,
      builder: (context, snap) {
        // While loading, show placeholder rows with the same height so layout
        // does not jump.
        if (snap.connectionState == ConnectionState.waiting) {
          return _buildRow(context, 'Hostel', '...', 'Room', '...');
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildRow(
            context,
            'Hostel',
            'None assigned',
            'Room',
            'None assigned',
          );
        }

        final booking = docs.first.data() as Map<String, dynamic>;
        final hostelId = booking['hostelId'] as String?;
        final roomName = (booking['roomName'] as String?) ?? 'Not set';

        if (hostelId == null) {
          return _buildRow(context, 'Hostel', 'Not set', 'Room', roomName);
        }

        return FutureBuilder<String>(
          future: _getHostelName(hostelId),
          // initialData prevents the widget from showing empty while the future resolves.
          initialData: _hostelNameCache[hostelId] ?? '...',
          builder: (context, nameSnap) {
            final hostelName = nameSnap.data ?? '...';
            return _buildRow(context, 'Hostel', hostelName, 'Room', roomName);
          },
        );
      },
    );
  }

  Widget _buildRow(
    BuildContext context,
    String hostelLabel,
    String hostelValue,
    String roomLabel,
    String roomValue,
  ) {
    return Column(
      children: [
        _infoRowItem(
          context,
          Icons.apartment_rounded,
          hostelLabel,
          hostelValue,
        ),
        _infoRowItem(context, Icons.meeting_room_rounded, roomLabel, roomValue),
      ],
    );
  }

  Widget _infoRowItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: _kGreenPale,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _kGreyText),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _kDark,
                    fontWeight: FontWeight.w600,
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

// ─── Hostel Details Tab ───────────────────────────────────────────────────────

class _HostelDetailsTab extends StatefulWidget {
  final String? userId;
  final FirebaseFirestore firestore;

  const _HostelDetailsTab({required this.userId, required this.firestore});

  @override
  State<_HostelDetailsTab> createState() => _HostelDetailsTabState();
}

class _HostelDetailsTabState extends State<_HostelDetailsTab> {
  final Map<String, String> _hostelNameCache = {};
  final Map<String, String?> _hostelImageCache = {};
  late Stream<QuerySnapshot> _bookingsStream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    _bookingsStream = widget.userId != null
        ? widget.firestore
              .collection('bookings')
              .where('userId', isEqualTo: widget.userId)
              .orderBy('createdAt', descending: true)
              .snapshots()
        : const Stream.empty();
  }

  @override
  void didUpdateWidget(_HostelDetailsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _initStream();
    }
  }

  Future<Map<String, String?>> _getHostelData(String? hostelId) async {
    if (hostelId == null) return {'name': 'Hostel', 'imageUrl': null};
    if (_hostelNameCache.containsKey(hostelId)) {
      return {
        'name': _hostelNameCache[hostelId],
        'imageUrl': _hostelImageCache[hostelId],
      };
    }
    try {
      final doc = await widget.firestore
          .collection('hostels')
          .doc(hostelId)
          .get();
      final data = doc.data();
      final name = (data?['name'] as String?) ?? 'Hostel';
      final image = data?['imageUrl'] as String?;

      _hostelNameCache[hostelId] = name;
      _hostelImageCache[hostelId] = image;
      return {'name': name, 'imageUrl': image};
    } catch (e) {
      return {'name': 'Hostel', 'imageUrl': null};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      // ── FIX: minHeight prevents card from collapsing ──────────────────────
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 120),
        child: StreamBuilder<QuerySnapshot>(
          stream: _bookingsStream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const _LoadingCard();
            }

            final docs = snap.data?.docs ?? [];

            if (docs.isEmpty) {
              return const _EmptyCard(
                icon: Icons.hotel_outlined,
                message: 'No hostel bookings yet',
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Bookings',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _kDark,
                  ),
                ),
                const SizedBox(height: 12),
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final hostelId = data['hostelId'] as String?;

                  return FutureBuilder<Map<String, String?>>(
                    future: _getHostelData(hostelId),
                    initialData: _hostelNameCache.containsKey(hostelId)
                        ? {
                            'name': _hostelNameCache[hostelId],
                            'imageUrl': _hostelImageCache[hostelId],
                          }
                        : null,
                    builder: (context, snapshot) {
                      final hostelName = snapshot.data?['name'] ?? 'Loading...';
                      final imageUrl = snapshot.data?['imageUrl'];

                      return _BookingTile(
                        key: ValueKey(doc.id),
                        data: data,
                        docId: doc.id,
                        firestore: widget.firestore,
                        hostelName: hostelName,
                        imageUrl: imageUrl,
                      );
                    },
                  );
                }),
              ],
            ); // closes Column
          }, // closes builder: (context, snap) {
        ), // closes StreamBuilder(
      ), // closes ConstrainedBox(
    ); // closes Container(
  } // closes build()
} // closes _HostelDetailsTabState

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: _kDark,
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TransactionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final type = data['type'] ?? 'Payment';
    final amount = data['amount']?.toString() ?? '0';
    final status = data['status'] ?? 'completed';
    final isSuccess = status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSuccess ? _kGreenPale : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check_rounded : Icons.close_rounded,
              color: isSuccess ? AppTheme.primaryColor : Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _kDark,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSuccess ? AppTheme.primaryColor : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₦$amount',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: _kDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final FirebaseFirestore firestore;
  final String? hostelName; // optional — pre-fetched by parent
  final String? imageUrl; // optional — pre-fetched by parent

  const _BookingTile({
    super.key,
    required this.data,
    required this.docId,
    required this.firestore,
    this.hostelName,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hostelId = data['hostelId'] as String?;
    final roomName = data['roomName'] ?? 'Room';
    final status = data['status'] ?? 'confirmed';
    final isActive = status != 'cancelled';

    final bookingId = docId;
    final paymentReference = data['paymentReference'] ?? '';
    final isCancelled = status == 'cancelled';

    // Use pre-fetched hostelName/imageUrl if provided, otherwise fetch inline.
    if (hostelName != null) {
      return _buildTile(
        context,
        hostelName: hostelName!,
        imageUrl: imageUrl,
        roomName: roomName,
        status: status,
        isActive: isActive,
        bookingId: bookingId,
        paymentReference: paymentReference,
        isCancelled: isCancelled,
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: hostelId != null
          ? firestore.collection('hostels').doc(hostelId).get()
          : null,
      builder: (context, snap) {
        final hostelData = snap.data?.data() as Map<String, dynamic>?;
        return _buildTile(
          context,
          hostelName: hostelData?['name'] ?? 'Hostel',
          imageUrl: hostelData?['imageUrl'] as String?,
          roomName: roomName,
          status: status,
          isActive: isActive,
          bookingId: bookingId,
          paymentReference: paymentReference,
          isCancelled: isCancelled,
        );
      },
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String hostelName,
    required String? imageUrl,
    required String roomName,
    required String status,
    required bool isActive,
    required String bookingId,
    required String paymentReference,
    required bool isCancelled,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? _kGreenLight : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= ROW =================
          Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                ),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 72,
                        height: 72,
                        color: _kGreenPale,
                        child: Icon(
                          Icons.hotel_rounded,
                          color: AppTheme.primaryColor,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hostelName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _kDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        roomName,
                        style: const TextStyle(color: _kGreyText, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? _kGreenPale : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isActive ? AppTheme.primaryColor : _kGreyText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          CancelButton(
            bookingId: bookingId,
            paymentReference: paymentReference,
            isCancelled: isCancelled,
            hostelName: hostelName,
            roomName: roomName,
            imageUrl: data['imageUrl'] ?? '',
            amount: (data['amount'] ?? 0).toDouble(),
            createdAt: (data['createdAt'] as Timestamp).toDate(),
          ),
        ],
      ),
    );
  } // closes _buildTile
} // closes _BookingTile

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(icon, color: _kGreenLight, size: 36),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: _kGreyText),
            ),
          ],
        ),
      ),
    );
  }
}
