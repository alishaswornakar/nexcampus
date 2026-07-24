/// Root Google Drive folder containing all semester/subject material.
/// Used as the fallback for a subject's NOTES/SYLLABUS link when it
/// doesn't have its own specific folder yet.
const String rootDriveFolder =
    'https://drive.google.com/drive/u/1/folders/1Fg8e1YiguWAxwIYJiN36p7IQILFXXVpA';
const String rootDriveFolderId = '1Fg8e1YiguWAxwIYJiN36p7IQILFXXVpA';

/// Backup folder — automatically loaded if rootDriveFolder fails to load.
const String secondaryDriveFolder =
    'https://drive.google.com/drive/u/1/folders/1x7QuORJx2uPGqW--b6UODK3Ni9CemGWC';
const String secondaryDriveFolderId = '1x7QuORJx2uPGqW--b6UODK3Ni9CemGWC';

/// Default QUESTION BANK (QNB) folder. Used as the fallback for a
/// subject's QNB link when it doesn't have its own specific QNB folder yet.
/// (This is the same folder as `secondaryDriveFolder` above — it's now
/// being reused/repurposed as the shared QNB source.)
const String defaultQnbFolder =
    'https://drive.google.com/drive/u/1/folders/1x7QuORJx2uPGqW--b6UODK3Ni9CemGWC';
const String defaultQnbFolderId = '1x7QuORJx2uPGqW--b6UODK3Ni9CemGWC';

