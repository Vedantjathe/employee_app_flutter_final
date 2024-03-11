import 'package:flutter/material.dart';

import '../TicketSubpages.dart/ticket_details_page.dart';
import '../models/TicketMasterDataModel.dart';

class TicketCardWidget extends StatelessWidget {
  final TicketMasterData tmData;
  const TicketCardWidget(this.tmData, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0XFFF9F9F9),
        border: Border.all(width: 1, color: const Color(0XFFBEDCF0)),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First column
              Expanded(
                flex: 1,
                child: Container(
                  //color: Colors.yellow,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ticket ID',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tmData.TicketID,
                        style: const TextStyle(
                          color: Color(0xff166397),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Ticket Type',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tmData.TicketType,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff166397),
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                      const Text(
                        'Created By',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        tmData.CreatedBy,
                        style: const TextStyle(
                          color: Color(0xff166397),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Created ons',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        tmData.CreatedOn,
                        style: const TextStyle(
                          color: Color(0xff166397),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Contact No.",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        tmData.RaisedPersonContactNo,
                        style: const TextStyle(
                          color: Color(0xff166397),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Add more content for the first column if needed
                    ],
                  ),
                ),
              ),

              // Second column
              Expanded(
                flex: 1,
                child: Container(
                  // height: 350,
                  //color: Colors.purple,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        tmData.Location_Name,
                        style: const TextStyle(
                          color: Color(0xff166397),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Priority',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        tmData.Priority_Ticket,
                        style: const TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Approver and On',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        '${tmData.ApproverName}\n${tmData.ApprovalOn}',
                        style: const TextStyle(
                          color: Color(0xff166397),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Visibility(
                        visible: tmData.Is_Approved.toLowerCase() == 'true',
                        child: const Text(
                          'Approved',
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        ),
                      ),

                      // Add more content for the first column if needed
                    ],
                  ),
                ),
              ),

              // Third column
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(5, 25, 5, 4),
                      margin: const EdgeInsets.fromLTRB(0, 14, 2, 0),
                      decoration: BoxDecoration(
                        color: _getCardColor(tmData),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            tmData.TicketStatus,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: _getStatusColor(tmData.TicketStatus),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(
                            color: Colors.blue,
                            thickness: 1,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Solved By',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            tmData.SolvedBy,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(
                            color: Colors.blue,
                            thickness: 1,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'TAT',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            tmData.TAT,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const Divider(
                            color: Colors.blue,
                            thickness: 1,
                          ),
                          Text(
                            'Comment',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            tmData.Pending_NewComment,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),
                          // Add more content for the third column if needed
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TicketDetailsPage(
                        data: tmData,
                      ))),
              child: const Text('More Detail'))
        ],
      ),
    );
  }

  _getCardColor(TicketMasterData tmData) {
    if (tmData.Pending_NewComment != null) {
      if (int.parse(tmData.Pending_NewComment == "null"
              ? "0"
              : tmData.Pending_NewComment) >
          0) {
        return (const Color(0xFFADD8E6));
      } else {
        //return (Color(0xFFF5F5F5"))
        if (tmData.TAT != null) {
          if (tmData.is_AboveTat.toLowerCase().contains("yes")) {
            return (const Color(0xFFffa07a));
          } else {
            return (const Color(0xFFF5F5F5));
          }
        } else {
          return (const Color(0xFFF5F5F5));
        }
      }
    } else {
      return (const Color(0xFFF5F5F5));
    }
  }

  _getStatusColor(String ticketStatus) {
    switch (ticketStatus.toUpperCase()) {
      case "New":
        return Colors.red;
      case "ACKNOWLEGED":
        return Colors.blue;
      case "IN PROCESS":
        return const Color(0xFFFFFF00);
      case "HOLD":
        return const Color(0xFFFFA500);
      case "REJECTED":
        return Colors.black;
      case "SOLVED":
        return const Color(0xFF90EE90);
      case "CLOSED":
        return const Color(0xFF008000);
    }
  }
}
