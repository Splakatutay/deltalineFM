import 'package:deltaline/pages/edit_service_request_screen.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:deltaline/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:deltaline/pages/service_request_screen.dart';
import 'dart:io';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';

class ShowServiceRequest extends StatefulWidget {
  final ApiService apiService;
  final int requestId;

  ShowServiceRequest({required this.apiService, required this.requestId});

  _ShowServiceRequest createState() =>
      _ShowServiceRequest();
}
class _ShowServiceRequest extends State<ShowServiceRequest> {

  late Future<ServiceRequest> _serviceRequestFuture;
  final SignatureController _signatureController = SignatureController(
    penColor: Colors.black,
    penStrokeWidth: 5,
  );
  final List<String> imagePaths = [];
  String user_type = 'tenant';
  bool _isLoading = false;
  File? _signatureFile;


  void initState() {
    super.initState();
    _loadData();
    _setUserType();
  }

  void _loadData() {
    // Simulate data loading
    _serviceRequestFuture = widget.apiService.fetchServiceRequestById(widget.requestId);
    print(_serviceRequestFuture);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _setUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_type = prefs.getString('role')!;
    });

  }

  Future<void> _saveSignature() async {
    final signatureData = _signatureController.toPngBytes();
    if (signatureData != null) {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/signature.png';
      final file = File(filePath);
      await file.writeAsBytes(signatureData as List<int>);

      setState(() {
        _signatureFile = file;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Request Details' ,
          style: TextStyle(
            color: Colors.black
          ),
        ),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Define your action here
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ServiceRequestScreen(apiService: widget.apiService))
            );
          },
        ),
      ),
      body: FutureBuilder<ServiceRequest>(
        future: _serviceRequestFuture,
        builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Failed to load service request: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No service request found.'));
            } else {
              final request = snapshot.data!;
              print(request.techician_notes);
              print(request.media);
              Color color = Colors.yellow;
              if(request.status == 'complete') {
                color = Colors.green;
              } else if(request.status == 'on-going') {
                color = Colors.orangeAccent;
              }
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RequestDetailRow(
                            title: 'Request ID:',
                            valueWidget: Container(
                              child: Text(
                                request.id.toString(),
                                style: TextStyle(
                                  color: Colors.black ,
                                ),
                              ),
                            ),
                          ),
                          RequestDetailRow(
                            title: 'Status:',
                            valueWidget: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                request.status,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text('Building Name: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 5.0),
                          Text(request.building_name),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text('Unit No.', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 5.0),
                          Text(request.unit_no),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text('Emergency.', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 5.0),
                          Text(request.emergency.toString()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Issue:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(request.description),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text('Date Requested:', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 5.0),
                          Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(request.date))),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const Text('Time Slots:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4.0),
                      Text(request.time_slot),
                      Text(request.time_slot1),
                      Text(request.time_slot2),
                      const SizedBox(height: 16),
                      Text('Technician Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(request.techician_notes.toString()),
                      Text('Remarks:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(request.request_remarks ?? 'no remarks'),
                      const SizedBox(height: 16),
                      const Text('Attachment(s)', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          request.media != null && request.media!.isEmpty
                          ? Center(child: Text('No Attachment available'))
                          : Container(
                            height: 250,
                            child: PhotoViewGallery.builder(
                              itemCount: request.media!.length,
                              builder: (context, index) {
                                final attachment = request.media![index];
                                return PhotoViewGalleryPageOptions(
                                  imageProvider: NetworkImage(request.media![index]),
                                  initialScale: PhotoViewComputedScale.contained,
                                  minScale: PhotoViewComputedScale.contained,
                                  maxScale: PhotoViewComputedScale.covered * 2,
                                );
                              },
                              scrollPhysics: BouncingScrollPhysics(),
                              backgroundDecoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              loadingBuilder: (context, progress) => Center(
                                child: CircularProgressIndicator(
                                  value: progress == null
                                      ? null
                                      : progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children:[
                            user_type == 'tenant' ?
                                request.status != 'complete' ?
                                Container(
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
                                    width: 140.0,
                                child: ElevatedButton(
                                  onPressed: () => _showMarkAsCompleteDialog(context),
                                  child: Text(
                                    'Mark Complete' ,
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 236, 236, 236),
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14.0), backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    elevation: 10,
                                    shadowColor: Colors.black12,
                                  ),
                                )
                                )
                                : SizedBox(width: 1)
                             :
                            Container(
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
                              width: 140.0,
                              child:
                              ElevatedButton(
                                onPressed: () => _showAddNotesDialog(context),
                                child: Text(
                                  'Add Notes' ,
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 236, 236, 236),
                                    fontSize: 14.0,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14.0), backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  elevation: 10,
                                  shadowColor: Colors.black12,
                                ),
                              ),
                            ),
                          SizedBox(width: 5),
                            request.status != 'complete' && user_type == 'tenant' ?
                            Container(
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
                                width: 140.0,
                                child: ElevatedButton(
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditServiceRequestScreen(apiService: widget.apiService, requestId: request.id)),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14.0), backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                elevation: 10,
                                shadowColor: Colors.black12,
                              ),
                              child: Text(
                                'Edit Request' ,
                                style: TextStyle(
                                  color: Color.fromARGB(255, 236, 236, 236),
                                  fontSize: 14.0,
                                ),
                              ),
                            )
                            )
                                : SizedBox(width: 1)
                        ],
                      ),

                    ],
                  ),
                ),
              );
            }
        }
      ),



    );
  }


  void _showMarkAsCompleteDialog(BuildContext context) {
    final TextEditingController _detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Mark as Complete'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  maxLines: 4,
                  controller: _detailsController,
                  decoration: InputDecoration(hintText: 'Enter details'),
                ),
                // Container(
                //   height: 200,
                //  child:                 Column(
                //    children: [
                //      Expanded(
                //        child: Padding(
                //          padding: const EdgeInsets.all(8.0),
                //          child: Signature(
                //            controller: _signatureController,
                //            height: 300,
                //            backgroundColor: Colors.white,
                //          ),
                //        ),
                //      ),
                //      Row(
                //        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //        children: [
                //          ElevatedButton(
                //            onPressed: () {
                //              _signatureController.clear();
                //            },
                //            child: Text('Clear'),
                //          ),
                //          ElevatedButton(
                //            onPressed: () async {
                //              await _saveSignature();
                //            },
                //            child: Text('Save'),
                //          ),
                //        ],
                //      ),
                //      if (_signatureFile != null)
                //        Padding(
                //          padding: const EdgeInsets.all(8.0),
                //          child: Image.file(_signatureFile!),
                //        ),
                //    ],
                //  ),
                // )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                  var details = _detailsController.text ?? '';
                  await _submitMarkAsComplete(details, widget.requestId);
                  Navigator.of(context).pop();
                  _refreshPage();

              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }


  void _showAddNotesDialog(BuildContext context) {
    final TextEditingController _notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Notes'),
          content: SingleChildScrollView(
            child: TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(hintText: 'Enter notes'),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                var notes = _notesController.text;
                print(notes);
                if (notes.isNotEmpty) {
                  await _submitAddNoted(notes, widget.requestId);
                  Navigator.of(context).pop();
                  _refreshPage();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Notes cannot be empty')),
                  );
                }

              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitMarkAsComplete(String details, int id) async {

    print('https://admin.deltalinefm.com/api/service-requests/$id/updates');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print(token);
    print(details);
    print(id);
    final response = await http.put(
      Uri.parse('https://admin.deltalinefm.com/api/service-requests/$id/updates'),
      headers: {
        'Authorization': 'Bearer $token' ,
        'Content-Type': 'application/json'
      },
      body: json.encode({
        'request_remarks': details,
        'status': 'complete'
      }),
    );

  }

  Future<void> _submitAddNoted(String details, int id) async {

    print('https://admin.deltalinefm.com/api/service-requests/$id/updates');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print(token);
    final response = await http.put(
      Uri.parse('https://admin.deltalinefm.com/api/service-requests/$id/updates'),
      headers: {
        'Authorization': 'Bearer $token' ,
        'Content-Type': 'application/json'
      },
      body: json.encode({
        'technician_comment': details,
      }),
    );
    
    print(json.decode(response.body));
  }

  void _refreshPage() {
    setState(() {
      setState(() {
        _isLoading = true;
      });
      _loadData();
    });
  }

}

class RequestDetailRow extends StatelessWidget {
  final String title;
  final String value;
  final Widget valueWidget;

  const RequestDetailRow({super.key, 
    required this.title,
    this.value = '',
    this.valueWidget = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        valueWidget != const SizedBox.shrink()
            ? valueWidget
            : Text(value),
      ],
    );
  }
}

class AttachmentImage extends StatelessWidget {
  final String imagePath;

  const AttachmentImage(this.imagePath, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        height: 100,
      ),
    );
  }
}

class ImageCarouselScreen extends StatelessWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const ImageCarouselScreen({super.key, 
    required this.imagePaths,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: AssetImage(imagePaths[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        itemCount: imagePaths.length,
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}