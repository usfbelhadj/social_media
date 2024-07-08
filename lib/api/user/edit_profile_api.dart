import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> updateUserInformation({
  required String apiUrl,
  required String accessToken,
  required Map<String, dynamic> updatedData,
}) async {
  try {
    final http.Response response = await http.patch(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode(updatedData),
    );
    print('userdata : $updatedData');

    if (response.statusCode == 202) {
      print('User information updated successfully.');
    } else {
      print(
          'Failed to update user information. Status code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error updating user information: $error');
  }
}

Future<void> updateUserProfile({
  required String updatedFirstName,
  required String updatedLastName,
  required String updatedEmail,
  required String updatedPhone,
}) async {
  const apiUrl = '${env.api}/api/v1/me/edit/';
  final box = GetStorage();
  final accessToken = box.read('accessToken');
  final Map<String, dynamic> updatedData = {};

  if (updatedFirstName.isNotEmpty) {
    updatedData['first_name'] = updatedFirstName;
  }
  if (updatedLastName.isNotEmpty) {
    updatedData['last_name'] = updatedLastName;
  }
  if (updatedEmail.isNotEmpty) {
    updatedData['email'] = updatedEmail;
  }
  if (updatedPhone.isNotEmpty) {
    updatedData['phone'] = updatedPhone;
  }

  await updateUserInformation(
    apiUrl: apiUrl,
    accessToken: accessToken,
    updatedData: updatedData,
  );
}
