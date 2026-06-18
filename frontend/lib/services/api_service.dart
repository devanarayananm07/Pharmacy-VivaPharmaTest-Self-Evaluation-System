import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiService {
  /// The Frappe server host IP and port. 
  /// - Use '10.0.2.2:8000' if you are running the Frappe server on your localhost and using an Android Emulator.
  /// - Use your computer's LAN IP (e.g. '192.168.52.186:8000') if using a physical device or different setup.
  /// The Frappe server host IP or Domain (without http:// or https://).
  static const String serverHost = '192.168.52.186:8000';

  /// Set to true if your public URL uses HTTPS (e.g. ngrok or cloud hosting).
  static const bool useHttps = false;

  static String get baseUrl => '${useHttps ? 'https' : 'http'}://$serverHost/api/method';
  static String get resourceUrl => '${useHttps ? 'https' : 'http'}://$serverHost/api/resource';

  static const String apiKey = 'amrita_aepl_viva_metaflow_secure_2026_xf92';
  static const Duration timeoutDuration = Duration(seconds: 2);

  // Offline caching status tracking to improve network performance
  static bool _serverOffline = false;
  static DateTime? _lastOfflineCheck;
  static const Duration _retryOfflineAfter = Duration(seconds: 30);

  static void markServerOffline() {
    if (!_serverOffline) {
      _serverOffline = true;
      _lastOfflineCheck = DateTime.now();
      print("ApiService: Server marked as OFFLINE. Subsequent calls will bypass network.");
    }
  }

  static bool checkIsServerOffline() {
    if (_serverOffline && _lastOfflineCheck != null) {
      final elapsed = DateTime.now().difference(_lastOfflineCheck!);
      if (elapsed < _retryOfflineAfter) {
        return true; // Use offline fallback
      } else {
        // Retry time elapsed; reset offline status to attempt connection
        _serverOffline = false;
        print("ApiService: Retry interval elapsed. Attempting server reconnection.");
      }
    }
    return false;
  }

  static final List<Map<String, dynamic>> _mockEmployees = [
    {
      "emp_id": "employee",
      "name1": "Test Employee",
      "designation": "Staff Pharmacist",
      "email": "employee@amrita.edu",
      "department": "Inpatient Pharmacy"
    },
    {
      "emp_id": "mentor",
      "name1": "Test Mentor",
      "designation": "Clinical Mentor",
      "email": "mentor@amrita.edu",
      "department": "Outpatient Pharmacy"
    },
    {
      "emp_id": "admin",
      "name1": "System Administrator",
      "designation": "IT Administrator",
      "email": "admin@amrita.edu",
      "department": "IT Support"
    }
  ];

  static final List<Map<String, dynamic>> _mockQuestions = [
    {
      "id": "q1",
      "generic_name": "AMOXICILLIN",
      "drug_name": "Amoxil",
      "company": "GlaxoSmithKline",
      "speciality": "Infectious Diseases",
      "ved": "E",
      "abc": "A",
      "sku": "Y",
      "indication": "Treatment of bacterial infections such as pneumonia, tonsillitis, and middle ear infections.",
      "gsp": "AMOXICILLIN(500 mg)Capsule",
      "schedule": "Rx",
      "store": "Main Pharmacy A",
      "days": "Day 001",
      "store_code": "101"
    },
    {
      "id": "q2",
      "generic_name": "METFORMIN",
      "drug_name": "Glucophage",
      "company": "Merck",
      "speciality": "Endocrinology",
      "ved": "V",
      "abc": "A",
      "sku": "Y",
      "indication": "Management of Type 2 diabetes mellitus, particularly in overweight patients.",
      "gsp": "METFORMIN(850 mg)Tablet",
      "schedule": "Rx",
      "store": "Main Pharmacy A",
      "days": "Day 002",
      "store_code": "101"
    },
    {
      "id": "q3",
      "generic_name": "ATORVASTATIN",
      "drug_name": "Lipitor",
      "company": "Pfizer",
      "speciality": "Cardiology",
      "ved": "E",
      "abc": "B",
      "sku": "Y",
      "indication": "Prevention of cardiovascular disease and reduction of LDL cholesterol levels.",
      "gsp": "ATORVASTATIN(20 mg)Tablet",
      "schedule": "Rx",
      "store": "Outpatient Pharmacy",
      "days": "Day 003",
      "store_code": "102"
    },
    {
      "id": "q4",
      "generic_name": "IBUPROFEN",
      "drug_name": "Advil",
      "company": "Pfizer Consumer Healthcare",
      "speciality": "Therapeutics",
      "ved": "E",
      "abc": "C",
      "sku": "Y",
      "indication": "Relief of mild to moderate pain, inflammation, and fever.",
      "gsp": "IBUPROFEN(200 mg)Tablet",
      "schedule": "OTC",
      "store": "Outpatient Pharmacy",
      "days": "Day 004",
      "store_code": "102"
    },
    {
      "id": "q5",
      "generic_name": "PARACETAMOL",
      "drug_name": "Panadol",
      "company": "Haleon",
      "speciality": "Therapeutics",
      "ved": "E",
      "abc": "C",
      "sku": "Y",
      "indication": "Management of mild pain and reduction of fever.",
      "gsp": "PARACETAMOL(500 mg)Tablet",
      "schedule": "OTC",
      "store": "Main Pharmacy A",
      "days": "Day 001",
      "store_code": "101"
    },
    {
      "id": "q6",
      "generic_name": "LOSARTAN",
      "drug_name": "Cozaar",
      "company": "Organon",
      "speciality": "Cardiology",
      "ved": "E",
      "abc": "A",
      "sku": "Y",
      "indication": "Treatment of hypertension and protection of kidneys in diabetic patients.",
      "gsp": "LOSARTAN(50 mg)Tablet",
      "schedule": "Rx",
      "store": "Outpatient Pharmacy",
      "days": "Day 005",
      "store_code": "102"
    },
    {
      "id": "q7",
      "generic_name": "TRASTUZUMAB",
      "drug_name": "Herceptin",
      "company": "Roche",
      "speciality": "Oncology",
      "ved": "V",
      "abc": "A",
      "sku": "Y",
      "indication": "Treatment of HER2-positive breast cancer and gastric cancer.",
      "gsp": "TRASTUZUMAB(440 mg)Injection",
      "schedule": "Rx",
      "store": "Pharmacy Store/Oncology",
      "days": "Day 012",
      "store_code": "131"
    },
    {
      "id": "q8",
      "generic_name": "DOXORUBICIN",
      "drug_name": "Adriamycin",
      "company": "Pfizer",
      "speciality": "Oncology",
      "ved": "V",
      "abc": "B",
      "sku": "Y",
      "indication": "Chemotherapy for leukemia, lymphoma, breast, and ovarian cancers.",
      "gsp": "DOXORUBICIN(50 mg)Injection",
      "schedule": "Rx",
      "store": "Pharmacy Store/Oncology",
      "days": "Day 015",
      "store_code": "131"
    },
    {
      "id": "q9",
      "generic_name": "ASPIRIN",
      "drug_name": "Ecotrin",
      "company": "Bayer",
      "speciality": "Cardiology",
      "ved": "E",
      "abc": "B",
      "sku": "Y",
      "indication": "Low-dose platelet aggregation inhibitor for cardiovascular prophylaxis.",
      "gsp": "ASPIRIN(75 mg)Tablet",
      "schedule": "OTC",
      "store": "Main Pharmacy A",
      "days": "Day 001",
      "store_code": "101"
    },
    {
      "id": "q10",
      "generic_name": "OMEPRAZOLE",
      "drug_name": "Prilosec",
      "company": "AstraZeneca",
      "speciality": "Gastroenterology",
      "ved": "E",
      "abc": "B",
      "sku": "Y",
      "indication": "Treatment of gastroesophageal reflux disease (GERD) and peptic ulcer disease.",
      "gsp": "OMEPRAZOLE(20 mg)Capsule",
      "schedule": "Rx",
      "store": "Outpatient Pharmacy",
      "days": "Day 002",
      "store_code": "102"
    }
  ];

  static final List<Map<String, dynamic>> _mockAttempts = [
    {
      "id": "att1",
      "employee_id": "employee",
      "exam_day": "Day 001",
      "store": "Main Pharmacy A",
      "date": "2026-06-12 10:15:30",
      "percent": 85.0,
      "passed": 1,
      "status": "Completed"
    },
    {
      "id": "att2",
      "employee_id": "employee",
      "exam_day": "Day 002",
      "store": "Main Pharmacy A",
      "date": "2026-06-11 11:20:00",
      "percent": 75.0,
      "passed": 1,
      "status": "Completed"
    },
    {
      "id": "att3",
      "employee_id": "employee",
      "exam_day": "Day 003",
      "store": "Outpatient Pharmacy",
      "date": "2026-06-10 14:05:15",
      "percent": 60.0,
      "passed": 0,
      "status": "Completed"
    },
    {
      "id": "att4",
      "employee_id": "employee",
      "exam_day": "Day 004",
      "store": "Outpatient Pharmacy",
      "date": "2026-06-09 09:30:00",
      "percent": 90.0,
      "passed": 1,
      "status": "Completed"
    },
    {
      "id": "att5",
      "employee_id": "employee",
      "exam_day": "Day 005",
      "store": "Outpatient Pharmacy",
      "date": "2026-06-08 16:40:00",
      "percent": 95.0,
      "passed": 1,
      "status": "Completed"
    },
    {
      "id": "att6",
      "employee_id": "employee",
      "exam_day": "Day 012",
      "store": "Pharmacy Store/Oncology",
      "date": "2026-06-07 13:10:00",
      "percent": 100.0,
      "passed": 1,
      "status": "Completed"
    }
  ];

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'X-API-KEY': apiKey,
      if (token != null && !token.startsWith('session_active_')) 'Authorization': 'Bearer $token',
    };
  }

  // ================= GENERIC GET AND POST FOR CUSTOM SCRIPTS / DOCTYPES =================

  /// Generic GET method to fetch data.
  /// Set [isResource] to true if calling a DocType Resource endpoint (`/api/resource/` instead of `/api/method/`).
  Future<dynamic> get(String path, {Map<String, String>? queryParameters, bool isResource = false}) async {
    try {
      final rootUrl = isResource ? resourceUrl : baseUrl;
      final uri = Uri.parse('$rootUrl/$path').replace(queryParameters: queryParameters);
      return await _makeRequest(() async => http.get(uri, headers: await _getHeaders()));
    } catch (e) {
      print("ApiService GET Exception on path '$path': $e");
      rethrow;
    }
  }

  /// Generic POST method to send data.
  /// Set [isResource] to true if calling a DocType Resource endpoint (`/api/resource/` instead of `/api/method/`).
  Future<dynamic> post(String path, dynamic body, {Map<String, String>? queryParameters, bool isResource = false}) async {
    try {
      final rootUrl = isResource ? resourceUrl : baseUrl;
      final uri = Uri.parse('$rootUrl/$path').replace(queryParameters: queryParameters);
      return await _makeRequest(
        () async => http.post(
          uri,
          headers: await _getHeaders(),
          body: body != null ? jsonEncode(body) : null,
        ),
      );
    } catch (e) {
      print("ApiService POST Exception on path '$path': $e");
      rethrow;
    }
  }

  // Generic request handler
  Future<dynamic> _makeRequest(Future<http.Response> Function() requestFn) async {
    if (checkIsServerOffline()) {
      throw Exception("Server is offline (cached state)");
    }

    try {
      final response = await requestFn().timeout(timeoutDuration);
      if (response.statusCode == 200) {
        _serverOffline = false; // Successfully reached the server, clear offline flag
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
        return data;
      } else {
        final errorMsg = _parseError(response);
        throw Exception(errorMsg);
      }
    } catch (e) {
      print("ApiService Error: $e");
      markServerOffline(); // Mark offline to prevent subsequent hangs
      rethrow;
    }
  }

  String _parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data['message'] ?? data['exception'] ?? 'Request failed with code ${response.statusCode}';
    } catch (_) {
      return 'Request failed with code ${response.statusCode}';
    }
  }

  // ================= AUTHENTICATION ENDPOINTS (emp_auth_api) =================

  Future<Map<String, dynamic>> login(String employeeId, String password) async {
    final cleanId = employeeId.trim();
    final cleanPass = password.trim();

    // 1. Separate Admin Login
    if (cleanId.toLowerCase() == 'admin' && cleanPass == 'admin@amrita') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'session_active_admin');
      await prefs.setString('employee_id', 'admin');
      await prefs.setString('employee_name', 'System Administrator');
      await prefs.setString('employee_role', 'Admin');
      await prefs.setBool('force_password_change', false);

      return {
        "status": "Success",
        "employee_id": "admin",
        "name": "System Administrator",
        "role": "Admin",
        "force_password_change": false
      };
    }

    // Temporary Employee Login
    if (cleanId.toLowerCase() == 'employee' && cleanPass == 'employee@123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'session_active_employee');
      await prefs.setString('employee_id', 'employee');
      await prefs.setString('employee_name', 'Test Employee');
      await prefs.setString('employee_role', 'Employee');
      await prefs.setBool('force_password_change', false);

      return {
        "status": "Success",
        "employee_id": "employee",
        "name": "Test Employee",
        "role": "Employee",
        "force_password_change": false
      };
    }

    // Temporary Mentor Login
    if (cleanId.toLowerCase() == 'mentor' && cleanPass == 'mentor@123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'session_active_mentor');
      await prefs.setString('employee_id', 'mentor');
      await prefs.setString('employee_name', 'Test Mentor');
      await prefs.setString('employee_role', 'Mentor');
      await prefs.setBool('force_password_change', false);

      return {
        "status": "Success",
        "employee_id": "mentor",
        "name": "Test Mentor",
        "role": "Mentor",
        "force_password_change": false
      };
    }

    // 2. Regular Employee Login via emp_auth_api
    try {
      final res = await _makeRequest(
        () async => http.post(
          Uri.parse('$baseUrl/emp_auth_api?action=login'),
          headers: await _getHeaders(),
          body: jsonEncode({
            'employee_id': cleanId,
            'password': cleanPass,
          }),
        ),
      );

      final loginRes = Map<String, dynamic>.from(res);
      
      // If the login API returns basic info, use it. Otherwise, fetch from master.
      String name = loginRes['name'] ?? loginRes['employee_name'] ?? 'Staff';
      String role = loginRes['role'] ?? 'Employee';
      bool mustChange = loginRes['must_change_password'] == true || loginRes['must_change_password'] == "1";

      // If loginRes is sparse, we might need to fetch employee details to get the role
      if (loginRes['role'] == null) {
        try {
          final employees = await getEmployees();
          final matches = employees.where(
            (e) => (e['emp_id'] ?? '').toString().toLowerCase() == cleanId.toLowerCase(),
          );
          if (matches.isNotEmpty) {
            final emp = matches.first;
            name = emp['name1'] ?? name;
            final des = (emp['designation'] ?? '').toString().toLowerCase();
            if (des.contains('analyst') || des.contains('admin')) {
              role = "Admin";
            } else if (des.contains('mentor') || des.contains('supervisor')) {
              role = "Mentor";
            }
          }
        } catch (_) {
          // If employee lookup fails, continue with default role
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'session_active_$cleanId');
      await prefs.setString('employee_id', cleanId);
      await prefs.setString('employee_name', name);
      await prefs.setString('employee_role', role);
      await prefs.setBool('force_password_change', mustChange);

      return {
        "status": "Success",
        "employee_id": cleanId,
        "name": name,
        "role": role,
        "force_password_change": mustChange
      };
    } catch (e) {
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  Future<void> initPassword(String employeeId) async {
    await _makeRequest(
      () async => http.post(
        Uri.parse('$baseUrl/emp_auth_api?action=init'),
        headers: await _getHeaders(),
        body: jsonEncode({'employee_id': employeeId.trim()}),
      ),
    );
  }

  Future<void> changePassword(String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final employeeId = prefs.getString('employee_id');
    if (employeeId == null) throw Exception("Session expired");

    await _makeRequest(
      () async => http.post(
        Uri.parse('$baseUrl/emp_auth_api?action=change_password'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'employee_id': employeeId,
          'new_password': newPassword.trim(),
        }),
      ),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ================= EMPLOYEE MASTER ENDPOINTS =================

  Future<List<dynamic>> getEmployees() async {
    try {
      final res = await _makeRequest(
        () async => http.get(
          Uri.parse('$baseUrl/employee_master_api'),
          headers: await _getHeaders(),
        ),
      );
      return List<dynamic>.from(res);
    } catch (e) {
      print("ApiService getEmployees failed: $e. Using mock employees.");
      return List.from(_mockEmployees);
    }
  }

  Future<Map<String, dynamic>> createEmployee(Map<String, dynamic> employee) async {
    try {
      final res = await _makeRequest(
        () async => http.post(
          Uri.parse('$baseUrl/employee_master_api?action=create'),
          headers: await _getHeaders(),
          body: jsonEncode(employee),
        ),
      );
      return Map<String, dynamic>.from(res);
    } catch (e) {
      print("ApiService createEmployee failed: $e. Mocking creation.");
      final newEmp = Map<String, dynamic>.from(employee);
      _mockEmployees.add(newEmp);
      return newEmp;
    }
  }

  Future<Map<String, dynamic>> updateEmployee(Map<String, dynamic> employee) async {
    try {
      final res = await _makeRequest(
        () async => http.post(
          Uri.parse('$baseUrl/employee_master_api?action=update'),
          headers: await _getHeaders(),
          body: jsonEncode(employee),
        ),
      );
      return Map<String, dynamic>.from(res);
    } catch (e) {
      print("ApiService updateEmployee failed: $e. Mocking update.");
      final empId = employee['emp_id']?.toString();
      final idx = _mockEmployees.indexWhere((x) => x['emp_id'].toString() == empId);
      if (idx != -1) {
        _mockEmployees[idx] = Map<String, dynamic>.from(employee);
      }
      return employee;
    }
  }

  Future<void> deleteEmployee(String empId) async {
    try {
      await _makeRequest(
        () async => http.post(
          Uri.parse('$baseUrl/employee_master_api?action=delete'),
          headers: await _getHeaders(),
          body: jsonEncode({'emp_id': empId}),
        ),
      );
    } catch (e) {
      print("ApiService deleteEmployee failed: $e. Mocking deletion.");
      _mockEmployees.removeWhere((x) => x['emp_id'].toString() == empId);
    }
  }

  // ================= QUESTIONS MASTER ENDPOINTS =================

  Future<List<dynamic>> getQuestions({
    String? store,
    String? speciality,
    String? days,
    String? search
  }) async {
    final queryParams = {
      if (store != null && store.isNotEmpty) 'store': store,
      if (speciality != null && speciality.isNotEmpty) 'speciality': speciality,
      if (days != null && days.isNotEmpty) 'days': days,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    
    try {
      final uri = Uri.parse('$baseUrl/questions_master_api').replace(queryParameters: queryParams);
      final res = await _makeRequest(() async => http.get(uri, headers: await _getHeaders()));
      return List<dynamic>.from(res);
    } catch (e) {
      print("ApiService getQuestions failed: $e. Using mock questions.");
      Iterable<Map<String, dynamic>> filtered = _mockQuestions;
      if (store != null && store.isNotEmpty) {
        filtered = filtered.where((q) => q['store'].toString().toLowerCase() == store.toLowerCase());
      }
      if (speciality != null && speciality.isNotEmpty) {
        filtered = filtered.where((q) => q['speciality'].toString().toLowerCase().contains(speciality.toLowerCase()));
      }
      if (days != null && days.isNotEmpty) {
        filtered = filtered.where((q) => q['days'].toString().toLowerCase() == days.toLowerCase());
      }
      if (search != null && search.isNotEmpty) {
        final query = search.toLowerCase();
        filtered = filtered.where((q) =>
          q['generic_name'].toString().toLowerCase().contains(query) ||
          q['drug_name'].toString().toLowerCase().contains(query)
        );
      }
      return filtered.toList();
    }
  }

  Future<Map<String, dynamic>> createQuestion(Map<String, dynamic> question) async {
    try {
      final res = await _makeRequest(
        () async => http.post(
          Uri.parse('$baseUrl/questions_master_api?action=create'),
          headers: await _getHeaders(),
          body: jsonEncode(question),
        ),
      );
      return Map<String, dynamic>.from(res);
    } catch (e) {
      print("ApiService createQuestion failed: $e. Mocking creation.");
      final newQ = {
        "id": "q_local_${DateTime.now().millisecondsSinceEpoch}",
        ...question
      };
      _mockQuestions.add(newQ);
      return newQ;
    }
  }

  Future<Map<String, dynamic>> updateQuestion(Map<String, dynamic> question) async {
    try {
      final res = await _makeRequest(
        () async => http.post(
          Uri.parse('$baseUrl/questions_master_api?action=update'),
          headers: await _getHeaders(),
          body: jsonEncode(question),
        ),
      );
      return Map<String, dynamic>.from(res);
    } catch (e) {
      print("ApiService updateQuestion failed: $e. Mocking update.");
      final qId = question['id']?.toString();
      final idx = _mockQuestions.indexWhere((x) => x['id'].toString() == qId);
      if (idx != -1) {
        _mockQuestions[idx] = Map<String, dynamic>.from(question);
      }
      return question;
    }
  }

  Future<void> deleteQuestion(String id) async {
    try {
      await _makeRequest(
        () async => http.post(
          Uri.parse('$baseUrl/questions_master_api?action=delete'),
          headers: await _getHeaders(),
          body: jsonEncode({'id': id}),
        ),
      );
    } catch (e) {
      print("ApiService deleteQuestion failed: $e. Mocking deletion.");
      _mockQuestions.removeWhere((x) => x['id'].toString() == id);
    }
  }

  // ================= ATTEMPT MASTER ENDPOINTS =================

  Future<List<dynamic>> getAttempts({String? employeeId}) async {
    final queryParams = {
      if (employeeId != null && employeeId.isNotEmpty) 'employee_id': employeeId,
    };
    try {
      final uri = Uri.parse('$baseUrl/attempt_master_api').replace(queryParameters: queryParams);
      final res = await _makeRequest(() async => http.get(uri, headers: await _getHeaders()));
      return List<dynamic>.from(res);
    } catch (e) {
      print("ApiService getAttempts failed: $e. Using mock attempts.");
      if (employeeId != null && employeeId.isNotEmpty) {
        final filtered = _mockAttempts.where((a) => a['employee_id'].toString().toLowerCase() == employeeId.toLowerCase()).toList();
        if (filtered.isEmpty) {
          // Generate/duplicate mock attempts for this specific user ID for offline UI testing
          return _mockAttempts.map((a) => {
            ...a,
            "employee_id": employeeId,
          }).toList();
        }
        return filtered;
      }
      return List.from(_mockAttempts);
    }
  }

  Future<Map<String, dynamic>> createAttempt(Map<String, dynamic> attempt) async {
    try {
      final res = await _makeRequest(
        () async => http.post(
          Uri.parse('$baseUrl/attempt_master_api?action=create'),
          headers: await _getHeaders(),
          body: jsonEncode(attempt),
        ),
      );
      return Map<String, dynamic>.from(res);
    } catch (e) {
      print("ApiService createAttempt failed: $e. Mocking creation.");
      final newAttempt = {
        "id": "att_local_${DateTime.now().millisecondsSinceEpoch}",
        "employee_id": attempt['employee_id'] ?? 'employee',
        "exam_day": attempt['exam_day'] ?? 'Day 001',
        "store": attempt['store'] ?? 'Main Pharmacy A',
        "date": DateTime.now().toString().substring(0, 19),
        "percent": (attempt['percent'] as num?)?.toDouble() ?? 0.0,
        "passed": (attempt['passed'] as num?)?.toInt() ?? 0,
        "status": attempt['status'] ?? 'Completed'
      };
      _mockAttempts.insert(0, newAttempt);
      return newAttempt;
    }
  }

  // ================= DASHBOARD STATISTICS API =================

  Future<Map<String, dynamic>> getDashboardStats(String employeeId) async {
    try {
      final uri = Uri.parse('$baseUrl/dashboard_stats_api').replace(queryParameters: {'employee_id': employeeId});
      final res = await _makeRequest(() async => http.get(uri, headers: await _getHeaders()));
      return Map<String, dynamic>.from(res);
    } catch (e) {
      print("ApiService getDashboardStats failed: $e. Using mock dashboard stats.");
      final userAttempts = _mockAttempts.where((a) => a['employee_id'].toString().toLowerCase() == employeeId.toLowerCase() && a['status'] == 'Completed').toList();
      final completedCount = userAttempts.length;
      double sumPercent = 0.0;
      int passedCount = 0;
      for (var a in userAttempts) {
        sumPercent += (a['percent'] as num).toDouble();
        if ((a['passed'] as num).toInt() == 1) {
          passedCount++;
        }
      }
      final double avgScore = completedCount > 0 ? (sumPercent / completedCount) : 0.0;
      
      return {
        "exams_attended": completedCount,
        "avg_mark": avgScore,
        "completed_count": completedCount,
        "accuracy_rate": completedCount > 0 ? (passedCount / completedCount * 100) : 0.0
      };
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
