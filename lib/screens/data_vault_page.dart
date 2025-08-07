import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:headsup_ats/models/Candidate_model.dart';
import 'package:headsup_ats/models/db_candiate_status_model.dart';
import 'package:headsup_ats/models/db_candidate_model.dart';
import 'package:headsup_ats/models/db_vault_model.dart';
import 'package:headsup_ats/services/candidatte_db_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/app_colors.dart';
import 'dashboard_shell_screen.dart';
import '../services/database_service.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io' as io;

class DataVaultPage extends StatefulWidget {
  final VoidCallback? onBackToHome;
  final bool isAdmin;
  const DataVaultPage({super.key, this.onBackToHome, this.isAdmin = false});

  @override
  State<DataVaultPage> createState() => _DataVaultPageState();
}

class _DataVaultPageState extends State<DataVaultPage> {
  List<CandidateModelConverter> allCandidates = [];
  List<CandidateModelConverter> databaseCandidates = [];
  List<CandidateModelConverter> unlockedCandidates = [];
  String selectedStatusFilter = 'All';
  String selectedGenderFilter = 'All';
  String selectedExperienceFilter = 'All';
  String selectedLocationFilter = 'All';
  String selectedUploadDateFilter = 'All';
  bool isDatabaseTabSelected = true;
  static UserProvider? userProvider;

