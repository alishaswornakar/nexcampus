import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/user_profile_bloc.dart';
import '../bloc/user_profile_event.dart';
import '../bloc/user_profile_state.dart';
import '../model/user_profile_model.dart';
import '../widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfileModel profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _departmentController;
  late final TextEditingController _semesterController;
  late final TextEditingController _sectionController;
  late final TextEditingController _rollNumberController;
  late final TextEditingController _bloodGroupController;
  late final TextEditingController _guardianNameController;
  late final TextEditingController _guardianPhoneController;

  DateTime? _dateOfBirth;
  bool _isSaving = false;
  // add near your other state vars
  DateTime? _joinedDate;
  late final bool
  _isBatchLocked; // computed once, doesn't change during this screen's life
  Future<void> _pickBatchYear() async {
    if (_isBatchLocked) return; // safety net, button is also disabled
    final now = DateTime.now();
    final selectedYear = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Batch Year'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: YearPicker(
              firstDate: DateTime(now.year - 15),
              lastDate: DateTime(now.year + 1),
              selectedDate: _joinedDate ?? now,
              onChanged: (date) => Navigator.of(context).pop(date.year),
            ),
          ),
        );
      },
    );
    if (selectedYear != null) {
      setState(() => _joinedDate = DateTime(selectedYear, 1, 1));
    }
  }

  static const Color _skyBlue = Color(0xFF1E88E5);

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _fullNameController = TextEditingController(text: p.fullName);
    _phoneController = TextEditingController(text: p.phoneNumber ?? '');
    _addressController = TextEditingController(text: p.address ?? '');
    _departmentController = TextEditingController(text: p.department ?? '');
    _semesterController = TextEditingController(text: p.semester ?? '');
    _sectionController = TextEditingController(text: p.section ?? '');
    _rollNumberController = TextEditingController(text: p.rollNumber ?? '');
    _bloodGroupController = TextEditingController(text: p.bloodGroup ?? '');
    _guardianNameController = TextEditingController(text: p.guardianName ?? '');
    _guardianPhoneController = TextEditingController(
      text: p.guardianPhone ?? '',
    );
    _dateOfBirth = p.dateOfBirth;
    _joinedDate = p.joinedDate;
    _isBatchLocked = p.joinedDate != null; //added this line.
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _departmentController.dispose();
    _semesterController.dispose();
    _sectionController.dispose();
    _rollNumberController.dispose();
    _bloodGroupController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: _skyBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> updatedFields = {
      'fullName': _fullNameController.text.trim(),
      'phoneNumber': _emptyToNull(_phoneController.text),
      'address': _emptyToNull(_addressController.text),
      'department': _emptyToNull(_departmentController.text),
      'semester': _emptyToNull(_semesterController.text),
      'section': _emptyToNull(_sectionController.text),
      'rollNumber': _emptyToNull(_rollNumberController.text),
      'bloodGroup': _emptyToNull(_bloodGroupController.text),
      'guardianName': _emptyToNull(_guardianNameController.text),
      'guardianPhone': _emptyToNull(_guardianPhoneController.text),
      'dateOfBirth': _dateOfBirth?.toIso8601String(),
    };
    if (!_isBatchLocked && _joinedDate != null) {
      updatedFields['joinedDate'] = _joinedDate!.toIso8601String();
    }
    setState(() => _isSaving = true);

    context.read<UserProfileBloc>().add(
      UserProfileFieldsUpdated(widget.profile.uid, updatedFields),
    );
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final digitsOnly = value.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 7) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  InputDecoration _decoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: _skyBlue) : null,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _skyBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (!_isSaving) return;

        if (state.status == UserProfileStatus.success) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: _skyBlue,
            ),
          );
          Navigator.of(context).pop();
        } else if (state.status == UserProfileStatus.failure) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to update profile'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        // ...unchanged, everything below this line stays exactly the same
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: _skyBlue,
          foregroundColor: Colors.white,
          title: const Text('Edit Profile'),
        ),
        body: AbsorbPointer(
          absorbing: _isSaving,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Hero(
                    tag: 'profile-avatar-${widget.profile.uid}',
                    child: ProfileAvatar(
                      uid: widget.profile.uid,
                      photoUrl: widget.profile.photoUrl,
                      fullName: widget.profile.fullName,
                      radius: 56,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _fullNameController,
                  decoration: _decoration(
                    'Full Name',
                    icon: Icons.person_outline,
                  ),
                  validator: _requiredValidator,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: widget.profile.email,
                  decoration: _decoration('Email', icon: Icons.email_outlined),
                  enabled: false,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  decoration: _decoration(
                    'Phone Number',
                    icon: Icons.phone_outlined,
                  ),
                  keyboardType: TextInputType.phone,
                  validator: _phoneValidator,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _addressController,
                  decoration: _decoration('Address', icon: Icons.home_outlined),
                  maxLines: 2,
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickDateOfBirth,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: _decoration(
                      'Date of Birth',
                      icon: Icons.cake_outlined,
                    ),
                    child: Text(
                      _dateOfBirth == null
                          ? 'Select date'
                          : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                      style: TextStyle(
                        color: _dateOfBirth == null
                            ? Colors.grey.shade500
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Academic Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _skyBlue,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _departmentController,
                  decoration: _decoration(
                    'Department',
                    icon: Icons.school_outlined,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _semesterController,
                        decoration: _decoration('Semester'),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _sectionController,
                        decoration: _decoration('Section'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _rollNumberController,
                  decoration: _decoration(
                    'Roll Number',

                    icon: Icons.badge_outlined,
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _isBatchLocked ? null : _pickBatchYear,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration:
                        _decoration(
                          'Batch (Joined Year)',
                          icon: Icons.event_available_outlined,
                        ).copyWith(
                          fillColor: _isBatchLocked
                              ? Colors.grey.shade200
                              : Colors.grey.shade50,
                          suffixIcon: _isBatchLocked
                              ? Tooltip(
                                  message: 'Batch can only be set once',
                                  child: Icon(
                                    Icons.lock_outline,
                                    size: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                )
                              : null,
                        ),
                    child: Text(
                      _joinedDate == null
                          ? 'Select batch year'
                          : '${_joinedDate!.year}',
                      style: TextStyle(
                        color: _joinedDate == null
                            ? Colors.grey.shade500
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Guardian & Health Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _skyBlue,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _bloodGroupController,
                  decoration: _decoration(
                    'Blood Group',
                    icon: Icons.bloodtype_outlined,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _guardianNameController,
                  decoration: _decoration(
                    'Guardian Name',
                    icon: Icons.family_restroom_outlined,
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _guardianPhoneController,
                  decoration: _decoration(
                    'Guardian Phone',
                    icon: Icons.phone_forwarded_outlined,
                  ),
                  keyboardType: TextInputType.phone,
                  validator: _phoneValidator,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _onSavePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _skyBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _isSaving
                              ? const SizedBox(
                                  key: ValueKey('saving'),
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save', key: ValueKey('save')),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
