import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/admin/models/teacher_model.dart';

class TeacherListScreen extends StatefulWidget {
  const TeacherListScreen({super.key});

  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? _selectedDepartment;

  final List<String> _departments = ['Computer', 'Civil', 'Architecture'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✏️ TEACHER DATA EDIT UPDATE DIALOG
  void _showEditTeacherDialog(TeacherModel teacher) {
    final nameController = TextEditingController(text: teacher.name);
    final emailController = TextEditingController(text: teacher.email);
    final phoneController = TextEditingController(text: teacher.phone);
    final addressController = TextEditingController(text: teacher.address);
    final qualController = TextEditingController(text: teacher.qualification);
    String selectedDept = teacher.department;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text("Edit ${teacher.name}"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                      initialValue: _departments.contains(selectedDept)
                          ? selectedDept
                          : _departments.first,
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
                    TextField(
                      controller: qualController,
                      decoration: const InputDecoration(
                        labelText: "Qualification",
                      ),
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
                      await _db
                          .collection('teacherData')
                          .doc(teacher.id)
                          .update({
                            'name': nameController.text.trim(),
                            'email': emailController.text.trim(),
                            'phone': phoneController.text.trim(),
                            'address': addressController.text.trim(),
                            'department': selectedDept,
                            'qualification': qualController.text.trim(),
                          });

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Teacher details updated successfully!",
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

  // 🗑️ TEACHER DELETE CONFIRMATION DIALOG
  void _confirmDeleteTeacher(TeacherModel teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Teacher"),
        content: Text("Are you sure you want to delete ${teacher.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await _db.collection('teacherData').doc(teacher.id).delete();
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${teacher.name} has been deleted."),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Teacher Directory",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Search & Filter Section (polished card)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 🔍 Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search by name or Teacher ID...",
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

                  // Department Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDepartment,
                    hint: const Text("All Departments"),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text("All Departments"),
                      ),
                      ..._departments.map((dept) {
                        return DropdownMenuItem(value: dept, child: Text(dept));
                      }),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedDepartment = val);
                    },
                  ),
                ],
              ),
            ),
          ),

          // StreamBuilder for Firestore Realtime List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('teacherData').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: _db.collection('teachers').snapshots(),
                    builder: (context, altSnapshot) {
                      if (altSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!altSnapshot.hasData ||
                          altSnapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("No teachers found in database."),
                        );
                      }
                      return _buildTeacherList(
                        altSnapshot.data!.docs,
                        primaryColor,
                      );
                    },
                  );
                }

                return _buildTeacherList(snapshot.data!.docs, primaryColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherList(
    List<QueryDocumentSnapshot> docs,
    Color primaryColor,
  ) {
    final List<TeacherModel> allTeachers = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return TeacherModel.fromMap(data, doc.id);
    }).toList();

    // Filter Logic
    final filteredTeachers = allTeachers.where((teacher) {
      if (_searchQuery.isNotEmpty) {
        final matchesName = teacher.name.toLowerCase().contains(_searchQuery);
        final matchesId = teacher.teacherId.toLowerCase().contains(
          _searchQuery,
        );
        if (!matchesName && !matchesId) return false;
      }

      if (_selectedDepartment != null &&
          _selectedDepartment!.isNotEmpty &&
          teacher.department.toLowerCase().trim() !=
              _selectedDepartment!.toLowerCase().trim()) {
        return false;
      }

      return true;
    }).toList();

    // 📊 Header Card Label Logic
    bool hasFilter = _selectedDepartment != null || _searchQuery.isNotEmpty;
    String filterText = "Overall Total";
    if (hasFilter) {
      if (_selectedDepartment != null && _selectedDepartment!.isNotEmpty) {
        filterText = "${_selectedDepartment!} Department";
      } else {
        filterText = "Search Result";
      }
    }

    return Column(
      children: [
        // 📊 TOTAL TEACHERS COUNT HEADER CARD
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha:0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha:0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      color: Colors.orange,
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
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${filteredTeachers.length} Teachers",
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

        // 📜 List View / Empty State
        Expanded(
          child: filteredTeachers.isEmpty
              ? const Center(
                  child: Text(
                    "No matching teachers found.",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredTeachers.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final teacher = filteredTeachers[index];

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
                            // Avatar Circle
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.orange.withValues(alpha:0.1),
                              child: Text(
                                teacher.name.isNotEmpty
                                    ? teacher.name[0].toUpperCase()
                                    : 'T',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Details Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name & Teacher ID Badge
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          teacher.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (teacher.teacherId.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: Colors.blue.shade200,
                                            ),
                                          ),
                                          child: Text(
                                            "Teacher ID: ${teacher.teacherId}",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  Text(
                                    "📧 ${teacher.email}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "📞 ${teacher.phone}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),

                                  if (teacher.address.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      "🏠 ${teacher.address}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 4),
                                  Text(
                                    "🏛️ Dept: ${teacher.department} | 🎓 Qual: ${teacher.qualification}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 📌 THREE DOTS MENU (Edit / Delete Options)
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.grey,
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditTeacherDialog(teacher);
                                } else if (value == 'delete') {
                                  _confirmDeleteTeacher(teacher);
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
                                        "Delete Teacher",
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
}
