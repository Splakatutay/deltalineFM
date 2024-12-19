import 'dart:io';
import 'package:deltaline/pages/show_service_request.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:deltaline/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class EditServiceRequestScreen extends StatefulWidget {
  final ApiService apiService;
  final int requestId;

  EditServiceRequestScreen({required this.apiService, required this.requestId});
  @override
  _EditServiceRequestScreenState createState() => _EditServiceRequestScreenState();
}

class _EditServiceRequestScreenState extends State<EditServiceRequestScreen> {

  late Future<ServiceRequest> _serviceRequestFuture;
  final List<String> imagePaths = [];
  String user_type = 'tenant';
  bool _isLoading = false;

  String? _selectedValue;
  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  File? _selectedFile;
  Future<void>? _uploadFuture;

  final List<XFile> _images = [];
  List<File> _images1 = [];
  DateTime? _availabilityDate;
  final List<TimeOfDay?> _timeSlots = [];

  final _buildingNameController = TextEditingController();
  final _unitNoController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactNoController = TextEditingController();


  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Simulate data loading
    _loadRequestData();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadRequestData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print(token);
    setState(() {
      _isLoading = true;
    });
    // Load existing data from API
    final response = await http.get(
      Uri.parse('https://admin.deltalinefm.com/api/service-requests/${widget.requestId}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _buildingNameController.text = data['building_name'];
        _unitNoController.text = data['unit_no'];
        _descriptionController.text = data['description'];
        _contactNoController.text = data['contact_no'];
        _availabilityDate = DateTime.parse(data['availability_date']);
        _timeSlots.add(_convertStringToTimeOfDay(data['time_slot']));
        _timeSlots.add(_convertStringToTimeOfDay(data['time_slot1']));
        _timeSlots.add(_convertStringToTimeOfDay(data['time_slot2']));
        _selectedValue = data['emergency'];
      });

      for(String url in data['media1'])
      {
        final xfile1 = await _downloadImage(url);
        if (xfile1 != null) {
          setState(() {
            _images1.add(xfile1);
            print(xfile1);
          });
        }

      }
      setState(() {
        _isLoading = false;

      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load request data');
    }
  }

