import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Modules/Management.dart';
//import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Constants/StringConstants.dart';
import '../Modules/EventObject.dart';

import '../Networking/ApiConstants.dart';
import '../Networking/Futures.dart';
import '../Pages/LoginPage.dart';
import '../SharedPreferences/Prefs.dart';
import '../Style/theme.dart';
import 'package:path/path.dart' as path;
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class AdvancedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new AdvancedPageState();
  }
}

class AdvancedPageState extends State<AdvancedPage> {
  Management? loggedManagement;
  TextEditingController Datefrom = new TextEditingController();
  final format = DateFormat("yyyy-MM-dd");
  bool stageSelected = false, gradeSelected = false, classSelected = false;
  TextEditingController messageValue = new TextEditingController();
  TextEditingController subjectValue = new TextEditingController();
  TextEditingController nameValue = new TextEditingController();
  TextEditingController mobileValue = new TextEditingController();
  TextEditingController emailValue = new TextEditingController();
  TextEditingController regnoValue = new TextEditingController();
  FileType? _pickingType;
  File? filepath;
  String url = ApiConstants.FILE_UPLOAD_MANAGEMENT_BY_SELECT_API;
  bool isLoading = false;
  bool isLoadingSearch = false;
  List<File> selectedFilesList = [];
  List<File> tempSelectedFilesList = [];
  List newFileName = [];
  String? userSection,
      userAcademicYear,
      userStage,
      userGrade,
      userId,
      userType,
      userClass;
  bool loadingPath = false;
  bool _hasValidMime = false;
  bool dataSend = false;
  bool isLoadingSearchResult = false;
  List? teacherSelected, studentSelected, parentSelected;
  bool filesize = true;
  List<dynamic> studentsList = [];
  Map sectionsOptions = new Map();
  Map stageOptions = new Map();
  Map gradeOptions = new Map();
  Map classOptions = new Map();
  String? stageValue, stageName, gradeValue, gradeName, classValue, className;

  final uploader = FlutterUploader();
  initState() {
    super.initState();

    getLoggedInUser();
  }

