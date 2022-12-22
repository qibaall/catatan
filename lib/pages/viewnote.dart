import 'package:catatan/pages/addnote.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewNote extends StatefulWidget {
  final String documentId;

  const ViewNote({super.key, required this.documentId});

  @override
  State<ViewNote> createState() => _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  var titleController = TextEditingController();

  final descriptionController = TextEditingController();
  bool _isDeleting = false;
  bool update = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: update
          ? FloatingActionButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  setState(() {
                    update = true;
                  });
                  await FirebaseFirestore.instance
                      .collection('notes')
                      .doc(widget.documentId)
                      .update({
                    'title': titleController.text,
                    'description': descriptionController.text,
                  }).whenComplete(() => Navigator.pop(context));
                }
              },
              child: const Icon(
                Icons.save_outlined,
                color: Colors.black,
              ),
              backgroundColor: Colors.yellow,
            )
          : null,
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  update = !update;
                });
              },
              icon: const Icon(Icons.edit)),
          IconButton(
              onPressed: (() async {
                setState(() {
                  _isDeleting = true;
                });
                await FirebaseFirestore.instance
                    .collection('notes')
                    .doc(widget.documentId)
                    .delete()
                    .whenComplete(() => Navigator.pop(context));
              }),
              icon: _isDeleting
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : const Icon(Icons.delete_outline_outlined)),
        ],
        backgroundColor: Colors.black,
      ),
      body: Container(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notes')
              .doc(widget.documentId)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading');
            }
            final doc = snapshot.data;
            DateTime date = (doc!['created'] as Timestamp).toDate();
            String formatted = DateFormat('MMMM dd, yyyy').format(date);
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: titleController,
                      enabled: update,
                      decoration: const InputDecoration.collapsed(
                          hintText: 'Title',
                          hintStyle: TextStyle(color: Colors.grey)),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                    ),
                    Text(
                      formatted,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: descriptionController,
                      enabled: update,
                      decoration: const InputDecoration.collapsed(
                          hintText: 'Description',
                          hintStyle: TextStyle(color: Colors.grey)),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