  Future<File?> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final documentDirectory = await getApplicationDocumentsDirectory();
        final filePath = '${documentDirectory.path}/${url.split('/').last}';
        File file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);

        return file;
      }
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
    return null;
  }

  TimeOfDay _convertStringToTimeOfDay(String timeString) {
    final format = RegExp(r'(\d{1,2}):(\d{2}) ([APMapm]{2})');
    final match = format.firstMatch(timeString);

    if (match != null) {
      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final period = match.group(3)!.toUpperCase();

      final int normalizedHour = period == 'PM' && hour != 12
          ? hour + 12
          : (period == 'AM' && hour == 12 ? 0 : hour);

      return TimeOfDay(hour: normalizedHour, minute: minute);
    } else {
      throw FormatException("Invalid time format");
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 2)),
      firstDate: DateTime.now().add(Duration(days: 2)),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _availabilityDate) {
      setState(() {
        _availabilityDate = picked;
      });
    }
  }

  void _selectTime(BuildContext context, int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _timeSlots[index]) {
      setState(() {
        _timeSlots[index] = picked;
      });
    }
  }

  void _addTimeSlot() {
    if (_timeSlots.length < 3) {
      setState(() {
        _timeSlots.add(null);
      });
    }
  }

  void _removeTimeSlot(int index) {
    setState(() {
      _timeSlots.removeAt(index);
    });
  }

  void _pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    setState(() {
      _images.addAll(selectedImages);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images1.removeAt(index);
    });
  }

  Future<void> _submitRequest(BuildContext context) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    setState(() {
      _isLoading = true;
    });
    final uri = Uri.parse('https://admin.deltalinefm.com/api/service-requests/${widget.requestId}'); // Replace with your API endpoint
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['description'] = _descriptionController.text;
    request.fields['building_name'] = _buildingNameController.text;
    request.fields['unit_no'] = _unitNoController.text;
    request.fields['contact_no'] = _contactNoController.text;
    request.fields['_method'] = 'PUT';

    if(_selectedValue != null){
      request.fields['emergency'] =  _selectedValue!;
      print(_selectedValue);
    }
    request.fields['availability_date'] = _availabilityDate.toString();
    request.fields['time_slot'] = customTimeToString(TimeOfDay(hour: _timeSlots[0]!.hour, minute: _timeSlots[0]!.minute));
    print(customTimeToString(TimeOfDay(hour: _timeSlots[0]!.hour, minute: _timeSlots[0]!.minute)));
    request.fields['time_slot1'] = customTimeToString(TimeOfDay(hour: _timeSlots[1]!.hour, minute: _timeSlots[1]!.minute));
    print(customTimeToString(TimeOfDay(hour: _timeSlots[1]!.hour, minute: _timeSlots[1]!.minute)));
    request.fields['time_slot2'] = customTimeToString(TimeOfDay(hour: _timeSlots[2]!.hour, minute: _timeSlots[2]!.minute));
    print(customTimeToString(TimeOfDay(hour: _timeSlots[2]!.hour, minute: _timeSlots[2]!.minute)));

    if (_images1 != null) {
      for (var image in _images1) {
        request.files.add(
          http.MultipartFile(
            'attachments[]', // Assuming the API expects an array of files
            image.readAsBytes().asStream(),
            image.lengthSync(),
            filename: basename(image.path),
          ),
        );
      }
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {

      setState(() {
        _isLoading = false;
      });

      final result = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updating Request Failed: ${result['message']}')),
      );
    } else {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service Request Successfully Updated...')),
      );

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>
              ShowServiceRequest(
                  apiService: widget.apiService, requestId: widget.requestId))
      );
    }

  }

  String customTimeToString(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';

    int finalHours = timeOfDay.hour % (12);
    if(finalHours == 0) {
      finalHours = 12;
    }

    return '$finalHours:$minute $period';
  }

  Future<void> _pickFile() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _selectedFile = pickedFile != null ? File(pickedFile.path) : null;
      _images1.add(File(pickedFile!.path));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Edit Service Request'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Define your action here
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShowServiceRequest(apiService: widget.apiService, requestId: widget.requestId))
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const Text(
                "Building Name:" ,
                style: TextStyle(
                    color: Colors.black
                ),
              ),
              const SizedBox(height: 5.0),
              TextFormField(
                cursorColor: Colors.black,
                style:const TextStyle(fontSize:14),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 236, 236, 236))
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                          color: Colors.lightGreen
                      )
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 236, 236, 236),
                  contentPadding: const EdgeInsets.fromLTRB(20, 5, 20, 5),

                ),
                controller: _buildingNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Building Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              const Text(
                "Unit No:" ,
                style: TextStyle(
                    color: Colors.black
                ),
              ),
              const SizedBox(height: 5.0),
              TextFormField(
                cursorColor: Colors.black,
                style:const TextStyle(fontSize:14),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 236, 236, 236))
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                          color: Colors.lightGreen
                      )
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 236, 236, 236),
                  contentPadding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                ),
                controller: _unitNoController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Unit No. is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              const Text(
                "Issue:" ,
                style: TextStyle(
                    color: Colors.black
                ),
              ),
              const SizedBox(height: 5.0),
              TextFormField(
                cursorColor: Colors.black,
                style:const TextStyle(fontSize:14),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 236, 236, 236))
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                          color: Colors.lightGreen
                      )
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 236, 236, 236),
                  contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                ),
                maxLines: 5,
                controller: _descriptionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Issue is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),
              const Text(
                "Emerygency:" ,
                style: TextStyle(
                    color: Colors.black
                ),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 236, 236, 236),
                  contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    borderSide: BorderSide(color: Colors.red, width: 1.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    borderSide: BorderSide(color: Colors.red, width: 1.0),
                  ),
                ),
                value: _selectedValue,
                items: <String>["", 'AC', 'Gas', 'Electric']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedValue = newValue;
                  });
                },
                validator: (value) {
                  // if (value == null || value.isEmpty) {
                  //   return 'Please select an option';
                  // }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              const Text(
                "Contact No:" ,
                style: TextStyle(
                    color: Colors.black
                ),
              ),
              TextFormField(
                cursorColor: Colors.black,
                style:const TextStyle(fontSize:14),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 236, 236, 236))
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                          color: Colors.lightGreen
                      )
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 236, 236, 236),
                  contentPadding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                ),
                keyboardType: TextInputType.number,
                controller: _contactNoController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contact No. is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              const Text(
                "Availability:" ,
                style: TextStyle(
                    color: Colors.black
                ),
              ),
              const SizedBox(height: 5.0),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.calendar_month, color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 236, 236, 236))
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(
                          color: Colors.lightGreen
                      )
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 236, 236, 236),
                  contentPadding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                ),
                onTap: () => _selectDate(context),
                controller: TextEditingController(
                  text: _availabilityDate == null
                      ? ''
                      : DateFormat('dd-MMMM-yyyy').format(_availabilityDate!),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Availability Date is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ..._buildTimeSlots(context),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                        Text('Attach Photos', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildImagePreview(),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 178, 179, 177).withOpacity(1),
                        spreadRadius: 1,
                        blurRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  width: 180.0,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Handle form submission

                        setState(() {
                          _uploadFuture = _submitRequest(context);
                        });

                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14.0), backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 10,
                      shadowColor: Colors.black12,
                    ),
                    child: _isLoading ?
                      FutureBuilder<void>(
                      future: _uploadFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return SizedBox(
                            child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color.fromARGB(255, 236, 236, 236)),
                                )
                            ),
                            height: 15.0,
                            width: 15.0,
                          );
                        } else if (snapshot.hasError) {
                          //return Text('Error: ${snapshot.error}');
                        } else if (snapshot.connectionState == ConnectionState.done) {
                          //return Text('Request Submitted Successfully');
                        }
                        return SizedBox.shrink();
                      },
                    )
                    :
                    Text(
                        'UPDATE REQUEST' ,
                        style: TextStyle(
                          color: Color.fromARGB(255, 236, 236, 236),
                          fontSize: 14.0,
                        )
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTimeSlots(BuildContext context) {
    List<Widget> timeSlotFields = [];
    for (int i = 0; i < _timeSlots.length; i++) {
      int _i = 1 + i;
      timeSlotFields.add(
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Time Slot $_i" ,
                      hintStyle: const TextStyle(color: Colors.grey),
                      suffixIcon: const Icon(Icons.access_time),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                          borderSide: const BorderSide(color: Color.fromARGB(255, 236, 236, 236))
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                          borderSide: const BorderSide(
                              color: Colors.lightGreen
                          )
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 236, 236, 236),
                      contentPadding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                    ),

                    onTap: () => _selectTime(context, i),
                    controller: TextEditingController(
                      text: _timeSlots[i] == null
                          ? ''
                          : _timeSlots[i]!.format(context),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Please select a time' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    }
    return timeSlotFields;
  }

  Widget _buildImagePreview() {
    if (_images1.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images1.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Image.file(
                  File(_images1[index].path),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    color: Colors.black54,
                    child: const Icon(Icons.remove_circle, color: Colors.red),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}