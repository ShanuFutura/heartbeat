import 'dart:convert';
import 'dart:io';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:heartbeat/constants/dummy_lists.dart';
import 'package:heartbeat/providers/image_upload.dart';
// import 'package:flutter/services.dart';
// import 'package:heartbeat/models/dummy_lists.dart';
import 'package:heartbeat/screens/login_screen.dart';
import 'package:heartbeat/screens/patient_home_page.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
// import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

// final url = Uri.parse('http://192.168.29.77/Doctor_patient/api/');

class DBHelper extends ChangeNotifier {
  var urlS = 'http://192.168.29.191/Doctor_Patient/api/';
  var urlsForImage = 'http://192.168.29.191/Doctor_Patient/img/';
  var urlsForLabResultImage =
      'http://192.168.29.191/Doctor_Patient/loginpanel/assets/img/';
  // static bool authTok=false;
  var prescForPatients;
  var loginId;

  List<Map<String, Object>> paymentProfile = [];

  Future<bool> loginCall(
    String username,
    String password,
  ) async {
    print('inside login page');
    final url = Uri.parse(urlS + 'login.php');
    final loginResponse =
        await post(url, body: {'username': username, 'password': password});
    print('login res' + json.decode(loginResponse.body).toString());

    if (json.decode(loginResponse.body)['message'] ==
        'User Successfully LoggedIn') {
      final spref = await SharedPreferences.getInstance();
      if (json.decode(loginResponse.body)['type'] == 'patient') {
        spref.setString(
            'patient_id', json.decode(loginResponse.body)['patient_id']);
        print('++++++++' + json.decode(loginResponse.body)['patient_id']);
        //  print('id' + loginId);
        print('user type:' + json.decode(loginResponse.body)['type']);

        // final pref = await SharedPreferences.getInstance();
        spref.setString('authTok', 'patient');
      } else {
        getTestsAndMedicines();
        getDocDetails();
        print('user type :' + json.decode(loginResponse.body)['type']);
        spref.setString('authTok', 'doc');
        final resp = await post(Uri.parse(urlS + 'login_to_doctor.php'),
            body: {'login_id': json.decode(loginResponse.body)['patient_id']});
        print('convrted doc id ' + resp.body);
        spref.setString(
            'doc_id', (jsonDecode(resp.body) as dynamic)['doctor_id']);
      }
      return true;
    } else {
      return false;
    }
  }

  // var isFetchingBool = false;

  // bool get isFetching {
  // return isFetchingBool;
  // }

  String get login_id {
    return loginId;
  }

  Future<String> signupCall(
    String name,
    String age,
    String gender,
    String email,
    String mobile,
    String username,
    String password,
    BuildContext context,
  ) async {
    final spref = await SharedPreferences.getInstance();
    final url = Uri.parse(urlS + 'register.php');
    try {
      final res = await post(url, body: {
        'name': name,
        'age': age,
        'gender': gender,
        'email': email,
        'mobile': mobile,
        'username': username,
        'password': password,
      });
      print('signup_res:' + res.body);
      // print(
      //   '{$username, $gender, $age, $email, $mobile, $name, $password}',
      // );
      Future<void> setToken() async {
        final pref = await SharedPreferences.getInstance();
        pref.setString('authTok', 'patient');
      }

      // print(res.body);
      if (jsonDecode(res.body)['message'] == 'registration successfull') {
        setToken();
        spref.setString('patient_id', jsonDecode(res.body)['reg_id']);
        print('regid' + spref.getString('patient_id').toString());
        Navigator.of(context).pushNamed(PatientHomePage.routeName);
      }
      return 'ok';
    } catch (error) {
      print('error' + error.toString());
      return error.toString();
    }
  }

  Future<void> logout(BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString('authTok', 'nop');
    Navigator.of(context).pushNamed(LoginScreen.routeName);
  }

