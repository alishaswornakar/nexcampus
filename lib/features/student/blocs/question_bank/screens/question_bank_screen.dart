import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/student/widgets/bottom_nav_bar.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import '../bloc/question_bank_bloc.dart';
import '../bloc/question_bank_event.dart';
import '../bloc/question_bank_state.dart';
import 'question_bank_subject_screen.dart';

class QuestionBankScreen extends StatelessWidget {
  const QuestionBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuestionBankBloc()..add(const LoadQuestionBank()),
      child: const _QuestionBankView(),
    );
  }
}

class _QuestionBankView extends StatelessWidget {
  const _QuestionBankView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Question Bank",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.secondary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<QuestionBankBloc, QuestionBankState>(
        builder: (context, state) {
          if (state is QuestionBankLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QuestionBankError) {
            return Center(child: Text(state.message));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 8,
            itemBuilder: (context, index) {
              final semester = index + 1;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.secondary,
                      child: Text(
                        semester.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      "Semester $semester",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.background,
                      ),
                    ),
                    subtitle: const Text("View subjects and Question Banks"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.read<QuestionBankBloc>().add(
                        SelectSemester(semester),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              QuestionBankSubjectScreen(semester: semester),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }
}
