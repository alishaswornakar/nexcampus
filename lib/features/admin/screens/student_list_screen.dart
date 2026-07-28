import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Search Controller
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Filter Selection Variables
  String? _selectedDepartment;
  String? _selectedSemester;
  String? _selectedSection;

  final List<String> _departments = ['Computer', 'Civil', 'Architecture'];
  final List<String> _sections = ['A', 'B', 'C', 'D', 'E'];

  List<String> _getSemesterList() {
    if (_selectedDepartment == 'Architecture') {
      return List.generate(10, (index) => (index + 1).toString());
    }
    return List.generate(8, (index) => (index + 1).toString());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✏️ STUDENT EDIT / UPDATE DIALOG
  void _showEditStudentDialog(Map<String, dynamic> data) {
    final docId = data['docId'];
    final nameController = TextEditingController(
      text: data['name'] ?? data['fullName'] ?? '',
    );
    final emailController = TextEditingController(text: data['email'] ?? '');
    final rollController = TextEditingController(
      text: data['rollNo'] ?? data['roll'] ?? '',
    );
    final phoneController = TextEditingController(text: data['phone'] ?? '');
    final addressController = TextEditingController(
      text: data['address'] ?? '',
    );

    String selectedDept = data['department'] ?? 'Computer';
    String selectedSem = (data['semester'] ?? '1').toString().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    String selectedSec = (data['section'] ?? 'A')
        .toString()
        .replaceAll(RegExp(r'[^A-Ea-e]'), '')
        .toUpperCase();

    if (!_departments.contains(selectedDept)) selectedDept = _departments.first;
    if (!_sections.contains(selectedSec)) selectedSec = _sections.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final availableSemesters = selectedDept == 'Architecture'
                ? List.generate(10, (i) => (i + 1).toString())
                : List.generate(8, (i) => (i + 1).toString());

            if (!availableSemesters.contains(selectedSem)) {
              selectedSem = availableSemesters.first;
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text("Edit Student Details"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: rollController,
                      decoration: const InputDecoration(labelText: "Roll No"),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Full Name"),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email Address",
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: "Address"),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedDept,
                      decoration: const InputDecoration(
                        labelText: "Department",
                      ),
                      items: _departments.map((dept) {
                        return DropdownMenuItem(value: dept, child: Text(dept));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedDept = val);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedSem,
                            decoration: const InputDecoration(
                              labelText: "Semester",
                            ),
                            items: availableSemesters.map((sem) {
                              return DropdownMenuItem(
                                value: sem,
                                child: Text("Sem $sem"),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => selectedSem = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedSec,
                            decoration: const InputDecoration(
                              labelText: "Section",
                            ),
                            items: _sections.map((sec) {
                              return DropdownMenuItem(
                                value: sec,
                                child: Text("Sec $sec"),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => selectedSec = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor ?? Colors.blue,
                  ),
                  onPressed: () async {
                    try {
                      final updateData = {
                        'name': nameController.text.trim(),
                        'fullName': nameController.text.trim(),
                        'email': emailController.text.trim(),
                        'rollNo': rollController.text.trim(),
                        'roll': rollController.text.trim(),
                        'phone': phoneController.text.trim(),
                        'address': addressController.text.trim(),
                        'department': selectedDept,
                        'semester': selectedSem,
                        'section': selectedSec,
                      };

                      await _db
                          .collection('studentData')
                          .doc(docId)
                          .update(updateData)
                          .catchError((_) async {
                            await _db
                                .collection('students')
                                .doc(docId)
                                .update(updateData);
                          });

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Student details updated successfully!",
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Failed to update: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Save Updates",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 🗑️ DELETE CONFIRMATION DIALOG
  void _confirmDeleteStudent(String docId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Student"),
        content: Text("Are you sure you want to delete $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await _db
                    .collection('studentData')
                    .doc(docId)
                    .delete()
                    .catchError((_) async {
                      await _db.collection('students').doc(docId).delete();
                    });

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$name has been deleted."),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppTheme.primaryColor ?? Colors.blue;
    final currentSemesters = _getSemesterList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      appBar: AppBar(
        title: const Text(
          "Student Directory",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Filter & Search Box Container
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.white,
            child: Column(
              children: [
                // 🔍 Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search student by name or roll no...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = "";
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Dropdowns
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        "Department",
                        _selectedDepartment,
                        _departments,
                        (val) {
                          setState(() {
                            _selectedDepartment = val;
                            if (val != 'Architecture' &&
                                _selectedSemester != null &&
                                int.parse(_selectedSemester!) > 8) {
                              _selectedSemester = null;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDropdown(
                        "Semester",
                        _selectedSemester,
                        currentSemesters,
                        (val) {
                          setState(() => _selectedSemester = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDropdown(
                        "Section",
                        _selectedSection,
                        _sections,
                        (val) {
                          setState(() => _selectedSection = val);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // STREAM BUILDER
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('studentData').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: _db.collection('students').snapshots(),
                    builder: (context, altSnapshot) {
                      if (altSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!altSnapshot.hasData ||
                          altSnapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("No students found in database."),
                        );
                      }
                      return _buildStudentList(
                        altSnapshot.data!.docs,
                        primaryColor,
                      );
                    },
                  );
                }

                return _buildStudentList(snapshot.data!.docs, primaryColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(
    List<QueryDocumentSnapshot> docs,
    Color primaryColor,
  ) {
    final List<Map<String, dynamic>> rawList = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['docId'] = doc.id;
      return data;
    }).toList();

    // Filtering Logic
    final filteredDocs = rawList.where((data) {
      final name = (data['name'] ?? data['fullName'] ?? '')
          .toString()
          .toLowerCase()
          .trim();
      final roll = (data['rollNo'] ?? data['roll'] ?? '')
          .toString()
          .toLowerCase()
          .trim();

      if (name.isEmpty && roll.isEmpty) return false;

      // Search Query Filter
      if (_searchQuery.isNotEmpty) {
        if (!name.contains(_searchQuery) && !roll.contains(_searchQuery)) {
          return false;
        }
      }

      // Dept, Sem, Sec Filters
      final dept = (data['department'] ?? '').toString().toLowerCase().trim();
      final sem = (data['semester'] ?? '').toString().trim();
      final sec = (data['section'] ?? '').toString().toLowerCase().trim();

      if (_selectedDepartment != null && _selectedDepartment!.isNotEmpty) {
        final selectedDept = _selectedDepartment!.toLowerCase().trim();
        if (!dept.contains(selectedDept) && !selectedDept.contains(dept)) {
          return false;
        }
      }

      if (_selectedSemester != null && _selectedSemester!.isNotEmpty) {
        if (sem != _selectedSemester!.trim() &&
            sem != "Semester ${_selectedSemester!.trim()}") {
          return false;
        }
      }

      if (_selectedSection != null && _selectedSection!.isNotEmpty) {
        final selectedSec = _selectedSection!.toLowerCase().trim();
        if (sec != selectedSec && sec != "section $selectedSec") {
          return false;
        }
      }

      return true;
    }).toList();

    // 💡 Dynamic Title for Summary Banner
    bool hasFilter =
        _selectedDepartment != null ||
        _selectedSemester != null ||
        _selectedSection != null ||
        _searchQuery.isNotEmpty;

    String filterText = "Overall student";
    if (hasFilter) {
      List<String> activeFilters = [];
      if (_selectedDepartment != null) activeFilters.add(_selectedDepartment!);
      if (_selectedSemester != null) {
        activeFilters.add("Sem ${_selectedSemester!}");
      }
      if (_selectedSection != null) {
        activeFilters.add("Sec ${_selectedSection!}");
      }
      filterText = activeFilters.isNotEmpty
          ? activeFilters.join(" | ")
          : "Filtered Result";
    }

    return Column(
      children: [
        // 📊 TOTAL STUDENTS COUNT HEADER CARD
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha:0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withValues(alpha:0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people_alt_outlined,
                      color: primaryColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filterText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${filteredDocs.length} Students",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // List View
        Expanded(
          child: filteredDocs.isEmpty
              ? const Center(
                  child: Text(
                    "No matching students found.",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredDocs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index];
                    final name =
                        data['name'] ?? data['fullName'] ?? 'Unknown Student';
                    final email = data['email'] ?? 'No Email';
                    final roll = data['rollNo'] ?? data['roll'] ?? 'N/A';
                    final phone = data['phone'] ?? '';
                    final address = data['address'] ?? '';
                    final dept = data['department'] ?? 'N/A';
                    final sem = data['semester'] ?? 'N/A';
                    final sec = data['section'] ?? 'N/A';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: primaryColor.withValues(alpha:0.1),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withValues(alpha:0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: primaryColor.withValues(alpha:
                                              0.3,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "Roll: $roll",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "📧 $email",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (phone.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      "📞 $phone",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                  if (address.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      "🏠 $address",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    "🏛️ Dept: $dept | 🎓 Sem: $sem | Sec: $sec",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.grey,
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditStudentDialog(data);
                                } else if (value == 'delete') {
                                  _confirmDeleteStudent(data['docId'], name);
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text("Edit Details"),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Delete Student",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String hint,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            hint,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          value: value,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
