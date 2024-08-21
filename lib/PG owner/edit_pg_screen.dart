import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../components/resuable.dart';

class EditPGScreen extends StatefulWidget {
  final String pgId;

  EditPGScreen({required this.pgId});

  @override
  _EditPGScreenState createState() => _EditPGScreenState();
}

class _EditPGScreenState extends State<EditPGScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _billamtcontroller = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _otherServiceController = TextEditingController();
  final _picker = ImagePicker();
  List<Map<String, dynamic>> sharingOptions=[];
  String _gender = 'Both';
  String _elecbill = 'Not Included';
  String _cctv = 'Not Available';
  String _wifi = 'Not Available';
  String _parking = 'Not Available';
  String _laundary = 'Not Available';
  String _profession = 'Student';
  List<String> _imageUrls = [];
  List<File> _newImages = [];
  List<String> _selectedFooding = [];
  List<String> _selectedFoodType = [];
  List<String> _selectedAC = [];

  @override
  void initState() {
    super.initState();
    _loadPGDetails();
  }
  Widget _buildCheckboxList(
      String title, List<String> options, List<String> selectedOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 2),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: options.length,
          itemBuilder: (context, index) {
            String option = options[index];
            return Container(
              margin: EdgeInsets.only(bottom: 2.0),
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(option, style: TextStyle(fontSize: 16)),
                value: selectedOptions.contains(option),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedOptions.add(option);
                    } else {
                      selectedOptions.remove(option);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            );
          },
        ),
        SizedBox(height: 2),
      ],
    );
  }

  Future<void> _loadPGDetails() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('pgs')
        .doc(widget.pgId)
        .get();
    setState(() {
      _nameController.text = doc['name'];
      _locationController.text = doc['location'];
      _landmarkController.text = doc['landmark'];
      _timeController.text = doc['time'];
      _summaryController.text = doc['summary'];
      _otherServiceController.text = doc['otherService'];
      _billamtcontroller.text = doc['billAmount'];
      _gender = doc['gender'];
      _elecbill = doc['elecbill'];
      _cctv = doc['cctv'];
      sharingOptions = List<Map<String, dynamic>>.from(doc['sharing_details']);
      _selectedFooding=List<String>.from(doc['fooding']);
      _selectedAC=List<String>.from(doc['ac']);
      _selectedFoodType=List<String>.from(doc['foodtype']);
      _wifi = doc['wifi'];
      _parking = doc['parking'];
      _laundary = doc['laundary'];
      _profession = doc['profession'];
      _imageUrls = List<String>.from(doc['images']);
    });
  }

  Future<String> _uploadSingleImage(File image) async {
    String fileName =
        'images/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = storageRef.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _replaceImage(int index) async {
    final picker = ImagePicker();
    final XFile? newImage = await picker.pickImage(source: ImageSource.gallery);

    if (newImage != null) {
      File newImageFile = File(newImage.path);
      try {
        // Upload the new image
        String newImageUrl = await _uploadSingleImage(newImageFile);

        // Replace the old image URL with the new one
        setState(() {
          _imageUrls[index] = newImageUrl;
        });

        // Update Firestore
        await FirebaseFirestore.instance
            .collection('pgs')
            .doc(widget.pgId)
            .update({'images': _imageUrls});
      } catch (e) {
        print('Error replacing image: $e');
      }
    }
  }

  Future<void> _updatePG() async {
    try {
      await FirebaseFirestore.instance
          .collection('pgs')
          .doc(widget.pgId)
          .update({
        'images': _imageUrls,
        'name': _nameController.text.trim(),
        'landmark': _landmarkController.text.trim(),
        'time': _timeController.text.trim(),
        'otherService': _otherServiceController.text.trim(),
        'location': _locationController.text.trim(),
        'summary': _summaryController.text.trim(),
        'gender': _gender,
        'elecbill': _elecbill,
        'billAmount':
        _elecbill == 'Included' ? _billamtcontroller.text.trim() : null,
        'cctv': _cctv,
        'wifi': _wifi,
        'ac': _selectedAC,
        'foodtype': _selectedFoodType,
        'fooding': _selectedFooding,
        'parking': _parking,
        'laundary': _laundary,
        'profession': _profession,
      });
      Navigator.pop(context);
    } catch (e) {
      print('Failed to update PG: $e');
    }
  }
  Future<void> uploadMultipleImage(int index) async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage();

    if (pickedImages != null) {
      List<String> imageUrls = [];

      // Loop through each selected image
      for (var image in pickedImages) {
        // Create a reference to the Firebase Storage location
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('images/${DateTime.now().millisecondsSinceEpoch}_${image.name}');

        // Upload the file to Firebase Storage
        UploadTask uploadTask = storageReference.putFile(File(image.path));

        // Wait for the upload to complete
        TaskSnapshot taskSnapshot = await uploadTask;

        // Get the download URL of the uploaded image
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        // Add the download URL to the list
        imageUrls.add(imageUrl);
      }

      // Update the state with the URLs
      setState(() {
        sharingOptions[index]['images'] = imageUrls;
      });

      // Optionally: save imageUrls to Firestore
      // await FirebaseFirestore.instance
      //     .collection('your_collection_name')
      //     .doc('your_document_id')
      //     .update({
      //   'sharingOptions.$index.images': imageUrls,
      // });
    }
  }
  Future<void> _deleteImage(String imageUrl) async {
    setState(() {
      _imageUrls.remove(imageUrl);
    });
    try {
      Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      print('Failed to delete image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit PG',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
        ),
        backgroundColor: Color(0xff0094FF),
      ),
      backgroundColor: Color(0xffF7F7F7),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /*SizedBox(height: 20,),
              Uploadimage(context, "Pick New Images", uploadMultipleImages),*/
              SizedBox(height: 10),
              Text('Current Thumbnail:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              //
              Wrap(
                children: _imageUrls.map((imageUrl) {
                  int index = _imageUrls.indexOf(imageUrl);
                  return Stack(
                    children: [
                      Image.network(
                        imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Image.asset(
                            'assets/images/manage_pg.jpg',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          );
                        },
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                    null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ??
                                        1)
                                    : null,
                              ),
                            );
                          }
                        },
                      ),
                      /*Positioned(
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteImage(imageUrl),
                        ),
                      ),*/
                      Positioned(
                        left: 0,
                        child: IconButton(
                          icon: Icon(Icons.edit_rounded, color: Colors.blue),
                          onPressed: () => _replaceImage(index),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              SizedBox(
                height: 20,
              ),
              DataTextField(
                  'PG Name', Icons.home_outlined, false, _nameController),
              SizedBox(
                height: 10,
              ),
              DataTextField('Location', Icons.location_city_outlined, false,
                  _locationController),
              SizedBox(
                height: 10,
              ),
              DataTextField('Landmark', Icons.pin_drop_outlined, false,
                  _landmarkController),
              SizedBox(
                height: 10,
              ),
              DataTextField(
                  'Time', Icons.timelapse_outlined, false, _timeController),
              SizedBox(
                height: 10,
              ),
              DataTextField('Summary', Icons.summarize_outlined, false,
                  _summaryController),
              SizedBox(
                height: 10,
              ),
              DataTextField(
                  'Other Services',
                  Icons.home_repair_service_outlined,
                  false,
                  _otherServiceController),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Gender',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              DropdownButtonFormField(
                value: _gender,
                items: <String>['Boys', 'Girls', 'Both']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue!;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Gender",
                  filled: true,
                  fillColor: Color(0xffF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sharing Options',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                ...sharingOptions.map((option) {
                  int index = sharingOptions.indexOf(option);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        title: Text(
                          option['title'],
                          style: TextStyle(
                            /*fontWeight: FontWeight.bold,*/
                            fontSize: 18,
                          ),
                        ),
                        value: option['selected'],
                        onChanged: (bool? value) {
                          setState(() {
                            option['selected'] = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (option['selected'])
                        Padding(
                          padding:
                          const EdgeInsets.only(left: 40.0, bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Number of Vacant Beds',
                                      labelStyle: TextStyle(fontSize: 16),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            int currentValue = int.tryParse(
                                                option['vacantBeds'] ??
                                                    '0') ??
                                                0;
                                            option['vacantBeds'] =
                                                (currentValue + 1).toString();
                                          });
                                        },
                                      ),
                                      prefixIcon: IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () {
                                          setState(() {
                                            int currentValue = int.tryParse(
                                                option['vacantBeds'] ??
                                                    '0') ??
                                                0;
                                            if (currentValue > 0) {
                                              option['vacantBeds'] =
                                                  (currentValue - 1).toString();
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    controller: TextEditingController(
                                        text: option['vacantBeds']),
                                    onChanged: (value) {
                                      setState(() {
                                        option['vacantBeds'] = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Price',
                                  labelStyle: TextStyle(fontSize: 16),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                controller: TextEditingController(
                                    text: option['price'] ?? ''),
                                onChanged: (value) {
                                  setState(() {
                                    option['price'] = value;
                                  });
                                },
                              ),
                              SizedBox(height: 3),

                              // Text(
                              //   'Furnishing',
                              //   style: TextStyle(
                              //     fontWeight: FontWeight.bold,
                              //     fontSize: 18,
                              //   ),
                              // ),
                              Column(
                                children: [
                                  RadioListTile<String>(
                                    title: Text('Unfurnished'),
                                    value: 'Unfurnished',
                                    groupValue: option['furnishing'],
                                    onChanged: (String? value) {
                                      setState(() {
                                        option['furnishing'] = value;
                                      });
                                    },
                                  ),
                                  RadioListTile<String>(
                                    title: Text('Semi-Furnished'),
                                    value: 'Semi-Furnished',
                                    groupValue: option['furnishing'],
                                    onChanged: (String? value) {
                                      setState(() {
                                        option['furnishing'] = value;
                                      });
                                    },
                                  ),
                                  RadioListTile<String>(
                                    title: Text('Furnished'),
                                    value: 'Furnished',
                                    groupValue: option['furnishing'],
                                    onChanged: (String? value) {
                                      setState(() {
                                        option['furnishing'] = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 3),
                              ElevatedButton.icon(
                                onPressed: () => uploadMultipleImage(index),
                                icon: Icon(
                                  Icons.upload_file,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Upload Images',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff0094FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                              ),
                              /*SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _pickThumbnailImage(index),
                                icon: Icon(Icons.upload),
                                label: Text('Upload Thumbnail Image'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff0094FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                              ),*/
                            ],
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ],
              SizedBox(height: 10),
              _buildCheckboxList(
                  'Fooding', ['Included', 'Not Included'], _selectedFooding),
              _buildCheckboxList(
                  'Food Type', ['Veg', 'Non-Veg'], _selectedFoodType),
              _buildCheckboxList(
                  'AC', ['Available', 'Not Available'], _selectedAC),
              SizedBox(height: 10),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CCTV',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              DropdownButtonFormField(
                value: _cctv,
                onChanged: (String? newValue) {
                  setState(() {
                    _cctv = newValue!;
                  });
                },
                items: <String>['Available', 'Not Available']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  hintText: "CCTV",
                  filled: true,
                  fillColor: Color(0xffF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Wifi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              DropdownButtonFormField(
                value: _wifi,
                onChanged: (String? newValue) {
                  setState(() {
                    _wifi = newValue!;
                  });
                },
                items: <String>['Available', 'Not Available']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  hintText: "WIFI",
                  filled: true,
                  fillColor: Color(0xffF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Parking',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              DropdownButtonFormField(
                value: _parking,
                onChanged: (String? newValue) {
                  setState(() {
                    _parking = newValue!;
                  });
                },
                items: <String>['Available', 'Not Available']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  hintText: "Parking",
                  filled: true,
                  fillColor: Color(0xffF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Laundary',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              DropdownButtonFormField(
                value: _laundary,
                onChanged: (String? newValue) {
                  setState(() {
                    _laundary = newValue!;
                  });
                },
                items: <String>['Available', 'Not Available']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  hintText: "Laundary",
                  filled: true,
                  fillColor: Color(0xffF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Electricity Bill',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              // DropdownButtonFormField(value: _elecbill,
              //   onChanged: (String? newValue) {
              //     setState(() {
              //       _elecbill = newValue!;
              //     });
              //   },
              //   items: <String>['Included', 'Not Included']
              //       .map<DropdownMenuItem<String>>((String value) {
              //     return DropdownMenuItem<String>(
              //       value: value,
              //       child: Text(value,),
              //     );
              //   }).toList(), decoration: InputDecoration(
              //     hintText: "Electricity Bill",
              //     filled: true,
              //     fillColor: Color(0xffF7F7F7),
              //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),),
              //   ),),
              ListTile(
                  title: const Text('Not Included'),
                  leading: Radio<String>(
                    value: 'Not Included',
                    groupValue: _elecbill,
                    onChanged: (String? value) {
                      setState(() {
                        _elecbill = value!;
                      });
                    },
                  )),
              ListTile(
                  title: const Text('Included'),
                  leading: Radio<String>(
                    value: 'Included',
                    groupValue: _elecbill,
                    onChanged: (String? value) {
                      setState(() {
                        _elecbill = value!;
                      });
                    },
                  )),
              if (_elecbill == 'Not Included')
                DataTextField(
                  _billamtcontroller.text,
                  Icons.money,
                  false,
                  _billamtcontroller,
                ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profession',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              DropdownButtonFormField(
                value: _profession,
                onChanged: (String? newValue) {
                  setState(() {
                    _profession = newValue!;
                  });
                },
                items: <String>['Student', 'Professional', 'Both']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  hintText: "Profession",
                  filled: true,
                  fillColor: Color(0xffF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: _updatePG,
                child: Text('Update PG'),
                style: ButtonStyle(
                    foregroundColor:
                    MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.white;
                      }
                      return Color(0xff0094FF);
                    }),
                    backgroundColor:
                    MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Color(0xff0094FF);
                      }
                      return Colors.white;
                    }),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: Color(0xff0094FF)),
                        ))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