  void _openFileExplorer() async {
    if (_pickingType != FileType.custom || _hasValidMime) {
      setState(() => loadingPath = true);
      try {
        FilePickerResult? result = await FilePicker.platform
            .pickFiles(allowMultiple: true, type: FileType.any);

        if (result != null) {
          tempSelectedFilesList =
              result.paths.map((path) => File(path!)).toList();
        }
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;

      setState(() {
        loadingPath = false;
        if (tempSelectedFilesList.length > 0)
          selectedFilesList = tempSelectedFilesList;
      });
    }
  }

  Future<void> getLoggedInUser() async {
    loggedManagement = await getUserData() as Management;
    userAcademicYear = loggedManagement!.academicYear;
    userSection = loggedManagement!.section;
    userId = loggedManagement!.id!;
    userType = loggedManagement!.type!;

    syncStageOptions();
  }

  Future<void> syncStageOptions() async {
    print("section" + userSection!);
    print("stage" + userSection!);
    print("id" + userId!);
    EventObject objectEventStage =
        await stageManagmentOptions(userSection!, userAcademicYear!, userId!);
    if (objectEventStage.success!) {
      Map? data = objectEventStage.object as Map?;
      List<dynamic> x = data!['stageId'];
      Map Stagearr = new Map();
      for (int i = 0; i < x.length; i++) {
        Stagearr[data['stageId'][i]] = data['stageName'][i];
      }
      setState(() {
        stageOptions = Stagearr;
        print("stage map:" + Stagearr.toString());
      });
    } else {
      String? msg = objectEventStage.object as String?;
      /*Flushbar(
        title: "Failed",
        message: msg.toString(),
        icon: Icon(Icons.close),
        backgroundColor: AppTheme.appColor,
        duration: Duration(seconds: 3),
      )
        ..show(context);*/
      Fluttertoast.showToast(
          msg: msg.toString(),
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
          backgroundColor: AppTheme.appColor,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> syncGradeOptions() async {
    EventObject objectEventGarde = await gradeManagementOptions(
        userSection!, stageValue!, userAcademicYear!, userId!);
    if (objectEventGarde.success!) {
      Map? data = objectEventGarde.object as Map?;
      List<dynamic> y = data!['gardeId'];
      Map Gardearr = new Map();
      for (int i = 0; i < y.length; i++) {
        Gardearr[data['gardeId'][i]] = data['gardeName'][i];
      }
      setState(() {
        gradeOptions = Gardearr;
        print("grade map:" + Gardearr.toString());
      });
    } else {
      String? msg = objectEventGarde.object as String?;
      /*Flushbar(
        title: "Failed",
        message: msg.toString(),
        icon: Icon(Icons.close),
        backgroundColor: AppTheme.appColor,
        duration: Duration(seconds: 3),
      )
        ..show(context);*/
      Fluttertoast.showToast(
          msg: msg.toString(),
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
          backgroundColor: AppTheme.appColor,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> syncClassOptions() async {
    EventObject objectEventClass = await classManagenemtOptions(
        userSection!, stageValue!, gradeValue!, userAcademicYear!, userId!);
    if (objectEventClass.success!) {
      Map? data = objectEventClass.object as Map?;
      List<dynamic> m = data!['classId'];
      Map Classarr = new Map();
      for (int i = 0; i < m.length; i++) {
        Classarr[data['classId'][i]] = data['classsName'][i];
      }
      setState(() {
        classOptions = Classarr;
        print("class map:" + Classarr.toString());
      });
    } else {
      String? msg = objectEventClass.object as String?;
      /*Flushbar(
        title: "Failed",
        message: msg.toString(),
        icon: Icon(Icons.close),
        backgroundColor: AppTheme.appColor,
        duration: Duration(seconds: 3),
      )
        ..show(context);*/
      Fluttertoast.showToast(
          msg: msg.toString(),
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
          backgroundColor: AppTheme.appColor,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stage = Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButton<String>(
          isExpanded: true,
          value: stageValue,
          hint: Text("Select Stage"),
          style: TextStyle(color: AppTheme.appColor),
          underline: Container(
            height: 2,
            color: AppTheme.appColor,
          ),
          onChanged: (String? newValue) {
            setState(() {
              stageSelected = true;
              stageValue = newValue!;
              stageName = stageOptions[newValue];
              gradeOptions.clear();
              gradeValue = null;
              gradeName = null;
              gradeSelected = false;

              classOptions.clear();
              classValue = null;
              className = null;
              classSelected = false;
              syncGradeOptions();
            });
          },
          items: stageOptions
              .map((key, value) {
                return MapEntry(
                    value,
                    DropdownMenuItem<String>(
                      value: key,
                      child: Text(value),
                    ));
              })
              .values
              .toList()),
    );
    final grade = Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButton<String>(
          isExpanded: true,
          value: gradeValue,
          hint: Text("Select Grade"),
          style: TextStyle(color: AppTheme.appColor),
          underline: Container(
            height: 2,
            color: AppTheme.appColor,
          ),
          onChanged: (String? newValue) {
            setState(() {
              gradeSelected = true;
              gradeValue = newValue!;
              gradeName = gradeOptions[newValue];
              classOptions.clear();
              classValue = null;
              className = null;
              classSelected = false;

              syncClassOptions();
            });
          },
          items: gradeOptions
              .map((key, value) {
                return MapEntry(
                    value,
                    DropdownMenuItem<String>(
                      value: key,
                      child: Text(value),
                    ));
              })
              .values
              .toList()),
    );

    final managementclass = Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButton<String>(
          isExpanded: true,
          value: classValue,
          hint: Text("Select Class"),
          style: TextStyle(color: AppTheme.appColor),
          underline: Container(
            height: 2,
            color: AppTheme.appColor,
          ),
          onChanged: (String? newValue) {
            setState(() {
              classSelected = true;
              classValue = newValue!;
              className = classOptions[newValue];
            });
          },
          items: classOptions
              .map((key, value) {
                return MapEntry(
                    value,
                    DropdownMenuItem<String>(
                      value: key,
                      child: Text(value),
                    ));
              })
              .values
              .toList()),
    );
    final selectedStudent = Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: MultiSelectFormField(
          // autovalidate: false,
          title: Text("Student"),
          validator: (value) {
            if (value == null) {
              return 'Please select one or more option(s)';
            }
          },
          errorText: 'Please select one or more option(s)',
          dataSource: studentsList,
          textField: 'display',
          valueField: 'value',
          okButtonLabel: 'OK',
          cancelButtonLabel: 'CANCEL',
          // required: true,
          initialValue: studentSelected,
          onSaved: (value) {
            setState(() {
              studentSelected = value;
            });
          }),
    );
    final nameInput = Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: nameValue,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Name',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        ),
      ),
    );
    final mobileInput = Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: mobileValue,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Mobile',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        ),
      ),
    );
    final emailInput = Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: emailValue,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Email',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        ),
      ),
    );
    final regInput = Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: regnoValue,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Regno',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        ),
      ),
    );
    final subjectInput = Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: subjectValue,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'title',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        ),
      ),
    );

    final messageInput = Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: messageValue,
        keyboardType: TextInputType.multiline,
        maxLines: 7,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Message',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        ),
      ),
    );

    final loadingSign = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: SpinKitPouringHourGlass(
        color: AppTheme.appColor,
      ),
    );

    final messageBody = Column(
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * .5,
          child: selectedStudent,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * .75,
          child: subjectInput,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * .75,
          child: messageInput,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: RaisedButton(
            color: AppTheme.appColor,
            textColor: Colors.white,
            onPressed: () => _openFileExplorer(),
            child: new Text("Choose File"),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * .7,
          padding: const EdgeInsets.only(bottom: 10.0),
          child: new Scrollbar(
              child: new ListView.separated(
            shrinkWrap: true,
            itemCount:
                selectedFilesList.length > 0 && selectedFilesList.isNotEmpty
                    ? selectedFilesList.length
                    : 1,
            itemBuilder: (BuildContext context, int index) {
              if (selectedFilesList.length > 0) {
                return new ListTile(
                  title: new Text(
                    path.basename(selectedFilesList[index].path),
                  ),
                );
              } else {
                return Center(child: new Text("No file chosen"));
              }
            },
            separatorBuilder: (BuildContext context, int index) =>
                new Divider(),
          )),
        ),
        isLoading
            ? loadingSign
            : Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });

                    if (selectedFilesList.isNotEmpty) {
                      newFileName = await uploadFile(selectedFilesList, url);
                    }
                    if (subjectValue.text.isNotEmpty) {
                      dataSend = await addAdvanced(
                          newFileName,
                          userAcademicYear!,
                          userId!,
                          userSection!,
                          subjectValue.text,
                          messageValue.text,
                          studentSelected!);
                      setState(() {
                        isLoading = false;
                      });
                      if (dataSend) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdvancedPage()),
                        );
                        /*Flushbar(
                title: "Success",
                message: "Message Sent",
                icon: Icon(Icons.done_outline),
                backgroundColor: AppTheme.appColor,
                duration: Duration(seconds: 3),
              )..show(context);*/
                        Fluttertoast.showToast(
                            msg: "Message Sent",
                            toastLength: Toast.LENGTH_LONG,
                            timeInSecForIosWeb: 3,
                            backgroundColor: AppTheme.appColor,
                            textColor: Colors.white,
                            fontSize: 16.0);
                        //  }
                      } else {
                        /*Flushbar(
                title: "Failed",
                message:
                "Please Enter Comment or Choose File (max size of file 5 MB)",
                icon: Icon(Icons.close),
                backgroundColor: AppTheme.appColor,
                duration: Duration(seconds: 3),
              )..show(context);*/
                        Fluttertoast.showToast(
                            msg:
                                "Please Enter Comment or Choose File (max size of file 5 MB)",
                            toastLength: Toast.LENGTH_LONG,
                            timeInSecForIosWeb: 3,
                            backgroundColor: AppTheme.appColor,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    } else {
                      setState(() {
                        isLoading = false;
                      });
                      /*Flushbar(
              title: "Failed",
              message:
              "Please Enter Title",
              icon: Icon(Icons.close),
              backgroundColor: AppTheme.appColor,
              duration: Duration(seconds: 3),
            )
              ..show(context);*/
                      Fluttertoast.showToast(
                          msg: "Please Enter Title",
                          toastLength: Toast.LENGTH_LONG,
                          timeInSecForIosWeb: 3,
                          backgroundColor: AppTheme.appColor,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  },
                  padding: EdgeInsets.all(12),
                  color: AppTheme.appColor,
                  child: Text('Send', style: TextStyle(color: Colors.white)),
                ),
              )
      ],
    );

    Future<void> syncGetStaffStudentId() async {
      EventObject objectEventReport = await getStudentOfAdvancedManagement(
          userSection!,
          stageValue!,
          gradeValue!,
          classValue!,
          userAcademicYear!,
          Datefrom.text,
          nameValue.text,
          mobileValue.text,
          emailValue.text,
          regnoValue.text);
      if (objectEventReport.success!) {
        Map? getStudentValues = objectEventReport.object as Map?;
        List<dynamic> listOfStudents = getStudentValues!['data'];
        setState(() {
          studentsList = listOfStudents;
        });
        isLoadingSearch = true;
        isLoadingSearchResult = true;
      } else {
        isLoadingSearch = false;
        String? msg = objectEventReport.object as String?;
        /*Flushbar(
          title: "Failed",
          message: msg.toString(),
          icon: Icon(Icons.close),
          backgroundColor: AppTheme.appColor,
          duration: Duration(seconds: 3),
        )..show(context);*/
        Fluttertoast.showToast(
            msg: msg.toString(),
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 3,
            backgroundColor: AppTheme.appColor,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }

    final body = SingleChildScrollView(
      child: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.width * .02),
            ),
            isLoadingSearch
                ? Container()
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .5,
                          child: stage,
                        ),
                        stageSelected
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width * .5,
                                child: grade,
                              )
                            : Container(),
                        gradeSelected
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width * .5,
                                child: managementclass,
                              )
                            : Container(),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * .5,
                          child: nameInput,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .5,
                          child: regInput,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .5,
                          child: mobileInput,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .5,
                          child: emailInput,
                        ),
                        Text('Date',
                            style: TextStyle(
                                color: AppTheme.appColor,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 70),
                            child: Container(
                                width: MediaQuery.of(context).size.width * .5,
                                height:
                                    MediaQuery.of(context).size.height * .05,
                                child: DateTimeField(
                                  format: format,
                                  controller: Datefrom,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppTheme.appColor)),
                                  ),
                                  onShowPicker: (context, currentValue) {
                                    return showDatePicker(
                                        context: context,
                                        firstDate: DateTime(1996),
                                        initialDate: DateTime.now(),
                                        lastDate: DateTime(2050));
                                  },
                                ))),

                        /////////////////////////////////////////////////////////
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            onPressed: () {
                              syncGetStaffStudentId();
                            },
                            padding: EdgeInsets.all(12),
                            color: AppTheme.appColor,
                            child: Text('Search',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),

            isLoadingSearchResult
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: messageBody,
                  )
                : Container(),
            /////////////////////////////////////////////////////////////
          ],
        ),
      ),
    );

    Widget _buildBody() {
      return body;
    }

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
        child: _buildBody(),
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('stageValue', stageValue));
  }
}
