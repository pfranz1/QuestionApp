import 'package:provider/provider.dart';
import 'package:question_app/applicationState.dart';
import 'package:question_app/pages/question/resultWidget.dart';

import '../../models/models.dart';
import '../../widgets/widgets.dart';
import 'package:flutter/material.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage(
      {Key? key, required this.appState, required this.qId, this.hasVoted})
      : super(key: key);

  final ApplicationState appState;
  final String qId;
  final bool? hasVoted;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  @override
  void initState() {
    super.initState();
    widget.appState.loadQuestion(widget.qId, widget.hasVoted);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      final isError = appState.questionLoadState == QuestionLoadState.error;
      return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Color(0xFF38EF7D),
            Color(0xFF11998E),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
              // title: Text("Question App"),
              ),
          body: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  if (appState.questionLoadState == QuestionLoadState.loading)
                    CircularProgressIndicator(),
                  if (!isError && !appState.hasVoted)
                    QuestionInterface(
                      question: appState.question,
                      onSubmit: appState.addResponse,
                    ),
                  if (!isError &&
                      appState.questionLoadState == QuestionLoadState.done &&
                      appState.hasVoted)
                    Column(
                      children: [
                        if (appState.resultLoadState == ResultLoadState.done)
                          ResultsCard(
                            results: appState.results!,
                            question: appState.question!,
                          ),
                        if (appState.resultLoadState == ResultLoadState.loading)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.45,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(width: 2.0),
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('Fetching results'),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  CircularProgressIndicator(),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  if (isError) const Center(child: ErrorCard()),
                  if (isError)
                    StyledButton(
                        child: const Text('Reload'), onPressed: appState.reload)
                ],
              )),
        ),
      );
    });
  }
}

class ErrorCard extends StatelessWidget {
  const ErrorCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(6.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Sorry! There was an error loading, try reloading.',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
      ),
    );
  }
}
