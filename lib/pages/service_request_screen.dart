
import 'package:deltaline/pages/home_screen.dart';
import 'package:deltaline/pages/show_service_request.dart';
import 'package:flutter/material.dart';
import 'package:deltaline/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> statuses = <String>['pending', 'on-going', 'complete'];

class ServiceRequestScreen extends StatefulWidget {
  final ApiService apiService;

  const ServiceRequestScreen({required this.apiService, Key? key}) : super(key: key);
  @override
  _ServiceRequestScreenState createState() =>
      _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {

  String? role ="";
  List<ServiceRequest>? _serviceRequests;
  bool _isLoading = false;
  bool filterSelected = true;
  String dropdownValue = "";

  void initState() {
    super.initState();
    _fetchServiceRequests();
  }

  Future<void> _fetchServiceRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? "Role";
    });

    setState(() {
      _isLoading = true;
    });

    try {

      final requests = await widget.apiService.fetchServiceRequests();

      setState(() {
        _serviceRequests = requests;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load service requests: $e')),
      );
    }
  }

  Future<void> _navigateToServiceRequest(BuildContext context, ApiService apiService, int requestId) async {
    bool shouldReload = await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ShowServiceRequest(
          apiService: apiService,
          requestId: requestId),
      ),
    );

    if (shouldReload == true) {
      _fetchServiceRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'My Requests',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Define your action here
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(apiService: widget.apiService))
            );
          },
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.filter_list_alt, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openEndDrawer(); // Open the right drawer
              },
            ),
          ),
        ],
      ),
      endDrawer: _buildEndDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _serviceRequests == null
            ? Center(child: Text('No service requests found.'))
            :  Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (filterSelected && dropdownValue != "") _buildFilter(dropdownValue),
            Expanded(child: _buildRequestList()),
          ],
        ),
      ),
    );
  }

  Widget _buildEndDrawer() {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          const SizedBox(height: 40.0),
          const Text(
            "Filter By:" ,
            style: TextStyle(
              color: Colors.black ,
              fontSize: 18.0 ,
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text("Status: ", style: TextStyle(
                  letterSpacing: 0.5,
                  color: Colors.black87,
                  fontFamily: "Sans",
                  // fontWeight: FontWeight.w600,
                  fontSize: 14.0,),
                  overflow: TextOverflow.fade,),
              ),
              DropdownMenu<String>(
                initialSelection: dropdownValue == ""? "Pending" : dropdownValue,
                onSelected: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    dropdownValue = value!;
                  });

                  _buildFilter(dropdownValue);
                  filterSelected = true;
                  Navigator.pop(context);
                },
                dropdownMenuEntries: statuses.map<DropdownMenuEntry<String>>((String value) {
                  return DropdownMenuEntry<String>(value: value, label: value);
                }).toList(),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(dropDownValue) {

    return
      _serviceRequests!.length>0?
        Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Text(
            'Selected filter:',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8.0),
          Chip(
            label: Text('$dropDownValue'),
            deleteIcon: const Icon(Icons.clear),
            onDeleted: () {
              setState(() {
                filterSelected = false;
                dropdownValue = "";
              });
            },
          ),
        ],
      ),
    )
          :
        Text(
              'No Request Found'
        );
  }

  Widget _buildRequestList() {
    return ListView.builder(
      itemCount:   _serviceRequests!.length,
      itemBuilder: (context, index) {
        final request = _serviceRequests![index];
        return _buildRequestItem(request);
        // ListTile(
        //   title: Text(request.status),
        //   subtitle: Text(request.description),
        // );

      },
    );
  }

  Widget _buildRequestItem(request) {
    Color color = Colors.yellow;
    if(request.status == 'complete') {
      color = Colors.green;
    } else if(request.status == 'on-going') {
      color = Colors.orangeAccent;
    }
    if(request.status != dropdownValue && dropdownValue != "") { return const SizedBox(); }

    return
      GestureDetector(
        onTap: () {
          _navigateToServiceRequest(context, widget.apiService, request.id);
        },
        child: Container(
          child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Request ID: ',
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: request.id.toString() ,
                            style: const TextStyle(
                                color: Colors.black, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(
                        request.status!,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: color,
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Issue:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4.0),
                Text(request.description!),
                const SizedBox(height: 8.0),
                Text(
                  'Date Requested: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(request.date))}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        )
        )
      );
  }
}