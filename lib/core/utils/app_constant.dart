import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart' as intl;
import 'package:toastification/toastification.dart';

import 'package:geocoding/geocoding.dart';

bool isLoggedInUser = false;
bool isOnBoarding = true;

class AppConstant {
  static Object? toast(String message, bool isTrue, BuildContext context) {
    toastification.dismissAll();
    return toastification.show(
      context: context,
      alignment: Alignment.topCenter,
      type: isTrue ? ToastificationType.success : ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: Text(
        message,
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontWeight: FontWeight.w600,
        ),
      ),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      borderRadius: BorderRadius.circular(10),
      showProgressBar: false,
      closeOnClick: true,
      dragToClose: true,
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  static double getProductPriceAfterDiscount(
    String discountType,
    double productPrice,
    double discount,
  ) {
    if (discountType == "percent") {
      return productPrice - (discount * productPrice) / 100;
    } else {
      return productPrice - discount;
    }
  }

  static double getDiscountOnProduct(
    String discountType,
    double productPrice,
    double discount,
  ) {
    if (discountType == "percent") {
      return (discount * productPrice) / 100;
    } else {
      return discount;
    }
  }

  static String confirmRoundTo3Numbers(double number) {
    return number.toStringAsFixed(3);
  }

  static Map<String, int> requestsType = {
    "orders_from_manager": 0,
    "my_orders": 1,
    "leave_orders": 2,
  };

  static void openUrl(String webUrl) async {
    final String url = webUrl;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw "Could not launch $url";
    }
  }

  static String formatDate222String(String dateString) {
    try {
      // Parse the ISO date string

      DateTime dateTime = DateTime.parse(dateString);

      // Format only hours and minutes
      return intl.DateFormat('HH:mm').format(dateTime);
    } catch (error) {
      return '';
    }
  }

  static String formatDateString(String dateString) {
    // تحويل النص إلى DateTime
    DateTime dateTime = DateTime.parse(dateString).toLocal();
    DateTime now = DateTime.now();

    // الفرق بين اليوم والوقت
    Duration difference = now.difference(dateTime);

    // نفس اليوم
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return intl.DateFormat.Hm().format(dateTime); // مثال: 14:40
    }
    // أمس
    else if (difference.inDays == 1 &&
        dateTime.day == now.subtract(const Duration(days: 1)).day) {
      return "Yesterday";
    }
    // أي يوم آخر
    else {
      return intl.DateFormat('yyyy-MM-dd').format(dateTime); // مثال: 2025-09-26
    }
  }

  // static void openUrl(String webUrl) async {
  //   final String url = webUrl;
  //   if (await canLaunchUrl(Uri.parse(url))) {
  //     await launchUrl(Uri.parse(url));
  //   } else {
  //     throw "Could not launch $url";
  //   }
  // }

  static String formatDateRange(DateTime startDate, DateTime endDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final startDateOnly = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    String dayText;
    if (startDateOnly == today) {
      dayText = "Today";
    } else if (startDateOnly == tomorrow) {
      dayText = "Tomorrow";
    } else {
      dayText = intl.DateFormat.EEEE().format(
        startDate,
      ); // Example: Monday, Tuesday
    }

    String startTime = intl.DateFormat.Hm().format(startDate); // 18:00
    String endTime = intl.DateFormat.Hm().format(endDate); // 18:30

    return "$dayText $startTime - $endTime";
  }

  static Future<void> openPhoneCall(String phoneNumber) async {
    final String cleanedPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');

    final Uri phoneUri = Uri(scheme: 'tel', path: cleanedPhone);

    if (!await canLaunchUrl(phoneUri)) {
      throw Exception('Could not open phone dialer');
    }

    await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
  }

  // static String getMonthName(int monthNumber) {
  //    if (monthNumber < 1 || monthNumber > 12) {
  //      return 'Invalid month';
  //    }
  //
  //    List<String> monthNames = [
  //      'January', 'February', 'March', 'April', 'May', 'June',
  //      'July', 'August', 'September', 'October', 'November', 'December'
  //    ];
  //
  //    return monthNames[monthNumber - 1];
  //  }
  //
  // static void openUrl(String webUrl) async {
  //   final String url = webUrl;
  //   if (await canLaunchUrl(Uri.parse(url))) {
  //     await launchUrl(Uri.parse(url));
  //   } else {
  //     throw "Could not launch $url";
  //   }
  // }

  static Future<void> openMap(double latitude, double longitude) async {
    final googleUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }

  static Future<String?> getAddressFromLatLng({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final List<Placemark> placemarks = await Geocoding()
          .placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) return null;

      final Placemark place = placemarks.first;

      final addressParts = [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
      ].where((e) => e != null && e.trim().isNotEmpty).toList();

      return addressParts.join(', ');
    } catch (e) {
      return null;
    }
  }
  //
  // static Future<String> getLocationFromCoordinates(
  //   double latitude,
  //   double longitude,
  // ) async {
  //   try {
  //     if (latitude != 0 && longitude != 0) {
  //       List<Placemark> placeMarks = await placemarkFromCoordinates(
  //         latitude,
  //         longitude,
  //       );
  //       if (placeMarks != null && placeMarks.isNotEmpty) {
  //         Placemark placeMark = placeMarks[0];
  //         String address =
  //             // '${placeMark.thoroughfare} ,'
  //             ' ${placeMark.administrativeArea!.replaceAll("Governorate", "")},${placeMark.country!}';
  //         return address;
  //       }
  //     }
  //   } catch (e) {
  //     return "";
  //     // print('Error retrieving location: $e');
  //   }
  //   return "";
  //   // return 'Location not found';
  // }

  // static String getDistance(
  //   Position? position1,
  //   String latitude,
  //   String longitude,
  // ) {
  //   double distanceInMeters = Geolocator.distanceBetween(
  //     position1?.latitude ?? 0,
  //     position1?.longitude ?? 0,
  //     double.tryParse(latitude) ?? 0,
  //     double.tryParse(longitude) ?? 0,
  //   );
  //   if (distanceInMeters > 1000) {
  //     return "${(distanceInMeters / 1000).toStringAsFixed(2)} km";
  //   } else {
  //     return "${(distanceInMeters).toStringAsFixed(2)}m";
  //   }
  // }

  static String convertTo12Hour(String time24) {
    final parts = time24.split(':');
    int hour = int.parse(parts[0]);
    String minute = parts[1];

    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;

    return "$hour:$minute $period";
  }
}
