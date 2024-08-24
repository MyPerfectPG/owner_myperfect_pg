import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../components/resuable.dart';

class AddPGScreen extends StatefulWidget {
  @override
  _AddPGScreenState createState() => _AddPGScreenState();
}

class _AddPGScreenState extends State<AddPGScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _billamtcontroller = TextEditingController();
  final TextEditingController _otherServiceController = TextEditingController();

  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  String _gender = 'Both';
  /*String _fooding = 'Not Included';*/
  String _elecbill = 'Included';
  /*String _foodtype = 'Both';
  String _furnishing = 'Unfurnished';
  String _ac = 'Not Available';*/
  String _cctv = 'Not Available';
  String _wifi = 'Not Available';
  String _parking = 'Not Available';
  String _laundary = 'Not Available';
  String _profession = 'Student';
  List<String> _images = [];
  List<String> thumbnailimagesUrls=[];
  List<String> _selectedFooding = [];
  List<String> _selectedFoodType = [];
  List<String> _selectedAC = [];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(pickedFile.path);
      });
    }
  }

  List<String> imageUrls = [];
  List<String> imageUrls1 = [];
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

  Future<void> _pickThumbnailImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      try {
        String fileName =
            'thumbnails/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
        TaskSnapshot snapshot =
        await FirebaseStorage.instance.ref(fileName).putFile(imageFile);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          sharingOptions[index]['thumbnailUrl'] = downloadUrl;
        });
      } catch (e) {
        print('Error uploading thumbnail image: $e');
      }
    }
  }

  //List<String> imageUrls = [];

  Future<List<String>> uploadMultipleImages() async {
    final picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images == null || images.isEmpty) {
      print('No images selected.');
      // return;
    }



    for (XFile image in images!) {
      File imageFile = File(image.path);

      try {
        // Create a unique file name for each image
        String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}_${image.name}';

        // Upload the image to Firebase Storage
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref(fileName)
            .putFile(imageFile);

        // Get the download URL of the uploaded image
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Store the download URL in a list
        imageUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    return imageUrls;
    // Store the list of image URLs in Firestore
    await FirebaseFirestore.instance.collection('pg_owners').add({
      'imageUrls': imageUrls,
      'timestamp': FieldValue.serverTimestamp(),
    });

    print('Images uploaded successfully!');
  }

  Future<List<String>> uploadSingleImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      print('No image selected.');
      return []; // Return an empty list if no image was selected
    }

    File imageFile = File(image.path);

    try {
      // Create a unique file name for the image
      String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}_${image.name}';

      // Upload the image to Firebase Storage
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref(fileName)
          .putFile(imageFile);

      // Get the download URL of the uploaded image
      String downloadUrl = await snapshot.ref.getDownloadURL();


      print('Image uploaded successfully!');
      thumbnailimagesUrls.add(downloadUrl); // Add the URL to the list
      return thumbnailimagesUrls; // Return the list of image URLs
    } catch (e) {
      print('Error uploading image: $e');
      return []; // Return an empty list in case of error
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

  /*Future<void> uploadMultipleImage(int index) async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null) {
      setState(() {
        // Add the selected images to the corresponding sharing option's images array
        sharingOptions[index]['images'] = pickedImages.map((image) => image.path).toList();
      });
    }
  }*/

  /*Future<List<String>> uploadMultipleImage(int index) async {
    final picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images == null || images.isEmpty) {
      print('No images selected.');
    }

    for (XFile image in images!) {
      File imageFile = File(image.path);

      try {
        String fileName =
            'images/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        TaskSnapshot snapshot =
        await FirebaseStorage.instance.ref(fileName).putFile(imageFile);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls1.add(downloadUrl);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    return imageUrls;
  }*/

  String? uid;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
    }
  }

  Future<void> _addPG() async {
    try {
      CollectionReference pgs = FirebaseFirestore.instance.collection('pgs');
      await pgs.add({
        'name': _nameController.text.trim(),
        'landmark': _landmarkController.text.trim(),
        'time': _timeController.text.trim(),
        'otherService': _otherServiceController.text.trim(),
        'gender': _gender,
        'fooding': _selectedFooding,
        'elecbill': _elecbill,
        'foodtype': _selectedFoodType,
        /*'furnishing': _furnishing,*/
        'billAmount':
        _elecbill == 'Not Included' ? _billamtcontroller.text.trim() : "",
        'sharing_details':sharingOptions,
        'ac': _selectedAC,
        'cctv': _cctv,
        'wifi': _wifi,
        'parking': _parking,
        'laundary': _laundary,
        'profession': _profession,
        'location': _locationController.text.trim(),
        'summary': _summaryController.text.trim(),
        /*'price': int.parse(_priceController.text.trim()),*/
        'thumbnail': thumbnailimagesUrls,
        'ownerId': uid,
      });
      Navigator.pop(context);
    } catch (e) {
      print('Failed to add PG: $e');
    }
  }

  List<Map<String, dynamic>> sharingOptions = [
    {
      'title': 'Single',
      'selected': false,
      'vacantBeds': '',
      'price': '',
      'images': []
    },
    {
      'title': 'Double',
      'selected': false,
      'vacantBeds': '',
      'price': '',
      'images': []
    },
    {
      'title': 'Triple',
      'selected': false,
      'vacantBeds': '',
      'price': '',
      'images': []
    },
  ];

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add PG',
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
              Uploadimage(context, "Upload Thumbnail \n          Image", uploadSingleImage),
              SizedBox(height: 20),
              DataTextField(
                  'PG Name', Icons.home_outlined, false, _nameController),
              SizedBox(height: 10),
              DataTextField('Location', Icons.location_city_outlined, false,
                  _locationController),
              SizedBox(height: 10),
              DataTextField('Landmark', Icons.pin_drop_outlined, false,
                  _landmarkController),
              SizedBox(height: 10),
              DataTextField(
                  'Time', Icons.timelapse_outlined, false, _timeController),
              SizedBox(height: 10),
              DataTextField('Summary', Icons.summarize_outlined, false,
                  _summaryController),
              SizedBox(height: 10),
              DataTextField(
                  'Other Services',
                  Icons.home_repair_service_outlined,
                  false,
                  _otherServiceController),
              /*SizedBox(height: 10),
              DataTextField('Price', Icons.currency_rupee_outlined, false,
                  _priceController),*/
              SizedBox(height: 10),
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
              SizedBox(height: 5,),
              DropdownButtonFormField(
                items: <String>['Boys', 'Girls', 'Both']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
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
                                icon: Icon(Icons.upload_file,color: Colors.white,),
                                label: Text('Upload Images',style: TextStyle(color: Colors.white),),
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
              SizedBox(height: 5,),
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
              SizedBox(height: 10,),
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
              SizedBox(height: 5,),
              DropdownButtonFormField(
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
              SizedBox(height: 5,),
              DropdownButtonFormField(
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
                  hintText: "Wifi",
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
              SizedBox(height: 5,),
              DropdownButtonFormField(
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
              SizedBox(height: 5,),
              DropdownButtonFormField(
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
                  'Profession',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 5,),
              DropdownButtonFormField(
                onChanged: (String? newValue) {
                  setState(() {
                    _profession = newValue!;
                  });
                },
                items: <String>['Student', 'Working Profession', 'Both']
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
                onPressed: _addPG,
                child: Text('Add PG'),
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
