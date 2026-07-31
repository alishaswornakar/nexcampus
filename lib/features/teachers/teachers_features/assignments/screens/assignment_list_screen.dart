import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../models/assignment_model.dart';
import '../repository/assignment_repository.dart';
import '../services/assignment_service.dart';

import 'assignment_detail_screen.dart';
import 'create_assignment_screen.dart';

class AssignmentListScreen extends StatefulWidget {
  final String department;
  final String? semester;
  final String subject;
  final double blurRadius = 0;
  final Offset offset = const Offset(0, 0);

  const AssignmentListScreen({
    super.key,
    required this.department,
    required this.semester,
    required this.subject,
    // required this.blurRadius,
    //required this.offset,
  });

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final AssignmentRepository repository = AssignmentRepository(
    AssignmentService(),
  );

  final TextEditingController searchController = TextEditingController();

  String search = "";

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      extendBodyBehindAppBar: false,

      body: SafeArea(
        top: false, // allow status bar color control

        child: Column(
          children: [
            Container(
              width: double.infinity,

              color: AppTheme.primary,

              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                bottom: 18,
                left: size.width * 0.05,
                right: size.width * 0.05,
              ),

              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },

                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  SizedBox(width: size.width * 0.04),

                  const Text(
                    "Assignments",

                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.02),

            // SEARCH BAR
            // SEARCH BAR
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),

              child: Container(
                height: 52,

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(16),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: TextField(
                  controller: searchController,

                  onChanged: (value) {
                    setState(() {
                      search = value;
                    });
                  },

                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff20263A),
                  ),

                  decoration: InputDecoration(
                    hintText: "Search assignments",

                    hintStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),

                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 24,
                      color: Colors.black,
                    ),

                    suffixIcon: search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.grey,
                            ),

                            onPressed: () {
                              searchController.clear();

                              setState(() {
                                search = "";
                              });
                            },
                          )
                        : null,

                    border: InputBorder.none,

                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 10,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.02),

            // ASSIGNMENT LIST
            Expanded(
              child: StreamBuilder<List<AssignmentModel>>(
                stream: repository.getAssignments(
                  department: widget.department,

                  semester: widget.semester.toString(),

                  subject: widget.subject,
                ),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Assignments Yet",

                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  final assignments = snapshot.data!;

                  final filtered = assignments.where((assignment) {
                    return assignment.title.toLowerCase().contains(
                      search.toLowerCase(),
                    );
                  }).toList();

                  return ListView.builder(
                    padding: EdgeInsets.only(
                      left: size.width * 0.05,
                      right: size.width * 0.05,
                      top: 8,
                      bottom: 100,
                    ),

                    itemCount: filtered.length,

                    itemBuilder: (context, index) {
                      final assignment = filtered[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (context) => AssignmentDetailScreen(
                                assignment: assignment,
                              ),
                            ),
                          );
                        },

                        child: AssignmentTile(
                          assignment: assignment,

                          size: size,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,

        foregroundColor: Colors.white,

        icon: const Icon(Icons.add),

        label: const Text(
          "Assignment",

          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        onPressed: () {
          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (context) => CreateAssignmentScreen(
                department: widget.department,

                semester: widget.semester,

                selectedSubject: widget.subject,
              ),
            ),
          );
        },
      ),
    );
  }
}

class AssignmentTile extends StatelessWidget {
  final AssignmentModel assignment;

  final Size size;

  const AssignmentTile({
    super.key,

    required this.assignment,

    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.018),

      padding: EdgeInsets.all(size.width * 0.035),

      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],

        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Container(
                height: size.width * 0.12,

                width: size.width * 0.12,

                decoration: const BoxDecoration(
                  shape: BoxShape.circle,

                  color: Color(0xffCDD7FF),
                ),

                child: const Icon(Icons.assignment, color: AppTheme.primary),
              ),

              SizedBox(width: size.width * 0.04),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      assignment.title,

                      style: const TextStyle(
                        fontSize: 16,

                        fontWeight: FontWeight.w700,

                        color: Color(0xff20263A),
                      ),
                    ),

                    SizedBox(height: size.height * 0.008),

                    Text(
                      assignment.description,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 14,

                        color: Color(0xff7B8297),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.015),

          Divider(color: Colors.grey.shade300),

          SizedBox(height: size.height * 0.008),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,

                    size: 16,

                    color: AppTheme.primary,
                  ),

                  SizedBox(width: size.width * 0.02),

                  Text(
                    assignment.dueDate.toString(),

                    style: const TextStyle(
                      fontSize: 13,

                      color: Color(0xff778096),
                    ),
                  ),
                ],
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,

                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xffB8F0DD),

                  borderRadius: BorderRadius.circular(20),
                ),

                child: const Text(
                  "Active",

                  style: TextStyle(
                    fontSize: 12,

                    fontWeight: FontWeight.w600,

                    color: Color(0xff16A36A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
