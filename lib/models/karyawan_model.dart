class KaryawanModel {
  final String empId;
  final String empName;
  final String userIdHris;
  final String company;
  final String positionTitle;
  final String dept;
  final String supervisorName;
  final String email;
  final String remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  KaryawanModel({
    required this.empId,
    required this.empName,
    required this.userIdHris,
    required this.company,
    required this.positionTitle,
    required this.dept,
    required this.supervisorName,
    required this.email,
    required this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KaryawanModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json;
    if (rawData is! Map) {
      throw const FormatException('Format data karyawan tidak valid');
    }

    final data = Map<String, dynamic>.from(rawData);

    String value(String key) => data[key]?.toString().trim() ?? '';

    DateTime dateValue(String key) {
      return DateTime.tryParse(value(key)) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    return KaryawanModel(
      empId: value('emp_id'),
      empName: value('emp_name'),
      userIdHris: value('user_id_hris'),
      company: value('company'),
      positionTitle: value('position_title'),
      dept: value('dept'),
      supervisorName: value('supervisor_name'),
      email: value('email'),
      remarks: value('remarks'),
      createdAt: dateValue('created_at'),
      updatedAt: dateValue('updated_at'),
    );
  }
}
