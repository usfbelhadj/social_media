import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../common_widgets/snack_message/snack_message.dart';

Future<bool> submitImages(
    List<File> imageFiles, String selectDocuments, BuildContext context) async {
  print(context);
  final url = Uri.parse('${env.api}/api/v1/me/identity/');
  final request = http.MultipartRequest('POST', url);
  request.headers['Authorization'] =
      'Bearer ${GetStorage().read('accessToken')}';

  // Add images to the request
  for (int i = 0; i < imageFiles.length; i++) {
    request.files.add(
      await http.MultipartFile.fromPath(
        i == 0
            ? 'front_image'
            : 'back_image', // Assuming the first file is the front image and the second file is the back image
        imageFiles[i].path,
      ),
    );
  }

  // Add other fields to the request
  request.fields['document_type'] =
      selectDocuments; // Replace this with the actual document type
  request.fields['user'] =
      GetStorage().read('accessToken'); // Replace this with the actual user id
  request.fields['submitted_at'] = DateTime.now()
      .toIso8601String(); // Replace this with the actual submission time if necessary

  final response = await request.send();
  final responseData = await response.stream.bytesToString();
  print(responseData);

  if (response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: CustomSnackBarContent(
          title: 'Success',
          message: 'Your documents are submitted successfully.',
          bgcolor: Colors.green,
          bubcolor: Color.fromARGB(255, 0, 114, 4),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
    return true;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: CustomSnackBarContent(
          title: 'Error',
          message: 'You have already submitted your documents.',
          bgcolor: Colors.red,
          bubcolor: Color.fromARGB(255, 131, 35, 28),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
    return false;
  }
}
