import 'package:catatan/pages/addnote.dart';
import 'package:catatan/pages/viewnote.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    ;
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: ((context) => const AddNote())));
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
        backgroundColor: Colors.yellow,
      ),
      appBar: AppBar(
        title: Text('Notes App'),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
        backgroundColor: Color.fromARGB(255, 216, 199, 45),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('notes').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading');
            }
            final docs = snapshot.data?.docs;
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, index) {
                DateTime date = (docs![index]['created'] as Timestamp).toDate();

                String formatted = DateFormat('MMMM dd, yyyy').format(date);

                return InkWell(
                  onTap: (() {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: ((context) => ViewNote(
                              documentId: docs[index].id,
                              //documentId: documentId,
                            )),
                      ),
                    );
                  }),
                  child: SizedBox(
                    width: 100,
                    height: 150,
                    child: Card(
                      color: Colors.grey.shade900,
                      child: ListTile(
                        title: Text(
                          docs[index]['title'],
                          style: const TextStyle(
                              color: Colors.yellow, fontSize: 24),
                        ),
                        subtitle: Text(
                          docs[index]['description'],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                        trailing: Text(
                          formatted,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
