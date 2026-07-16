import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

/// -----------------------------------------------------------------------
/// NexCampus - College Information Screen
/// Madan Bhandari College of Engineering (MBCOE)
/// -----------------------------------------------------------------------

class CollegeInformationScreen extends StatefulWidget {
  const CollegeInformationScreen({super.key});

  @override
  State<CollegeInformationScreen> createState() =>
      _CollegeInformationScreenState();
}

class _CollegeInformationScreenState extends State<CollegeInformationScreen> {
  static const String collegeName = 'Madan Bhandari College of Engineering';
  static const String collegeShortName = 'MBCOE';
  static const String institutionName = 'Madan Bhandari Memorial Academy Nepal';
  static const String institutionShortName = 'MBMAN';
  static const String collegeAddress =
      'Urlabari-3, Morang, Koshi Province, Nepal';
  static const String collegePhone = '+977-021-000000';
  static const String collegeEmail = 'info@mbman.edu.np';
  static const String collegeWebsite = 'https://mbman.edu.np';
  static const String collegeAboutUrl = 'https://mbman.edu.np/about.php';
  static const String affiliation = 'Pokhara University';
  static const double collegeLat = 26.662031;
  static const double collegeLng = 87.599602;

  final LatLng collegeLocation = const LatLng(collegeLat, collegeLng);
  final MapController _mapController = MapController();
  bool _isFavorite = false;

  final List<_ProgramItem> _programs = const [
    _ProgramItem(
      name: 'B.E. in Computer Engineering',
      icon: Icons.computer_rounded,
    ),
    _ProgramItem(
      name: 'B.E. in Civil Engineering',
      icon: Icons.foundation_rounded,
    ),
  ];

  final List<_FacilityItem> _facilities = const [
    _FacilityItem(name: 'Library', icon: Icons.local_library_rounded),
    _FacilityItem(name: 'Computer Labs', icon: Icons.desktop_windows_rounded),
    _FacilityItem(
      name: 'Engineering Labs',
      icon: Icons.precision_manufacturing_rounded,
    ),
    _FacilityItem(name: 'Wi-Fi Campus', icon: Icons.wifi_rounded),
    _FacilityItem(name: 'Sports Ground', icon: Icons.sports_soccer_rounded),
    _FacilityItem(
      name: 'Smart Classrooms',
      icon: Icons.cast_for_education_rounded,
    ),
    _FacilityItem(name: 'Seminar Hall', icon: Icons.meeting_room_rounded),
    _FacilityItem(
      name: 'Transportation',
      icon: Icons.directions_bus_filled_rounded,
    ),
    _FacilityItem(name: 'Cafeteria', icon: Icons.restaurant_rounded),
    _FacilityItem(name: 'Hostel', icon: Icons.apartment_rounded),
  ];

  final List<_LeaderItem> _leaders = const [
    _LeaderItem(
      title: 'Executive Director & Principal',
      name: 'Prof. Binod Aryal',
      subtitle: 'Madan Bhandari Memorial Academy Nepal',
    ),
  ];

