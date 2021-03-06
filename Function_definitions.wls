WolframModelObjectProperties[x_] := {
  x["Rules"], 
  x[0], 
  x["FinalState"],
  x["VertexCountList"],
  x["EdgeCountList"], 
  Map[GraphDiameter, 
   Map[UndirectedGraph, 
    Map[ResourceFunction["HypergraphToGraph"], x["StatesList"]]]], 
  ResourceFunction["ConnectedHypergraphQ"][x["FinalState"]]
  }

WolframModelObjectProperties :: usage = 
  "WolframModelObjectProperties takes a WolframModelEvolutionObject \
as an input. It gives the list of: its underlying Rules, Initial \
State, Final State, its vertex and edge count list, list of diameter \
at each stage, and whether the hypergraph is final connected or not.";

WolframModelObjectPropertiesVisual[x_] := {
  RulePlot[ResourceFunction["WolframModel"][x["Rules"]]], 
  ResourceFunction["WolframModelPlot"][x[0]], 
  x["FinalStatePlot"],
  ListLinePlot[{x["VertexCountList"], 
    Table[If[(E^i) <= x["VertexCountList"][[-1]], E^i, Nothing], {i, 
      0, 10}]}, PlotLegends -> {"Vertex Count", "Exp(x)"}],
  ListLinePlot[{x["EdgeCountList"], 
    Table[If[(E^i) <= x["EdgeCountList"][[-1]], E^i, Nothing], {i, 0, 
      10}]}, PlotLegends -> {"Edge Count", "Exp(x)"}], 
  ListLinePlot[
   Map[GraphDiameter, 
    Map[UndirectedGraph, 
     Map[ResourceFunction["HypergraphToGraph"], x["StatesList"]]]], 
   PlotLabel -> "Diameter growth with steps"], 
  ResourceFunction["ConnectedHypergraphQ"][x["FinalState"]]
  }

WolframModelObjectPropertiesVisual:: usage = 
  "WolframModelObjectProperties takes a WolframModelEvolutionObject \
as an input. It gives the list of: Plot of its underlying Rules, Plot \
of Initial State, Plot of Final State, Line Plot of its vertex and \
edge counts at each stage - compared with Exp(x), plot of diameter at \
all states, and whether the hypergraph is final connected or not.";

WolframModelSignGrowthCon[x_] := Table[
  If[
   ResourceFunction["ConnectedHypergraphQ"][
     ResourceFunction["WolframModel"][i, Keys[i], 3, "FinalState"]] && 
    Length@
      ResourceFunction["WolframModel"][i, Keys[i], 3, 
       "EdgeCountList"] > 2, 
   ResourceFunction["WolframModel"][i, Keys[i], 10], 
   Nothing
   ],
  {i, ResourceFunction["EnumerateWolframModelRules"][x]}
  ]

WolframModelSignGrowthCon::usage = 
  "WolframModelSignGrowthCon takes in a signature [x] and returns the \
output of WolframModel[x, Keys[x], 10] minus the rules for which the \
hypergraph at 3rd step is disconnected or does not grow after 3 \
steps.";

WolframModelMultiSignGrowthCon[x_] := Module[
  {Rules},
  Rules = Map[ResourceFunction["EnumerateWolframModelRules"],  x];
  Table[
   If[
    ResourceFunction["ConnectedHypergraphQ"][
      ResourceFunction["WolframModel"][i, Keys[i[[1]]], 3, 
       "FinalState"]] && 
     Length@ResourceFunction["WolframModel"][i, Keys[i[[1]]], 3, 
        "EdgeCountList"] > 2, 
    ResourceFunction["WolframModel"][i, Keys[i[[1]]], 10], 
    Nothing
    ],
   {i, Table[Map[RandomChoice, Rules], {j, Max[Map[Length, Rules]]}]}
   ]
  ]

WolframModelMultiSignGrowthCon::usage = 
  "WolframModelMultiSignGrowth takes in a list of signatures and \
returns a WolframModelEvolutionObject for a random set of rules of \
the signatures given in x for all the connected and non-terminating.";

