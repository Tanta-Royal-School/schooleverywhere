import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
//import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:path/path.dart' as path;
import 'package:just_audio/just_audio.dart' as ap;

import 'package:schooleverywhere/widget/Audio/audio_player.dart';
import 'package:schooleverywhere/widget/Audio/audio_record.dart';
import '../Constants/StringConstants.dart';
import '../Modules/EventObject.dart';
import '../Modules/Staff.dart';
import '../Networking/ApiConstants.dart';
import '../Networking/Futures.dart';
import '../Pages/HomePage.dart';
import '../SharedPreferences/Prefs.dart';
import '../Style/theme.dart';

import '../Pages/LoginPage.dart';
import 'StudentSendtoclassReply.dart';

class SendToClass extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _SendToClassState();
  }
}

class _SendToClassState extends State<SendToClass> {
  Staff? loggedStaff;

  String StaffSection = "Loading...";
  String StaffSectionId = "";
  String StaffStage = "Loading...";
  String StaffStageId = "";
  String StaffGrade = "Loading...";
  String StaffGradeId = "";
  String StaffSemester = "Loading...";
  String StaffSemesterId = "";
  String StaffClass = "Loading...";
  String StaffClassId = "";
  String StaffSubject = "Loading...";
  String StaffSubjectId = "";
  String academicYearValue = "Loading...";
  String Url = ApiConstants.FILE_UPLOAD_SEND_TO_CLASS_API;
  bool isLoading = false;
  List<File> selectedFilesList = [];
  List<File> TempselectedFilesList = [];
  List NewFileName = [];
  File? voice;
  String? _extension;
  bool _loadingPath = false;
  bool _hasValidMime = false;
  FileType? _pickingType;
  File? filepath;
  String? msgclass;
  // bool datasend = false;
  EventObject? datasend;
  final uploader = FlutterUploader();
  dynamic taskId;
  bool filesize = true;
  Map staffclassOptions = new Map();
  TextEditingController CommentValue = new TextEditingController();
  TextEditingController urlValue = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late List classSelected;
  List<dynamic> classstaff = [];
  bool showPlayer = false;
  ap.AudioSource? audioSource;

  initState() {
    super.initState();
    classSelected = [];
    getLoggedStaff();
  }

  Future<void> getLoggedStaff() async {
    loggedStaff = await getUserData() as Staff;
    StaffSection = loggedStaff!.sectionName!;
    StaffSectionId = loggedStaff!.section!;
    StaffStage = loggedStaff!.stageName!;
    StaffStageId = loggedStaff!.stage!;
    StaffGrade = loggedStaff!.gradeName!;
    StaffGradeId = loggedStaff!.grade!;
    StaffSemester = loggedStaff!.semesterName!;
    StaffSemesterId = loggedStaff!.semester!;
    StaffClass = loggedStaff!.staffClassName!;
    StaffClassId = loggedStaff!.staffClass!;
    StaffSubject = loggedStaff!.subjectName!;
    StaffSubjectId = loggedStaff!.subject!;
    academicYearValue = loggedStaff!.academicYear!;
    syncClassOptions();
    setState(() {});
  }

