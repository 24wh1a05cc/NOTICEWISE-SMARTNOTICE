import 'package:noticewise/core/services/database_service.dart';
import 'package:noticewise/core/utils/logger.dart';
import 'package:noticewise/features/notices/domain/notice.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Seeds realistic sample notices into the database on first launch.
///
/// Checks the seed_done table — if already seeded, does nothing.
/// This prevents duplicate data on app restart.
class DataSeeder {
  DataSeeder._();
  static final DataSeeder instance = DataSeeder._();

  final _uuid = const Uuid();

  Future<void> seedIfNeeded() async {
    final db = await DatabaseService.instance.database;

    // Check if already seeded
    final rows = await db.query('seed_done', where: 'id = 1', limit: 1);
    if (rows.isNotEmpty && (rows.first['done'] as int) == 1) {
      logger.i('[DataSeeder] Already seeded — skipping.');
      return;
    }

    logger.i('[DataSeeder] Seeding sample notices...');
    await _insertSampleNotices(db);

    // Mark as done
    await db.insert(
      'seed_done',
      {'id': 1, 'done': 1},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    logger.i('[DataSeeder] Seeding complete.');
  }

  Future<void> _insertSampleNotices(Database db) async {
    final now = DateTime.now();

    final notices = [
      {
        'id': _uuid.v4(),
        'title': 'End Semester Examination Timetable – Nov 2026',
        'body':
            'The End Semester Examination (ESE) timetable for November 2026 has been released.\n\n'
            'Key dates:\n'
            '• 01 Nov – Mathematics (10:00 AM – 01:00 PM)\n'
            '• 03 Nov – Data Structures (10:00 AM – 01:00 PM)\n'
            '• 05 Nov – Operating Systems (10:00 AM – 01:00 PM)\n'
            '• 07 Nov – Computer Networks (10:00 AM – 01:00 PM)\n'
            '• 09 Nov – Software Engineering (10:00 AM – 01:00 PM)\n\n'
            'All examinations will be held in Block A examination hall. Hall tickets must be collected from the academic office by 28 Oct.',
        'category': 'Examinations',
        'priority': NoticePriority.urgent.index,
        'is_pinned': 1,
        'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'remind_at': now.add(const Duration(days: 5)).toIso8601String(),
        'status': NoticeStatus.published.index,
        'author_name': 'Academic Office',
        'publish_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'expires_at': now.add(const Duration(days: 30)).toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'title': 'Assignment Submission Deadline – Software Engineering Project',
        'body':
            'All students of B.Tech 3rd Year are reminded that the final project submission deadline for the Software Engineering course is:\n\n'
            '📅 Date: 20 October 2026\n'
            '⏰ Time: 5:00 PM\n'
            '📁 Mode: Upload to the course portal (LMS) AND submit a printed copy to Room 301.\n\n'
            'Late submissions will attract a 10% penalty per day. Submissions after 23 Oct will not be accepted.\n\n'
            'Ensure your submission includes:\n'
            '• SRS Document\n'
            '• Design Document (UML diagrams)\n'
            '• Source Code (GitHub link)\n'
            '• Test Report',
        'category': 'Academic',
        'priority': NoticePriority.high.index,
        'is_pinned': 1,
        'created_at': now.subtract(const Duration(days: 5)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 5)).toIso8601String(),
        'remind_at': now.add(const Duration(days: 2)).toIso8601String(),
        'status': NoticeStatus.published.index,
        'author_name': 'Prof. Rajesh Kumar',
        'publish_at': now.subtract(const Duration(days: 5)).toIso8601String(),
        'expires_at': now.add(const Duration(days: 10)).toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'title': 'Annual Technical Fest – TechSurge 2026',
        'body':
            'We are thrilled to announce the Annual Technical Festival – TechSurge 2026!\n\n'
            '📅 Date: 25–27 October 2026\n'
            '📍 Venue: Main Auditorium and Open-Air Amphitheatre\n\n'
            'Events include:\n'
            '• Hackathon (24 hours) – Prize pool: ₹50,000\n'
            '• Paper Presentation\n'
            '• Robotics Competition\n'
            '• Coding Challenge (LeetCode style)\n'
            '• Project Exhibition\n\n'
            'Registration is open until 22 Oct via the college portal. Teams of 2–4 members. Spot registrations subject to availability.\n\n'
            'Chief Guest: Dr. Anita Sharma, CTO, TechVentures India.',
        'category': 'Events',
        'priority': NoticePriority.high.index,
        'is_pinned': 0,
        'created_at': now.subtract(const Duration(days: 7)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 7)).toIso8601String(),
        'remind_at': now.add(const Duration(days: 3)).toIso8601String(),
        'status': NoticeStatus.published.index,
        'author_name': 'Student Activities Committee',
        'publish_at': now.subtract(const Duration(days: 7)).toIso8601String(),
        'expires_at': now.add(const Duration(days: 20)).toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'title': 'Holiday Notice – Diwali Break',
        'body':
            'The institution will remain closed for the Diwali holiday break from:\n\n'
            '📅 28 October 2026 (Tuesday) to 01 November 2026 (Saturday)\n\n'
            'Regular classes and office operations will resume on Monday, 03 November 2026.\n\n'
            'The library and computer labs will be accessible on 29 Oct (10 AM – 4 PM) for students with exam preparation needs.\n\n'
            'All students are advised to ensure their project submissions and assignments due before the break are completed in advance.\n\n'
            'Wishing everyone a safe and joyful Diwali! 🪔',
        'category': 'General',
        'priority': NoticePriority.normal.index,
        'is_pinned': 0,
        'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        'remind_at': null,
        'status': NoticeStatus.published.index,
        'author_name': 'Principal Office',
        'publish_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        'expires_at': now.add(const Duration(days: 25)).toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'title': 'Campus Placement Drive – Infosys & TCS',
        'body':
            'On-campus placement drives for the batch of 2026 are scheduled as follows:\n\n'
            '🏢 Infosys\n'
            '  Date: 14 November 2026\n'
            '  Roles: Systems Engineer, Digital Specialist\n'
            '  Package: ₹4.5 – 9.5 LPA\n'
            '  Eligibility: 60% aggregate, no active backlogs\n\n'
            '🏢 TCS (TCS BPS & NQT)\n'
            '  Date: 18 November 2026\n'
            '  Roles: Assistant System Engineer\n'
            '  Package: ₹3.6 – 7 LPA\n'
            '  Eligibility: 60% aggregate, 2026 pass-out\n\n'
            'Students must register via the Training & Placement portal (tpo.college.edu) before 10 Nov.\n\n'
            'Pre-placement talks on 12 Nov at 3 PM in Seminar Hall 1. Attendance is mandatory for registered students.',
        'category': 'Placements',
        'priority': NoticePriority.urgent.index,
        'is_pinned': 1,
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'remind_at': now.add(const Duration(days: 10)).toIso8601String(),
        'status': NoticeStatus.published.index,
        'author_name': 'Training & Placement Office',
        'publish_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'expires_at': now.add(const Duration(days: 45)).toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'title': 'Library Book Return – End of Semester',
        'body':
            'All students are requested to return borrowed library books before the end of semester examinations.\n\n'
            'Deadline for return: 25 October 2026\n\n'
            'A fine of ₹5 per book per day will be charged for overdue books.\n\n'
            'Students with outstanding dues will not receive hall tickets for the end semester examination.\n\n'
            'Library timings:\n'
            'Mon–Fri: 8:00 AM – 8:00 PM\n'
            'Saturday: 9:00 AM – 5:00 PM',
        'category': 'General',
        'priority': NoticePriority.normal.index,
        'is_pinned': 0,
        'created_at': now.subtract(const Duration(days: 10)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 10)).toIso8601String(),
        'remind_at': null,
        'status': NoticeStatus.published.index,
        'author_name': 'Library Committee',
        'publish_at': now.subtract(const Duration(days: 10)).toIso8601String(),
        'expires_at': now.add(const Duration(days: 15)).toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'title': 'Scholarship Applications Open – Merit-cum-Means 2026–27',
        'body':
            'Applications are invited for the Merit-cum-Means Scholarship for the academic year 2026–27.\n\n'
            'Eligibility:\n'
            '• Minimum 75% marks in the previous semester\n'
            '• Family annual income below ₹6 lakhs\n\n'
            'Documents required:\n'
            '• Income certificate (latest)\n'
            '• Previous semester marksheet\n'
            '• Bank account details\n'
            '• Aadhar card copy\n\n'
            'Application form available at the scholarship portal (scholarship.college.edu) and the administrative office.\n\n'
            'Last date to apply: 30 October 2026.\n\n'
            'Amount: ₹25,000 per annum.',
        'category': 'Academic',
        'priority': NoticePriority.high.index,
        'is_pinned': 0,
        'created_at': now.subtract(const Duration(days: 4)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 4)).toIso8601String(),
        'remind_at': null,
        'status': NoticeStatus.published.index,
        'author_name': 'Scholarship Committee',
        'publish_at': now.subtract(const Duration(days: 4)).toIso8601String(),
        'expires_at': now.add(const Duration(days: 20)).toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'title': 'Guest Lecture – Cloud Computing and DevOps',
        'body':
            'The Department of Computer Science is pleased to announce a guest lecture:\n\n'
            '🎙️ Topic: Cloud Computing & DevOps in Modern Enterprises\n'
            '👤 Speaker: Mr. Vikram Singh, Senior Solutions Architect, Amazon Web Services\n'
            '📅 Date: 17 October 2026 (Friday)\n'
            '⏰ Time: 2:00 PM – 4:30 PM\n'
            '📍 Venue: Seminar Hall 2, Block B\n\n'
            'Topics covered:\n'
            '• Introduction to AWS services\n'
            '• CI/CD pipelines using GitHub Actions\n'
            '• Containerisation with Docker and Kubernetes\n'
            '• Real-world case studies\n\n'
            'All B.Tech students (2nd, 3rd, and 4th year) are encouraged to attend. Registration not required.\n\n'
            'Q&A session at the end. Certificates of participation will be issued.',
        'category': 'Events',
        'priority': NoticePriority.normal.index,
        'is_pinned': 0,
        'created_at': now.subtract(const Duration(days: 8)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 8)).toIso8601String(),
        'remind_at': null,
        'status': NoticeStatus.published.index,
        'author_name': 'CS Department',
        'publish_at': now.subtract(const Duration(days: 8)).toIso8601String(),
        'expires_at': now.add(const Duration(days: 8)).toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'title': 'Sports Day – Inter-House Tournament',
        'body':
            'The Annual Inter-House Sports Tournament will be held from 10–12 November 2026.\n\n'
            'Sports included:\n'
            '• Cricket\n'
            '• Football\n'
            '• Basketball\n'
            '• Badminton\n'
            '• Table Tennis\n\n'
            'Registration open for all students. Contact your house captain or the sports committee by 05 Nov.',
        'category': 'Sports',
        'priority': NoticePriority.low.index,
        'is_pinned': 0,
        'created_at': now.subtract(const Duration(days: 6)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 6)).toIso8601String(),
        'remind_at': null,
        'status': NoticeStatus.published.index,
        'author_name': 'Sports Committee',
        'publish_at': now.subtract(const Duration(days: 6)).toIso8601String(),
        'expires_at': now.add(const Duration(days: 35)).toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'title': 'Campus Wi-Fi Maintenance – Scheduled Downtime',
        'body':
            'Planned maintenance of the campus Wi-Fi infrastructure has been scheduled.\n\n'
            'Date: 19 October 2026 (Sunday)\n'
            'Time: 11:00 PM – 3:00 AM (Monday)\n\n'
            'During this period, Wi-Fi access will be unavailable across all campus buildings including hostels.\n\n'
            'The IT team apologises for any inconvenience. For urgent connectivity, please use mobile data.\n\n'
            'Post-maintenance improvements:\n'
            '• Increased bandwidth (1 Gbps → 2 Gbps)\n'
            '• Extended coverage in Blocks C and D\n'
            '• Faster authentication',
        'category': 'General',
        'priority': NoticePriority.normal.index,
        'is_pinned': 0,
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'remind_at': null,
        'status': NoticeStatus.published.index,
        'author_name': 'IT Infrastructure Team',
        'publish_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'expires_at': now.add(const Duration(days: 10)).toIso8601String(),
      },
    ];

    for (final notice in notices) {
      await db.insert(
        'notices',
        notice,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}
