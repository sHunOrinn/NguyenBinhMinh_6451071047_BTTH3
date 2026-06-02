class ProfileModel {
  final int id;
  final String fullName;
  final String studentId;
  final String email;
  final String aboutMe;
  final String workExperience;
  final String education;
  final String skill;
  final String language;
  final String appreciation;
  final String resume;

  ProfileModel({
    required this.id,
    required this.fullName,
    required this.studentId,
    required this.email,
    required this.aboutMe,
    required this.workExperience,
    required this.education,
    required this.skill,
    required this.language,
    required this.appreciation,
    required this.resume,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] ?? 1,
      fullName: map['fullName'] ?? '',
      studentId: map['studentId'] ?? '',
      email: map['email'] ?? '',
      aboutMe: map['aboutMe'] ?? '',
      workExperience: map['workExperience'] ?? '',
      education: map['education'] ?? '',
      skill: map['skill'] ?? '',
      language: map['language'] ?? '',
      appreciation: map['appreciation'] ?? '',
      resume: map['resume'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'studentId': studentId,
      'email': email,
      'aboutMe': aboutMe,
      'workExperience': workExperience,
      'education': education,
      'skill': skill,
      'language': language,
      'appreciation': appreciation,
      'resume': resume,
    };
  }
}