WolframModelLinearFilter[x_] := Switch[
  FindLinearRecurrence /@ {x["VertexCountList"], x["EdgeCountList"]},
  {{2, -1}, {2, -1}}, Nothing,
  {{1}, {2, -1}}, Nothing, 
  {{2, -1}, {1}}, Nothing,
  {{1}, {1}}, Nothing,
   _, x
  ]

WolframModelLinearFilter::usage = 
  "WolframModelLinearFilter takes a WolframModelEvolutionObject as an \
input and returns the object unchanged if its [VertexCountList] AND \
[EdgeCountList] both do not show a linear growth rate. It returns \
Nothing otherwise.";

WolframModelLinearFilterClassify[x_] := Switch[
  FindLinearRecurrence /@ {x["VertexCountList"], x["EdgeCountList"]},
  {{2, -1}, {2, -1}}, {x["Rules"], x[0]},
  {{1}, {2, -1}}, {x["Rules"], x[0]}, 
  {{2, -1}, {1}}, {x["Rules"], x[0]},
  {{1}, {1}}, {x["Rules"], x[0]},
   _, Nothing
  ]

WolframModelLinearFilterClassify::usage = 
  "WolframModelLinearFilterClassify takes a \
WolframModelEvolutionObject as an input and returns the underlying \
rules and it's initial state if its [VertexCountList] AND \
[EdgeCountList] both show a linear growth rate. It returns Nothing \
otherwise.";

WolframModelExponentialFilter[x_] := Module[
  {ObjAsmp},
  ObjAsmp = Table[
    Asymptotic[FindSequenceFunction[y][i], i -> Infinity],
    {y, {x["VertexCountList"], x["EdgeCountList"]}}
    ];
  If[
   Which[
     MatchQ[ObjAsmp[[1]], 
      HoldPattern[_Integer*(_Integer^(_Integer + \
_Integer*_Symbol))]], True,
     MatchQ[ObjAsmp[[1]], 
      HoldPattern[_Integer^(_Integer + _Integer*_Symbol)]], True, 
     MatchQ[ObjAsmp[[1]], HoldPattern[_Integer^(_Integer*_Symbol)]], 
     True, 
     MatchQ[ObjAsmp[[1]], HoldPattern[_Integer^(_Symbol)]], True, 
     MatchQ[ObjAsmp[[1]], 
      HoldPattern[_Integer*(_Integer^(_Integer*_Symbol))]], True, 
     MatchQ[ObjAsmp[[1]], 
      HoldPattern[_Integer*(_Integer^(_Symbol))]], True, 
     MatchQ[ObjAsmp[[1]], 
      HoldPattern[_Integer*(_Integer^(_Integer + _Symbol))]], True, 
     MatchQ[ObjAsmp[[1]], 
      HoldPattern[_Integer^(_Integer + _Symbol)]], True,
     True, False 
     ] &&
    Which[
     MatchQ[ObjAsmp[[2]], 
      HoldPattern[_Integer*(_Integer^(_Integer + \
_Integer*_Symbol))]], True,
     MatchQ[ObjAsmp[[2]], 
      HoldPattern[_Integer^(_Integer + _Integer*_Symbol)]], True, 
     MatchQ[ObjAsmp[[2]], HoldPattern[_Integer^(_Integer*_Symbol)]], 
     True, 
     MatchQ[ObjAsmp[[2]], HoldPattern[_Integer^(_Symbol)]], True, 
     MatchQ[ObjAsmp[[2]], 
      HoldPattern[_Integer*(_Integer^(_Integer*_Symbol))]], True, 
     MatchQ[ObjAsmp[[2]], 
      HoldPattern[_Integer*(_Integer^(_Symbol))]], True, 
     MatchQ[ObjAsmp[[2]], 
      HoldPattern[_Integer*(_Integer^(_Integer + _Symbol))]], True, 
     MatchQ[ObjAsmp[[2]], 
      HoldPattern[_Integer^(_Integer + _Symbol)]], True,
     True, False
     ],
   Nothing, 
   x
   ]
  ]

