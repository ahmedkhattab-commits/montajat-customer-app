// import 'package:app_settings/app_settings.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class BluetoothPermissionHandler {
//   static Future<void> init(bool isOpenSetting) async {
//     bool granted = await BluetoothPermissionHandler.checkPermissions();
//
//     if (!granted) {
//       bool success = await BluetoothPermissionHandler.requestPermissions();
//
//       if (!success) {
//         print("Some permissions are denied, try granting them from settings.");
//         if (isOpenSetting) {
//           BluetoothPermissionHandler.openAppSettings();
//         }
//       }
//     } else {
//       print("All permissions already granted!");
//     }
//   }
//
//   /// Checks if all Bluetooth permissions are granted
//   static Future<bool> checkPermissions() async {
//     return await Permission.bluetooth.isGranted &&
//         await Permission.bluetoothScan.isGranted &&
//         await Permission.bluetoothConnect.isGranted &&
//         await Permission.location.isGranted;
//   }
//
//   /// Requests Bluetooth permissions from the user
//   static Future<bool> requestPermissions() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.bluetooth,
//       Permission.bluetoothScan,
//       Permission.bluetoothConnect,
//       Permission.location
//     ].request();
//
//     return statuses[Permission.bluetooth]!.isGranted &&
//         statuses[Permission.bluetoothScan]!.isGranted &&
//         statuses[Permission.bluetoothConnect]!.isGranted &&
//         statuses[Permission.location]!.isGranted;
//   }
//
//   /// Checks if the permission is permanently denied (needs to open settings)
//   static Future<bool> isPermanentlyDenied() async {
//     return await Permission.bluetooth.isPermanentlyDenied ||
//         await Permission.bluetooth.isDenied ||
//         await Permission.bluetoothScan.isPermanentlyDenied ||
//         await Permission.bluetoothScan.isDenied ||
//         await Permission.bluetoothConnect.isPermanentlyDenied ||
//         await Permission.bluetoothConnect.isDenied ||
//         await Permission.location.isPermanentlyDenied ||
//         await Permission.location.isDenied;
//   }
//
//   /// Opens app settings if permissions are permanently denied
//   static Future<void> openAppSettings() async {
//     if (await isPermanentlyDenied()) {
//       await AppSettings.openAppSettings();
//     }
//   }
// }
