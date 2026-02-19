import 'package:flutter/material.dart';

class ComplaintPage extends StatefulWidget {
  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  String _complaintText = '';
  String _selectedCategory = 'Plumbing';
  bool _imageAttached = false;

  // Complaint categories
  final List<String> _categories = [
    'Plumbing',
    'Electricity',
    'Maintenance',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Complaint')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Category:', style: TextStyle(fontSize: 16)),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              Text('Your Complaint:', style: TextStyle(fontSize: 16)),
              TextFormField(
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Type your complaint here',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a complaint';
                  }
                  return null;
                },
                onSaved: (value) {
                  _complaintText = value!;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.image),
                    label: Text(_imageAttached ? 'Image Attached' : 'Upload Image'),
                    onPressed: () {
                      // Fake image picker
                      setState(() {
                        _imageAttached = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Image upload coming soon!')),
                      );
                    },
                  ),
                  SizedBox(width: 10),
                  Text(_imageAttached ? '✔' : ''),
                ],
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  child: Text('Submit Complaint'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Show popup
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Success'),
                          content: Text('Your complaint has been submitted!'),
                          actions: [
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.pop(context);
                                // Reset form
                                _formKey.currentState!.reset();
                                setState(() {
                                  _imageAttached = false;
                                  _selectedCategory = 'Plumbing';
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
