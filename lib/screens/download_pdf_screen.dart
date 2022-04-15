import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileDownloaderScreen extends StatefulWidget {
  @override
  _FileDownloaderScreenState createState() => _FileDownloaderScreenState();
}

class _FileDownloaderScreenState extends State<FileDownloaderScreen> {

  final pdfUrl = "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf";

  bool downloading = false;
  var progress = "";
  var path = "No Data";
  var platformVersion = "Unknown";
  var _onPressed;
  Directory? externalDir;

  @override
  void initState() {
    super.initState();
    downloadFile();
  }

  String convertCurrentDateTimeToString() {
    String formattedDateTime =
    DateFormat('yyyyMMdd_kkmmss').format(DateTime.now()).toString();
    return formattedDateTime;
  }

  Future<void> downloadFile() async {
    Dio dio = Dio();

    final status = await Permission.storage.request();
    if (status.isGranted) {
      String dirloc = "";
      if (Platform.isAndroid) {
        dirloc = "/sdcard/download/";
      } else {
        dirloc = (await getApplicationDocumentsDirectory()).path;
      }

      try {
        FileUtils.mkdir([dirloc]);
        await dio.download(pdfUrl, dirloc + convertCurrentDateTimeToString() + ".pdf",
            onReceiveProgress: (receivedBytes, totalBytes) {
          print('here 1');

            setState(() {
              downloading = true;
              progress = ((receivedBytes / totalBytes) * 100).toStringAsFixed(0) + "%";
              print(progress);
            });
            print('here 2');
          });
      } catch (e) {
        print('catch catch catch');
        print(e);
      }

    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        downloading = false;
        progress = "Download Completed.";
        path = dirloc + convertCurrentDateTimeToString() + ".pdf";
      });
    });
      print(path);
      print('here give alert-->completed');
    } else {
      setState(() {
        progress = "Permission Denied!";
        _onPressed = () {
          downloadFile();
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('File Downloader'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: (){
              setState(() {
                downloadFile();
              });
            },
            child: downloading ? SizedBox(
              height: 120.0,
              width: 200.0,
              child: Card(
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10.0,),
                    Text('Downloading File: $progress', style: TextStyle(color: Colors.white),),
                  ],
                ),
              ),
            ) : Column(
              children: [
                Text(path),
                const SizedBox(height: 10,),
                SizedBox(
                  height: 50.0, width: 200.0,
                  child: Card(
                    color: Colors.black,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Text('Download File',style: TextStyle(color: Colors.white),),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    // body: Center(
    //   child: downloading ?
    //   SizedBox(
    //     height: 120.0, width: 200.0,
    //     child: Card(
    //       color: Colors.black,
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: <Widget>[
    //           const CircularProgressIndicator(),
    //           const SizedBox(height: 10.0,),
    //           Text('Downloading File: $progress',style: TextStyle(color: Colors.white),),
    //         ],
    //       ),
    //     ),
    //   ) :
    //   Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: <Widget>[
    //       Text(path),
    //       MaterialButton(
    //         child: const Text('Request Permission Again.'),
    //         onPressed: _onPressed,
    //         disabledColor: Colors.blueGrey,
    //         color: Colors.pink,
    //         textColor: Colors.white,
    //         height: 40.0,
    //         minWidth: 100.0,
    //       ),
    //     ],
    //   ),
    // ),
  );
}

