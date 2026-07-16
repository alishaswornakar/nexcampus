import 'package:flutter/material.dart';

class AttendanceFilterScreen extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;

  const AttendanceFilterScreen({super.key, this.initialFilters});

  @override
  State<AttendanceFilterScreen> createState() => _AttendanceFilterScreenState();
}

class _AttendanceFilterScreenState extends State<AttendanceFilterScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;

  String? _selectedStatus;
  String? _selectedMonth;
  String? _selectedYear;

  final List<String> statuses = const [
    'All',
    'Present',
    'Absent',
    'Late',
    'Leave',
  ];

  final List<String> months = const [
    'All',
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

  final List<String> years = const ['2024', '2025', '2026', '2027'];

  @override
  void initState() {
    super.initState();

    final filters = widget.initialFilters;

    if (filters != null) {
      _fromDate = filters['fromDate'];
      _toDate = filters['toDate'];
      _selectedStatus = filters['status'];
      _selectedMonth = filters['month'];
      _selectedYear = filters['year'];
    }
  }

  Future<void> _pickDate(bool isFromDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked == null) return;

    setState(() {
      if (isFromDate) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
    });
  }

  void _applyFilter() {
    Navigator.pop(context, {
      'fromDate': _fromDate,
      'toDate': _toDate,
      'status': _selectedStatus,
      'month': _selectedMonth,
      'year': _selectedYear,
    });
  }

  void _clearFilter() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _selectedStatus = 'All';
      _selectedMonth = 'All';
      _selectedYear = null;
    });
  }

  Widget _buildDateTile(String title, DateTime? date, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        date == null ? 'Select Date' : '${date.day}/${date.month}/${date.year}',
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Filter')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDateTile('From Date', _fromDate, () => _pickDate(true)),

          _buildDateTile('To Date', _toDate, () => _pickDate(false)),

          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            initialValue: _selectedStatus ?? 'All',
            decoration: const InputDecoration(labelText: 'Status'),
            items: statuses
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            initialValue: _selectedMonth ?? 'All',
            decoration: const InputDecoration(labelText: 'Month'),
            items: months
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedMonth = value;
              });
            },
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            initialValue: _selectedYear,
            decoration: const InputDecoration(labelText: 'Academic Year'),
            items: years
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedYear = value;
              });
            },
          ),

          const SizedBox(height: 30),

          ElevatedButton.icon(
            onPressed: _applyFilter,
            icon: const Icon(Icons.filter_alt),
            label: const Text('Apply Filter'),
          ),

          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: _clearFilter,
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Filter'),
          ),
        ],
      ),
    );
  }
}
