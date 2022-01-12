import 'dart:html';
import 'dart:math';

import 'package:flutter/foundation.dart';

class ResultsContainer {
  List<String> results;
  List<String> options;

  bool resolutionComputed = false;
  late final List<TabulationFrame> frames;
  late final String winner;

  ResultsContainer(this.results, this.options);

  List<int> getVotesAtDepth(int depth, List<bool> isElementRemoved) {
    // int acumulatedVotes = 0;

    List<int> acumulatedVotes = List<int>.filled(options.length, 0);

    for (String result in results) {
      int depthTracker = depth;
      int entryWalker = -1;
      do {
        entryWalker++;
        int voteWinner =
            int.parse(result.substring(2 * entryWalker).split(',').first);
        //If i have found a valid winner that hasnt been removed
        if (!isElementRemoved[voteWinner]) {
          depthTracker--;
          if (depthTracker < 0) {
            acumulatedVotes[voteWinner]++;
          }
        }
      } while (depthTracker >= 0);
    }

    return acumulatedVotes;
  }

  List<int> getPreferenceAtDepth(int depth) {
    List<int> acumulatedVotes = List<int>.filled(options.length, 0);

    for (String result in results) {
      acumulatedVotes[
          int.parse(result.substring(2 * depth).split(',').first)]++;
    }

    return acumulatedVotes;
  }

  /**
   * I know that i may post this code online and this mess with be seen.
   * I could clean this up and remove old ideas and streamline it
   * Im not going to spend that time now becasue i am sick of working on this problem
   * if its a problem later i will fix it later. Would rather have soemthing ugly but done
   */
  Future<bool> computeResults() async {
    print('compute result called');
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
      final firstChoiceVotes = getVotesAtDepth(0, isElementRemoved);
      for (final votes in firstChoiceVotes.asMap().entries) {
        hasWinner =
            hasWinner || voteCollectors[votes.key].addVotes(votes.value);
      }

      //At this point i have tallied all of the votes and ensured that only active elements recived votes
      //Now im going to make a tabulation frame
      tabulationFrames.add(TabulationFrame(hasWinner: hasWinner, snapshots: [
        for (ElementVoteCollector vc in voteCollectors) vc.makeSnapshot()
      ]));

      if (hasWinner) break;

      //Now I do some post work like removing the lowest first-pref vote person

      // List<ElementVoteCollector> lowestFirstVotes = [
      //   voteCollectors
      //       .firstWhere((element) => element.isRemovedFromRunning == false)
      // ];
      // //I find the first one where it hasnt yet been removed
      // for (final vc in voteCollectors) {
      //   if (!vc.isRemovedFromRunning && vc.id != lowestFirstVotes[0].id) {
      //     if (vc.voteBreakdown[0] == lowestFirstVotes[0].voteBreakdown[0]) {
      //       //This means that some vc is tying for the lowest first choice votes
      //     }
      //   }
      // }

      int? lowestVote;
      for (final vc in voteCollectors) {
        if (!vc.isRemovedFromRunning) {
          lowestVote = min(vc.votes, lowestVote ?? vc.votes + 1);
        }
      }

      //Find vc to remove
      List<ElementVoteCollector> vcsToRemove = voteCollectors
          .where((element) => element.votes == lowestVote)
          .toList();
      //If i have multiple to remove i need to do some tiebreaking
      int n = 0;
      while (vcsToRemove.length > 1) {
        n++;
        //The votes that they start with are first pref votes, i want to check second pref and on and on
        final nthPlaceVotes = getPreferenceAtDepth(n);
        //Now i want to compare these
        //Find the lowest value
        int lowestNthPlaceVotes = nthPlaceVotes[vcsToRemove.first.id];
        List<ElementVoteCollector> newLowest = [];
        for (final vc in vcsToRemove) {
          if (nthPlaceVotes[vc.id] == lowestNthPlaceVotes) {
            newLowest.add(vc);
          } else if (nthPlaceVotes[vc.id] < lowestNthPlaceVotes) {
            lowestNthPlaceVotes = nthPlaceVotes[vc.id];
            newLowest = [vc];
          }
        }
        vcsToRemove = newLowest;
      }

      // voteCollectors
      //     .firstWhere((element) => element.isRemovedFromRunning == false);

      //Need to handle the case where the last one is tied with another and do a tiebreak among all the lowest ones

      vcsToRemove.first.markRemoved();
      isElementRemoved[vcsToRemove.first.id] = true;
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
    //1,0,2, 0,1,2,
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
  final int id;

  ElementVCSnapshot(
      {required this.id,
      required this.votes,
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
    votes = 0;
    voteBreakdown.add(0);
  }

  ElementVCSnapshot makeSnapshot() {
    return ElementVCSnapshot(
        id: id,
        votes: votes,
        voteBreakdown: voteBreakdown,
        isRemoved: isRemovedFromRunning);
  }

  @override
  int compareTo(ElementVoteCollector other) {
    //Okay so this is so vauge but as far as I can find its the first pref counts only that count when comparing to remove one
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