const semesterSubjects = <int, List<Map<String, String>>>{
  1: [
    {'name': 'Calculus I', 'pdf': 'assets/pdfs/sem1_calculus1.pdf'},
    {'name': 'Digital Logic', 'pdf': 'assets/pdfs/sem1_digital_logic.pdf'},
    {'name': 'Programming in C', 'pdf': 'assets/pdfs/sem1_programming_c.pdf'},
    {
      'name': 'Basic Electrical Engineering',
      'shortName': 'BEE',
      'pdf': 'assets/pdfs/sem1_basic_electrical.pdf',
      'notes':
          'https://drive.google.com/drive/u/0/folders/17SwbX9BitTuiTa9e4_LqFiKWYNvVKtz2',
      'driveId': '17SwbX9BitTuiTa9e4_LqFiKWYNvVKtz2',
      'qnb':
          'https://drive.google.com/drive/u/0/folders/1pwOnpO_zr-3EDomF9R0SiPpOrbxCIM5L',
      'qnbDriveId': '1pwOnpO_zr-3EDomF9R0SiPpOrbxCIM5L',
    },
    {
      'name': 'Computer Workshop',
      'shortName': 'CW',
      'pdf': 'assets/pdfs/sem1_computer_workshop.pdf',
    },
    {
      'name': 'Communication Technique',
      'shortName': 'CT',
      'pdf': 'assets/pdfs/sem1_communication_technique.pdf',
    },
    {
      'name': 'Electronics Devices and Circuits',
      'shortName': 'EDC',
      'pdf': 'assets/pdfs/sem1_electronics_devices.pdf',
    },
  ],
  2: [
    {
      'name': 'Algebra and Geometry',
      'shortName': 'AG',
      'pdf': 'assets/pdfs/sem2_algebra_geometry.pdf',
    },
    {
      'name': 'Applied Physics',
      'shortName': 'Physics',
      'pdf': 'assets/pdfs/sem2_applied_physics.pdf',
    },
    {
      'name': 'Applied Chemistry',
      'shortName': 'Chemistry',
      'pdf': 'assets/pdfs/sem2_applied_chemistry.pdf',
    },
    {
      'name': 'Basic Engineering Drawing',
      'shortName': 'BED',
      'pdf': 'assets/pdfs/sem2_basic_engineering_drawing.pdf',
    },
    {
      'name': 'Object Oriented Programming in C++',
      'shortName': 'OOP C++',
      'pdf': 'assets/pdfs/sem2_objected_oriented_programming_in_c++.pdf',
    },
    {
      'name': 'Data Structure and Algorithm',
      'shortName': 'DSA',
      'pdf': 'assets/pdfs/sem2_data_structure_and_algorithm.pdf',
    },
    {
      'name': 'Instrumentation',
      'shortName': 'Ins',
      'pdf': 'assets/pdfs/sem2_instrumentation.pdf',
    },
  ],
  3: [
    {'name': 'Calculus II', 'pdf': 'assets/pdfs/sem3_calculus2.pdf'},
    {
      'name': 'Database Management System',
      'shortName': 'DBMS',
      'pdf': 'assets/pdfs/sem3_database_management_system.pdf',
    },
    {
      'name': 'Operating Systems',
      'shortName': 'OS',
      'pdf': 'assets/pdfs/sem3_operating_system.pdf',
      'notes':
          'https://drive.google.com/drive/u/0/folders/17_gfLE0sRrlCKpNXcXyuq-TU5vcEvkas',
      'driveId': '17_gfLE0sRrlCKpNXcXyuq-TU5vcEvkas',
      'qnb':
          'https://drive.google.com/drive/u/0/folders/1vVLXfD1rmTDciaABIS-lKRnsL-TsTFSv',
      'qnbDriveId': '1vVLXfD1rmTDciaABIS-lKRnsL-TsTFSv',
    },
    {
      'name': 'Microprocessor and Assembly Language Programming',
      'shortName': 'MALP',
      'pdf': 'assets/pdfs/sem3_microprocessor.pdf',
    },
    {
      'name': 'Computer Graphics',
      'shortName': 'CG',
      'pdf': 'assets/pdfs/sem3_computer_graphics.pdf',
    },
    {
      'name': 'Data Communication',
      'shortName': 'DC',
      'pdf': 'assets/pdfs/sem3_data_communication.pdf',
    },
  ],
  4: [
    {
      'name': 'Applied Mathematics',
      'shortName': 'AM',
      'pdf': 'assets/pdfs/sem4_applied_mathematics.pdf',
    },
    {
      'name': 'Numerical Methods',
      'shortName': 'NM',
      'pdf': 'assets/pdfs/sem4_numerical_methods.pdf',
    },
    {
      'name': 'Advanced Programming With Java',
      'shortName': 'Java',
      'pdf': 'assets/pdfs/sem4_advanced_programming_with_java.pdf',
    },
    {
      'name': 'Theory of Computation',
      'shortName': 'TOC',
      'pdf': 'assets/pdfs/sem4_theory_of_computation.pdf',
    },
    {
      'name': 'Computer Architecture',
      'shortName': 'CA',
      'pdf': 'assets/pdfs/sem4_computer_architecture.pdf',
      'notes':
          'https://drive.google.com/drive/u/0/folders/1xvOIf8u6bnmxLzGY7KHPoLS2e_PJvSeY',
      'driveId': '1xvOIf8u6bnmxLzGY7KHPoLS2e_PJvSeY',
      'qnb':
          'https://drive.google.com/drive/u/0/folders/1Rv36O8KT627-f0ZetV1kxDQZ-CnaHG_C',
      'qnbDriveId': '1Rv36O8KT627-f0ZetV1kxDQZ-CnaHG_C',
    },
    {
      'name': 'Research Fundamentals',
      'shortName': 'RF',
      'pdf': 'assets/pdfs/sem4_research_fundamentals.pdf',
    },
  ],
  5: [
    {
      'name': 'Probability and Statistics',
      'shortName': 'P&S',
      'pdf': 'assets/pdfs/sem5_probability_and_statistics.pdf',
    },
    {
      'name': 'Embedded System',
      'shortName': 'ES',
      'pdf': 'assets/pdfs/sem5_embedded_systems.pdf',
    },
    {
      'name': 'Engineering Management',
      'shortName': 'EM',
      'pdf': 'assets/pdfs/sem5_engineering_management.pdf',
    },
    {
      'name': 'Artificial Intelligence',
      'shortName': 'AI',
      'pdf': 'assets/pdfs/sem5_artificial_intelligence.pdf',
    },
    {
      'name': 'Digital Signal Analysis and Processing',
      'shortName': 'DSAP',
      'pdf': 'assets/pdfs/sem5_dsap.pdf',
      'notes':
          'https://drive.google.com/drive/u/0/folders/17lsAMfXvpM1np_F8H5nCFTcCITG12dc-',
      'driveId': '17lsAMfXvpM1np_F8H5nCFTcCITG12dc-',
      'qnb':
          'https://drive.google.com/drive/u/0/folders/1S14AVw6oFbbPCEplkexB6jHLGYCUjWBH',
      'qnbDriveId': '1S14AVw6oFbbPCEplkexB6jHLGYCUjWBH',
    },
    {
      'name': 'Software Engineering',
      'shortName': 'SE',
      'pdf': 'assets/pdfs/sem5_software_engineering.pdf',
    },
  ],
  6: [
    {
      'name': 'Image Processing and Pattern Recognition',
      'shortName': 'IPPR',
      'pdf': 'assets/pdfs/sem6_image_processing_and_pattern_recognition.pdf',
    },
    {
      'name': 'Machine Learning',
      'shortName': 'ML',
      'pdf': 'assets/pdfs/sem6_machine_learning.pdf',
    },
    {
      'name': 'Compiler Design',
      'shortName': 'CD',
      'pdf': 'assets/pdfs/sem6_compiler_design.pdf',
    },
    {
      'name': 'Computer Networks',
      'shortName': 'CN',
      'pdf': 'assets/pdfs/sem6_computer_networks.pdf',
    },
    {
      'name': 'Simulation and Modeling',
      'shortName': 'S&M',
      'pdf': 'assets/pdfs/sem6_simulation_and_modeling.pdf',
    },
    {'name': 'Elective I', 'pdf': 'assets/pdfs/sem6_elective1.pdf'},
    {'name': 'Project I', 'pdf': 'assets/pdfs/sem6_project1.pdf'},
  ],
  7: [
    {
      'name': 'Entrepreneurship and Professional Practice',
      'shortName': 'EPP',
      'pdf': 'assets/pdfs/sem7_entrepreneurship_and_professional_practice.pdf',
    },
    {
      'name': 'Engineering Economics',
      'shortName': 'Economics',
      'pdf': 'assets/pdfs/sem7_engineering_economics.pdf',
    },
    {
      'name': 'Network and Cyber Security',
      'shortName': 'Cyber Security',
      'pdf': 'assets/pdfs/sem7_network_and_cyber_security.pdf',
    },
    {
      'name': 'Cloud Computing and Virtualization',
      'shortName': 'CCV',
      'pdf': 'assets/pdfs/sem7_cloud_computing_and_virtualization.pdf',
    },
    {
      'name': 'Data Science and Analytics',
      'shortName': 'Data Science',
      'pdf': 'assets/pdfs/sem7_data_science_and_analytics.pdf',
    },
    {
      'name': 'Elective II',
      'pdf': 'assets/pdfs/sem7_elective_2_ip_routing_and_switching.pdf',
    },
  ],
  8: [
    {'name': 'Elective III', 'pdf': 'assets/pdfs/sem8_elective3.pdf'},
    {'name': 'Internship', 'pdf': 'assets/pdfs/sem8_internship.pdf'},
    {'name': 'Project II', 'pdf': 'assets/pdfs/sem8_project2.pdf'},
  ],
};

