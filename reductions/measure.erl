-module(measure).

-export([measure_direct/4, measure_external/3, measure_external_n/3, measure_function_n/2]).

measure_direct(Module, Function, N, Percent) ->
    {TimeSpin, _} = measure_spin(N * Percent div 100),
    {TimeCity, _} = measure_external(Module, Function, N),
    TimeCity / TimeSpin.

measure_external(Module, Function, N) ->
    [erlang:garbage_collect(Pid) || Pid <- processes()],
    {Time,_} = timer:tc(Module, Function, [N]),
    {Time, Time/N}.

measure_external_n(Module, Function, N) ->
    [erlang:garbage_collect(Pid) || Pid <- processes()],
    {Time,_} = timer:tc(fun run_external_n/3, [Module,Function,N]),
    {Time, Time/N}.

measure_function_n(Func, N) ->
    [erlang:garbage_collect(Pid) || Pid <- processes()],
    {Time,_} = timer:tc(fun run_function_n/2, [Func,N]),
    {Time, Time/N}.

run_external_n(_Module, _Function, 0) ->
    ok;
run_external_n(Module, Function, N) ->
    Module:Function(),
    run_external_n(Module, Function, N-1).

run_function_n(_Func, 0) ->
    ok;
run_function_n(Func, N) ->
    Func(),
    run_function_n(Func, N-1).

measure_spin(N) ->
    [erlang:garbage_collect(Pid) || Pid <- processes()],
    {Time,_} = timer:tc(fun spin_n/1, [N]),
    {Time, Time/N}.

spin_n(0) ->
    ok;
spin_n(N) ->
    spin(2000),
    spin_n(N-1).

spin(0) ->
    ok;
spin(N) ->
    spin(N-1).
