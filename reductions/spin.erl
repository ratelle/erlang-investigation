-module(spin).

-export([function1_n/1, function1/0, run_measure_external/1, run_measure_external_n/1, run_measure_function_n/1]).

run_measure_external(N) ->
    measure:measure_external(spin,function1_n,N).

run_measure_external_n(N) ->
    measure:measure_external_n(spin,function1,N).

run_measure_function_n(N) ->
    measure:measure_function_n(fun function1/0,N).

function1_n(0) ->
    ok;
function1_n(N) ->
    function1(),
    function1_n(N-1).

function1() ->
    ok.
