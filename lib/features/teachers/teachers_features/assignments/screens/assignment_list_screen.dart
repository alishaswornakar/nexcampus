import 'package:flutter/material.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_repository.dart';

import '../models/assignment_model.dart';

import '../services/assignment_service.dart';
import '../widgets/assignment_card.dart';
import 'assignment_detail_screen.dart';
import 'create_assignment_screen.dart';
class AssignmentListScreen extends StatefulWidget {
  final String department;
  final int semester;
  final String subject;

  const AssignmentListScreen({
    super.key,
    required this.department,
    required this.semester,
    required this.subject,
  });

  @override
  State<AssignmentListScreen> createState() =>
      _AssignmentListScreenState();
}

class _AssignmentListScreenState
    extends State<AssignmentListScreen> {

  final AssignmentRepository repository =
      AssignmentRepository(
    AssignmentService(),
  );

  final TextEditingController searchController =
      TextEditingController();

  String search = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
  @override
Widget build(BuildContext context) {

  return Scaffold(

    backgroundColor: const Color(0xffF5F7FA),

    appBar: AppBar(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      centerTitle: true,
      title: Column(
        children: [
          Text(widget.subject),
          Text(
            "Semester ${widget.semester}",
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
    body: Column(

children: [

Padding(
padding: const EdgeInsets.all(16),

child: TextField(

controller: searchController,

decoration: InputDecoration(

hintText: "Search Assignment",

prefixIcon: const Icon(Icons.search),

filled: true,

fillColor: Colors.white,

border: OutlineInputBorder(

borderRadius:
BorderRadius.circular(14),

borderSide: BorderSide.none,

),

),

onChanged: (value){

setState((){

search=value;

});

},

),

),
Expanded(

child: StreamBuilder<List<AssignmentModel>>(

stream: repository.getAssignments(

department: widget.department,

semester: widget.semester.toString(),

subject: widget.subject,

),

builder:(context,snapshot){

if(snapshot.connectionState==ConnectionState.waiting){

return const Center(
child:CircularProgressIndicator(),
);

}

if(snapshot.hasError){

return Center(
child:Text(snapshot.error.toString()),
);

}

if(!snapshot.hasData || snapshot.data!.isEmpty){

return const Center(

child: Text(

"No Assignments Yet",

style: TextStyle(
fontSize:18,
),

),

);

}
final assignments =
snapshot.data!;

final filtered =
assignments.where((assignment){

return assignment.title
.toLowerCase()
.contains(
search.toLowerCase(),
);

}).toList();
return ListView.separated(

padding: const EdgeInsets.fromLTRB(
16,
0,
16,
90,
),

itemCount: filtered.length,

separatorBuilder:(_,__)=>const SizedBox(height:10),

itemBuilder:(context,index){

final assignment=filtered[index];

return AssignmentCard(

assignment: assignment,

onTap:(){

Navigator.push(

context,

MaterialPageRoute(

builder:(_)=>AssignmentDetailScreen(

assignment: assignment,

),

),

);

},

);

},

);

},

),

),

],

),
floatingActionButton:
FloatingActionButton.extended(

backgroundColor: Colors.blue,

foregroundColor: Colors.white,

icon: const Icon(Icons.add),

label: const Text("Assignment"),

onPressed:(){

Navigator.push(

context,

MaterialPageRoute(

builder:(_)=>CreateAssignmentScreen(

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