// import 'package:geolocator/geolocator.dart';

// class YourLocation {
//   static Future<Position?> getCurrentLocation() async {
//     LocationPermission permission;
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (serviceEnabled) {
//       permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.deniedForever) {
//         return null;
//       }
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission != LocationPermission.whileInUse &&
//             permission != LocationPermission.always) {
//           return null;
//         }
//       }
//       return await Geolocator.getCurrentPosition(
//         locationSettings: const LocationSettings(
//           accuracy: LocationAccuracy.high,
//         ),
//       );
//     } else {
//       return null;
//     }
//   }
// }
