import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../data/models/profile_model.dart';
import '../../../data/repository/profile_repository.dart';
import '../widget/about_me_widget.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileRepository _profileRepository = ProfileRepository();

  ProfileModel? profileInfo;
  bool isLoading = true;

  bool isEditMode = false;
  String? expandedItem;

  final TextEditingController _aboutMeController = TextEditingController();
  final TextEditingController _workExperienceController =
  TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _appreciationController =
  TextEditingController();
  final TextEditingController _resumeController = TextEditingController();

  static const Color primaryColor = Color(0xFF1B0066);
  static const Color orangeColor = Color(0xFFFF8A35);
  static const Color backgroundColor = Color(0xFFEDEDED);
  static const Color textColor = Color(0xFF150B4D);
  static const Color subTextColor = Color(0xFF6E6885);

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final ProfileModel profile = await _profileRepository.getProfile();

    if (!mounted) return;

    setState(() {
      profileInfo = profile;
      isLoading = false;
    });
  }

  List<String> parseItems(String value) {
    if (value.trim().isEmpty) return [];

    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String itemsToString(List<String> items) {
    return items.map((item) => item.trim()).where((item) => item.isNotEmpty).join(', ');
  }

  void toggleDropdown(String key) {
    setState(() {
      expandedItem = expandedItem == key ? null : key;
    });
  }

  Future<void> showEditDialog({
    required String title,
    required String columnName,
    required TextEditingController controller,
    required String currentValue,
  }) async {
    controller.text = currentValue;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: AboutMeWidget(
            controller: controller,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _profileRepository.deleteProfileSection(
                  columnName: columnName,
                );

                if (!mounted) return;

                Navigator.pop(context);
                await loadProfile();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa dữ liệu trong SQLite'),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                await _profileRepository.updateProfileSection(
                  columnName: columnName,
                  value: controller.text.trim(),
                );

                if (!mounted) return;

                Navigator.pop(context);
                await loadProfile();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã cập nhật vào SQLite'),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showMultiValueDialog({
    required String title,
    required String columnName,
    required String currentValue,
  }) async {
    final TextEditingController inputController = TextEditingController();
    List<String> items = parseItems(currentValue);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add $title',
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: inputController,
                      decoration: InputDecoration(
                        hintText: 'Nhập $title',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final String text = inputController.text.trim();

                            if (text.isEmpty) return;

                            setDialogState(() {
                              items.add(text);
                              inputController.clear();
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: items.map((item) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F3F8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item,
                                style: const TextStyle(
                                  color: Color(0xFF524B6B),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    items.remove(item);
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () async {
                                await _profileRepository.updateProfileSection(
                                  columnName: columnName,
                                  value: itemsToString(items),
                                );

                                if (!mounted) return;

                                Navigator.pop(context);
                                await loadProfile();

                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã lưu vào SQLite'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'SAVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: primaryColor,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'CLOSE',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    inputController.dispose();
  }

  void handleInfoTap({
    required String key,
    required String title,
    required String columnName,
    required TextEditingController controller,
    required String currentValue,
    bool isMultiValue = false,
  }) {
    if (isEditMode) {
      if (isMultiValue) {
        showMultiValueDialog(
          title: title,
          columnName: columnName,
          currentValue: currentValue,
        );
      } else {
        showEditDialog(
          title: title,
          columnName: columnName,
          controller: controller,
          currentValue: currentValue,
        );
      }
    } else {
      toggleDropdown(key);
    }
  }

  @override
  void dispose() {
    _aboutMeController.dispose();
    _workExperienceController.dispose();
    _educationController.dispose();
    _skillController.dispose();
    _languageController.dispose();
    _appreciationController.dispose();
    _resumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileModel? profile = profileInfo;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: textColor,
          ),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 14),
            Text(
              profile?.fullName ?? '',
              style: const TextStyle(
                color: Color(0xFF1F1A3D),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(profile?.studentId ?? ''),
            const SizedBox(height: 4),
            Text(profile?.email ?? ''),
            const SizedBox(height: 28),

            InfoItem(
              title: 'About me',
              url: 'assets/icons/aboutme.svg',
              value: profile?.aboutMe ?? '',
              isEditMode: isEditMode,
              isExpanded: expandedItem == 'aboutMe',
              onTap: () {
                handleInfoTap(
                  key: 'aboutMe',
                  title: 'About me',
                  columnName: 'aboutMe',
                  controller: _aboutMeController,
                  currentValue: profile?.aboutMe ?? '',
                );
              },
            ),

            InfoItem(
              title: 'Work experience',
              url: 'assets/icons/work.svg',
              value: profile?.workExperience ?? '',
              isEditMode: isEditMode,
              isExpanded: expandedItem == 'workExperience',
              onTap: () {
                handleInfoTap(
                  key: 'workExperience',
                  title: 'Work experience',
                  columnName: 'workExperience',
                  controller: _workExperienceController,
                  currentValue: profile?.workExperience ?? '',
                );
              },
            ),

            InfoItem(
              title: 'Education',
              url: 'assets/icons/education.svg',
              value: profile?.education ?? '',
              isEditMode: isEditMode,
              isExpanded: expandedItem == 'education',
              onTap: () {
                handleInfoTap(
                  key: 'education',
                  title: 'Education',
                  columnName: 'education',
                  controller: _educationController,
                  currentValue: profile?.education ?? '',
                );
              },
            ),

            InfoItem(
              title: 'Skill',
              url: 'assets/icons/skill.svg',
              value: profile?.skill ?? '',
              isEditMode: isEditMode,
              isExpanded: expandedItem == 'skill',
              isMultiValue: true,
              onTap: () {
                handleInfoTap(
                  key: 'skill',
                  title: 'Skill',
                  columnName: 'skill',
                  controller: _skillController,
                  currentValue: profile?.skill ?? '',
                  isMultiValue: true,
                );
              },
            ),

            InfoItem(
              title: 'Language',
              url: 'assets/icons/language.svg',
              value: profile?.language ?? '',
              isEditMode: isEditMode,
              isExpanded: expandedItem == 'language',
              isMultiValue: true,
              onTap: () {
                handleInfoTap(
                  key: 'language',
                  title: 'Language',
                  columnName: 'language',
                  controller: _languageController,
                  currentValue: profile?.language ?? '',
                  isMultiValue: true,
                );
              },
            ),

            InfoItem(
              title: 'Appreciation',
              url: 'assets/icons/appreciation.svg',
              value: profile?.appreciation ?? '',
              isEditMode: isEditMode,
              isExpanded: expandedItem == 'appreciation',
              onTap: () {
                handleInfoTap(
                  key: 'appreciation',
                  title: 'Appreciation',
                  columnName: 'appreciation',
                  controller: _appreciationController,
                  currentValue: profile?.appreciation ?? '',
                );
              },
            ),

            ResumeItem(
              title: 'Resume',
              value: profile?.resume ?? '',
              isEditMode: isEditMode,
              isExpanded: expandedItem == 'resume',
              onTap: () {
                handleInfoTap(
                  key: 'resume',
                  title: 'Resume',
                  columnName: 'resume',
                  controller: _resumeController,
                  currentValue: profile?.resume ?? '',
                );
              },
              onDelete: () async {
                await _profileRepository.deleteProfileSection(
                  columnName: 'resume',
                );

                if (!mounted) return;

                await loadProfile();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa resume trong SQLite'),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isEditMode = !isEditMode;
                    expandedItem = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  isEditMode ? 'DONE' : 'UPDATE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final String title;
  final String url;
  final String value;
  final bool isEditMode;
  final bool isExpanded;
  final bool isMultiValue;
  final VoidCallback? onTap;

  const InfoItem({
    super.key,
    required this.title,
    required this.url,
    required this.value,
    required this.isEditMode,
    required this.isExpanded,
    this.isMultiValue = false,
    this.onTap,
  });

  static const Color orangeColor = Color(0xFFFF8A35);
  static const Color textColor = Color(0xFF150B4D);
  static const Color subTextColor = Color(0xFF6E6885);

  @override
  Widget build(BuildContext context) {
    final String displayValue =
    value.trim().isEmpty ? 'Chưa có thông tin.' : value.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            leading: SvgPicture.asset(
              url,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                orangeColor,
                BlendMode.srcIn,
              ),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            trailing: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEEE6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEditMode
                    ? Icons.edit_outlined
                    : isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.add,
                color: orangeColor,
                size: 18,
              ),
            ),
          ),
          if (isExpanded && !isEditMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  if (isMultiValue)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: value
                          .split(',')
                          .map((item) => item.trim())
                          .where((item) => item.isNotEmpty)
                          .map((item) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F3F8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item,
                            style: const TextStyle(
                              color: Color(0xFF524B6B),
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    Text(
                      displayValue,
                      style: const TextStyle(
                        color: subTextColor,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ResumeItem extends StatelessWidget {
  final String title;
  final String value;
  final bool isEditMode;
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ResumeItem({
    super.key,
    required this.title,
    required this.value,
    required this.isEditMode,
    required this.isExpanded,
    this.onTap,
    this.onDelete,
  });

  static const Color orangeColor = Color(0xFFFF8A35);
  static const Color textColor = Color(0xFF150B4D);
  static const Color subTextColor = Color(0xFF6E6885);

  @override
  Widget build(BuildContext context) {
    final String fileName = value.trim().isEmpty ? 'Chưa có resume.' : value.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            leading: const Icon(
              Icons.description_outlined,
              color: orangeColor,
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            trailing: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEEE6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEditMode
                    ? Icons.edit_outlined
                    : isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.add,
                color: orangeColor,
                size: 18,
              ),
            ),
          ),
          if (isExpanded && !isEditMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'PDF',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}