import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minimalsocial/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// firestore instance
  final FireStoreServices fireStoreServices = FireStoreServices();

// textcontroller to get the text from the dialog box
  final TextEditingController textController = TextEditingController();

// open a dialog vox to add a new note
  // void openNoteDialog({String? docId}) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       content: TextField(
  //         controller: textController,
  //       ),
  //       actions: [
  //         //add btn
  //         ElevatedButton(
  //           onPressed: () {
  //             // add new notes
  //             if (docId == null) {
  //               fireStoreServices.addNotes(textController.text);
  //             } else {
  //               fireStoreServices.updateNotes(docId, textController.text);
  //             }

  //             // clear the textfield
  //             textController.clear();

  //             // close the dialog box
  //             Navigator.pop(context);
  //           },
  //           child: const Text('Add'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  void openNoteDialog({String? docId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: 'Enter your note',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // add new notes
              if (docId == null) {
                fireStoreServices.addNotes(textController.text);
              } else {
                fireStoreServices.updateNotes(docId, textController.text);
              }

              // clear the textfield
              textController.clear();

              // close the dialog box
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: openNoteDialog,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: fireStoreServices.getNotesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // If data is still loading, return a loading indicator
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // If there's an error, display an error message
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              // If there's no data, display a message indicating no notes
              return const Center(
                  child: Text(
                'No notes...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ));
            } else {
              // If there is data, render the notes
              List notesList = snapshot.data!.docs;
              return ListView.separated(
                itemCount: notesList.length,
                separatorBuilder: (BuildContext context, int index) {
                  // Add padding between items
                  return const SizedBox(height: 16); // Adjust height as needed
                },
                itemBuilder: (context, index) {
                  DocumentSnapshot document = notesList[index];
                  String docId = document.id;
                  // Ensure the 'note' field is not null before accessing it
                  Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
                  if (data != null && data.containsKey('note')) {
                    String noteText = data['note'];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ListTile(
                          title: Text(noteText),
                          tileColor: Colors.grey[400],
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // update button
                              IconButton(
                                icon: const Icon(Icons.settings),
                                onPressed: () => openNoteDialog(docId: docId),
                              ),
                              // delete button
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => fireStoreServices.deleteNotes(docId),
                              ),
                            ],
                          )),
                    );
                  } else {
                    // Handle the case where 'note' field is missing or null
                    return const ListTile(
                      title: Text('Missing or empty note'),
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}