  Future<void> syncClassOptions() async {
    EventObject objectEventClass = await getClassStaffData(StaffSectionId,
        StaffStageId, StaffGradeId, academicYearValue, loggedStaff!.id!);
    if (objectEventClass.success!) {
      Map? data = objectEventClass.object as Map?;
      List<dynamic> listOfColumns = data!['data'];
      setState(() {
        classstaff = listOfColumns;
      });
    } else {
      String? msg = objectEventClass.object as String?;

      Fluttertoast.showToast(
          msg: msg.toString(),
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
          backgroundColor: AppTheme.appColor,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void _openFileExplorer() async {
    if (_pickingType != FileType.custom || _hasValidMime) {
      setState(() => _loadingPath = true);
      try {
        FilePickerResult? result = await FilePicker.platform
            .pickFiles(allowMultiple: true, type: FileType.any);

        if (result != null) {
          TempselectedFilesList =
              result.paths.map((path) => File(path!)).toList();
        }
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;

      setState(() {
        _loadingPath = false;
        if (TempselectedFilesList.length > 0)
          selectedFilesList = TempselectedFilesList;
      });
    }
  }

  final loadingSign = Padding(
    padding: EdgeInsets.symmetric(vertical: 16.0),
    child: SpinKitPouringHourGlass(
      color: AppTheme.appColor,
    ),
  );

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (_selectedIndex) {
        case 0:
          Navigator.push(context,
              new MaterialPageRoute(builder: (context) => SendToClass()));
          break;
        case 1:
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => StudentSendtoclassReplyFromStaff()));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedClasses = Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: MultiSelectFormField(
          autovalidate: false,
          title: Text("Class"),
          validator: (value) {
            if (value == null) return 'Please select one or more class(s)';
          },
          errorText: 'Please select one or more class(s)',
          dataSource: classstaff,
          textField: 'display',
          valueField: 'value',
          required: true,
          initialValue: classSelected,
          onSaved: (value) {
            setState(() {
              classSelected = value;
            });
          }),
    );

    final data = Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Table(
                border: TableBorder.all(color: AppTheme.appColor),
                children: [
                  TableRow(
                      //decoration: ,
                      children: <Widget>[
                        Text(" Section: ",
                            style: TextStyle(
                                wordSpacing: 10,
                                color: AppTheme.appColor,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        Text(" " + StaffSection,
                            style: TextStyle(
                                wordSpacing: 10,
                                color: AppTheme.appColor,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                      ]),
                  TableRow(children: <Widget>[
                    Text(" Stage: ",
                        style: TextStyle(
                            wordSpacing: 10,
                            color: AppTheme.appColor,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Text(" " + StaffStage,
                        style: TextStyle(
                            wordSpacing: 10,
                            color: AppTheme.appColor,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ]),
                  TableRow(children: <Widget>[
                    Text(" Grade: ",
                        style: TextStyle(
                            wordSpacing: 10,
                            color: AppTheme.appColor,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Text(" " + StaffGrade,
                        style: TextStyle(
                            wordSpacing: 10,
                            color: AppTheme.appColor,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ]),
                  TableRow(children: <Widget>[
                    Text(" Semester: ",
                        style: TextStyle(
                            wordSpacing: 10,
                            color: AppTheme.appColor,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Text(" " + StaffSemester,
                        style: TextStyle(
                            wordSpacing: 10,
                            color: AppTheme.appColor,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ]),
                  TableRow(children: <Widget>[
                    Text(" Subject: ",
                        style: TextStyle(
                            wordSpacing: 10,
                            color: AppTheme.appColor,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Text(" " + StaffSubject,
                        style: TextStyle(
                            wordSpacing: 10,
                            color: AppTheme.appColor,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ]),
                ])),
        SizedBox(
          width: MediaQuery.of(context).size.width * .75,
          child: selectedClasses,
        ),
        Text(" Comment ",
            style: TextStyle(
                color: AppTheme.appColor,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: TextFormField(
            controller: CommentValue,
            keyboardType: TextInputType.multiline,
            maxLines: 7,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.appColor)),
            ),
          ),
        ),
        Text(" URL ",
            style: TextStyle(
                color: AppTheme.appColor,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: TextFormField(
            controller: urlValue,
            keyboardType: TextInputType.url,
            validator: (value) {
              if ((urlValue.text.trim() != "") &&
                  !RegExp(r"^(http(s)?:\/\/)[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+$")
                      .hasMatch(value!)) {
                return 'Please enter some valid URL';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "it should start with http/https",
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.appColor)),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: showPlayer
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: AudioPlayer(
                    source: audioSource!,
                    onDelete: () {
                      setState(() => showPlayer = false);
                    },
                  ),
                )
              : AudioRecorder(
                  onStop: (path) {
                    setState(() {
                      audioSource = ap.AudioSource.uri(Uri.parse(path));
                      print(path);
                      voice = File(path);
                      showPlayer = true;
                    });
                  },
                ),
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
        Expanded(
          flex: 1,
          child: Container(
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
                    //subtitle: new Text(path),
                  );
                } else {
                  return Center(child: new Text("No file chosen"));
                }
              },
              separatorBuilder: (BuildContext context, int index) =>
                  new Divider(),
            )),
          ),
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
                    if (_formKey.currentState!.validate()) {
                      if (selectedFilesList.isNotEmpty) {
                        var lengthoffile = 0, toto;
                        for (int y = 0; y < selectedFilesList.length; y++) {
                          File f = selectedFilesList[y];
                          try {
                            toto = await f.length();
                            lengthoffile = toto;
                            print(lengthoffile.toString());
                            if (lengthoffile > 5000000) {
                              filesize = false;
                              break;
                            }
                          } on PlatformException catch (e) {
                            print("Unsupported File" + e.toString());
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SendToClass()),
                            );
                            /*   Flushbar(
                            title: "Failed",
                            message: "Unsupported File",
                            icon: Icon(Icons.close),
                            backgroundColor: AppTheme.appColor,
                            duration: Duration(seconds: 3),
                          )..show(context);*/
                            Fluttertoast.showToast(
                                msg: "Unsupported File",
                                toastLength: Toast.LENGTH_LONG,
                                timeInSecForIosWeb: 3,
                                backgroundColor: AppTheme.appColor,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        }
                        if (filesize) {
                          NewFileName =
                              await uploadFile(selectedFilesList, Url);
                        } else {
                          /* Flushbar(
                          title: "Failed",
                          message: "max size of one file allowed 5 MB",
                          icon: Icon(Icons.close),
                          backgroundColor: AppTheme.appColor,
                          duration: Duration(seconds: 3),
                        )..show(context);*/
                          Fluttertoast.showToast(
                              msg: "max size of one file allowed 5 MB",
                              toastLength: Toast.LENGTH_LONG,
                              timeInSecForIosWeb: 3,
                              backgroundColor: AppTheme.appColor,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      }
                      if (filesize) {
                        if (classSelected.isNotEmpty &&
                            (selectedFilesList.isNotEmpty ||
                                CommentValue.text.isNotEmpty)) {
                          datasend = await addSendToClass(
                              voice!,
                              NewFileName,
                              CommentValue.text,
                              urlValue.text,
                              loggedStaff!.id!,
                              loggedStaff!.name!,
                              loggedStaff!.academicYear!,
                              loggedStaff!.section!,
                              loggedStaff!.stage!,
                              loggedStaff!.grade!,
                              classSelected,
                              loggedStaff!.semester!,
                              loggedStaff!.subject!);
                          setState(() {
                            isLoading = false;
                          });
                          if (datasend!.success!) {
                            /*   Flushbar(
                            title: "Success",
                            message: "Comment and File Uploaded",
                            icon: Icon(Icons.done_outline),
                            backgroundColor: AppTheme.appColor,
                            duration: Duration(seconds: 3),
                          )..show(context);*/
                            Fluttertoast.showToast(
                                msg: "Comment and File Uploaded",
                                toastLength: Toast.LENGTH_LONG,
                                timeInSecForIosWeb: 3,
                                backgroundColor: AppTheme.appColor,
                                textColor: Colors.white,
                                fontSize: 16.0);
                            //  }
                          } else {
                            String? msg = datasend!.object as String?;

                            /*  Flushbar(
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
                        } else {
                          if (classSelected.isEmpty) {
                            msgclass = "Please Select Class";
                          } else {
                            msgclass = "Please Enter Comment or Choose File";
                          }

                          /* Flushbar(
                          title: "Failed",
                          message: msgclass,
                          icon: Icon(Icons.close),
                          backgroundColor: AppTheme.appColor,
                          duration: Duration(seconds: 3),
                        )..show(context);*/
                          Fluttertoast.showToast(
                              msg: msgclass!,
                              toastLength: Toast.LENGTH_LONG,
                              timeInSecForIosWeb: 3,
                              backgroundColor: AppTheme.appColor,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      }
                    } else {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Not Valid URL')));
                    }
                  },
                  padding: EdgeInsets.all(12),
                  color: AppTheme.appColor,
                  child: Text('Send', style: TextStyle(color: Colors.white)),
                ),
              )
      ],
    );

    return Scaffold(
      appBar: new AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(SCHOOL_NAME),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(new MaterialPageRoute(
                    builder: (context) => HomePage(
                        type: loggedStaff!.type!,
                        sectionid: loggedStaff!.section!,
                        Id: "",
                        Academicyear: "")));
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('img/logo.png'),
              ),
            )
          ],
        ),
        backgroundColor: AppTheme.appColor,
      ),
      body: Form(
        key: _formKey,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 1.2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('img/bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: data,
            ),
          ]),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_comment),
            title: Text('New'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            title: Text('Student Reply'),
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.appColor,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
          elevation: 55,
          onPressed: () {
            logOut(loggedStaff!.type!, loggedStaff!.id!);
            removeUserData();
            while (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
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
