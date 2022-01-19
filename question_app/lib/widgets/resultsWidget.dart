// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:question_app/models/models.dart';
// import 'package:question_app/services/services.dart';
// import 'package:question_app/widgets/widgets.dart';

// class ResultsCard extends StatefulWidget {
//   ResultsCard({Key? key, required this.results, required this.question})
//       : super(key: key);

//   final List<String> results;
//   final Question question;

//   @override
//   State<ResultsCard> createState() => _ResultsCardState();
// }

// class _ResultsCardState extends State<ResultsCard> {
//   late final ResultsContainer resultsContainer;

//   @override
//   void initState() {
//     resultsContainer =
//         ResultsContainer(widget.results, widget.question.options);
//     resultsContainer.addListener(() => setState(() {}));
//     _computeResults();
//     super.initState();
//   }

//   Future _computeResults() async {
//     await resultsContainer.tryComputeResults();
//   }

//   Widget? get _questionHeader {}
//   Widget get _options {
//     return QuestionResultsList(optionList: widget.question.options);
//   }

//   Widget get _underview {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         const Padding(
//             padding: const EdgeInsets.only(top: 8.0),
//             child: Text('One day other buttons could go here')),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double avalaibleHeight = MediaQuery.of(context).size.height * 0.45;
//     final resultsList = _options;
//     if (resultsContainer.resolutionComputed == ComputationState.done) {
//       return Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: QuestionHeader(questionText: widget.question.questionText),
//             ),
//             _options,
//             _underview,
//           ],
//         ),
//       );
//     } else if (resultsContainer.resolutionComputed ==
//         ComputationState.loading) {
//       return Container(
//         height: avalaibleHeight,
//         decoration: BoxDecoration(
//           border: Border.all(width: 2.0),
//           color: Theme.of(context).colorScheme.surface,
//         ),
//         child: const Center(child: CircularProgressIndicator()),
//       );
//     } else {
//       return Container(
//         height: avalaibleHeight,
//         decoration: BoxDecoration(
//           border: Border.all(width: 2.0),
//           color: Theme.of(context).colorScheme.surface,
//         ),
//         child: const Center(child: Text('Error :(')),
//       );
//     }
//   }
// }
// //Maybe it would be smarter to merge the two objects together, but ill start from the complex and go to the simple
// //IE ill code this first then reuse this

// class QuestionResultsList extends StatefulWidget {
//   const QuestionResultsList({Key? key, required this.optionList})
//       : super(key: key);

//   final List<String?> optionList;

//   @override
//   _QuestionResultsListState createState() => _QuestionResultsListState();
// }

// const _offsetPerOption = 4.0; //margin + border width

// class _QuestionResultsListState extends State<QuestionResultsList> {
//   @override
//   Widget build(BuildContext context) {
//     final double avalaibleHeight = MediaQuery.of(context).size.height * 0.45;
//     final double avalaibleHeightPerOption =
//         (avalaibleHeight - (_offsetPerOption * widget.optionList.length)) /
//             widget.optionList.length;

//     return Container(
//       height: avalaibleHeight,
//       decoration: BoxDecoration(
//         border: Border.all(width: 2.0),
//         color: Theme.of(context).colorScheme.surface,
//       ),
//       child: ReorderableListView(
//         buildDefaultDragHandles: false,
//         header: const SizedBox(
//           height: _offsetPerOption,
//         ),
//         children: [
//           for (String? option in widget.optionList)
//             QuestionOptionElement(
//               key: option != null ? Key(option) : UniqueKey(),
//               option: option,
//               height: avalaibleHeightPerOption,
//             ),
//         ],
//         onReorder: (int oldIndex, int newIndex) {
//           setState(() {
//             if (oldIndex < newIndex) {
//               newIndex -= 1;
//             }
//             final String? item = widget.optionList.removeAt(oldIndex);
//             widget.optionList.insert(newIndex, item);
//           });
//         },
//       ),
//     );
//   }
// }

// class QuestionResultElement extends StatelessWidget {
//   QuestionResultElement({Key? key, this.option, this.height})
//       : color = ColorHasher.getColor(option ?? 'nothing').withOpacity(1.0),
//         super(key: key);

//   final String? option;
//   final double? height;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: height,
//       child: Card(
//         child: ListTile(
//           tileColor: color,
//           title: Center(
//             child: Container(
//               decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(5.0)),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   option ?? '---',
//                   style: Theme.of(context).textTheme.headline5,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
