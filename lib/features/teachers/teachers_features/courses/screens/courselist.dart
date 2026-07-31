import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart'; 

import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../blocs/bloc/course_bloc.dart';
import 'add_course_screen.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatefulWidget {final String department;final String semester;

const CourseListScreen({super.key,required this.department,required this.semester,});

@override
State<CourseListScreen> createState() => _CourseListScreenState();}

class _CourseListScreenState extends State<CourseListScreen> {@override
void initState() {super.initState();

WidgetsBinding.instance.addPostFrameCallback((_) {
  context.read<CourseBloc>().add(
        LoadCoursesEvent(
          department: widget.department,
          semester: widget.semester,
        ),
      );
});

}

void openAddCourse() {
  Navigator.push(context,MaterialPageRoute(builder: (context) => BlocProvider.value(value: context.read<CourseBloc>(),
child: AddCourseScreen(department: widget.department,semester: widget.semester,),),),);}

@override
Widget build(BuildContext context) {
  return Scaffold(backgroundColor:Colors.white,

  appBar: AppBar(
    backgroundColor: AppTheme.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    surfaceTintColor: Colors.white,
    scrolledUnderElevation: 0,
    title: const  Text(
      "My Courses",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),

  floatingActionButton: BlocBuilder<CourseBloc, CourseState>(
    builder: (context, state) {
      if (state is CoursesLoaded && state.courses.isNotEmpty) {
        return FloatingActionButton.extended(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.grey,
          icon: const Icon(Icons.add),
          label: const Text("Add Course"),
          onPressed: openAddCourse,
        );
      }

      return const SizedBox.shrink();
    },
  ),

  body: BlocConsumer<CourseBloc, CourseState>(
    listener: (context, state) {
      if (state is CourseAdded ||
          state is CourseDeleted ||
          state is CourseUpdated) {
        context.read<CourseBloc>().add(
              LoadCoursesEvent(
                department: widget.department,
                semester: widget.semester,
              ),
            );
      }
    },
    builder: (context, state) {
      if (state is CourseLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (state is CourseError) {
        return Center(
          child: Text(state.message),
        );
      }

      if (state is CoursesLoaded) {
        if (state.courses.isEmpty) {

return Center(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 28),child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Container(width: 170,height: 170,decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: .08),shape: BoxShape.circle,),child: Icon(Icons.menu_book_rounded,size: 70,color: AppTheme.primary.withValues(alpha: .45),),),

      const SizedBox(height: 36),

      const Text(
        "No courses added yet",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 14),

      const Text(
        "Add your first course to start managing\nattendance, assignments and study materials.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color:AppTheme.primary,
          fontSize: 16,
          height: 1.5,
        ),
      ),

      const SizedBox(height: 40),

      SizedBox(
        width: 190,
        height: 52,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            foregroundColor:  Colors.grey.shade300,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: openAddCourse,
          icon: const Icon(Icons.add),
          label: const Text(
            "Add Course",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ],
  ),
),

);}

return Column(crossAxisAlignment: CrossAxisAlignment.start,children: [Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [Text(widget.department,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold,),),

      const SizedBox(height: 4),

      Text(
        "Semester ${widget.semester}",
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
        ),
      ),
    ],
  ),
),

Expanded(
  child: ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
    itemCount: state.courses.length,
    itemBuilder: (context, index) {
      final course = state.courses[index];
      return Container(

margin: const EdgeInsets.only(bottom: 16),
decoration: BoxDecoration(
  color:  Colors.white,borderRadius: BorderRadius.circular(18),boxShadow: [BoxShadow(color:AppTheme.primary.withValues(alpha: 0.05),blurRadius: 12,offset: const Offset(0, 4),),],),child: InkWell(borderRadius: BorderRadius.circular(18),onTap: () {Navigator.push(context,MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course,),),);},child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 14,),child: Row(children: [Container(width: 52,height: 52,decoration: BoxDecoration(color: AppTheme.primary?.withValues(alpha: .08),borderRadius: BorderRadius.circular(14),),child: const Icon(Icons.menu_book_rounded,color: AppTheme.primary,size: 26,),),

      const SizedBox(width: 16),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.courseName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(
                  Icons.tag,
                  size: 15,
                  color: Colors.black,
                ),
                const SizedBox(width: 6),
                Text(
                  course.courseCode,
                  style: const TextStyle(
                    fontSize: 13,
                    color:Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(
                  Icons.school_outlined,
                  size: 15,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${course.department} • Semester ${course.semester}",
                    style: const TextStyle(
                      fontSize: 13,
                      color:Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      PopupMenuButton<String>(
        icon: const Icon(
          Icons.more_vert,
          color:Colors.black,
        ),
        onSelected: (value) {
          switch (value) {
            case "details":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseDetailScreen(
                    course: course,
                  ),
                ),
              );
              break;

            case "delete":
              context.read<CourseBloc>().add(
                    DeleteCourseEvent(course.id),
                  );
              break;
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: "details",
            child: Row(
              children: [
                Icon(Icons.visibility_outlined),
                SizedBox(width: 10),
                Text("View Details"),
              ],
            ),
          ),
          PopupMenuItem(
            value: "delete",
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                SizedBox(width: 10),
                Text("Delete"),
              ],
            ),
          ),
        ],
      ),
    ],
  ),
),

),);},),),]);}

return const Center(child: Text("No data found",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,),),);},),);}}