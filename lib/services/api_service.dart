import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<Map<String, dynamic>> login(String email, String password, String fcm_token) async {
    print('$baseUrl/login');
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'fcm_token': fcm_token
      }),
    );

    return json.decode(response.body);

  }

  Future<Map<String, dynamic>> register(String name,String email, String password, String repassword, String user_type, String fcm_token) async {
    print('$baseUrl/register');
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': repassword ,
        'user_type' : user_type,
        'fcm_token' : fcm_token
      }),
    );

    return json.decode(response.body);

  }

  Future<Map<String, dynamic>> deleteUser() async {
    print('$baseUrl/user-delete');
    final response = await http.post(
      Uri.parse('$baseUrl/user-delete'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        '_method': 'delete'
      }),
    );

    return json.decode(response.body);

  }

  Future<Map<String, dynamic>> changePass(String password, String repassword) async {
    print('$baseUrl/change-password');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/change-password'),
      headers: {
        'Content-Type': 'application/json' ,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'password': password,
        'password_confirmation': repassword
      }),
    );

    return json.decode(response.body);

  }

  Future<Map<String, dynamic>> updateProfile(String name) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/update-profile'),
      headers: {
        'Content-Type': 'application/json' ,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
      }),
    );

    return json.decode(response.body);

  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {

    final response = await http.post(
      Uri.parse('$baseUrl/password/code'),
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'email' : email
      }),
    );

    return json.decode(response.body);

  }

  Future<Map<String, dynamic>> sendCode(String code, String email) async {
    print('$baseUrl/password/verify-code');

    final response = await http.post(
      Uri.parse('$baseUrl/password/verify-code'),
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'email': email,
        'code' : code
      }),
    );

    return json.decode(response.body);

  }

  Future<Map<String, dynamic>> resetPass(String password, String repassword, String email, String code) async {
    print('$baseUrl/password/reset');

    final response = await http.post(
      Uri.parse('$baseUrl/password/reset'),
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'password': password,
        'password_confirmation': repassword,
        'email': email,
        'code' : code
      }),
    );

    return json.decode(response.body);

  }

  // Future<Map<String, dynamic>> createServiceRequest(String building_name, String unit_no, ) async {
  //   print('$baseUrl/login');
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/login'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'email': email, 'password': password}),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     throw Exception('Failed to login');
  //   }
  // }

  Future<List<ServiceRequest>> fetchServiceRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/service-requests'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((request) => ServiceRequest.fromJson(request)).toList();
    } else {
      throw Exception('Failed to load service requests');
    }
  }

  Future<ServiceRequest> fetchServiceRequestById(int id) async {
    print('$baseUrl/service-requests/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
        Uri.parse('$baseUrl/service-requests/$id'),
        headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return ServiceRequest.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load service request');
    }
  }



}

class ServiceRequest {
  final int id;
  final String status;
  final String building_name;
  final String unit_no;
  final String contact_no;
  final String availability_date;
  final String time_slot;
  final String time_slot1;
  final String time_slot2;
  final String description;
  final String date;
  final String? techician_notes;
  final String? emergency;
  final String? request_remarks;
  final List<String>? media;

  ServiceRequest({
    required this.id, required this.status,
    required this.building_name, required this.description,
    required this.date, required this.unit_no, required this.contact_no,
    required this.availability_date, required this.time_slot, required this.time_slot1,
    required this.time_slot2, this.media, this.techician_notes, this.request_remarks,
    this.emergency
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'],
      status: json['status'] ?? 'No Status',
      building_name: json['building_name'] ?? 'No Building Name',
      description: json['description'] ?? 'no issue',
      date: json['created_at'] ?? 'no date',
      unit_no: json['unit_no'] ?? 'no unit no',
      contact_no: json['contact_no'] ?? 'no contact no',
      availability_date: json['availability_date'] ?? 'no availability date',
      time_slot: json['time_slot'] ?? 'no time slot',
      time_slot1: json['time_slot1'] ?? 'no time slot 1',
      time_slot2: json['time_slot2'] ?? 'no time slot 2',
      techician_notes: json['technician_comment'] ?? 'no notes',
      request_remarks: json['request_remarks'] ?? 'no remarks',
      emergency: json['emergency'] ?? 'N/A',
      media: json['media1'] != null ? List<String>.from(json['media1']) : [],
    );
  }
}
