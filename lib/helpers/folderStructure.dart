import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/*
This class contains all the methods for checking the folders structure.
Permissions and misc operations pertaining to folders and directory.
*/
class FolderStructure {
  Directory? directory;
  /*
  This method returns the path to Android internal storage, We need this path to
  verify our storage structure.
  */

  /*
  IDEA
  Check all folders in one single function. And Create folders one by one.
  */

  static String getDateTime() {
    return DateTime.now().day.toString() +
        "-" +
        DateTime.now().month.toString() +
        "-" +
        DateTime.now().year.toString() +
        ";" +
        DateTime.now().hour.toString() +
        ":" +
        DateTime.now().minute.toString();
  }

  static String getYesterdayDate() {
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.millisecondsSinceEpoch.toString();
  }

  static String getDateInMilliSeconds() {
    DateTime dateTime = DateTime.now();
    return dateTime.millisecondsSinceEpoch.toString();
  }

  static String getDate(int millisecondFromEpoch) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(millisecondFromEpoch);

    return dateTime.day.toString() +
        "-" +
        dateTime.month.toString() +
        "-" +
        dateTime.year.toString();
  }

  static String getTime() {
    int hour = DateTime.now().hour;
    String ampm = "AM";
    String time = "";
    if (hour > 12) {
      int hoursConverted = hour - 12;
      time += hoursConverted <= 9
          ? "0" + hoursConverted.toString()
          : hoursConverted.toString();
      ampm = "PM";
    }
    time += ":" + DateTime.now().minute.toString() + " " + ampm;
    return time;
  }

  static String getTime24Hr(bool forFile) {
    int hour = DateTime.now().hour;
    int minutes = DateTime.now().minute;
    int seconds = DateTime.now().second;
    if (forFile) {
      return hour.toString() +
          "-" +
          minutes.toString() +
          "-" +
          seconds.toString();
    }
    return hour.toString() +
        ":" +
        minutes.toString() +
        ":" +
        seconds.toString();
  }

  Future<String> _getPath() async {
    directory = await getExternalStorageDirectory();
    String newPath = "";
    List<String> folders = directory!.path.split("/");

    for (int i = 0; i < folders.length; i++) {
      String folder = folders[i];
      if (i != 0) {
        if (folder != "Android") {
          newPath += "/" + folder;
        } else {
          break;
        }
      } else {
        newPath += folder;
      }
    }
    print("Internal path for Android: " + newPath);
    return newPath;
  }

  Future<bool> checkRootFolder() async {
    String internalPath = await _getPath();
    String rootPath = internalPath + "/BookingApp";
    Directory rootDirectory = Directory(rootPath);
    if (await rootDirectory.exists()) {
      print("Root folder exists, Now checking if sub folders exist");
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkSubFolders() async {
    String internalPath = await _getPath();
    String rootPath = internalPath + "/BookingApp";
    String importFolderPath = rootPath + "/Import";
    String exportFolderPath = rootPath + "/Export";

    Directory importFolderDirectory = Directory(importFolderPath);
    Directory exportFolderDirectory = Directory(exportFolderPath);

    if (!await importFolderDirectory.exists() &&
        !await exportFolderDirectory.exists()) {
      print("Both folders or one does not exist. Create both folders");
      return false;
    } else {
      print("Both folders exist");
      return true;
    }
  }

  void createRootFolder() async {
    String internalPath = await _getPath();
    String rootPath = internalPath + "/BookingApp";
    Directory rootDirectory = Directory(rootPath);
    await rootDirectory.create(recursive: true);
  }

  void createSubFolders() async {
    String internalPath = await _getPath();
    String rootPath = internalPath + "/BookingApp";
    String importFolderPath = rootPath + "/Import";
    String exportFolderPath = rootPath + "/Export";

    Directory importFolderDirectory = Directory(importFolderPath);
    Directory exportFolderDirectory = Directory(exportFolderPath);

    await importFolderDirectory.create(recursive: true);
    await exportFolderDirectory.create(recursive: true);
  }

  /*
  This function is responsible for checking the permission. If permission
  is not granted then ask the user for permission using request permission
  method.
  */
  static Future<bool> checkPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      /*
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
      */
      return false;
    }
  }

  static Future<String> getImportFilePath() async {
    FolderStructure object = FolderStructure();
    String internalPath = await object._getPath();
    print("Internal path: " + internalPath);
    return internalPath;
    //return internalPath + "/BookingApp/Import";
  }

  static Future<String> getExportFilePath() async {
    FolderStructure object = FolderStructure();
    String internalPath = await object._getPath();
    return internalPath + "/BookingApp/Export";
  }

  static Future<bool> requestPermission(Permission permission) async {
    var result = await permission.request();
    if (result == PermissionStatus.granted) {
      return true;
    } else
      return false;
  }
}
