-module(many_pids_test).

-export([run_test/3,
         run_self_spinner_test/1,
         run_spinner_killer_test/1,
         low_spinner_starter/0,
         run_spinner_counter/1]).

-define(LOW_REDUCTIONS, 1900).
-define(HIGH_REDUCTIONS, 8000).

run_test(LowGenerators, HighGenerators, ChildrenPerSecond) ->
    start_long_schedule_logger(1),
    [spawn(fun () -> low_generator(ChildrenPerSecond,ChildrenPerSecond) end) || _X <- lists:seq(1,LowGenerators)],
    [spawn(fun () -> high_generator(ChildrenPerSecond,ChildrenPerSecond) end) || _X <- lists:seq(1,HighGenerators)],
    ok.

run_spinner_counter(Spinners) ->
    start_long_schedule_counter(1),
    [spawn(fun high_spinner_starter/0) || _X <- lists:seq(1,Spinners)],
    ok.

run_self_spinner_test(Spinners) ->
    start_long_schedule_logger(1),
    [spawn(many_pids_test, low_spinner_starter, []) || _X <- lists:seq(1,Spinners)].

run_spinner_killer_test(Spinners) ->
    start_long_schedule_logger(1),
    [spawn(fun low_spinner_killer/0) || _X <- lists:seq(1,Spinners)].

start_long_schedule_logger(LongSchedule) ->
    Logger = spawn(fun long_schedule_logger/0),
    erlang:system_monitor(Logger, [{long_schedule, LongSchedule}]),
    ok.

long_schedule_logger() ->
    receive
        X ->
            io:format("~p~n", [X])
    end,
    long_schedule_logger().

start_long_schedule_counter(LongSchedule) ->
    Logger = spawn(fun () -> long_schedule_counter(0,0) end),
    erlang:system_monitor(Logger, [{long_schedule, LongSchedule}]),
    timer:send_after(10000,Logger,print),
    ok.

long_schedule_counter(LS,MS) ->
    receive
        {monitor, _Pid, long_schedule, [{timeout, ThisMS}|_]} ->
            long_schedule_counter(LS+1, MS + ThisMS);
        print ->
            timer:send_after(10000,self(),print),
            case LS of
                0 ->
                    io:format("0 LS/s~n");
                _ ->
                    io:format("~.2f LS/s | ~.2f ms AVG~n",[LS/10,MS/LS])
            end,
            long_schedule_counter(0,0)
    end.

low_generator(0, ChildrenPerSecond) ->
    timer:sleep(1000),
    low_generator(ChildrenPerSecond, ChildrenPerSecond);
low_generator(Remaining, ChildrenPerSecond) ->
    spawn(fun low/0),
    low_generator(Remaining-1, ChildrenPerSecond).

high_generator(0, ChildrenPerSecond) ->
    timer:sleep(1000),
    high_generator(ChildrenPerSecond, ChildrenPerSecond);
high_generator(Remaining, ChildrenPerSecond) ->
    spawn(fun high/0),
    high_generator(Remaining-1, ChildrenPerSecond).

low_spinner_starter() ->
    low_spin(400),
    spawn(many_pids_test, low_spinner_starter, []).

high_spinner_starter() ->
    high(),
    timer:sleep(5),
    spawn(fun high_spinner_starter/0).

low_spinner_killer() ->
    PID = spawn(fun high/0),
    low_spin(2100),
    exit(PID, kill),
    low_spinner_killer().

low() ->
    low_spin(?LOW_REDUCTIONS).

high() ->
    high_spin(?HIGH_REDUCTIONS).

low_spin(0) ->
    ok;
low_spin(N) ->
    low_spin(N-1).

low_spin2(0) ->
    ok;
low_spin2(N) ->
    low_spin2(N-1).

high_spin(0) ->
    ok;
high_spin(N) ->
    high_spin(N-1).