  Future<List?> fetchAndSetDoctorsList(BuildContext context) async {
    DummyLists.docsList.clear();
    print('fetching docs');
    // isFetchingBool = true;
    try {
      final url = Uri.parse(urlS + 'doctor_list.php');
      final res = await get(url);
      // isFetchingBool = false;
      // print(res.body);
      final tempList = jsonDecode(res.body) as List;
      print('doctor list length:' + tempList.length.toString());
      DummyLists.docsList = (tempList);
      print(DummyLists.docsList);
      return tempList;
    } on SocketException catch (error) {
      print('connnection error--' + error.message);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('CONNECTION ERROR'),
            );
          }).then((value) => null);
    }

    // notifyListeners();
    // print(json.decode(res.body)[1]['doc_name']);

    // final url2 = Uri.parse(urlS + 'appointment_view');
  }

  Future<bool> patientProfUpdate(
    // String login_id,
    String name,
    String age,
    String gender,
    String email,
    String mobile,
  ) async {
    final spref = await SharedPreferences.getInstance();
    print('id while updating patient profile' +
        spref.getString('patient_id').toString());
    final url = Uri.parse(urlS + 'patient_profile_edit.php');
    final res = await post(url, body: {
      'patient_id': spref.getString('patient_id'),
      'name': name,
      'email': email,
      'phone': mobile,
      'gender': gender,
      'age': age,
    });
    print(res.body);
    //FILL THE POST BODY....!!!!!
    if (jsonDecode(res.body)['message'] == 'Successfully Updated') {
      Fluttertoast.showToast(msg: 'Successfully updated');
      return true;
    } else {
      return false;
    }
    // print('{$name,$age,$gender,$email,$gender,$mobile,}');
    // return true;
  }

  // static feedBack

  Future<void> feedBackCall(String feed) async {
    final spref = await SharedPreferences.getInstance();
    final id = spref.getString('patient_id');
    final url = Uri.parse(urlS + 'send_feedback.php');
    final res = await post(url, body: {'login_id': id, 'feedback': feed});
    print('feedback res:' + res.body);
    // print(feed);
  }

  void addAppoinment(String time_slot, String docId) async {
    final url = Uri.parse(urlS + 'add_appointment.php');
    print('docName:' + docId);
    print('LOgin id' + login_id);
    final res = await post(url, body: {
      'login_id': login_id,
      'doctor_id': docId,
      'time_slot': time_slot
    });
    print('book timeslot res:' + res.body);
    // DummyLists.appoinments.add({'time_slot': time_slot, 'doc_name': docId});
    // print('appointments in prvider:' + DummyLists.appoinments.toString());
  }

  // addImagePresc(File img, DateTime timestamp, String name) {
  //   DummyLists.oldPrescImages.add(
  //     {
  //       'image': img,
  //       'date': timestamp,
  //       'name': name,
  //     },
  //   );
  //   notifyListeners();
  // }

  // bool isImagePoppedWithoutName = true;

  List get imagePresc {
    return DummyLists.oldPrescImages;
    // notifyListeners();
  }

  List get dummyPrescs {
    return DummyLists.dummyPrescs;
  }

  void applyLeave(String date) async {
    final spref = await SharedPreferences.getInstance();
    final url = Uri.parse(urlS + 'leave_request.php');
    final res = await post(url,
        body: {'doctor_id': spref.getString('doc_id'), 'date': date});
    print('leave request response:' + res.body);
  }

  Future<String> isDocAvailable(int docId) async {
    final url = Uri.parse(urlS + 'leave_status_view.php');
    final res = await post(url, body: {'doctor_id': docId.toString()});
    print('is doc available res:' + res.body.toString());
    return jsonDecode(res.body)['message'];
  }

  Future<void> bookedSlots() async {}

  Future<int> availableTimeSlotsCount(int doc) async {
    final spref = await SharedPreferences.getInstance();
    loginId = spref.getString('patient_id');

    DummyLists.docTimeSlots = [
      {'time_slot': '09:00'},
      {'time_slot': '09:15'},
      {'time_slot': '09:20'},
      {'time_slot': '09:25'},
      {'time_slot': '09:30'},
      {'time_slot': '09:35'},
      {'time_slot': '09:45'},
      {'time_slot': '10:00'},
    ];
    print('docId' + doc.toString());
    final url = Uri.parse(urlS + 'appointment_view.php');
    final res = await post(url, body: {'doctor_id': doc.toString()});
    print(res.body);
    final bookedSlots = jsonDecode(res.body) as List;
    // final bookedSlots=bookedSlotsTemp.w
    print('tempList' + bookedSlots.toString());
    // final tempList = DummyLists.docTimeSlots.where((el) {
    //   return bookedSlots
    //       .any((element) => element['time_slot'] != el['time_slot']);
    // });
    // bookedSlots.map((e) => DummyLists.docTimeSlots
    //     .removeWhere((element) => element['time_slot'] == e['time_slot']));
    DummyLists.docTimeSlots.removeWhere((ele) => (bookedSlots
        .any((element) => ele['time_slot'] == element['time_slot'])));
    final tempList = [];
    // DummyLists.docTimeSlots.map((e) {});

    // DummyLists.docTimeSlots.addAll(tempList);
    // DummyLists.docTimeSlots = tempList;
    print('-----' + DummyLists.docTimeSlots.toString());
    return DummyLists.docTimeSlots.length;
  }

  double getPrices(String item) {
    return 25.0;
  }

  Future<dynamic> getPrescForPatientWithId(String id) async {
    // final spref = await SharedPreferences.getInstance();
    // final id = spref.getString('patient_id');
    // print(id);

    final res = await post(Uri.parse(urlS + 'priscription_list.php'),
        body: {'patient_id': id});
    print('presc_' + res.body);
    prescForPatients = jsonDecode(res.body) as List;
    DummyLists.dummyPrescs = jsonDecode(res.body) as List;
    await getUploadedPrecs();
    return jsonDecode(res.body);
  }

  Future<dynamic> getPrescForPatient() async {
    final spref = await SharedPreferences.getInstance();
    final id = spref.getString('patient_id');
    print('id while getting prescriptopnd' + id.toString());
    final res = await post(Uri.parse(urlS + 'priscription_list.php'),
        body: {'patient_id': id});
    print('received presc' + res.body);
    prescForPatients = jsonDecode(res.body) as List;
    DummyLists.dummyPrescs = jsonDecode(res.body) as List;
    await getUploadedPrecs();
    return jsonDecode(res.body);
  }

  Future<dynamic> appointmentPatients() async {
    try {
      final spref = await SharedPreferences.getInstance();
      final res = await post(Uri.parse(urlS + 'appointment_patient_list.php'),
          body: {'doctor_id': spref.getString('doc_id')});
      print(res.body);
      // DummyLists.patientsList = jsonDecode(res.body);
      // print(jsonDecode(res.body));
      return jsonDecode(res.body);
    } on Exception catch (err) {
      print(err);
    }
  }

  Future<dynamic> viewPatientWithId(String id) async {
    final spref = await SharedPreferences.getInstance();
    // final id = spref.getString('patient_id');
    final res = await post(Uri.parse(urlS + 'patient_view.php'),
        body: {'patient_id': id});
    print(res.body);
    return jsonDecode(res.body);
  }

  Future<dynamic> viewPatient() async {
    final spref = await SharedPreferences.getInstance();
    final id = spref.getString('patient_id');
    print('id while viewing patient' + id.toString());
    final res = await post(Uri.parse(urlS + 'patient_view.php'),
        body: {'patient_id': id});
    print(res.body);
    return jsonDecode(res.body);
  }

  Future<dynamic> getDocDetails() async {
    final spref = await SharedPreferences.getInstance();
    print('docId:' + spref.getString('doc_id')!);
    final res = await post(Uri.parse(urlS + 'doctor_view.php'),
        body: {'doctor_id': spref.getString('doc_id')});
    print(res);
    spref.setString('docName', jsonDecode(res.body)['doc_name']);
    return jsonDecode(res.body);
  }

  Future<dynamic> docProfileUpdate(
      String name, String email, String mobile) async {
    final spref = await SharedPreferences.getInstance();
    final res = await post(Uri.parse(urlS + 'profile_update.php'), body: {
      'doctor_id': spref.getString('doc_id'),
      'name': name,
      'email': email,
      'mobile': mobile,
    });
    print(res.body);
  }

  Future<dynamic> viewPatientAppoinments() async {
    final spref = await SharedPreferences.getInstance();

    final res = await post(Uri.parse(urlS + 'appointment_patient.php'),
        body: {'patient_id': spref.getString('patient_id')});
    print('appoinments ' + res.body);
    return jsonDecode(res.body);
  }

  Future<dynamic> getLeaveStatus() async {
    final spref = await SharedPreferences.getInstance();
    // final docId = spref.getString('doc_id');
    // print(docId);

    final res = await post(Uri.parse(urlS + 'doctor_status.php'),
        body: {'doctor_id': spref.getString('doc_id')});
    print(res.body);

    return jsonDecode(res.body);
    // print(err);

    // print('leave statuc' + res.body);
  }

  getTestsAndMedicines() async {
    final testRes = await post(Uri.parse(urlS + 'test_list.php'));
    final medRes = await post(Uri.parse(urlS + 'medicine_list.php'));
    DummyLists.tests = jsonDecode(testRes.body);
    DummyLists.medicines = jsonDecode(medRes.body);
  }

  prescribe(List presc) async {
    presc.map((e) async {
      // print(e);
      final res = await post(Uri.parse(urlS + 'add_priscription.php'), body: e);
      print(res.body);
    }).toList();
    // final res = await post(Uri.parse(urlS + 'prescriprions.php'),
    // body: {'prescriptions': presc});
  }

  Future<void> addMedToCart(String prescId) async {
    final res = await post(Uri.parse(urlS + 'priscription_cart.php'),
        body: {'priscription_id': prescId});
    if (jsonDecode(res.body)['result'] == 'Add to cart') {
      Fluttertoast.showToast(msg: 'Added to cart');
    }
    print(res.body);
  }

  var gTotal;
  Future<dynamic> getCartItems() async {
    final pref = await SharedPreferences.getInstance();
    final patientId = pref.getString('patient_id');
    final res = await post(Uri.parse(urlS + 'cart_view.php'),
        body: {'patient_id': patientId});
    print(res.body);
    // (jsonDecode(res.body) as List).map((el) {});
    return jsonDecode(res.body);
  }

  Future<dynamic> uploadImagePresc(
    File imageFile,
    // String name,
    // DateTime date
  ) async {
    final spref = await SharedPreferences.getInstance();

    final res = await ImageUpload.upload(
        imageFile: imageFile,
        url: Uri.parse(urlS + 'upload_priscription.php'),
        // name: name,
        // date: date,
        patientId: spref.getString('patient_id')!);
  }

  Future<dynamic> getUploadedPrecs() async {
    print('doing');
    final spref = await SharedPreferences.getInstance();
    final res = await post(Uri.parse(urlS + 'view_previous.php'),
        body: {'patient_id': spref.getString('patient_id')});
    DummyLists.oldPrescImages = jsonDecode(res.body);
    print('old prescse' + DummyLists.oldPrescImages.toString());
    // return jsonDecode(res.body);
    return null;
  }

  Future<dynamic> bookTest(String prescId) async {
    print('perscid' + prescId);
    final res = await post(Uri.parse(urlS + 'test_booking.php'),
        body: {'priscription_id': prescId});
    print('test booking' + res.body);
    if (jsonDecode(res.body)['result'] == 'Add to cart') {
      Fluttertoast.showToast(msg: 'Booked for medical test');
    }
  }

  Future<dynamic> viewBookedTests() async {
    final spref = await SharedPreferences.getInstance();
    final res = await post(Uri.parse(urlS + 'view_test_booking.php'),
        body: {'patient_id': spref.getString('patient_id')});
    print(res.body);

    return jsonDecode(res.body);
  }

  Future<dynamic> checkout() async {
    final spref = await SharedPreferences.getInstance();
    final res = await post(Uri.parse(urlS + 'checkout.php'), body: {
      'patient_id': spref.getString(
        'patient_id',
      )
    });
  }

  Future<dynamic> labtests() async {
    final spref = await SharedPreferences.getInstance();
    final res = await post(Uri.parse(urlS + 'view_test_booking.php'),
        body: {'patient_id': spref.getString('patient_id')});
    print(res.body);
    return jsonDecode(res.body);
  }

  Future<dynamic> getResults() async {
    final spref = await SharedPreferences.getInstance();
    final res = await post(Uri.parse(urlS + 'view_result.php'),
        body: {'patient_id': spref.getString('patient_id')});
    print(res.body);
    return jsonDecode(res.body);
  }

  Future<dynamic> sendGgrandTotal(int totalAmount) async {
    final spref = await SharedPreferences.getInstance();
    final res = await post(Uri.parse(urlS + 'total.php'), body: {
      'patient_id': spref.getString('patient_id'),
      'total': totalAmount.toString()
    });
    print(res.body);
    return null;
  }
}