WolframModelExponentialFilter::usage = 
  "This function takes in a WolframModelEvolutionObject and returns \
nothing if its [VertexCountList] AND [EdgeCountList] both do not show \
an exponential growth rate. It returns the \
WolframModelEvolutionObject otherwise.";

WolframModelExponentialFilterClassify[x_] := Module[
  {ObjAsmp},
  ObjAsmp = Table[
    Asymptotic[FindSequenceFunction[y][i], i -> Infinity],
    {y, {x["VertexCountList"], x["EdgeCountList"]}}
    ];
  If[
   Which[
     MatchQ[ObjAsmp[[1]], 
      HoldPattern[_Integer*(_Integer^(_Integer + \
_Integer*_Symbol))]], True,
     MatchQ[ObjAsmp[[1]], 
      HoldPattern[_Integer^(_Integer + _Integer*_Symbol)]], True, 
     MatchQ[ObjAsmp[[1]], HoldPattern[_Integer^(_Integer*_Symbol)]], 
     True, 
     MatchQ[ObjAsmp[[1]], HoldPattern[_Integer^(_Symbol)]], True, 
     MatchQ[ObjAsmp[[1]], 
      HoldPattern[_Integer*(_Integer^(_Integer*_Symbol))]], True, 
     MatchQ[ObjAsmp[[1]], 
      HoldPattern[_Integer*(_Integer^(_Symbol))]], True, 
     MatchQ[ObjAsmp[[1]], 
      HoldPattern[_Integer*(_Integer^(_Integer + _Symbol))]], True, 
     MatchQ[ObjAsmp[[1]], 
      HoldPattern[_Integer^(_Integer + _Symbol)]], True,
     True, False 
     ] &&
    Which[
     MatchQ[ObjAsmp[[2]], 
      HoldPattern[_Integer*(_Integer^(_Integer + \
_Integer*_Symbol))]], True,
     MatchQ[ObjAsmp[[2]], 
      HoldPattern[_Integer^(_Integer + _Integer*_Symbol)]], True, 
     MatchQ[ObjAsmp[[2]], HoldPattern[_Integer^(_Integer*_Symbol)]], 
     True, 
     MatchQ[ObjAsmp[[2]], HoldPattern[_Integer^(_Symbol)]], True, 
     MatchQ[ObjAsmp[[2]], 
      HoldPattern[_Integer*(_Integer^(_Integer*_Symbol))]], True, 
     MatchQ[ObjAsmp[[2]], 
      HoldPattern[_Integer*(_Integer^(_Symbol))]], True, 
     MatchQ[ObjAsmp[[2]], 
      HoldPattern[_Integer*(_Integer^(_Integer + _Symbol))]], True, 
     MatchQ[ObjAsmp[[2]], 
      HoldPattern[_Integer^(_Integer + _Symbol)]], True,
     True, False
     ],
   {x["Rules"], x[0]}, 
   Nothing
   ]
  ]

WolframModelExponentialFilterClassify::usage = 
  "This function takes in a WolframModelEvolutionObject and returns \
the underlying rules and initial state if its [VertexCountList] AND \
[EdgeCountList] both show an exponential growth rate. It returns \
Nothing otherwise.";

Options[WolframModelInterestingRules] = {"Output Type" -> "Default"};

