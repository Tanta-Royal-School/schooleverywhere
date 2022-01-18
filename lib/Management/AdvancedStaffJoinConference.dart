import 'dart:io';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

import '../Modules/Management.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Constants/StringConstants.dart';
import '../Modules/EventObject.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import '../Networking/ApiConstants.dart';
import '../Networking/Futures.dart';
import '../Pages/LoginPage.dart';
import '../SharedPreferences/Prefs.dart';
import '../Style/theme.dart';
import 'package:path/path.dart' as path;

class AdvancedStaffJoinConference extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new AdvancedStaffJoinConferenceState();
  }
}

class AdvancedStaffJoinConferenceState
    extends State<AdvancedStaffJoinConference> {
  Management? loggedManagement;

  bool stageSelected = false, gradeSelected = false, classSelected = false;
  TextEditingController messageValue = new TextEditingController();
  TextEditingController subjectValue = new TextEditingController();
  FileType? _pickingType;
  File? filepath;
  String url = ApiConstants.FILE_UPLOAD_MANAGEMENT_BY_SELECT_API;
  bool isLoading = false;
  List<File> selectedFilesList = [];
  List<File> tempSelectedFilesList = [];
  List newFileName = [];
  String? _extension,
      userSection,
      userAcademicYear,
      userStage,
      userGrade,
      userId,
      userType,
      userClass;
  bool loadingPath = false;
  bool _hasValidMime = false;
  bool dataSend = false;
  List? teacherSelected, studentSelected, parentSelected;
  bool filesize = true;
  List<dynamic> listOfMessage = [];
  Map sectionsOptions = new Map();
  Map stageOptions = new Map();
  Map gradeOptions = new Map();

  String? stageValue, stageName, gradeValue, gradeName, classValue;

  String? urlConference, userName;
  int? JoinStaff;
  final uploader = FlutterUploader();
  initState() {
    super.initState();

    getLoggedInUser();
  }

  Future<void> getUrlConference() async {
    EventObject objectEvent = new EventObject();
    objectEvent = await getUrlConferenceData(userSection!);
    // print("kkkkkkk" + objectEvent.object);
    Map? data = objectEvent.object as Map?;
    if (objectEvent.success!) {
      urlConference = data!['advancedConference'];
      print(data['conference']);
    }
  }

  Future<void> getLoggedInUser() async {
    loggedManagement = await getUserData() as Management;
    userAcademicYear = loggedManagement!.academicYear;
    userSection = loggedManagement!.section;
    userId = loggedManagement!.id!;
    userType = loggedManagement!.type!;
    userName = loggedManagement!.name!;
    getUrlConference();
    _getMessages();
  }

  Future<void> _getMessages() async {
    EventObject objectEventMessageData = await getAdvancedConferenceStaffData();
    if (objectEventMessageData.success!) {
      Map? messageData = objectEventMessageData.object as Map?;
      List<dynamic> listOfColumns = messageData!['data'];
      setState(() {
        listOfMessage = listOfColumns;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final showData = Center(
        child: ListView(
      children: <Widget>[
        DataTable(
          columns: [
            DataColumn(
                label: Text(
              "Staff Name",
              style: TextStyle(color: AppTheme.appColor, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            )),
            DataColumn(
                label: Text(
              "Start",
              style: TextStyle(color: AppTheme.appColor, fontSize: 16),
            )),
            DataColumn(
                label: Text(
              "Join",
              style: TextStyle(color: AppTheme.appColor, fontSize: 16),
            )),
          ],
          rows:
              listOfMessage // Loops through dataColumnText, each iteration assigning the value to element
                  .map(
                    ((element) => DataRow(
                          cells: <DataCell>[
                            DataCell(Text(
                              element["staffname"],
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                            )),

                            DataCell(Text(
                              element["startdate"],
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                            )),

                            //Extracting from Map element the value
                            DataCell(
                              Text(
                                "Conference",
                                style: TextStyle(
                                    color: Colors.lightBlue, fontSize: 14),
                              ),
                              onTap: () async {
//                        _joinMeeting(ApiConstants.ConferenceSchoolName+"Schooleverywhere"+element["staffid"]);
//                        SetConferenceJoinId(element["id"]);
//                        JoinConferenceStatus(element["id"]);
                                await launch(ApiConstants.BASE_URL +
                                    "staff/joinStaffAdvancedConferenceStaffOne.php?s=" +
                                    element["staffid"] +
                                    "&myid=" +
                                    userId! +
                                    "&i=" +
                                    element["id"] +
                                    "&section=" +
                                    userSection!);
                              },
                            ),
                          ],
                        )),
                  )
                  .toList(),
        )
      ],
    ));

    return Scaffold(
      appBar: new AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(SCHOOL_NAME),
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('img/logo.png'),
            )
          ],
        ),
        backgroundColor: AppTheme.appColor,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('img/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: showData,
      ),
      floatingActionButton: FloatingActionButton(
          elevation: 55,
          onPressed: () {
            logOut(userType!, userId!);
            removeUserData();
            while (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
//          Navigator.pop(context);
            Navigator.of(context).pushReplacement(
                new MaterialPageRoute(builder: (context) => LoginPage()));
          },
          child: Icon(
            FontAwesomeIcons.doorOpen,
            color: AppTheme.floatingButtonColor,
            size: 30,
          ),
          backgroundColor: Colors.transparent,
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
          )),
    );
  }
}
