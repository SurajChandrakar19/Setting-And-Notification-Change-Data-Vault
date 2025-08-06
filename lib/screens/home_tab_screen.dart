import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/notification_service.dart'
    show NotificationItem, NotificationType, NotificationService;
import '../widgets/candidate_popup_form.dart';
import '../../main.dart' show themeModeNotifier;
import '../../data/user_role.dart';
import '../../data/performance_data.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/go_for_interview_response.dart';
import '../services/dashboad_service.dart';
import '../models/dashboard_model.dart';
import '../models/dashbord_summary_model.dart';
import '../services/dashbord_service.dart';
import '../services/and_candidate_service.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _phoneController = TextEditingController();
  String _targetInterviewScheduled = '';

  // Time period selection
  String selectedPeriod = 'Weekly';

  // Use global performance data
  Map<String, Map<String, dynamic>> get performanceData =>
      globalPerformanceData;

  List<GoForInterviewResponse> gfiCandidates = [];
  List<GoForInterviewResponse> attendanceCandidates = [];

  static var userId = "";
  static UserProvider? userProvider;
  // DashboardSummaryResponse? summary;

  SimpleAdminDashboardSummary? dashboardSummary;

  // Sample candidates data for Set Target functionality
  List<Map<String, dynamic>> candidates = [];
  // {'name': 'Naveen M', 'id': 'HRS012', 'target': 0},
  // {'name': 'Rajeswari R', 'id': 'HRS012', 'target': 0},
  // {'name': 'Chandani', 'id': 'HRS012', 'target': 0},
  // {'name': 'Uma Devi', 'id': 'HRS012', 'target': 0},
  // {'name': 'Akhil', 'id': 'HRS012', 'target': 0},
  // {'name': 'Vanmati R', 'id': 'HRS012', 'target': 0},
  // {'name': 'Sandhaya', 'id': 'HRS012', 'target': 0},
  // {'name': 'Sushma', 'id': 'HRS012', 'target': 0},

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    userId = userProvider?.id?.toString() ?? '';

    // loadGFICount();
    // _loadGFICandidates();
    loadDashboardSummary();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // void _addCandidate() {
  //   final phone = _phoneController.text.trim();
  //   final phoneRegExp = RegExp(r'^\d{10}?$');
  //   if (phoneRegExp.hasMatch(phone)) {
  //     _showCandidatePopup();
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please enter a valid 10-digit mobile number'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  void _addCandidate() async {
    final phone = _phoneController.text.trim();
    final phoneRegExp = RegExp(r'^\d{10}$');

    if (!phoneRegExp.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      bool isTaken = await AddCandidateService.isPhoneNumberTaken(
        phone,
        userProvider?.accessToken ?? '',
      );
      if (isTaken) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number already exists'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        _showCandidatePopup(
          _phoneController.text,
        ); // Phone is valid and available
        _phoneController.clear(); // Clear input after showing popup
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking phone number: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCandidatePopup(String initialPhone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: CandidatePopupForm(
              initialPhone: initialPhone,
              userId: userId,
              onBookInterview: (candidateData) {
                Navigator.pop(context); // Close popup
                _phoneController.clear(); // Clear input

                // // Add to global candidates list
                // candidates_data.globalCandidates.add(candidateData);

                // // Add to global applications list
                // globalApplications.insert(0, {
                //   'id': globalApplications.isNotEmpty
                //       ? (globalApplications.first['id'] as int) + 1
                //       : 1,
                //   'company':
                //       candidateData['company'] ??
                //       (candidateData['selectedCompany']?['name'] ??
                //           'Not Assigned'),
                //   'position': candidateData['role'] ?? 'Unknown Position',
                //   'candidateName': candidateData['name'] ?? '',
                //   'appliedDate': 'Applied today',
                //   'status': 'pending',
                //   'phone': candidateData['phone'] ?? '',
                //   'whatsapp': candidateData['phone'] ?? '',
                //   'avatar':
                //       (candidateData['name'] != null &&
                //           candidateData['name'].isNotEmpty)
                //       ? candidateData['name'][0].toUpperCase()
                //       : '',
                // });

                _navigateToCandidatesTab();
              },
            ),
          ),
        );
      },
    );
  }

  void _navigateToCandidatesTab() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Interview booked successfully! Check Candidates tab for details.',
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Navigate to Set Target page
  void _navigateToSetTarget() async {
    // Fetch candidates from the service
    await DashboardService()
        .fetchUsers(userProvider?.accessToken ?? '')
        .then((candidates) {
          setState(() {
            this.candidates = candidates;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SetTargetPage(
                candidates: candidates,
                userProvider: userProvider,
                onTargetUpdated: (updatedCandidates) {
                  setState(() {
                    candidates = updatedCandidates;
                  });
                },
              ),
            ),
          );
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error fetching candidates: $error'),
              backgroundColor: Colors.red,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final currentData = performanceData[selectedPeriod]!;
    final currentUserRole = Provider.of<UserProvider>(context).admin ?? false
        ? 'admin'
        : 'user';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8), // space between icon and name
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          final userName = userProvider.name ?? 'Guest';
                          return Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ValueListenableBuilder<List<NotificationItem>>(
                        valueListenable:
                            _notificationService.notificationsNotifier,
                        builder: (context, notifications, child) {
                          final unreadCount = notifications
                              .where((n) => !n.isRead)
                              .length;
                          return Stack(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: Theme.of(context).iconTheme.color,
                                  size: 24,
                                ),
                                onPressed: () => _showNotifications(context),
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.settings_outlined,
                          color: Theme.of(context).iconTheme.color,
                          size: 24,
                        ),
                        onPressed: () => _showSettingsBottomSheet(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Add Candidate Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Enter 10-digit mobile number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _addCandidate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A7FF1),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'ADD CANDIDATE',
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

                    const SizedBox(height: 24),

                    // Original Targets For Today Section with Set Target button
                    _buildSectionCard(
                      context,
                      title: 'Targets For Today',
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Targets For Today',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (currentUserRole == 'admin')
                                ElevatedButton(
                                  onPressed: _navigateToSetTarget,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0A7FF1),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Set Target',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTargetItem(
                                  context,
                                  'Target Interview Scheduled',
                                  '${dashboardSummary?.nextMonth.totalAchieved.toString() ?? '0'}/${dashboardSummary?.nextMonth.totalTarget.toString() ?? '0'}',
                                  Colors.green,
                                ),
                              ),
                              //   if (currentUserRole == 'admin')
                              //     IconButton(
                              //       icon: const Icon(
                              //         Icons.edit,
                              //         color: Colors.blue,
                              //       ),
                              //       tooltip: 'Edit Target',
                              //       onPressed: () async {
                              //         final newValue = await showDialog<String>(
                              //           context: context,
                              //           builder: (context) {
                              //             final controller =
                              //                 TextEditingController(
                              //                   text: "_targetInterviewScheduled",
                              //                 );
                              //             return AlertDialog(
                              //               title: const Text(
                              //                 'Edit Target Interview Scheduled',
                              //               ),
                              //               content: TextField(
                              //                 controller: controller,
                              //                 keyboardType: TextInputType.number,
                              //                 decoration: const InputDecoration(
                              //                   hintText: 'Enter new target',
                              //                 ),
                              //               ),
                              //               actions: [
                              //                 TextButton(
                              //                   onPressed: () =>
                              //                       Navigator.pop(context),
                              //                   child: const Text('Cancel'),
                              //                 ),
                              //                 TextButton(
                              //                   onPressed: () => Navigator.pop(
                              //                     context,
                              //                     controller.text,
                              //                   ),
                              //                   child: const Text('Update'),
                              //                 ),
                              //               ],
                              //             );
                              //           },
                              //         );

                              //         if (newValue != null &&
                              //             newValue.trim().isNotEmpty) {
                              //           final parsed = int.tryParse(
                              //             newValue.trim(),
                              //           );
                              //           if (parsed != null) {
                              //             try {
                              //               await DashboardService()
                              //                   .updateTargetValue(
                              //                     userId: userId,
                              //                     targetValue: parsed,
                              //                   );

                              //               setState(() {
                              //                 _targetInterviewScheduled = parsed
                              //                     .toString();
                              //               });

                              //               ScaffoldMessenger.of(
                              //                 context,
                              //               ).showSnackBar(
                              //                 const SnackBar(
                              //                   content: Text(
                              //                     'Target updated successfully',
                              //                   ),
                              //                   backgroundColor: Colors.green,
                              //                 ),
                              //               );
                              //             } catch (e) {
                              //               ScaffoldMessenger.of(
                              //                 context,
                              //               ).showSnackBar(
                              //                 SnackBar(
                              //                   content: Text('Error: $e'),
                              //                   backgroundColor: Colors.red,
                              //                 ),
                              //               );
                              //             }
                              //           } else {
                              //             ScaffoldMessenger.of(
                              //               context,
                              //             ).showSnackBar(
                              //               const SnackBar(
                              //                 content: Text(
                              //                   'Please enter a valid number',
                              //                 ),
                              //                 backgroundColor: Colors.red,
                              //               ),
                              //             );
                              //           }
                              //         }
                              //       },
                              //     ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Performance Report Section (NEW DESIGN)
                    _buildPerformanceReportSection(),

                    const SizedBox(height: 24),

                    // GFI Calling Section (NEW DESIGN)
                    _buildGFICallingSection(),

                    const SizedBox(height: 24),

                    // Attendance Marking Section (NEW DESIGN)
                    _buildAttendanceMarkingSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [child],
      ),
    );
  }

  Widget _buildTargetItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceReportSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance Report',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              if (currentUserRole == 'admin')
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF0A7FF1)),
                  tooltip: 'Edit Performance Report',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Edit Performance Report'),
                          content: const Text(
                            'Admin editing functionality goes here.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Performance Table
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Column
              Expanded(
                child: Column(
                  children: [
                    // Month Column - all corners rounded
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF27DF5B),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Month',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(color: Color(0xFF0A7FF1)),
                      child: Center(
                        child: Text(
                          (dashboardSummary?.previousMonth?.monthName ?? 'N/A'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(color: Color(0xFF0A7FF1)),
                      child: Center(
                        child: Text(
                          (dashboardSummary?.currentMonth?.monthName ?? 'N/A'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A7FF1),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          (dashboardSummary?.nextMonth?.monthName ?? 'N/A'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Joining Column - all corners rounded
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF27DF5B),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Joining',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(color: Color(0xFF0A7FF1)),
                      child: Center(
                        child: Text(
                          (dashboardSummary?.previousMonth?.totalTarget
                                  .toString() ??
                              '0'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(color: Color(0xFF0A7FF1)),
                      child: Center(
                        child: Text(
                          (dashboardSummary?.currentMonth?.totalTarget
                                  .toString() ??
                              '0'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A7FF1),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          (dashboardSummary?.nextMonth?.totalTarget
                                  .toString() ??
                              '0'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Closers Column - all corners rounded
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF27DF5B),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Closers',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(color: Color(0xFF0A7FF1)),
                      child: Center(
                        child: Text(
                          (dashboardSummary?.previousMonth?.totalAchieved
                                  .toString() ??
                              '0'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(color: Color(0xFF0A7FF1)),
                      child: Center(
                        child: Text(
                          (dashboardSummary?.currentMonth?.totalAchieved
                                  .toString() ??
                              '0'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A7FF1),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          (dashboardSummary?.nextMonth?.totalAchieved
                                  .toString() ??
                              '0'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGFICallingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GFI Calling',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await _loadGFICandidates();
                  final selectedCandidates = gfiCandidates;

                  showDialog(
                    context: context,
                    builder: (context) => CandidateListDialog(
                      title: 'GFI Selected Candidates',
                      icon: Icons.group,
                      iconColor: Color(0xFF0A7FF1),
                      candidates: selectedCandidates,
                      emptyMessage: 'No candidates selected for GFI.',
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0085FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'View ${dashboardSummary?.todayTotalGoForInterviewCount ?? '0'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Prime New FC Associates-Flex/Alpha',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          Text(
            'Associates-Flex (Bengaluru) - Amazon',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceMarkingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance Marking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await _loadAttendanceMarking();
                  final selectedCandidates = attendanceCandidates;

                  showDialog(
                    context: context,
                    builder: (context) => CandidateListDialog(
                      title: 'Reached Candidates',
                      icon: Icons.verified,
                      iconColor: Colors.green,
                      candidates: selectedCandidates,
                      emptyMessage: 'No candidates marked as reached.',
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'View ${dashboardSummary?.todayTotalReachedCandidateCount ?? '0'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Prime New FC Associates-Flex/Alpha',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          Text(
            'Associates-Flex (Bengaluru) - Amazon',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return ValueListenableBuilder<List<NotificationItem>>(
              valueListenable: _notificationService.notificationsNotifier,
              builder: (context, notifications, child) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                          if (notifications.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                _notificationService.markAllAsRead();
                              },
                              child: const Text('Mark all as read'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: notifications.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.notifications_none,
                                      size: 64,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No notifications yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: notifications.length,
                                itemBuilder: (context, index) {
                                  final notification = notifications[index];
                                  return _buildNotificationItem(
                                    context,
                                    notification,
                                  );
                                },
                              ),
                      ),
                      if (notifications.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                _notificationService.clearAll();
                              },
                              child: const Text('Clear All Notifications'),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: themeModeNotifier.value == ThemeMode.dark,
                onChanged: (value) {
                  themeModeNotifier.value = value
                      ? ThemeMode.dark
                      : ThemeMode.light;
                },
                secondary: Icon(
                  themeModeNotifier.value == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.account_circle_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  'Account Settings',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).iconTheme.color,
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Add your account settings navigation here
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  'Notifications',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).iconTheme.color,
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Add your notifications navigation here
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.help_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  'Help & Support',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).iconTheme.color,
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Add your help & support navigation here
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Add your logout logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Logout'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Notification item builder
  Widget _buildNotificationItem(
    BuildContext context,
    NotificationItem notification,
  ) {
    IconData getIcon() {
      switch (notification.type) {
        case NotificationType.interview:
          return Icons.calendar_today;
        case NotificationType.reschedule:
          return Icons.schedule;
        case NotificationType.reached:
          return Icons.check_circle;
        default:
          return Icons.notifications;
      }
    }

    Color getColor() {
      switch (notification.type) {
        case NotificationType.interview:
          return Colors.green;
        case NotificationType.reschedule:
          return Colors.orange;
        case NotificationType.reached:
          return Colors.red;
        default:
          return Theme.of(context).colorScheme.primary;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead
          ? null
          : Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getColor().withOpacity(0.1),
          child: Icon(getIcon(), color: getColor(), size: 20),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.timestamp),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          if (!notification.isRead) {
            _notificationService.markAsRead(notification.id);
          }
        },
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

  // API connection for load all candidate on map fir GFi
  Future<void> _loadGFICandidates() async {
    try {
      final data = await DashboardService.fetchGFICandidates(
        userProvider?.accessToken.toString() ?? '',
      ); // replace 1 with dynamic userId if needed
      setState(() {
        gfiCandidates = data;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  // API connection for count how many are GFI
  // Future<void> loadGFICount() async {
  //   try {
  //     final result = await DashboardService.getDashboardSummary(userId);
  //     setState(() {
  //       dashboardSummary = result;
  //       _targetInterviewScheduled = '${da!.countGFI}/${summary!.target}';
  //     });
  //   } catch (e) {
  //     print('Error loading GFI count: $e');
  //   }
  // }

  // API connection for load all candidate on map for Attendance Marking
  Future<void> _loadAttendanceMarking() async {
    try {
      final data = await DashboardService.fetchAttendanceCandidates(
        userProvider?.accessToken.toString() ?? '',
      ); // replace 1 with dynamic userId if needed
      setState(() {
        attendanceCandidates = data;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> loadDashboardSummary() async {
    try {
      final checkAdmin = userProvider?.admin ?? false;

      final summary = checkAdmin
          ? await DashboardSummaryService.fetchSimpleAdminSummary(
              userProvider?.accessToken.toString() ?? '',
            )
          : await DashboardSummaryService.fetchSimpleUserSummary(
              userProvider?.accessToken.toString() ?? '',
            );

      if (summary != null) {
        setState(() {
          dashboardSummary = summary;
        });
      } else {
        print('Failed to fetch dashboard summary');
      }
    } catch (e) {
      print('Error fetching dashboard summary: $e');
    }
  }
}

// Set Target Page
class SetTargetPage extends StatefulWidget {
  final List<Map<String, dynamic>> candidates;
  final Function(List<Map<String, dynamic>>) onTargetUpdated;
  final UserProvider? userProvider;

  const SetTargetPage({
    super.key,
    required this.candidates,
    required this.onTargetUpdated,
    required this.userProvider,
  });

  @override
  State<SetTargetPage> createState() => _SetTargetPageState();
}

class _SetTargetPageState extends State<SetTargetPage> {
  late List<Map<String, dynamic>> _candidates;
  late UserProvider? userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = widget.userProvider;
    // Initialize candidates from the widget
    _candidates = List.from(widget.candidates);
  }

  void _showTargetDialog(int index) {
    final candidate = _candidates[index];
    final TextEditingController controller = TextEditingController(
      text: candidate['target'].toString(),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Blue header section
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF4A90E2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Target",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${candidate['name']} ${candidate['id']}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        final newTarget = int.tryParse(controller.text) ?? 0;
                        final candidateId = _candidates[index]['id'];
                        final token =
                            userProvider?.accessToken.toString() ?? '';

                        try {
                          await DashboardService.createTarget(
                            token: token,
                            userId: candidateId.toString(),
                            newTarget: newTarget,
                          );

                          setState(() {
                            _candidates[index]['target'] = newTarget;
                          });

                          widget.onTargetUpdated(_candidates);

                          Navigator.pop(
                            context,
                          ); // ✅ Only close the dialog, stay on current screen

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Target updated successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update target: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          Navigator.pop(
                            context,
                          ); // ✅ Only close the dialog, stay on current screen
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // White content section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 40,
                ),
                child: Column(
                  children: [
                    const Text(
                      'Set Target',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Target input field
                    Container(
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Text(
                      'target',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDialog(int index) {
    final candidate = _candidates[index];

    showDialog(
      context: context,
      builder: (context) => _ReportDialog(candidate: candidate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Set Target',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _candidates.length,
        itemBuilder: (context, index) {
          final candidate = _candidates[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${index + 1}.${candidate['name']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        candidate['id'],
                        style: TextStyle(fontSize: 14, color: Colors.blue[600]),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _showTargetDialog(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A7FF1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Set',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _showReportDialog(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Report',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Separate StatefulWidget for Report Dialog to handle tab switching
class _ReportDialog extends StatefulWidget {
  final Map<String, dynamic> candidate;

  const _ReportDialog({required this.candidate});

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  bool _isYearlySelected = false; // Start with Monthly selected

  // Monthly data (from first screenshot)
  Map<String, String> _monthlyData = {};
  // {
  //   'Target': '5',
  //   'Turn-up': '6',
  //   'Selection': '14',
  //   'Joining': '5',
  //   'Closer': '9',
  // };

  // Yearly data (from second screenshot)
  Map<String, String> _yearlyData = {};
  // {
  //   'Target': '60',
  //   'Turn-up': '72',
  //   'Selection': '168',
  //   'Joining': '60',
  //   'Closer': '108',
  // };

  void _shareReport() {
    final period = _isYearlySelected ? 'Yearly' : 'Monthly';
    final data = _isYearlySelected ? _yearlyData : _monthlyData;

    String shareText =
        '${widget.candidate['name']}/${widget.candidate['id']} - $period Report\n\n';

    data.forEach((key, value) {
      shareText += '$key: $value\n';
    });

    Share.share(shareText);
  }

  @override
  void initState() {
    super.initState();
    // Load monthly data (if needed)
    _loadYearlyStats();
    _loadMonthlyStats();
  }

  @override
  Widget build(BuildContext context) {
    final currentData = _isYearlySelected ? _yearlyData : _monthlyData;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header section with share button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${widget.candidate['name']}/${widget.candidate['id']}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _shareReport,
                    child: Icon(Icons.share, size: 20, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Tabs section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Monthly tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isYearlySelected = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: !_isYearlySelected
                                  ? const Color(0xFF4A90E2)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Monthly',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: !_isYearlySelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: !_isYearlySelected
                                ? const Color(0xFF4A90E2)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Yearly tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isYearlySelected = true;
                        });

                        // _loadYearlyStats(); // Call your API
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _isYearlySelected
                                  ? const Color(0xFF4A90E2)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Yearly',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: _isYearlySelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: _isYearlySelected
                                ? const Color(0xFF4A90E2)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider line
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 1,
              color: Colors.grey.withOpacity(0.2),
            ),

            const SizedBox(height: 32),

            // Performance metrics
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  // First row - Target and Turn-up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricColumn('Target', currentData['Target']!),
                      _buildMetricColumn('Turn-up', currentData['Turn-up']!),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // Second row - Selection and Joining
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricColumn(
                        'Selection',
                        currentData['Selection']!,
                      ),
                      _buildMetricColumn('Joining', currentData['Joining']!),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // Third row - Closer (centered)
                  _buildMetricColumn('Closer', currentData['Closer']!),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Back button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadYearlyStats() async {
    final stats = await ReportService().fetchYearlyStats(
      userId: widget.candidate['id'].toString(),
      year: DateTime.now().year.toString(),
      token: _HomeTabScreenState.userProvider?.accessToken.toString() ?? '',
    );

    if (stats != null) {
      setState(() {
        _yearlyData = {
          'Target': stats.targetCount.toString(),
          'Turn-up': stats.goForInterviewCount.toString(),
          'Selection': stats.selectedCandidateCount.toString(),
          'Joining': stats.joiningCandidateCount.toString(),
          'Closer': '0', // optional if not from backend
        };
      });
    }
  }

  Future<void> _loadMonthlyStats() async {
    final stats = await ReportService().fetchMonthlyStats(
      userId: widget.candidate['id'].toString(),
      year: DateTime.now().year.toString(),
      month: DateTime.now().month.toString(),
      token: _HomeTabScreenState.userProvider?.accessToken.toString() ?? '',
    );

    if (stats != null) {
      setState(() {
        _monthlyData = {
          'Target': stats.targetCount.toString(),
          'Turn-up': stats.goForInterviewCount.toString(),
          'Selection': stats.selectedCandidateCount.toString(),
          'Joining': stats.joiningCandidateCount.toString(),
          'Closer': '0', // optional if not from backend
        };
      });
    }
  }

  Widget _buildMetricColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class CandidateListDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<GoForInterviewResponse> candidates;
  final String emptyMessage;

  const CandidateListDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.candidates,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).cardColor,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            candidates.isEmpty
                ? Text(emptyMessage, style: const TextStyle(fontSize: 16))
                : SizedBox(
                    height: 250,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: candidates.length,
                      itemBuilder: (context, idx) {
                        final candidate = candidates[idx];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Candidate Name: ${candidate.candidateName ?? ''}',
                                ),
                                Text(
                                  'Candidate ID: ${candidate.candidateId ?? ''}',
                                ),
                                Text('User ID: ${candidate.userId ?? ''}'),
                                Text('Role: ${candidate.role ?? ''}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