  Future<void> _launchUri(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${uri.toString()}')),
      );
    }
  }

  Future<void> _openWebsite() => _launchUri(Uri.parse(collegeWebsite));

  Future<void> _callCollege() =>
      _launchUri(Uri(scheme: 'tel', path: collegePhone));

  Future<void> _emailCollege() =>
      _launchUri(Uri(scheme: 'mailto', path: collegeEmail));

  Future<void> _openLocation() {
    final Uri uri = Uri.parse(
      'https://www.openstreetmap.org/?mlat=$collegeLat&mlon=$collegeLng#map=17/$collegeLat/$collegeLng',
    );
    return _launchUri(uri);
  }

  Future<void> _getDirections() {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$collegeLat,$collegeLng',
    );
    return _launchUri(uri);
  }

  void _shareCollege() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share College',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  '$collegeName ($collegeShortName)\n$collegeAddress\n$collegeWebsite',
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(scheme),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickActionsRow(scheme),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    'About College',
                    Icons.info_outline_rounded,
                  ),
                  _buildInfoCard(
                    scheme: scheme,
                    child: Text(
                      '$collegeName ($collegeShortName) is a constituent engineering '
                      'college under $institutionName ($institutionShortName), '
                      'affiliated with $affiliation. Located in $collegeAddress, '
                      'the college is committed to delivering quality technical '
                      'education through modern infrastructure, experienced faculty, '
                      'and an innovation-driven learning environment. For the most '
                      'up-to-date information, please visit the official about page '
                      'at $collegeAboutUrl.',
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        height: 1.6,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Vision', Icons.visibility_rounded),
                  _buildInfoCard(
                    scheme: scheme,
                    child: Text(
                      'To be a center of excellence in engineering education, '
                      'producing globally competent, innovative, and ethical '
                      'engineers who contribute to national and international '
                      'development.',
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        height: 1.6,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Mission', Icons.flag_rounded),
                  _buildInfoCard(
                    scheme: scheme,
                    child: Text(
                      'To provide accessible, high-quality technical education '
                      'through modern curricula, skilled faculty, industry '
                      'collaboration, and a supportive campus environment that '
                      'nurtures creativity, leadership, and lifelong learning.',
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        height: 1.6,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Core Values', Icons.diamond_outlined),
                  _buildInfoCard(
                    scheme: scheme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _CoreValueRow(
                          icon: Icons.emoji_events_rounded,
                          label: 'Excellence in academics and research',
                        ),
                        _CoreValueRow(
                          icon: Icons.handshake_rounded,
                          label: 'Integrity and ethical responsibility',
                        ),
                        _CoreValueRow(
                          icon: Icons.groups_rounded,
                          label: 'Inclusivity and collaboration',
                        ),
                        _CoreValueRow(
                          icon: Icons.lightbulb_rounded,
                          label: 'Innovation and continuous improvement',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Programs Offered', Icons.school_rounded),
                  _buildInfoCard(
                    scheme: scheme,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: List.generate(_programs.length, (index) {
                        final program = _programs[index];
                        return Column(
                          children: [
                            _buildProgramTile(scheme, program),
                            if (index != _programs.length - 1)
                              Divider(
                                height: 1,
                                indent: 56,
                                color: scheme.outlineVariant.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle(
                    'Campus Facilities',
                    Icons.apartment_rounded,
                  ),
                  _buildFacilityGrid(scheme),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Leadership', Icons.badge_rounded),
                  Column(
                    children: _leaders
                        .map(
                          (leader) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildLeaderCard(scheme, leader),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  _buildSectionTitle(
                    'Contact Information',
                    Icons.contact_page_rounded,
                  ),
                  _buildInfoCard(
                    scheme: scheme,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        _buildContactTile(
                          scheme: scheme,
                          icon: Icons.location_on_rounded,
                          label: 'Address',
                          value: collegeAddress,
                          onTap: _openLocation,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildContactTile(
                          scheme: scheme,
                          icon: Icons.phone_rounded,
                          label: 'Phone',
                          value: collegePhone,
                          onTap: _callCollege,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildContactTile(
                          scheme: scheme,
                          icon: Icons.email_rounded,
                          label: 'Email',
                          value: collegeEmail,
                          onTap: _emailCollege,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildContactTile(
                          scheme: scheme,
                          icon: Icons.language_rounded,
                          label: 'Website',
                          value: collegeWebsite,
                          onTap: _openWebsite,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Campus Location', Icons.map_rounded),
                  _buildMapCard(scheme),
                  const SizedBox(height: 28),
                  _buildFooter(scheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Sliver App Bar with Hero Section
  // ---------------------------------------------------------------------
  Widget _buildSliverAppBar(ColorScheme scheme) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 280,
      backgroundColor: scheme.surface,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.35),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: 0.35),
            child: IconButton(
              icon: Icon(
                _isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _isFavorite ? Colors.redAccent : Colors.white,
              ),
              tooltip: 'Favorite',
              onPressed: () => setState(() => _isFavorite = !_isFavorite),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: 0.35),
            child: IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              tooltip: 'Share',
              onPressed: _shareCollege,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary,
                scheme.primary.withValues(alpha: 0.85),
                scheme.tertiary.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                left: -60,
                bottom: -30,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'college-logo',
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          child: Text(
                            collegeShortName.substring(0, 1),
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        collegeShortName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        collegeName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Engineering • Innovation • Excellence',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      title: null,
    );
  }

  // ---------------------------------------------------------------------
  // Quick Actions Row
  // ---------------------------------------------------------------------
  Widget _buildQuickActionsRow(ColorScheme scheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildQuickActionButton(
            scheme: scheme,
            icon: Icons.public_rounded,
            label: 'Website',
            onTap: _openWebsite,
          ),
          const SizedBox(width: 10),
          _buildQuickActionButton(
            scheme: scheme,
            icon: Icons.call_rounded,
            label: 'Call',
            onTap: _callCollege,
          ),
          const SizedBox(width: 10),
          _buildQuickActionButton(
            scheme: scheme,
            icon: Icons.email_rounded,
            label: 'Email',
            onTap: _emailCollege,
          ),
          const SizedBox(width: 10),
          _buildQuickActionButton(
            scheme: scheme,
            icon: Icons.location_on_rounded,
            label: 'Location',
            onTap: _openLocation,
          ),
          const SizedBox(width: 10),
          _buildQuickActionButton(
            scheme: scheme,
            icon: Icons.ios_share_rounded,
            label: 'Share',
            onTap: _shareCollege,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required ColorScheme scheme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: scheme.primaryContainer.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: scheme.primary, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Section Title
  // ---------------------------------------------------------------------
  Widget _buildSectionTitle(String title, IconData icon) {
    return Builder(
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // Generic Info Card
  // ---------------------------------------------------------------------
  Widget _buildInfoCard({
    required ColorScheme scheme,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ---------------------------------------------------------------------
  // Program Tile
  // ---------------------------------------------------------------------
  Widget _buildProgramTile(ColorScheme scheme, _ProgramItem program) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        child: Icon(program.icon, color: scheme.primary, size: 20),
      ),
      title: Text(
        program.name,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
    );
  }

  // ---------------------------------------------------------------------
  // Facility Grid
  // ---------------------------------------------------------------------
  Widget _buildFacilityGrid(ColorScheme scheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = constraints.maxWidth > 700
            ? 4
            : constraints.maxWidth > 480
            ? 3
            : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _facilities.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            final facility = _facilities[index];
            return Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      facility.icon,
                      color: scheme.onSecondaryContainer,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    facility.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // Leader Card
  // ---------------------------------------------------------------------
  Widget _buildLeaderCard(ColorScheme scheme, _LeaderItem leader) {
    return _buildInfoCard(
      scheme: scheme,
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: scheme.primaryContainer,
            child: Icon(Icons.person_rounded, color: scheme.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leader.title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.primary,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  leader.name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  leader.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Contact Tile
  // ---------------------------------------------------------------------
  Widget _buildContactTile({
    required ColorScheme scheme,
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        child: Icon(icon, color: scheme.primary, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, color: scheme.onSurfaceVariant),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
    );
  }

  // ---------------------------------------------------------------------
  // Map Card
  // ---------------------------------------------------------------------
  Widget _buildMapCard(ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 240,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: collegeLocation,
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.nexcampus.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: collegeLocation,
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.location_on_rounded,
                            color: scheme.error,
                            size: 44,
                          ),
                        ),
                      ],
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () => _launchUri(
                            Uri.parse('https://openstreetmap.org/copyright'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Column(
                    children: [
                      _MapZoomButton(
                        icon: Icons.add_rounded,
                        onTap: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom + 1,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _MapZoomButton(
                        icon: Icons.remove_rounded,
                        onTap: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom - 1,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: scheme.surfaceContainerLow,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    collegeAddress,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _getDirections,
                  icon: const Icon(Icons.directions_rounded, size: 18),
                  label: const Text('Get Directions'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Footer
  // ---------------------------------------------------------------------
  Widget _buildFooter(ColorScheme scheme) {
    return Center(
      child: Column(
        children: [
          Divider(color: scheme.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            '© ${DateTime.now().year} $institutionShortName. All rights reserved.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Developed using NexCampus',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Supporting Models
// ---------------------------------------------------------------------
class _ProgramItem {
  final String name;
  final IconData icon;

  const _ProgramItem({required this.name, required this.icon});
}

class _FacilityItem {
  final String name;
  final IconData icon;

  const _FacilityItem({required this.name, required this.icon});
}

class _LeaderItem {
  final String title;
  final String name;
  final String subtitle;

  const _LeaderItem({
    required this.title,
    required this.name,
    required this.subtitle,
  });
}

// ---------------------------------------------------------------------
// Core Value Row Widget
// ---------------------------------------------------------------------
class _CoreValueRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CoreValueRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.4,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Map Zoom Button Widget
// ---------------------------------------------------------------------
class _MapZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: scheme.onSurface),
        ),
      ),
    );
  }
}