/// ---------------------------------------------------------------------
/// Helpers
///
/// The raw `semesterSubjects` map above is left untouched for subjects
/// that don't have their own NOTES / QNB folder yet — we do NOT invent
/// fake folder IDs for them. Instead, use these helpers wherever you
/// display a subject's links; they transparently fall back to the shared
/// default folders (and tell you when a link is a fallback, in case you
/// want to show a "shared / general" badge in the UI instead of a
/// subject-specific one).
/// ---------------------------------------------------------------------

class SubjectLink {
  final String url;
  final String driveId;
  final bool isFallback;

  const SubjectLink({
    required this.url,
    required this.driveId,
    required this.isFallback,
  });
}

/// Returns the subject's NOTES/SYLLABUS folder link, falling back to
/// [rootDriveFolder] (and then [secondaryDriveFolder]) if the subject
/// has no specific one.
SubjectLink getNotesLink(Map<String, String> subject) {
  final url = subject['notes'];
  final id = subject['driveId'];
  if (url != null && id != null) {
    return SubjectLink(url: url, driveId: id, isFallback: false);
  }
  return const SubjectLink(
    url: rootDriveFolder,
    driveId: rootDriveFolderId,
    isFallback: true,
  );
}

/// Returns the subject's QUESTION BANK (QNB) folder link, falling back
/// to [defaultQnbFolder] if the subject has no specific one.
SubjectLink getQnbLink(Map<String, String> subject) {
  final url = subject['qnb'];
  final id = subject['qnbDriveId'];
  if (url != null && id != null) {
    return SubjectLink(url: url, driveId: id, isFallback: false);
  }
  return const SubjectLink(
    url: defaultQnbFolder,
    driveId: defaultQnbFolderId,
    isFallback: true,
  );
}

/// Returns the subject's SYLLABUS link. No syllabus-specific folders
/// exist in the source data yet, so this currently always resolves to
/// the shared [rootDriveFolder]. Once real per-subject syllabus links
/// are available, add a `'syllabus'` / `'syllabusDriveId'` key to the
/// relevant subject map and this will pick it up automatically, same
/// as [getNotesLink] does.
SubjectLink getSyllabusLink(Map<String, String> subject) {
  final url = subject['syllabus'];
  final id = subject['syllabusDriveId'];
  if (url != null && id != null) {
    return SubjectLink(url: url, driveId: id, isFallback: false);
  }
  return const SubjectLink(
    url: rootDriveFolder,
    driveId: rootDriveFolderId,
    isFallback: true,
  );
}