  // Track which candidates' unlock panels are open (by name+phone for uniqueness)
  Set<String> openUnlockPanelKeys = {};
  // Track which unlocked candidates' dropdowns are open
  Set<String> openUnlockedDropdowns = {};
  // Show loading indicator on tab switch
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    _initializeCandidates();
  }

  String _getStatusKey(StatusDTO status) {
    return '${status.statusName}-${status.addedDate}';
  }

  String? _getStatusKeyFromName(
    String? statusName,
    List<StatusDTO> statusList,
  ) {
    final match = statusList.firstWhere(
      (s) => s.statusName == statusName,
      orElse: () => StatusDTO(statusName: '', addedDate: ''),
    );
    return _getStatusKey(match);
  }

  void _initializeCandidates() async {
    final candidateService = CadidateDBService();
    try {
      // Replace with actual values
      int userId = userProvider?.id ?? 0;
      String accessToken = userProvider?.accessToken ?? '';

      final candidates = await candidateService.getAllLockedCandidates(
        userId,
        accessToken,
      );

      setState(() {
        allCandidates = candidates;
      });
    } catch (e) {
      print("Error fetching candidates: $e");
      // Optionally show a snackbar
    }
    // Initially all candidates are in database
    databaseCandidates = List.from(allCandidates);
    unlockedCandidates = [];
    filteredDatabaseCandidates = List.from(databaseCandidates);
    filteredUnlockedCandidates = List.from(unlockedCandidates);
  }

  void _unlockCandidate(CandidateModelConverter candidate) {
    setState(() {
      // Remove from database candidates
      databaseCandidates.removeWhere(
        (c) => c.candidateId == candidate.candidateId,
      );
      // Mark as unlocked and add to top of unlocked candidates
      candidate.isUnlocked = true;
      unlockedCandidates.insert(0, candidate);
      // Keep the slide-down open for this candidate
      openUnlockPanelKeys.add(candidate.candidateId);
      _applyFilters();
    });
    // No navigation, just unlock in-place
  }

  List<CandidateModelConverter> filteredDatabaseCandidates = [];
  List<CandidateModelConverter> filteredUnlockedCandidates = [];

  List<CandidateModelConverter> get currentCandidates {
    return isDatabaseTabSelected
        ? filteredDatabaseCandidates
        : filteredUnlockedCandidates;
  }

  void _applyFilters() {
    setState(() {
      filteredDatabaseCandidates = databaseCandidates
          .where(
            (c) =>
                (selectedStatusFilter == 'All' ||
                    (c.status ?? '').toLowerCase() ==
                        selectedStatusFilter.toLowerCase()) &&
                (selectedGenderFilter == 'All' ||
                    (c.gender ?? '').toLowerCase().startsWith(
                      selectedGenderFilter.toLowerCase(),
                    )) &&
                (selectedExperienceFilter == 'All' ||
                    (c.experience ?? '').toLowerCase().contains(
                      selectedExperienceFilter.toLowerCase(),
                    )) &&
                (selectedLocationFilter == 'All' ||
                    (c.location ?? '').toLowerCase().contains(
                      selectedLocationFilter.toLowerCase().trim(),
                    )) &&
                (selectedUploadDateFilter == 'All' ||
                    (c.uploadDate ?? '').toLowerCase().contains(
                      selectedUploadDateFilter.toLowerCase(),
                    )),
          )
          .toList();
      filteredUnlockedCandidates = unlockedCandidates
          .where(
            (c) =>
                (selectedStatusFilter == 'All' ||
                    (c.status ?? '').toLowerCase() ==
                        selectedStatusFilter.toLowerCase()) &&
                (selectedGenderFilter == 'All' ||
                    (c.gender ?? '').toLowerCase().startsWith(
                      selectedGenderFilter.toLowerCase(),
                    )) &&
                (selectedExperienceFilter == 'All' ||
                    (c.experience ?? '').toLowerCase().contains(
                      selectedExperienceFilter.toLowerCase(),
                    )) &&
                (selectedLocationFilter == 'All' ||
                    (c.location ?? '').toLowerCase().contains(
                      selectedLocationFilter.toLowerCase().trim(),
                    )) &&
                (selectedUploadDateFilter == 'All' ||
                    (c.uploadDate ?? '').toLowerCase().contains(
                      selectedUploadDateFilter.toLowerCase(),
                    )),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF181A20)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF23262B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardShellScreen(),
              ),
              (route) => false,
            );
          },
        ),
        title: Row(
          children: [
            Text(
              'Data Vault',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '(${databaseCandidates.length},${unlockedCandidates.length})',
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Upload Button with improved style and smaller menu
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: PopupMenuButton<String>(
              icon: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                width: 38,
                height: 38,
                child: Icon(
                  Icons.add,
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                  size: 22,
                ),
              ),
              color: isDark ? const Color(0xFF23262B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'excel',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 120,
                      maxWidth: 180,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.upload_file,
                          color: isDark ? Colors.white : Colors.black,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Upload Excel',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'google_sheets',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 120,
                      maxWidth: 180,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.table_chart,
                          color: isDark ? Colors.white : Colors.black,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Google Sheets',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              onSelected: _handleUploadOption,
              offset: const Offset(0, 40),
              elevation: 6,
            ),
          ),
          // Filter Button with improved style and smaller menu
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: PopupMenuButton<String>(
              icon: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                width: 38,
                height: 38,
                child: Icon(
                  Icons.menu,
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                  size: 22,
                ),
              ),
              color: isDark ? const Color(0xFF23262B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'filter',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 120,
                      maxWidth: 180,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Filter Options',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const Divider(height: 10, thickness: 1),
                        _buildFilterOption('By Status', isDark),
                        _buildFilterOption('By Gender', isDark),
                        _buildFilterOption('By Experience', isDark),
                        _buildFilterOption('By Location', isDark),
                        _buildFilterOption('By Upload Date', isDark),
                      ],
                    ),
                  ),
                ),
              ],
              onSelected: (value) {},
              offset: const Offset(0, 40),
              elevation: 6,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Section
          Container(
            color: isDark ? const Color(0xFF23262B) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      _isRefreshing = true;
                    });

                    try {
                      // Fetch fresh data from backend
                      final fetchedCandidates = await CadidateDBService()
                          .getAllLockedCandidates(
                            userProvider!.id ?? 0,
                            userProvider!.accessToken.toString() ?? '',
                          );

                      // Update state
                      setState(() {
                        allCandidates = fetchedCandidates;

                        // Filter out only locked candidates (isUnlocked == false or null)
                        databaseCandidates = allCandidates
                            .where((c) => c.isUnlocked != true)
                            .toList();

                        isDatabaseTabSelected = true;
                        openUnlockedDropdowns.clear();
                        openUnlockPanelKeys
                            .clear(); // Collapse all database dropdowns
                        unlockedCandidates = allCandidates
                            .where((c) => c.isUnlocked == true)
                            .toList();
                        _applyFilters(); // Apply sorting/filtering logic
                        _isRefreshing = false;
                      });
                    } catch (e) {
                      setState(() {
                        _isRefreshing = false;
                      });

                      // Optional: show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Failed to fetch candidates: $e"),
                        ),
                      );
                    }
                  },
                  child: _buildTab(
                    'Database',
                    '(${databaseCandidates.length})',
                    isDatabaseTabSelected,
                    isDark,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      _isRefreshing = true;
                    });

                    try {
                      // Call your API to fetch all candidates
                      final fetchedCandidates = await CadidateDBService()
                          .getAllUnlockedCandidates(
                            userProvider!.id ?? 0,
                            userProvider!.accessToken.toString() ?? '',
                          );

                      // Update the main list
                      setState(() {
                        allCandidates = fetchedCandidates;

                        // Extract unlocked candidates from updated list
                        unlockedCandidates = allCandidates
                            .where((c) => c.isUnlocked == true)
                            .toList();

                        // UI and state management
                        isDatabaseTabSelected = false;
                        openUnlockedDropdowns.clear();
                        _applyFilters();
                        _isRefreshing = false;
                      });
                    } catch (e) {
                      setState(() {
                        _isRefreshing = false;
                      });

                      // Optional: show error to user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Failed to fetch candidates: $e"),
                        ),
                      );
                    }
                  },
                  child: _buildTab(
                    'Unlocked',
                    '(${unlockedCandidates.length})',
                    !isDatabaseTabSelected,
                    isDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Candidate List
          Expanded(
            child: _isRefreshing
                ? Center(child: CircularProgressIndicator())
                : currentCandidates.isEmpty
                ? Center(
                    child: Text(
                      isDatabaseTabSelected
                          ? 'No candidates in database'
                          : 'No unlocked candidates yet',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: currentCandidates.length,
                    itemBuilder: (context, index) {
                      return _buildCandidateCard(
                        currentCandidates[index],
                        isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String title, bool isDark) {
    return InkWell(
      onTap: () => _showFilterDialog(title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(String filterType) {
    Navigator.pop(context);

    List<String> options = [];
    String currentValue = '';

    switch (filterType) {
      case 'By Status':
        options = ['All', 'Interested', 'RNR', 'Busy', 'Pending'];
        currentValue = selectedStatusFilter;
        break;
      case 'By Gender':
        options = ['All', 'Male', 'Female'];
        currentValue = selectedGenderFilter;
        break;
      case 'By Experience':
        options = ['All', 'Fresher', '1-2 Years', '3-5 Years', '5+ Years'];
        currentValue = selectedExperienceFilter;
        break;
      case 'By Location':
        options = ['All', 'Bangalore', 'Mumbai', 'Delhi', 'Chennai'];
        currentValue = selectedLocationFilter;
        break;
      case 'By Upload Date':
        options = ['All', 'Today', 'This Week', 'This Month'];
        currentValue = selectedUploadDateFilter;
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(filterType),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: currentValue,
                onChanged: (value) {
                  setState(() {
                    switch (filterType) {
                      case 'By Status':
                        selectedStatusFilter = value!;
                        break;
                      case 'By Gender':
                        selectedGenderFilter = value!;
                        break;
                      case 'By Experience':
                        selectedExperienceFilter = value!;
                        break;
                      case 'By Location':
                        selectedLocationFilter = value!;
                        break;
                      case 'By Upload Date':
                        selectedUploadDateFilter = value!;
                        break;
                    }
                  });
                  Navigator.pop(context);
                  _applyFilters();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _handleUploadOption(String option) {
    switch (option) {
      case 'excel':
        _uploadExcelSheet();
        break;
      case 'google_sheets':
        _connectGoogleSheets();
        break;
    }
  }

  Future<void> _uploadExcelSheet() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: kIsWeb, // Required for web
      );

      if (result == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❗No file selected.")));
        return;
      }

      String csvString;

      if (kIsWeb) {
        Uint8List fileBytes = result.files.single.bytes!;
        csvString = utf8.decode(fileBytes);
      } else {
        String? path = result.files.single.path;
        if (path == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("❌ Could not get file path.")));
          return;
        }
        final file = io.File(path);
        csvString = await file.readAsString();
      }

      List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);

      if (rows.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ CSV is empty or missing header.")),
        );
        return;
      }

      // Trim headers
      List<String> headers = rows.first
          .map((e) => e.toString().trim())
          .toList();
      List<CandidateDB> candidates = [];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        final Map<String, dynamic> rowData = {};

        for (int j = 0; j < headers.length; j++) {
          rowData[headers[j]] = j < row.length ? row[j] : null;
        }

        try {
          final candidate = CandidateDB.fromJson({
            'name': rowData['name']?.toString() ?? '',
            'location': rowData['location']?.toString() ?? '',
            'qualification': rowData['qualification']?.toString() ?? '',
            'languages': rowData['languages']?.toString() ?? '',
            'experience': rowData['experience']?.toString() ?? '',
            'gender': rowData['gender']?.toString() ?? '',
            'age': int.tryParse(rowData['age'].toString()) ?? 0,
            'callStatus': rowData['callStatus']?.toString() ?? '',
            'role': rowData['role']?.toString() ?? '',
            'uploadDate': rowData['uploadDate']?.toString() ?? '',
            'phone': rowData['phone'].toString(),
            'email': rowData['email']?.toString() ?? '',
            'isUnlocked':
                rowData['isUnlocked']?.toString().toLowerCase().trim() ==
                'true',
            'notes': rowData['notes']?.toString() ?? '',
            'other1': rowData['other1']?.toString() ?? '',
            'other2': rowData['other2']?.toString() ?? '',
            'userId': int.tryParse(rowData['userId'].toString()) ?? 0,
          });

          candidates.add(candidate);
        } catch (e) {
          debugPrint("Skipping row $i due to error: $e");
        }
      }

      if (candidates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❗No valid candidate data found.")),
        );
        return;
      }

      await _sendToBackend(
        context,
        candidates,
        userProvider!.accessToken.toString() ?? '',
      );
    } catch (e, st) {
      debugPrint("❌ Error while uploading CSV: $e\n$st");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error reading file: $e")));
    }
  }

  Future<void> _sendToBackend(
    BuildContext context,
    List<CandidateDB> candidates,
    String token,
  ) async {
    final result = await CadidateDBService.importCandidates(candidates, token);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "✅ Uploaded: ${result['inserted']} | Skipped: ${result['skipped']}",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "❌ Unknown error.")),
      );
    }
  }

  void _connectGoogleSheets() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sheets integration coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildTab(String title, String count, bool isSelected, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? primaryBlue.withOpacity(0.2) : Colors.blue[100])
            : (isDark ? Colors.grey[800] : Colors.grey[200]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? (isDark ? primaryBlue : Colors.blue[700])
                  : (isDark ? Colors.grey[300] : Colors.grey[600]),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              color: isSelected
                  ? (isDark ? primaryBlue : Colors.blue[700])
                  : (isDark ? Colors.grey[300] : Colors.grey[600]),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(CandidateModelConverter candidate, bool isDark) {
    final isUnlockedTab = !isDatabaseTabSelected;
    final isDropdownOpen = isUnlockedTab
        ? openUnlockedDropdowns.contains(candidate.candidateId)
        : openUnlockPanelKeys.contains(candidate.candidateId);
    final List<StatusDTO> statusList = candidate.statusList ?? [];
    final StatusDTO? selectedStatus = statusList.isNotEmpty
        ? statusList.last
        : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF23262B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name, candidateId, and role
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${candidate.candidateId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      candidate.location ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  candidate.role ?? '',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                // onTap: () {
                //   final editable = EditableCandidate(
                //     name: candidate.name ?? '',
                //     location: candidate.location ?? '',
                //     qualification: candidate.qualification ?? '',
                //     languages: candidate.languages ?? '',
                //     experience: candidate.experience ?? '',
                //     gender: candidate.gender ?? '',
                //     age: candidate.age ?? '',
                //     status: candidate.status ?? '',
                //     role: candidate.role ?? '',
                //     uploadDate: candidate.uploadDate ?? '',
                //     phone: candidate.phone ?? '',
                //     email: candidate.email ?? '',
                //     isUnlocked: candidate.isUnlocked ?? false,
                //   );
                //   showDialog(
                //     context: context,
                //     builder: (context) => EditCandidateDialog(
                //       candidate: editable,
                //       onSave: (edited) {
                //         setState(() {
                //           // Replace the candidate in the list with a new CandidateModelConverter
                //           int idx = currentCandidates.indexOf(candidate);
                //           CandidateModelConverter updated = CandidateModelConverter(
                //             candidateId: candidate.candidateId,
                //             name: edited.name,
                //             location: edited.location,
                //             qualification: edited.qualification,
                //             languages: edited.languages,
                //             experience: edited.experience,
                //             gender: edited.gender,
                //             age: edited.age,
                //             status: edited.status,
                //             role: edited.role,
                //             uploadDate: edited.uploadDate,
                //             phone: edited.phone,
                //             email: edited.email,
                //             isUnlocked: edited.isUnlocked,
                //           );
                //           if (isDatabaseTabSelected) {
                //             databaseCandidates[databaseCandidates.indexOf(candidate)] = updated;
                //             filteredDatabaseCandidates[idx] = updated;
                //           } else {
                //             unlockedCandidates[unlockedCandidates.indexOf(candidate)] = updated;
                //             filteredUnlockedCandidates[idx] = updated;
                //           }
                //         });
                //       },
                //     ),
                //   );
                // },
                child: Icon(
                  Icons.edit,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Details rows
          Row(
            children: [
              Expanded(
                child: _buildDetailRow(
                  Icons.school,
                  candidate.qualification ?? '',
                  isDark,
                ),
              ),
              Expanded(
                child: _buildDetailRow(
                  Icons.language,
                  candidate.languages ?? '',
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailRow(
                  Icons.work,
                  candidate.experience ?? '',
                  isDark,
                ),
              ),
              Expanded(
                child: _buildDetailRow(
                  Icons.person,
                  (candidate.gender ?? '') +
                      ((candidate.age ?? '').isNotEmpty
                          ? ', ${candidate.age}'
                          : ''),
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Communication buttons section (for unlocked candidates)
          if ((candidate.isUnlocked ?? false)) ...[
            // First row of communication buttons
            Row(
              children: [
                Expanded(
                  child: _buildExactScreenshotButton(
                    icon: FontAwesomeIcons.whatsapp,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () async {
                      final status = DBStatusDTO(
                        statusName: 'WhatsApp',
                        other1: 'Sent WhatsApp message',
                        candidateId: int.parse(candidate.candidateId),
                        userId: _DataVaultPageState.userProvider?.id ?? 0,
                      );

                      await CadidateDBService().addStatus(
                        status,
                        _DataVaultPageState.userProvider?.accessToken ?? '',
                      );

                      _showWhatsAppDialog(
                        candidate,
                      ); // Assuming it handles UI and message
                    },
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildExactScreenshotButton(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    color: const Color(0xFF2196F3),
                    onTap: () async {
                      final phone = candidate.phone ?? '';

                      // Call your API silently
                      final status = DBStatusDTO(
                        statusName: 'Phone',
                        other1: 'Called from Phone button',
                        candidateId: int.parse(candidate.candidateId),
                        userId: _DataVaultPageState.userProvider?.id ?? 0,
                      );

                      await CadidateDBService().addStatus(
                        status,
                        _DataVaultPageState.userProvider?.accessToken
                                .toString() ??
                            '',
                      ); // No context needed
                      _launchPhone(candidate.phone ?? '');
                    },
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildExactScreenshotButton(
                    icon: Icons.schedule_outlined,
                    label: 'Schedule',
                    color: const Color(0xFF9C27B0),
                    onTap: () => _scheduleCall(),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Second row of communication buttons
            Row(
              children: [
                Expanded(
                  child: _buildExactScreenshotButton(
                    icon: Icons.sms_outlined,
                    label: 'SMS',
                    color: const Color(0xFFFF9800),
                    onTap: () async {
                      final phone = candidate.phone ?? '';

                      final status = DBStatusDTO(
                        statusName: 'SMS',
                        other1: 'Sent SMS to candidate',
                        candidateId: int.parse(candidate.candidateId),
                        userId: _DataVaultPageState.userProvider?.id ?? 0,
                      );

                      await CadidateDBService().addStatus(
                        status,
                        _DataVaultPageState.userProvider?.accessToken ?? '',
                      );

                      _launchSMSWithMessage(
                        phone,
                        'Hi,\nI have a job vacancy in your city.\n\nJob: Sales executive\nSalary: up to Rs.35,000\nCall Me: 9818074659',
                      );
                    },

                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildExactScreenshotButton(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    color: const Color(0xFFF44336),
                    onTap: () async {
                      final email = candidate.email ?? '';

                      final status = DBStatusDTO(
                        statusName: 'Email',
                        other1: 'Sent email to candidate',
                        candidateId: int.parse(candidate.candidateId),
                        userId: _DataVaultPageState.userProvider?.id ?? 0,
                      );

                      await CadidateDBService().addStatus(
                        status,
                        _DataVaultPageState.userProvider?.accessToken ?? '',
                      );

                      _launchEmailWithMessage(
                        email,
                        'Dear Candidate,\n\nI hope this email finds you well.\n\nI have a job vacancy in your city.\n\nJob Details:\nPosition: Sales executive\nSalary: up to Rs.35,000\nContact: 9818074659\n\nBest regards',
                      );
                    },

                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _buildRemarksDropdown(candidate, isDark)),
              ],
            ),
            // Removed custom dropdown arrow and dropdown content for unlocked candidates
            const SizedBox(height: 16),
            // Status section
            // Status dropdown
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      candidate.status ?? '',
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(
                        candidate.status ?? '',
                      ).withOpacity(0.3),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: SizedBox(
                      width: 130, // 👈 Set max width
                      child: DropdownButton<String>(
                        isDense: true, // 👈 Reduce height
                        value: selectedStatus != null
                            ? _getStatusKey(selectedStatus)
                            : null,
                        icon: const Icon(Icons.arrow_drop_down, size: 18),
                        style: TextStyle(
                          color: _getStatusColor(
                            selectedStatus?.statusName ?? '',
                          ),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        onChanged: (String? newKey) {
                          final matchedStatus = statusList.firstWhere(
                            (s) => _getStatusKey(s) == newKey,
                            orElse: () =>
                                StatusDTO(statusName: '', addedDate: ''),
                          );

                          setState(() {
                            candidate.status = matchedStatus.statusName;
                          });
                        },
                        selectedItemBuilder: (BuildContext context) {
                          return statusList.map((StatusDTO status) {
                            // 👇 Show only name (not year) when dropdown is closed
                            return Text(
                              status.statusName ?? '',
                              overflow: TextOverflow.ellipsis,
                            );
                          }).toList();
                        },
                        items: statusList.map((StatusDTO status) {
                          final key = _getStatusKey(status);

                          String? formattedDate = '';
                          if (status.addedDate != null &&
                              status.addedDate!.isNotEmpty) {
                            try {
                              final DateTime parsed = DateTime.parse(
                                status.addedDate!,
                              );
                              formattedDate =
                                  '${parsed.day.toString().padLeft(2, '0')}/'
                                  '${parsed.month.toString().padLeft(2, '0')}/'
                                  '${parsed.year.toString().substring(2)}'; // 👈 DD/MM/YY
                            } catch (e) {
                              formattedDate = '';
                            }
                          }

                          return DropdownMenuItem<String>(
                            value: key,
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    status.statusName ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                if (formattedDate.isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    "($formattedDate)",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Bottom section with status and unlock button (only for database candidates)
            Column(
              children: [
                Row(
                  children: [
                    // Status dropdown inside decorated container
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          candidate.status ?? '',
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(
                            candidate.status ?? '',
                          ).withOpacity(0.3),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: SizedBox(
                          width: 130, // Set max width
                          child: DropdownButton<String>(
                            isDense: true,
                            value: _getStatusKeyFromName(
                              candidate.status,
                              statusList,
                            ),
                            icon: const Icon(Icons.arrow_drop_down, size: 18),
                            style: TextStyle(
                              color: _getStatusColor(candidate.status ?? ''),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            onChanged: (String? newKey) {
                              final matchedStatus = statusList.firstWhere(
                                (s) => _getStatusKey(s) == newKey,
                                orElse: () =>
                                    StatusDTO(statusName: '', addedDate: ''),
                              );
                              setState(() {
                                candidate.status = matchedStatus.statusName;
                              });
                            },
                            selectedItemBuilder: (BuildContext context) {
                              return statusList.map((StatusDTO status) {
                                return Text(
                                  status.statusName ?? '',
                                  overflow: TextOverflow.ellipsis,
                                );
                              }).toList();
                            },
                            items: statusList.map((StatusDTO status) {
                              final key = _getStatusKey(status);
                              String? formattedDate = '';
                              if (status.addedDate != null &&
                                  status.addedDate!.isNotEmpty) {
                                try {
                                  final DateTime parsed = DateTime.parse(
                                    status.addedDate!,
                                  );
                                  formattedDate =
                                      '${parsed.day.toString().padLeft(2, '0')}/'
                                      '${parsed.month.toString().padLeft(2, '0')}/'
                                      '${parsed.year.toString().substring(2)}';
                                } catch (e) {
                                  formattedDate = '';
                                }
                              }

                              return DropdownMenuItem<String>(
                                value: key,
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        status.statusName ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    if (formattedDate.isNotEmpty) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        "($formattedDate)",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Unlock button (unchanged)
                    if (!(candidate.isUnlocked ?? false) &&
                        !openUnlockPanelKeys.contains(candidate.candidateId))
                      ElevatedButton(
                        onPressed: () {
                          final key = candidate.candidateId;
                          setState(() {
                            openUnlockPanelKeys.add(key);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Unlock the candidate',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
                // Slide-down panel
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child:
                      (openUnlockPanelKeys.contains(candidate.candidateId) ||
                          (candidate.isUnlocked ?? false))
                      ? Padding(
                          padding: const EdgeInsets.only(
                            top: 12.0,
                            bottom: 4.0,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildExactScreenshotButton(
                                      icon: FontAwesomeIcons.whatsapp,
                                      label: 'WhatsApp',
                                      color: const Color(0xFF25D366),
                                      onTap: () => _launchWhatsAppWithMessage(
                                        candidate.phone ?? '',
                                        'Hi,\nI have a job vacancy in your city.\n\nJob Details:\nJob: Sales executive\nSalary: up to Rs.35,000\nCall Me: 9818074659',
                                      ),
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildExactScreenshotButton(
                                      icon: Icons.phone_outlined,
                                      label: 'Phone',
                                      color: const Color(0xFF2196F3),
                                      onTap: () async {
                                        final token =
                                            _DataVaultPageState
                                                .userProvider
                                                ?.accessToken ??
                                            '';
                                        final candidateId =
                                            candidate.candidateId;

                                        final success =
                                            await CadidateDBService()
                                                .unlockCandidateById(
                                                  candidateId,
                                                  token,
                                                );

                                        if (success) {
                                          setState(() {
                                            int allIdx = allCandidates
                                                .indexWhere(
                                                  (c) =>
                                                      c.candidateId ==
                                                      candidateId,
                                                );
                                            if (allIdx != -1) {
                                              allCandidates[allIdx].isUnlocked =
                                                  true;
                                            }

                                            databaseCandidates.removeWhere(
                                              (c) =>
                                                  c.candidateId == candidateId,
                                            );

                                            unlockedCandidates = allCandidates
                                                .where(
                                                  (c) => c.isUnlocked == true,
                                                )
                                                .toList();

                                            isDatabaseTabSelected = false;
                                            openUnlockedDropdowns.clear();
                                            _applyFilters();
                                          });

                                          _launchPhone(candidate.phone ?? '');
                                        } else {
                                          // Optional: show error Snackbar
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Failed to unlock candidate',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildExactScreenshotButton(
                                      icon: Icons.schedule_outlined,
                                      label: 'Schedule',
                                      color: const Color(0xFF9C27B0),
                                      onTap: () {},
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildExactScreenshotButton(
                                      icon: Icons.sms_outlined,
                                      label: 'SMS',
                                      color: const Color(0xFFFF9800),
                                      onTap: () => _launchSMSWithMessage(
                                        candidate.phone ?? '',
                                        'Hi,\nI have a job vacancy in your city.\n\nJob: Sales executive\nSalary: up to Rs.35,000\nCall Me: 9818074659',
                                      ),
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildExactScreenshotButton(
                                      icon: Icons.email_outlined,
                                      label: 'Email',
                                      color: const Color(0xFFF44336),
                                      onTap: () => _launchEmailWithMessage(
                                        candidate.email ?? '',
                                        'Dear Candidate,\n\nI hope this email finds you well.\n\nI have a job vacancy in your city.\n\nJob Details:\nPosition: Sales executive\nSalary: up to Rs.35,000\nContact: 9818074659\n\nBest regards',
                                      ),
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildRemarksDropdown(
                                      candidate,
                                      isDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Uploaded date\n${candidate.uploadDate ?? ''}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // WhatsApp Dialog
  void _showWhatsAppDialog(CandidateModelConverter candidate) {
    final TextEditingController messageController = TextEditingController();
    messageController.text = '''Hi,
I have a job vacancy in your city.

Job Details:
Job: Sales executive
Salary: up to Rs.35,000
Call Me: 9818074659''';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF23262B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send Whatsapp',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2D32) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: messageController,
                    maxLines: 6,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      hintText: 'Enter your message...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchWhatsAppWithMessage(
                          candidate.phone ?? '',
                          messageController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // SMS Dialog
  void _showSMSDialog(CandidateModelConverter candidate) {
    final TextEditingController messageController = TextEditingController();
    messageController.text = '''Hi,
I have a job vacancy in your city.

Job: Sales executive
Salary: up to Rs.35,000
Call Me: 9818074659''';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF23262B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send Sms',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2D32) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: messageController,
                    maxLines: 5,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      hintText: 'Enter your message...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchSMSWithMessage(
                          candidate.phone ?? '',
                          messageController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Email Dialog
  void _showEmailDialog(CandidateModelConverter candidate) {
    final TextEditingController messageController = TextEditingController();
    messageController.text = '''Dear Candidate,

I hope this email finds you well.

I have a job vacancy in your city.

Job Details:
Position: Sales executive
Salary: up to Rs.35,000
Contact: 9818074659

Best regards''';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF23262B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send Email',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2D32) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: messageController,
                    maxLines: 8,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      hintText: 'Enter your message...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchEmailWithMessage(
                          candidate.email ?? '',
                          messageController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExactScreenshotButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CORRECTED: Dropdown with proper positioning and reduced gaps
  Widget _buildRemarksDropdown(CandidateModelConverter candidate, bool isDark) {
    final List<String> statusOptions = [
      'Interested',
      'RNR',
      'Busy',
      'Contact again',
      'Pending',
      'Switched off',
      'Not Interested',
      'Not Suitable',
      'Wrong Number',
    ];

    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      onSelected: (String? newValue) async {
        if (newValue != null) {
          setState(() {
            candidate.status = newValue;
          });

          final status = DBStatusDTO(
            statusName: newValue,
            other1: 'Updated via Remarks dropdown',
            candidateId: int.parse(candidate.candidateId),
            userId: _DataVaultPageState.userProvider?.id ?? 0,
          );

          await CadidateDBService().addStatus(
            status,
            _DataVaultPageState.userProvider?.accessToken ?? '',
          );
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          enabled: false,
          height: 32,
          child: Text(
            'Call Status',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const PopupMenuDivider(height: 8),
        ...statusOptions.map((String status) {
          Color statusColor = _getStatusColor(status);
          return PopupMenuItem<String>(
            value: status,
            height: 32,
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Remarks',
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  // Updated color method with exact hex colors and better visibility for "Busy"
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Interested':
        return const Color(0xFF1FB529); // #1FB529
      case 'RNR':
        return const Color(0xFFD82D1A); // #D82D1A
      case 'Busy':
        return const Color(
          0xFFE67E22,
        ); // Using darker orange for better visibility
      case 'Contact again':
        return const Color(0xFF407BFF); // #407BFF
      case 'Pending':
        return Colors.purple;
      case 'Switched off':
        return Colors.grey;
      case 'Not Interested':
        return const Color(0xFFD82D1A);
      case 'Not Suitable':
        return const Color(0xFFD82D1A);
      case 'Wrong Number':
        return const Color(0xFFD82D1A);
      default:
        return Colors.grey;
    }
  }

  Future<void> _launchWhatsAppWithMessage(String phone, String message) async {
    final Uri whatsappUri = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchSMSWithMessage(String phone, String message) async {
    final Uri smsUri = Uri.parse(
      "sms:$phone?body=${Uri.encodeComponent(message)}",
    );
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }

  Future<void> _launchEmailWithMessage(String email, String message) async {
    final Uri emailUri = Uri.parse(
      "mailto:$email?subject=Job Opportunity&body=${Uri.encodeComponent(message)}",
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _scheduleCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Call'),
        content: const Text('Call scheduling feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Unlocked Candidate Detail Page
class UnlockedCandidateDetailPage extends StatefulWidget {
  final CandidateModelConverter candidate;
  final VoidCallback? onBack;

  final int databaseCount;
  final int unlockedCount;

  const UnlockedCandidateDetailPage({
    super.key,
    required this.candidate,
    this.onBack,
    required this.databaseCount,
    required this.unlockedCount,
  });

  @override
  State<UnlockedCandidateDetailPage> createState() =>
      _UnlockedCandidateDetailPageState();
}

class _UnlockedCandidateDetailPageState
    extends State<UnlockedCandidateDetailPage> {
  String selectedCallStatus = 'Interested';

  @override
  void initState() {
    super.initState();
    selectedCallStatus = widget.candidate.status ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF181A20)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF23262B) : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Data Vault',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '(${widget.databaseCount},${widget.unlockedCount})',
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Icon(
              Icons.add,
              color: isDark ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
          Icon(Icons.menu, color: isDark ? Colors.grey[300] : Colors.grey[600]),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Section - Fixed at top
          Container(
            color: isDark ? const Color(0xFF23262B) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.onBack != null) {
                      widget.onBack!();
                    }
                  },
                  child: _buildTab(
                    'Database',
                    '(${widget.databaseCount})',
                    false,
                    isDark,
                  ),
                ),
                const SizedBox(width: 16),
                _buildTab(
                  'Unlocked',
                  '(${widget.unlockedCount})',
                  true,
                  isDark,
                ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Candidate Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF23262B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with name and role
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.candidate.name ?? '',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.candidate.location ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                widget.candidate.role ?? '',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Edit'),
                                    content: const Text(
                                      'Edit feature coming soon!',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.edit,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[400],
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Details rows
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailRow(
                                Icons.school,
                                widget.candidate.qualification ?? '',
                                isDark,
                              ),
                            ),
                            Expanded(
                              child: _buildDetailRow(
                                Icons.language,
                                widget.candidate.languages ?? '',
                                isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailRow(
                                Icons.work,
                                widget.candidate.experience ?? '',
                                isDark,
                              ),
                            ),
                            Expanded(
                              child: _buildDetailRow(
                                Icons.person,
                                widget.candidate.gender ?? '',
                                isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Communication Options
                        Row(
                          children: [
                            Expanded(
                              child: _buildExactScreenshotButton(
                                icon: FontAwesomeIcons.whatsapp,
                                label: 'WhatsApp',
                                color: const Color(0xFF25D366),
                                onTap: () => _launchWhatsAppWithMessage(
                                  widget.candidate.phone ?? '',
                                  'Hi,\nI have a job vacancy in your city.\n\nJob Details:\nJob: Sales executive\nSalary: up to Rs.35,000\nCall Me: 9818074659',
                                ),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildExactScreenshotButton(
                                icon: Icons.phone_outlined,
                                label: 'Phone',
                                color: const Color(0xFF2196F3),
                                onTap: () =>
                                    _launchPhone(widget.candidate.phone ?? ''),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildExactScreenshotButton(
                                icon: Icons.schedule_outlined,
                                label: 'Schedule',
                                color: const Color(0xFF9C27B0),
                                onTap: () => _scheduleCall(),
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildExactScreenshotButton(
                                icon: Icons.sms_outlined,
                                label: 'SMS',
                                color: const Color(0xFFFF9800),
                                onTap: () => _launchSMSWithMessage(
                                  widget.candidate.phone ?? '',
                                  'Hi,\nI have a job vacancy in your city.\n\nJob: Sales executive\nSalary: up to Rs.35,000\nCall Me: 9818074659',
                                ),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildExactScreenshotButton(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                color: const Color(0xFFF44336),
                                onTap: () => _launchEmailWithMessage(
                                  widget.candidate.email ?? '',
                                  'Dear Candidate,\n\nI hope this email finds you well.\n\nI have a job vacancy in your city.\n\nJob Details:\nPosition: Sales executive\nSalary: up to Rs.35,000\nContact: 9818074659\n\nBest regards',
                                ),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildRemarksDropdown(
                                widget.candidate,
                                isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Call Status
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  selectedCallStatus,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getStatusColor(
                                    selectedCallStatus,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                selectedCallStatus,
                                style: TextStyle(
                                  color: _getStatusColor(selectedCallStatus),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Uploaded date\n${widget.candidate.uploadDate}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WhatsApp Dialog for Detail Page
  void _showWhatsAppDialog(CandidateModelConverter candidate) {
    final TextEditingController messageController = TextEditingController();
    messageController.text = '''Hi,
I have a job vacancy in your city.

Job Details:
Job: Sales executive
Salary: up to Rs.35,000
Call Me: 9818074659''';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF23262B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send Whatsapp',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2D32) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: messageController,
                    maxLines: 6,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      hintText: 'Enter your message...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchWhatsAppWithMessage(
                          candidate.phone ?? '',
                          messageController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // SMS Dialog for Detail Page
  void _showSMSDialog(CandidateModelConverter candidate) {
    final TextEditingController messageController = TextEditingController();
    messageController.text = '''Hi,
I have a job vacancy in your city.

Job: Sales executive
Salary: up to Rs.35,000
Call Me: 9818074659''';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF23262B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send Sms',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2D32) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: messageController,
                    maxLines: 5,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      hintText: 'Enter your message...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchSMSWithMessage(
                          candidate.phone ?? '',
                          messageController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Email Dialog for Detail Page
  void _showEmailDialog(CandidateModelConverter candidate) {
    final TextEditingController messageController = TextEditingController();
    messageController.text = '''Dear Candidate,

I hope this email finds you well.

I have a job vacancy in your city.

Job Details:
Position: Sales executive
Salary: up to Rs.35,000
Contact: 9818074659

Best regards''';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF23262B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send Email',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2D32) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: messageController,
                    maxLines: 8,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      hintText: 'Enter your message...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchEmailWithMessage(
                          candidate.email ?? '',
                          messageController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(String title, String count, bool isSelected, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? primaryBlue.withOpacity(0.2) : Colors.blue[100])
            : (isDark ? Colors.grey[800] : Colors.grey[200]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? (isDark ? primaryBlue : Colors.blue[700])
                  : (isDark ? Colors.grey[300] : Colors.grey[600]),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              color: isSelected
                  ? (isDark ? primaryBlue : Colors.blue[700])
                  : (isDark ? Colors.grey[300] : Colors.grey[600]),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildExactScreenshotButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CORRECTED: Dropdown with proper positioning and reduced gaps for detail page
  Widget _buildRemarksDropdown(CandidateModelConverter candidate, bool isDark) {
    final List<String> statusOptions = [
      'Interested',
      'RNR',
      'Busy',
      'Contact again',
      'Pending',
      'Switched off',
    ];

    return PopupMenuButton<String>(
      offset: const Offset(0, 40), // Position dropdown below the button
      onSelected: (String? newValue) {
        if (newValue != null) {
          setState(() {
            candidate.status = newValue;
            selectedCallStatus = newValue;
          });
        }
      },
      itemBuilder: (BuildContext context) => [
        // Header item (non-selectable)
        PopupMenuItem<String>(
          enabled: false,
          height: 32, // Reduced height
          child: Text(
            'Call Status',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Divider with reduced space
        const PopupMenuDivider(height: 8),
        // Status options with reduced height
        ...statusOptions.map((String status) {
          Color statusColor = _getStatusColor(status);
          return PopupMenuItem<String>(
            value: status,
            height: 32, // Reduced height
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Remarks',
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  // Updated color method with exact hex colors and better visibility for "Busy"
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Interested':
        return const Color(0xFF1FB529); // #1FB529
      case 'RNR':
        return const Color(0xFFD82D1A); // #D82D1A
      case 'Busy':
        return const Color(
          0xFFE67E22,
        ); // Using darker orange for better visibility
      case 'Contact again':
        return const Color(0xFF407BFF); // #407BFF
      case 'Pending':
        return Colors.purple;
      case 'Switched off':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _launchWhatsAppWithMessage(String phone, String message) async {
    final Uri whatsappUri = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchSMSWithMessage(String phone, String message) async {
    final Uri smsUri = Uri.parse(
      "sms:$phone?body=${Uri.encodeComponent(message)}",
    );
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }

  Future<void> _launchEmailWithMessage(String email, String message) async {
    final Uri emailUri = Uri.parse(
      "mailto:$email?subject=Job Opportunity&body=${Uri.encodeComponent(message)}",
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _scheduleCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Call'),
        content: const Text('Call scheduling feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
