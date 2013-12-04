-module(measure).

-export([measure_direct/5, measure_external/3, measure_external_n/4, measure_function_n/2]).

measure_direct(Module, Function, Args, N, Percent) ->
    {TimeSpin, _} = measure_external_n(spin, spin, [2000], N * Percent div 100),
    {TimeCity, _} = measure_external_n(Module, Function, Args, N),
    TimeCity / TimeSpin.

measure_external(Module, Function, N) ->
    [erlang:garbage_collect(Pid) || Pid <- processes()],
    {Time,_} = timer:tc(Module, Function, [N]),
    {Time, Time/N}.

measure_external_n(Module, Function, Args, N) ->
    [erlang:garbage_collect(Pid) || Pid <- processes()],
    {Time,_} = timer:tc(fun run_external_n/4, [Module,Function,Args,N]),
    {Time, Time/N}.

measure_function_n(Func, N) ->
    [erlang:garbage_collect(Pid) || Pid <- processes()],
    {Time,_} = timer:tc(fun run_function_n/2, [Func,N]),
    {Time, Time/N}.

run_external_n(_Module, _Function, _Args, 0) ->
    ok;
run_external_n(Module, Function, Args, N) ->
    erlang:apply(Module, Function, Args),
    run_external_n(Module, Function, Args, N-1).

run_function_n(_Func, 0) ->
    ok;
run_function_n(Func, N) ->
    Func(),
    run_function_n(Func, N-1).

measure_spin(N) ->
    [erlang:garbage_collect(Pid) || Pid <- processes()],
    {Time,_} = timer:tc(fun spin:spin_n/1, [N]),
    {Time, Time/N}.
