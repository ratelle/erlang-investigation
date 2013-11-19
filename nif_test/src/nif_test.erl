-module(nif_test).

-export([
         init/0,
         start_clean_spinner/2,
         start_dirty_spinner/1,
         start_pure_spinner/0,
         run_dirty_test/3,
         run_clean_test/4,
         run_pure_test/2,
         erl_spin/1,
         dirty_nif_spin/1
]).


-on_load(init/0).

-define(SPIN_BUDGET,4000).

%% A 2000 iteration pure-spin is approximately 2035 reductions in erlang

-spec init() -> ok.
init() ->
    PrivDir = case code:priv_dir(?MODULE) of
                  {error, _} ->
                      EbinDir = filename:dirname(code:which(?MODULE)),
                      AppPath = filename:dirname(EbinDir),
                      filename:join(AppPath, "priv");
                  Dir -> Dir
              end,
    SoName = filename:join(PrivDir, "nif_test"),
    case catch erlang:load_nif(SoName,[]) of
        ok -> ok;
        LoadError -> error_logger:error_msg("erl_adgear_geo: error loading NIF (~p): ~p",
                                            [SoName, LoadError])
    end.

run_pure_test(Spinners, LongSchedule) ->
    start_long_schedule_logger(LongSchedule),
    [start_pure_spinner() || _X <- lists:seq(1,Spinners)],
    ok.

run_dirty_test(Spinners, CleanPercent, LongSchedule) ->
    start_long_schedule_logger(LongSchedule),
    [start_dirty_spinner(CleanPercent) || _X <- lists:seq(1,Spinners)],
    ok.

% Goo value for NPerTen is 200
run_clean_test(Spinners, CleanPercent, NPerTen, LongSchedule) ->
    start_long_schedule_logger(LongSchedule),
    [start_clean_spinner(CleanPercent, NPerTen) || _X <- lists:seq(1,Spinners)],
    ok.

start_long_schedule_logger(LongSchedule) ->
    Logger = spawn(fun () -> long_schedule_logger(0,0) end),
    erlang:system_monitor(Logger, [{long_schedule, LongSchedule}]),
    timer:send_after(10000,Logger,print),
    ok.

long_schedule_logger(LS,MS) ->
    receive
        {monitor, _Pid, long_schedule, [{timeout, ThisMS}|_]} ->
            long_schedule_logger(LS+1, MS + ThisMS);
        print ->
            timer:send_after(10000,self(),print),
            case LS of
                0 ->
                    io:format("0 LS/s~n");
                _ ->
                    io:format("~.2f LS/s | ~.2f ms AVG~n",[LS/10,MS/LS])
            end,
            long_schedule_logger(0,0)
    end.

start_clean_spinner(CleanPercent, NPerTen) ->
    CleanBudget = CleanPercent * ?SPIN_BUDGET div 100,
    DirtyBudget = ?SPIN_BUDGET - CleanBudget,
    spawn(fun () -> clean_spinner(CleanBudget, DirtyBudget, NPerTen) end).

start_dirty_spinner(CleanPercent) ->
    CleanBudget = CleanPercent * ?SPIN_BUDGET div 100,
    DirtyBudget = ?SPIN_BUDGET - CleanBudget,
    spawn(fun () -> dirty_spinner(CleanBudget, DirtyBudget) end).

start_pure_spinner() ->
    spawn(fun pure_spinner/0).

clean_spinner(CleanBudget, DirtyBudget, NPerTen) ->
    erl_spin(CleanBudget),
    do_clean_nif_spin(CleanBudget, NPerTen),
    clean_spinner(CleanBudget, DirtyBudget, NPerTen).

%% erl spinning is about 3 time costlier than dirty spinning
dirty_spinner(CleanBudget, DirtyBudget) ->
    erl_spin(CleanBudget),
    dirty_nif_spin(DirtyBudget * 3),
    dirty_spinner(CleanBudget, DirtyBudget).

pure_spinner() ->
    erl_spin(?SPIN_BUDGET),
    pure_spinner().

do_clean_nif_spin(0, _) ->
    ok;
do_clean_nif_spin(N, NPerTen) ->
    Remaining = clean_nif_spin(N, NPerTen),
    do_clean_nif_spin(Remaining, NPerTen).

erl_spin(0) ->
    ok;
erl_spin(N) ->
    erl_spin(N-1).

clean_nif_spin(_N, _NPerTen) ->
    {error, nif_test_not_loaded}.

dirty_nif_spin(_N) ->
    {error, nif_test_not_loaded}.
