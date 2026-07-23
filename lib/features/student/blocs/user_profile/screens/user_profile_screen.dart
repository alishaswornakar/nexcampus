import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user_profile_bloc.dart';
import '../bloc/user_profile_event.dart';
import '../bloc/user_profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_card.dart';
import '../widgets/academic_information_card.dart';
import '../widgets/contact_information_card.dart';
import '../widgets/account_information_card.dart';
import '../widgets/edit_profile_button.dart';
import '../widgets/logout_tile.dart';
import '../widgets/loading_shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }
    return BlocProvider(
      create: (_) =>
          UserProfileBloc()..add(UserProfileSubscriptionRequested(user.uid)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Student Profile',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: AppTheme.secondary,
        ),
        body: BlocBuilder<UserProfileBloc, UserProfileState>(
          builder: (context, state) {
            if (state.status == UserProfileStatus.loading &&
                state.profile == null) {
              return const LoadingShimmer();
            }

            if (state.status == UserProfileStatus.failure &&
                state.profile == null) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'Something went wrong',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final profile = state.profile;
            if (profile == null) {
              return const Center(child: Text('No profile data found.'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<UserProfileBloc>().add(
                  UserProfileSubscriptionRequested(user.uid),
                );
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ProfileHeader(profile: profile),
                  const SizedBox(height: 16),
                  ProfileCard(profile: profile),
                  const SizedBox(height: 16),
                  AcademicInformationCard(profile: profile),
                  const SizedBox(height: 16),
                  ContactInformationCard(profile: profile),
                  const SizedBox(height: 16),
                  AccountInformationCard(profile: profile),
                  const SizedBox(height: 24),
                  EditProfileButton(profile: profile),
                  const SizedBox(height: 12),
                  const LogoutTile(),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
