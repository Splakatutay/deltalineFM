import 'package:flutter/material.dart';
import 'package:deltaline/pages/profile_screen.dart';
import 'package:deltaline/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final ApiService apiService;

  EditProfileScreen({required this.apiService});
  @override
  _EditProfileScreen createState() => _EditProfileScreen();

}

class _EditProfileScreen extends State<EditProfileScreen> {

  final TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? name = "";

  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async{
    // Simulate data loading
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? "User";
    });
  }

  void _updateProfile() async {

    if (_formKey.currentState!.validate()) {

      setState(() {
        _isLoading = true;
      });

      final result = await widget.apiService.updateProfile(
        nameController.text
      );

      setState(() {
        _isLoading = false;
      });
      print(result);
      if(result['status'] == 200)
      {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', result['name']);

        setState(() {
          name = prefs.getString('name') ?? 'User';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile Name Updated Successfully..')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileScreen(apiService: widget.apiService)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update Failed: ${result['message']}')),
        );
      }

    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Define your action here
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen(apiService: widget.apiService))
            );
          },
        ),
      ),
      body: SingleChildScrollView(
          child:
            Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(100.0),
                      bottomRight: Radius.circular(100.0)
                  ),
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.greenAccent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/avatar.png'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name!,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(40.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40.0),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Update Profile',
                          style: TextStyle(
                              fontSize: 20 ,
                              fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      const SizedBox(height: 20.0), // Adjust height as needed
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Fullname',
                          hintStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                          prefixIcon: const Icon(Icons.abc_sharp, color: Colors.black),
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
                          contentPadding: const EdgeInsets.fromLTRB(30, 5, 30, 5),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 30),
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
                          width: 140.0,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              elevation: 10,
                              shadowColor: Colors.black12,
                            ),
                            child: _isLoading
                                ? SizedBox(
                              child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color.fromARGB(255, 236, 236, 236)),
                                  )
                              ),
                              height: 15.0,
                              width: 15.0,
                            )
                                : Text(
                                'UPDATE',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 236, 236, 236),
                                  fontSize: 14.0,
                                )
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
      )

    );
  }

  Widget _buildProfileButton(IconData icon, String text) {
    return Card(
      child: ListTile(
        title: Text(text),
        trailing: Icon(icon, color: Colors.green),
        onTap: () {},
      ),
    );
  }
}