WolframModelInterestingRules[x_List, OptionsPattern[]] := 
 Switch[OptionValue["Output Type"],
  "Default",
  Module[
   {ObjRules1, LinearFilterMap1, ExpFilterMap1},
   ObjRules1 = If[
     Length[x] > 1,
     WolframModelMultiSignGrowthCon[x],
     WolframModelSignGrowthCon[x[[1]]]
     ];
   ParallelNeeds["SetReplace`"];
   LinearFilterMap1 = ParallelMap[
     WolframModelLinearFilter,
     ObjRules1
     ];
   ExpFilterMap1 =  ParallelMap[
     WolframModelExponentialFilter,
     LinearFilterMap1
     ];
   Column[
    ParallelMap[
     WolframModelObjectProperties,  
     ExpFilterMap1
     ]
    ]
   ],
  "Visualize",
  Module[
   {ObjRules2, LinearFilterMap2, ExpFilterMap2},
   ObjRules2 = If[
     Length[x] > 1,
     WolframModelMultiSignGrowthCon[x],
     WolframModelSignGrowthCon[x[[1]]]
     ];
   ParallelNeeds["SetReplace`"];
   LinearFilterMap2 = ParallelMap[
     WolframModelLinearFilter,
     ObjRules2
     ];
   ExpFilterMap2 =  ParallelMap[
     WolframModelExponentialFilter,
     LinearFilterMap2
     ];
   Column[
    ParallelMap[
     WolframModelObjectPropertiesVisual,  
     ExpFilterMap2
     ]
    ]
   ],
  "Classify",
  Module[
   {ObjRules3, LinearFilterMap3, ExpFilterMap3},
   ObjRules3 = If[
     Length[x] > 1,
     WolframModelMultiSignGrowthCon[x],
     WolframModelSignGrowthCon[x[[1]]]
     ];
   ParallelNeeds["SetReplace`"];
   LinearFilterMap3 = ParallelMap[
     WolframModelLinearFilter,
     ObjRules3
     ];
   ExpFilterMap3 =  ParallelMap[
     WolframModelExponentialFilter,
     LinearFilterMap3
     ];
   <|
    "Linear" ->  Column[
      ParallelMap[
       WolframModelLinearFilterClassify,
       ObjRules3
       ]
      ],
    "Exponential" ->  Column[
      ParallelMap[
       WolframModelExponentialFilterClassify,
       ObjRules3
       ]
      ],
    "Neither" -> Column[
      ParallelTable[
       {i["Rules"], i[0]},
       {i, ExpFilterMap3}
       ]
      ]
    |>
   ],
  "FeatureSpacePlot",
  Module[
   {ObjRules4, LinearFilterMap4, ExpFilterMap4, FinalStateTable, 
    ifinalstateplots},
   ObjRules4 = If[
     Length[x] > 1, 
     WolframModelMultiSignGrowthCon[x], 
     WolframModelSignGrowthCon[x[[1]]]
     ];
   ParallelNeeds["SetReplace`"];
   LinearFilterMap4 = ParallelMap[
     WolframModelLinearFilter, 
     ObjRules4
     ];
   ExpFilterMap4 = ParallelMap[
     WolframModelExponentialFilter,  
     LinearFilterMap4
     ];
   FinalStateTable = ParallelTable[
     i["FinalStatePlot"],
     {i, ExpFilterMap4}
     ];
   ifinalstateplots = 
    ParallelMap[Rasterize[#, Background -> None] &, FinalStateTable];
   FeatureSpacePlot[
    ifinalstateplots,
    LabelingFunction -> (Placed[Pane[Erosion[#, 1.5], 30], Center] &),
    PlotStyle -> None,
    FeatureExtractor -> "ImageFeatures"
    ]
   ]
  ]

WolframModelInterestingRules::usage = 
  "WolframModelInterestingRules takes in a list of signatures as an \
input. It then returns the output of WolframModelObjectProperties for \
the rules which give connected, non-terminating, non-linear growth, \
and non-exponential growth models. It has 4 option values for 'Output \
Type'.
  'Output Type' -> 'Default' : This returns the default output.
  'Output Type' -> 'Visualize' : This returns the visualization of \
the components of default output. This is not recommended as it is \
too computationally expensive to run on Personal Computers.
  'Output Type' -> 'Classify' : This returns a list of associations \
for growth rates, which can be Linear, Exponential, or Neither with \
the {Rules, Initial State} that exhibit that growth rate.
  'Output Type' -> 'FeatureSpacePlot' : This returns a \
FeatureSpacePlot of the final states of all the non-linear and \
non-exponential models.";
