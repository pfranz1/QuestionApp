import 'dart:html';

import 'package:flutter/foundation.dart';

class ResultsContainer {
  List<String> results;
  List<String> options;

  bool resolutionComputed = false;
  late final List<TabulationFrame> frames;
  late final String winner;

  ResultsContainer(this.results, this.options);

  Future<bool> computeResults() async {
    List<bool> isElementRemoved = List<bool>.filled(options.length, false);
    List<TabulationFrame> tabulationFrames = [];

    int voterCount = results.length;
    bool hasWinner = false;
    int currentRound = 0;
    List<ElementVoteCollector> voteCollectors = [
      for (MapEntry<int, String> entry in options.asMap().entries)
        ElementVoteCollector((int votes) => voterCount / 2 < votes, entry.key)
    ]; //Okay call me crazy but my compiler will just cache votercount / 2 right?

    //If there isnt anything in tabulation frames OR the last frame still has no winner
    while (
        tabulationFrames.isEmpty || tabulationFrames.last.hasWinner != true) {
      for (MapEntry<int, String> result in results.asMap().entries) {
        //Results are stored like '1,2,4,3' which means I like 1 the most, 2 the second most ect.
        //Figure who wins this persons vote, if they are invalid remove them from the pool and try again
        int voteWinner = int.parse(result.value.split(',').first);
        while (isElementRemoved[voteWinner]) {
          results[result.key] = result.value.replaceFirst('$voteWinner,', '');
          voteWinner = int.parse(result.value.split(',').first);
        }
        hasWinner = hasWinner || voteCollectors[voteWinner].addVotes(1);
      }
      //At this point i have tallied all of the votes and ensured that only active elements recived votes
      //Now im going to make a tabulation frame
      tabulationFrames.add(TabulationFrame(hasWinner: hasWinner, snapshots: [
        for (ElementVoteCollector vc in voteCollectors) vc.makeSnapshot()
      ]));

      //Now I do some post work like removing the lowest first-pref vote person
      voteCollectors.sort();
      //I find the first one where it hasnt yet been removed
      final vcToRemove = voteCollectors
          .firstWhere((element) => element.isRemovedFromRunning == false);

      vcToRemove.markRemoved();
      isElementRemoved[vcToRemove.id] = true;
      //Itterate through the vote collectors and let them know  a new round is starting
      currentRound++;
      for (final vc in voteCollectors) {
        vc.incrementSupportRound(currentRound);
      }
    }
    //After itterating until i had a winner in the final frame I land here
    frames = tabulationFrames;
    voteCollectors.sort();
    winner = options[voteCollectors.last.id];
    resolutionComputed = true;
    return true;
  }
}

//Tabulation frames
class TabulationFrame {
  final bool hasWinner;
  final List<ElementVCSnapshot> snapshots;

  TabulationFrame({required this.hasWinner, required this.snapshots});
}

class ElementVCSnapshot {
  final int votes;
  final List<int> voteBreakdown;
  final bool isRemoved;

  ElementVCSnapshot(
      {required this.votes,
      required this.voteBreakdown,
      required this.isRemoved});
}

class ElementVoteCollector implements Comparable<ElementVoteCollector> {
  int votes = 0;

  final int id;

  List<int> voteBreakdown = [0];
  int supportRound = 0;

  bool Function(int) isWinner;
  bool isRemovedFromRunning = false;

  ElementVoteCollector(this.isWinner, this.id);

  //Adds a vote to its running tally, - returns true if it has won according to a delegate
  bool addVotes(int addedVotes) {
    votes = votes + addedVotes;
    voteBreakdown[supportRound] = voteBreakdown[supportRound] + addedVotes;
    return isWinner(votes);
  }

  void markRemoved() {
    isRemovedFromRunning = true;
  }

  void incrementSupportRound(int newRound) {
    supportRound = newRound;
    voteBreakdown.add(0);
  }

  ElementVCSnapshot makeSnapshot() {
    return ElementVCSnapshot(
        votes: votes,
        voteBreakdown: voteBreakdown,
        isRemoved: isRemovedFromRunning);
  }

  @override
  int compareTo(ElementVoteCollector other) {
    //Okay so this is so vauge but as far as I can find its the first pref counts only that count
    if (isRemovedFromRunning) {
      if (other.isRemovedFromRunning) {
        return voteBreakdown[0] - other.voteBreakdown[0];
      } else {
        //just some large negative number so that if self.isRemoved it will be beneith
        return -100;
      }
    } else {
      if (other.isRemovedFromRunning) {
        return 100;
      } else {
        return voteBreakdown[0] - other.voteBreakdown[0];
      }
    }
  }
}
