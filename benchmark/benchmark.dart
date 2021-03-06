/*
 Copyright 2012 Seth Ladd

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

import 'package:a_star/a_star.dart';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'dart:collection';
import 'dart:math' as Math;

class Simple2DNode extends Object with Node {
  int x, y;
  num nodeInherentCost;
  Set<Simple2DNode> connectedNodes = new Set<Simple2DNode>();
  
  Simple2DNode(this.x, this.y, this.nodeInherentCost);
  
  toString() => "[$x,$y]";
}

class Simple2DMaze implements Graph<Simple2DNode> {
  List<List<Simple2DNode>> tiles;
  
  Simple2DMaze(List<List<num>> costMap) {
    tiles = new List<List<Simple2DNode>>(costMap.length);
    for (int i = 0; i < costMap.length; i++) {
      var rawRow = costMap[i];
      tiles[i] = new List<Simple2DNode>(rawRow.length);
      for (int j = 0; j < rawRow.length; j++) {
        var rawTile = rawRow[j];
        tiles[i][j] = new Simple2DNode(j, i, rawTile);
        allNodes.add(tiles[i][j]);
      }
    }
    _generateConnectedNodes();
  }
  
  void _generateConnectedNodes() {
    for (var rowNum = 0; rowNum < tiles.length; rowNum++) {
      var row = tiles[rowNum];
      for (var colNum = 0; colNum < row.length; colNum++) {
        var tile = row[colNum];
        for (var i = rowNum - 1; i <= rowNum + 1; i++) {
          if (i < 0 || i >= tiles.length) {
            continue;  // Outside Maze bounds.
          }
          for (var j = colNum - 1; j <= colNum + 1; j++) {
            if (j < 0 || j >= row.length) {
              continue;  // Outside Maze bounds.
            }
            if (i == rowNum && j == colNum) {
              continue;  // Same tile.
            }
            tile.connectedNodes.add(tiles[i][j]);
          }
        }
      }
    }
  }
  
  Simple2DNode getNode(int x, int y) => tiles[x][y];

  List<Simple2DNode> allNodes = new List();

  num getDistance(Simple2DNode a, Simple2DNode b) {
    return b.nodeInherentCost;
  }

  num getHeuristicDistance(Simple2DNode a, Simple2DNode b) {
    return Math.sqrt(Math.pow((a.x-b.x), 2) + Math.pow((a.y - b.y), 2));
  }

  Iterable<Simple2DNode> getNeighboursOf(Simple2DNode node) {
    return node.connectedNodes;
  }
}

class AStarBenchmark extends BenchmarkBase {
  static const List<List<num>> costMap = const [
      const [ 1, 10,  1,  1,  1,  1,  1,  1],
      const [ 1, 10,  1,  1,  1,  1,  1,  1],
      const [ 1, 10,  1,  1,  1,  1,  1,  1],
      const [ 1, 10,  1,  1,  1,  1,  1,  1],
      const [ 1, 10,  1,  2,  1,  1,  1,  1],
      const [ 1, 10,  1,  2,  1,  1,  1,  1],
      const [ 1, 10,  1,  2,  1,  1, 20,  2],
      const [ 1,  1,  1,  2,  1,  1, 10,  1]
  ];
  
  AStarBenchmark() : super("AStar");

  // The benchmark code.
  void run() {
    resultQueue = aStar.findPathSync(maze.getNode(0, 0), maze.getNode(7, 7));
  }
  
  Simple2DMaze maze;
  Queue<Simple2DNode> resultQueue;
  AStar aStar;

  // Not measured setup code executed prior to the benchmark runs.
  void setup() {
    maze = new Simple2DMaze(costMap);
    aStar = new AStar(maze);
  }

  // Not measures teardown code executed after the benchark runs.
  void teardown() { 
    print(resultQueue);
  }
}

main() {
  new AStarBenchmark().report();
}
