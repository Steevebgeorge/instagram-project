import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

getImage(ImageSource source) async {
  ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source);
  if (file != null) {
    return await file.readAsBytes();
  }
  log("No Image Selected");
}

customSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(content)),
  );
}

getFormattedTime({required BuildContext context, required String time}) {
  final date = DateTime.now();
  return TimeOfDay.fromDateTime(date).format(context);
}

String getFormattedLastSeen(DateTime time) {
  final now = DateTime.now();
  final difference = now.difference(time);

  if (difference.inDays > 365) {
    // More than a year ago
    return DateFormat("yMMMMd").format(time); // e.g., June 10, 2025
  } else if (difference.inDays > 30) {
    // More than a month ago
    return 'Last Seen: ${(difference.inDays / 30).floor()} month ago';
  } else if (difference.inDays > 0) {
    // Today (but still past few hours)
    return 'Last seen today at ${DateFormat("jm").format(time)}'; // e.g., 1:47 PM
  } else if (difference.inHours > 0) {
    // Last seen within a few hours
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inMinutes > 0) {
    // Last seen within a few minutes
    return 'Last Seen:${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else {
    // Less than a minute ago
    return 'Last Seen: Just now';
  }
}
