import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:heartbeat/models/dummy_lists.dart';
// import 'package:heartbeat/models/prescriptions.dart';

class PatientView extends StatefulWidget {
  // const PatientView({ Key? key }) : super(key: key);

  static const String routeName = 'patientView';

  @override
  State<PatientView> createState() => _PatientViewState();
}

class _PatientViewState extends State<PatientView> {
  var isLabtest = false;
  final List<String> tempMedicinesList = [];
  final List<String> tempTestsList = [];

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!isLabtest)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    elevation: 200,
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(builder: (BuildContext context,
                          StateSetter setState /*You can rename this!*/) {
                        return SingleChildScrollView(
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            // mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: DropdownSearch(
                                  hint: 'medicines',
                                  showSearchBox: true,
                                  items: DummyLists.medicines,
                                  onChanged: (value) {
                                    setState(() {
                                      tempMedicinesList.add(value.toString());
                                    });
                                    print(tempMedicinesList.toString());
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...tempMedicinesList.map((e) {
                                      return Text(e);
                                    }),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: DropdownSearch(
                                  hint: 'tests',
                                  showSearchBox: true,
                                  items: DummyLists.tests,
                                  onChanged: (value) {
                                    setState(() {
                                      tempTestsList.add(value.toString());
                                    });
                                    print(tempTestsList.toString());
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...tempTestsList.map((e) {
                                      return Text(e);
                                    }),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          DummyLists.newPrescList.add(
                                            Prescription(
                                              tempMedicinesList,
                                              tempTestsList,
                                              DateTime.now(),
                                            ),
                                          );
                                          print(DummyLists.newPrescList
                                              .toString());
                                          tempMedicinesList.clear();
                                          tempTestsList.clear();
                                          Navigator.pop(context);
                                        },
                                        child: Text('Prescribe')),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      });
                    },
                  );
                },
                child: Icon(Icons.add),
              ),
            ),
          GestureDetector(
            onTap: () {
              setState(() {
                isLabtest = !isLabtest;
              });
            },
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  color: Colors.blue,
                ),
                height: 90,
                width: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isLabtest ? Icons.text_snippet : Icons.biotech,
                      size: 60,
                      color: Colors.white,
                    ),
                    Text(
                      isLabtest ? 'Prescriptions' : 'Lab results',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                )
                // FittedBox(
                //   child: FloatingActionButton(
                //     onPressed: () {
                //       setState(() {
                //         isLabtest = !isLabtest;
                //       });
                //     },
                //     child: Center(
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.center,
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Icon(isLabtest ? Icons.text_snippet : Icons.biotech),
                //           Text(
                //             isLabtest ? 'Prescriptions' : 'Lab results',
                //             style: TextStyle(fontSize: 6),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            snap: true,
            floating: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              // centerTitle: true,
              background: Stack(
                alignment: Alignment.topRight,
                children: [
                  // Image.asset(
                  //   'assets/images/wallpaper.jpg',
                  //   fit: BoxFit.fitHeight,
                  // ),
                  Container(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 70, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'gender',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'age',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              title: Text(arg),
            ),
          ),
          SliverFillRemaining(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    isLabtest ? 'Labtests' : 'Previous Prescriptions',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Divider(),
                if (!isLabtest)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: DummyLists.prescriptionsList.length,
                    itemBuilder: (ctx, index) {
                      return Column(
                        children: [
                          ListTile(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      backgroundColor:
                                          Colors.black.withOpacity(0),
                                      child: Card(
                                        child: Container(
                                          child: Wrap(
                                            alignment:
                                                WrapAlignment.spaceAround,
                                            // mainAxisAlignment:
                                            //     MainAxisAlignment.spaceAround,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 20, 10, 50),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Text('date'),
                                                    Text('docName'),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 90, 10, 30),
                                                child: Text(DummyLists
                                                    .prescriptionsList[index]
                                                        ['contents']
                                                    .toString()),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            },
                            leading: Text(DummyLists.prescriptionsList[index]
                                ['PrescriptionId']!),
                            subtitle: Text(DummyLists.prescriptionsList[index]
                                ['PrescriptionDate']!),
                            trailing: Text(DummyLists.prescriptionsList[index]
                                ['contents']!),
                          ),
                          const Divider(
                            thickness: 2,
                          ),
                        ],
                      );
                    },
                  ),
                if (isLabtest)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: DummyLists.labtestReportsList.length,
                    itemBuilder: (ctx, index) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(DummyLists.labtestReportsList[index]
                                ['content']!),
                            subtitle: Text(
                                DummyLists.labtestReportsList[index]['date']!),
                            // trailing: Text(DummyLists
                            //     .prescriptionsList[index]['contents']!),
                          ),
                          const Divider(
                            thickness: 2,
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}