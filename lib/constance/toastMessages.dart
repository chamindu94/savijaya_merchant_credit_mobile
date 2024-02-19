import 'package:flutter/material.dart';

import 'customSnackbar.dart';

showErrorMsg(context, errorText) {
  ScaffoldMessenger.of(context)
      .showSnackBar(customSnackBar(Colors.red, 'Error Occurred!', errorText));
}

showSuccessMsg(context, successText) {
  ScaffoldMessenger.of(context)
      .showSnackBar(customSnackBar(Colors.green, 'Successful', successText));
}