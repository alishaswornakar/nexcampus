import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart ';
import 'package:nexcampus_app/features/student/blocs/attendance/models/attendance_model.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/bloc/attendance_bloc.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/bloc/attendance_event.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/bloc/attendance_state.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/repository/attendance_repository.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/widgets/attendance_summary_card.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/widgets/attendance_record_card.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/widgets/attendance_calendar.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/widgets/attendance_filter.dart';

class AttendanceScreen extends StatelessWidget {
  final String studentId;

  const AttendanceScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AttendanceBloc(repository: AttendanceRepository())
            ..add(ListenAttendance(studentId)),
      child: _AttendanceView(studentId: studentId),
    );
  }
}

class _AttendanceView extends StatefulWidget {
  final String studentId;

  const _AttendanceView({required this.studentId});

  @override
  State<_AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<_AttendanceView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _recordKeys = {};

  bool _isSearching = false;
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<AttendanceModel> _applyFilters(List<AttendanceModel> source) {
    List<AttendanceModel> result = List.from(source);

    final DateTime? fromDate = _activeFilters['fromDate'];
    final DateTime? toDate = _activeFilters['toDate'];
    final String? status = _activeFilters['status'];
    final String? month = _activeFilters['month'];
    final String? year = _activeFilters['year'];

    if (fromDate != null) {
      result = result
          .where(
            (a) => !a.date.isBefore(
              DateTime(fromDate.year, fromDate.month, fromDate.day),
            ),
          )
          .toList();
    }

    if (toDate != null) {
      result = result
          .where(
            (a) => !a.date.isAfter(
              DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59),
            ),
          )
          .toList();
    }

    if (status != null && status.isNotEmpty && status != 'All') {
      result = result
          .where((a) => a.status.toLowerCase() == status.toLowerCase())
          .toList();
    }

    if (month != null && month.isNotEmpty && month != 'All') {
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      final monthIndex = months.indexOf(month) + 1;
      if (monthIndex > 0) {
        result = result.where((a) => a.date.month == monthIndex).toList();
      }
    }

    if (year != null && year.isNotEmpty) {
      final parsedYear = int.tryParse(year);
      if (parsedYear != null) {
        result = result.where((a) => a.date.year == parsedYear).toList();
      }
    }

    return _searchAttendance(result);
  }

  List<AttendanceModel> _searchAttendance(List<AttendanceModel> source) {
    if (_searchQuery.trim().isEmpty) return source;

    final query = _searchQuery.trim().toLowerCase();

    return source.where((attendance) {
      final statusMatch = attendance.status.toLowerCase().contains(query);
      final remarksMatch = attendance.remarks.toLowerCase().contains(query);
      final dateMatch =
          '${attendance.date.day}/${attendance.date.month}/${attendance.date.year}'
              .contains(query);

      return statusMatch || remarksMatch || dateMatch;
    }).toList();
  }

  List<AttendanceModel> _sortNewestFirst(List<AttendanceModel> source) {
    final sorted = List<AttendanceModel>.from(source);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  Future<void> _refreshAttendance() async {
    context.read<AttendanceBloc>().add(LoadAttendance(widget.studentId));
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> _openFilter() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceFilterScreen(initialFilters: _activeFilters),
      ),
    );

    if (result != null) {
      setState(() {
        _activeFilters = result;
      });
    }
  }

  void _scrollToSelectedAttendance(
    DateTime day,
    List<AttendanceModel> visibleList,
  ) {
    AttendanceModel? match;

    for (final attendance in visibleList) {
      if (attendance.date.year == day.year &&
          attendance.date.month == day.month &&
          attendance.date.day == day.day) {
        match = attendance;
        break;
      }
    }

    if (match == null) return;

    final key = _recordKeys[match.id];
    final keyContext = key?.currentContext;

    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'refresh':
        context.read<AttendanceBloc>().add(ListenAttendance(widget.studentId));
        break;
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export feature is not available yet.')),
        );
        break;
      case 'settings':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance settings are not available yet.'),
          ),
        );
        break;
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: _isSearching
          ? _buildSearchField()
          : const Text('Attendance', style: TextStyle(color: Colors.white)),
      backgroundColor: AppTheme.secondary,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(
            context,
          ).pop(); //navigates back to the previous screen when the back button is pressed
          // Handle back button press
        },
      ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              if (_isSearching) {
                _isSearching = false;
                _searchQuery = '';
                _searchController.clear();
              } else {
                _isSearching = true;
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_alt_outlined),
          onPressed: _openFilter,
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuSelection,
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'refresh', child: Text('Refresh')),
            PopupMenuItem(value: 'export', child: Text('Export')),
            PopupMenuItem(value: 'settings', child: Text('Settings')),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        hintText: 'Search by status, remarks or date',
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildLoading() {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError(String message) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AttendanceBloc>().add(
                    ListenAttendance(widget.studentId),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No attendance records found.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(List<AttendanceModel> fullList) {
    final total = fullList.length;
    final present = fullList
        .where((a) => a.status.toLowerCase() == 'present')
        .length;
    final absent = fullList
        .where((a) => a.status.toLowerCase() == 'absent')
        .length;
    final late = fullList.where((a) => a.status.toLowerCase() == 'late').length;

    return AttendanceSummaryCard(
      totalClasses: total,
      present: present,
      absent: absent,
      late: late,
    );
  }

  Widget _buildCalendar(
    List<AttendanceModel> fullList,
    List<AttendanceModel> visibleList,
  ) {
    return AttendanceCalendar(
      attendanceList: fullList,
      onDaySelected: (day) => _scrollToSelectedAttendance(day, visibleList),
    );
  }

  Widget _buildAttendanceList(List<AttendanceModel> visibleList) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final attendance = visibleList[index];
        final key = _recordKeys.putIfAbsent(attendance.id, () => GlobalKey());

        return TweenAnimationBuilder<double>(
          key: ValueKey(attendance.id),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 40)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 20),
                child: child,
              ),
            );
          },
          child: Container(
            key: key,
            child: AttendanceRecordCard(attendance: attendance),
          ),
        );
      }, childCount: visibleList.length),
    );
  }

  Widget _buildContent(List<AttendanceModel> fullList) {
    final visibleList = _sortNewestFirst(_applyFilters(fullList));

    if (visibleList.isEmpty) {
      return CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [_buildEmpty()],
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildSummary(fullList)),
        SliverToBoxAdapter(child: _buildCalendar(fullList, visibleList)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Recent Attendance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        _buildAttendanceList(visibleList),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AttendanceSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AttendanceLoading || state is AttendanceInitial) {
            return CustomScrollView(slivers: [_buildLoading()]);
          }

          if (state is AttendanceError) {
            return CustomScrollView(slivers: [_buildError(state.message)]);
          }

          List<AttendanceModel> fullList = [];
          if (state is AttendanceLoaded) {
            fullList = state.attendanceList;
          }

          return RefreshIndicator(
            onRefresh: _refreshAttendance,
            child: _buildContent(fullList),
          );
        },
      ),
    );
  }
}
