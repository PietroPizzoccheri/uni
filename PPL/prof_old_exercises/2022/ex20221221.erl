-module(ex20221221).
-export([pmap/2, execute/3, test/0,
        check/3, pfilter/2, test1/0,
        dofold/3, partition/2, parthelp/6, parfold/3,
        listlink/2, master/1, master_loop/2]).

% parallel map
pmap(F, L) ->
    Ps = [ spawn(?MODULE, execute, [F, X, self()]) || X <- L],
    [receive 
         {Pid, X} -> X
     end || Pid <- Ps].

execute(F, X, Pid) ->
    Pid ! {self(), F(X)}.

test() ->
    pmap(fun (X) -> X*X end, [1,2,3,4]).


check(P, X, Pid) ->
    Pid ! {self(), P(X), X}.


pfilter(P, L) ->
    Ps = [ spawn(?MODULE, check, [P, X, self()]) || X <- L],
    lists:foldl(fun (F, Vo) ->
                        receive
                            {F, true, X} -> Vo ++ [X];
                            {F, false, _} -> Vo
                        end
               end, [], Ps).


test1() ->
    pfilter(fun (X) -> X > 2 end, [1,2,3,4]).


partition(L, N) -> 
    M = length(L),
    Chunk = M div N,
    End = M - Chunk*(N-1),
    parthelp(L, N, 1, Chunk, End, []).

parthelp(L, 1, P, _, E, Res) ->
    Res ++ [lists:sublist(L, P, E)];
parthelp(L, N, P, C, E, Res) ->
    R = lists:sublist(L, P, C),
    parthelp(L, N-1, P+C, C, E, Res ++ [R]).

parfold(F, L, N) ->
    Ls = partition(L, N),
    Ps = [spawn(?MODULE, dofold, [self(), F, X]) || X <- Ls],
    [R|Rs] = [receive
                  {P, V} -> V 
              end || P <- Ps],
    lists:foldl(F, R, Rs).

dofold(Pid, F, [X|Xs]) ->
    Pid ! {self(), lists:foldl(F, X, Xs)}.




listlink([], Pids) -> Pids;
listlink([F|Fs], Pids) ->
    Pid = spawn_link(F),
    listlink(Fs, Pids#{Pid => F}).


master(Functions) ->
    process_flag(trap_exit, true),
    Workers = listlink(Functions, #{}),
    master_loop(Workers, length(Functions)).


master_loop(_, 0) ->
    ok; 
master_loop(Workers, Count) ->
    receive
        {'EXIT', _, normal} ->
            master_loop(Workers, Count-1);
        {'EXIT', Pid, _} ->
            #{Pid := Fun} = Workers,
            Child = spawn_link(Fun),
            master_loop(Workers#{Child => Fun}, Count)
    end.






