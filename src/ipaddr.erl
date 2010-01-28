
-module(ipaddr).

-export([find/1, ipv4/1]).
-export([ipv4/2, inet_aton/1]).

-define(CLASSA_MIN, 10 bsl 24).
-define(CLASSA_MAX, (10 bsl 24) + (255 bsl 16) + (255 bsl 8) + 255).

-define(CLASSB_MIN, (172 bsl 24) + (16 bsl 16)).
-define(CLASSB_MAX, (172 bsl 24) + (31 bsl 16) + (255 bsl 8) + 255).

-define(CLASSC_MIN, (192 bsl 24) + (168 bsl 16)).
-define(CLASSC_MAX, (192 bsl 24) + (168 bsl 16) + (255 bsl 8) + 255).

-define(CLASSLOOP_MIN, 127 bsl 24).
-define(CLASSLOOP_MAX, (127 bsl 24) + (255 bsl 16) + (255 bsl 8) + 255).

-define(URL, "http://www.whatismyip.com/automation/n09230945.asp").


find(IP) ->
    {ok, {{"HTTP/1.1",200,"OK"}, _Headers, Body}} = http:request(?URL),
    case validip(Body) of
        true -> Body;
        false -> IP
    end.

ipv4(L) when is_list(L) ->
    ipv4(L, inet_aton(L)).
ipv4(L,N) when N >= ?CLASSA_MIN, N =< ?CLASSA_MAX ->
    find(L); 
ipv4(L,N) when N >= ?CLASSB_MIN, N =< ?CLASSB_MAX ->
    find(L); 
ipv4(L,N) when N >= ?CLASSC_MIN, N =< ?CLASSC_MAX ->
    find(L); 
ipv4(L,N) when N >= ?CLASSLOOP_MIN, N =< ?CLASSLOOP_MAX ->
    find(L); 
ipv4(L,_) ->
    L.

inet_aton(N) when is_list(N) ->
    [A,B,C,D] = string:tokens(N, "."),
    (list_to_integer(A) bsl 24) +
    (list_to_integer(B) bsl 16) +
    (list_to_integer(C) bsl 8) +
    list_to_integer(D).

validip(N) when is_list(N) ->
    case re:run(N, "^\\d+\\.\\d+\\.\\d+\\.\\d+$") of
        {match,_} -> true;
        _ -> false
    end.


