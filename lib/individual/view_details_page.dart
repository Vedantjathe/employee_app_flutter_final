import 'package:erp/custom_widgets/custom_button.dart';
import 'package:flutter/material.dart';

import '../models/ViewDetails2Model.dart';
import '../utils/util_methods.dart';

class ViewDetailsPages extends StatelessWidget {
  final String staffCode, staffName, fileName;
  final List<ExpenseItem> expenseItemList;
  final List jsonData;

  const ViewDetailsPages(
      {super.key,
      required this.staffCode,
      required this.staffName,
      required this.fileName,
      required this.expenseItemList,
      required this.jsonData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: const Center(
            child: Padding(
          padding: EdgeInsets.only(right: 40),
          child: Text(
            "Expense Amount",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Segoe',
                fontWeight: FontWeight.normal),
          ),
        )),
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xff3A9FBE),
                Color(0xff17E1DA),
              ],
              // colors: <Color> [Color.fromARGB(100, 58, 159, 190),
              //   Color.fromARGB(100, 23, 225,218),
              // ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text(
                    overflow: TextOverflow.visible,
                    "Staff Code: ",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Text(
                    staffCode,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  const Text(
                    "Staff Name: ",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Text(
                    overflow: TextOverflow.visible,
                    staffName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                      children: const [
                        TableCell(
                          child: Text(
                            "Registration\nDate",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),
                        ),
                        TableCell(
                          child: Text(
                            "Expense\nType",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                decoration: TextDecoration.none,
                                fontSize: 14),
                          ),
                        ),
                        TableCell(
                          child: Text(
                            "Center\nLocation",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                decoration: TextDecoration.none,
                                fontSize: 14),
                          ),
                        ),
                        TableCell(
                          child: Text(
                            "Expense\nAmount",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                decoration: TextDecoration.none,
                                fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    ...List.generate(
                        expenseItemList.length,
                        (index) => TableRow(
                              children: [
                                TableCell(
                                  child: Text(
                                    expenseItemList[index]
                                        .registeredDate
                                        .toString()
                                        .trim(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        decoration: TextDecoration.none,
                                        color: Colors.blue,
                                        fontSize: 14),
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    expenseItemList[index]
                                        .individualExpType
                                        .toString()
                                        .trim(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        decoration: TextDecoration.none,
                                        color: Colors.blue,
                                        fontSize: 14),
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    expenseItemList[index]
                                        .centerLocation
                                        .toString()
                                        .trim(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        decoration: TextDecoration.none,
                                        color: Colors.blue,
                                        fontSize: 14),
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    expenseItemList[index]
                                        .expenseAmount
                                        .toString()
                                        .trim(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        decoration: TextDecoration.none,
                                        color: Colors.blue,
                                        fontSize: 14),
                                  ),
                                ),
                              ],
                            ))
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                  child: GradientButton(
                    onPressed: () async {
                      bool result = await exportExcel(jsonData, fileName, [
                        "Registration Date",
                        "Expense Type",
                        "Center Location",
                        "Expense Amount"
                      ]);
                      if (result) {
                        Future.delayed(
                            const Duration(seconds: 0),
                            () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Excel File Downloaded in Employee App Folder'),
                                    backgroundColor: Colors.green,
                                  ),
                                ));
                      } else {
                        Future.delayed(
                            const Duration(seconds: 0),
                            () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Error Downloading File'),
                                    backgroundColor: Colors.red,
                                  ),
                                ));
                      }
                    },
                    label: 'Export',
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                  child: GradientButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    label: 'Close',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
