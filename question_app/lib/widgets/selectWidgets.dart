import 'package:flutter/material.dart';

class qSelectCard extends StatelessWidget {
  qSelectCard(
      {Key? key,
      required this.qId,
      required this.qText,
      required this.onSelect})
      : super(key: key);

  final String qId;
  final String qText;
  final void Function() onSelect;

  @override
  Widget build(BuildContext context) {
    if (qId == null) {
      throw Exception('Recived question with text $qText but no id');
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        color: Colors.white.withOpacity(1.0),
        borderRadius: BorderRadius.circular(6.0),
        child: InkWell(
          focusColor: Colors.black,
          onTap: () {
            onSelect();
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                // This is a bug i might see again, with ink well the lower things shouldnt have color as that will occude the inkwell
                // color: Theme.of(context).colorScheme.surface,
                border: Border.all(width: 2.0)),
            child: Text(
              qText,
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}
