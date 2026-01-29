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
    final data = json['data'] as Map<String, dynamic>;
    return KaryawanModel(
      empId: data['emp_id'],
      empName: data['emp_name'],
      userIdHris: data['user_id_hris'],
      company: data['company'],
      positionTitle: data['position_title'],
      dept: data['dept'],
      supervisorName: data['supervisor_name'],
      email: data['email'],
      remarks: data['remarks'],
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
    );
  }
}