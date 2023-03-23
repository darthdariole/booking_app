import 'dart:io';

import 'package:booking_app/helpers/folderStructure.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class FilesHistory extends StatefulWidget {
  const FilesHistory({Key? key}) : super(key: key);

  @override
  State<FilesHistory> createState() => _FilesHistoryState();
}

class _FilesHistoryState extends State<FilesHistory> {
  String? filePath;
  List<FileSystemEntity>? _files;

  getFilePath() async {
    String path = await FolderStructure.getExportFilePath();
    final myDir = new Directory(path);
    setState(() {
      filePath = path;
      _files = myDir.listSync(
        recursive: true,
        followLinks: false,
      );
    });
    if (_files != null) {
      print('In sort files...');
      _files!.sort((a, b) {
        File file_a = File(b.path);
        File file_b = File(a.path);

        DateTime lastModified_a = file_a.lastModifiedSync();
        DateTime lastModified_b = file_b.lastModifiedSync();

        print("Last modified a: " + lastModified_a.toString());
        print("Last modified b: " + lastModified_b.toString());

        return lastModified_a.compareTo(lastModified_b);
      });
    }
    print("Files path: " + filePath!);
    print("Files list: " + _files!.length.toString());
  }

  getFileLastModified(int index) {
    File file = File(_files![index].path);
    DateTime lastModified;
    if (file != null) {
      lastModified = file.lastModifiedSync();
    } else {
      lastModified = DateTime.now();
    }
    return lastModified;
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    getFilePath();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Files History'),
            Text(
                filePath == null
                    ? "No path specified error"
                    : "Path: " + filePath!,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16.0,
                )),
          ],
        ),
      ),
      body: _files != null
          ? ListView.builder(
              itemCount: _files!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _files![index].path.split('/').last,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                      'Created At: ' + getFileLastModified(index).toString()),
                  onTap: () {
                    bool export = false;

                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Share file?..'),
                            content: Text('Are you sure you want to export ' +
                                _files![index].path.split('/').last),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  export = false;
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  export = true;
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Share',
                                ),
                              ),
                            ],
                          );
                        }).then((value) async {
                      if (export) {
                        await Share.shareFiles([_files![index].path]);
                      }
                    });

                    print(
                        'User wants to share: ${_files![index].path.split('/').last}');
                  },
                );
              },
            )
          : const Center(
              child: Text(
                "No files found",
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.white60,
                ),
              ),
            ),
    );
  }
}
