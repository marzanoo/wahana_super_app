import 'package:flutter_test/flutter_test.dart';
import 'package:super_app_wahana/models/karyawan_model.dart';

void main() {
  test('KaryawanModel accepts nullable optional API fields', () {
    final karyawan = KaryawanModel.fromJson({
      'data': {
        'emp_id': '2026081801',
        'emp_name': 'TANZANO MIKAIL ARNANTO',
        'user_id_hris': 'TANZANO_MIK',
        'company': 'WMS',
        'position_title': 'PDCA ANALYST',
        'dept': 'PDC',
        'supervisor_name': 'DANU ADI WIRAWAN',
        'email': 'tanzanoomikail@gmail.com',
        'remarks': null,
        'created_at': '2026-10-06T23:50:46.000000Z',
        'updated_at': '2026-10-23T07:42:59.000000Z',
      },
    });

    expect(karyawan.empName, 'TANZANO MIKAIL ARNANTO');
    expect(karyawan.userIdHris, 'TANZANO_MIK');
    expect(karyawan.dept, 'PDC');
    expect(karyawan.remarks, isEmpty);
  });
}
