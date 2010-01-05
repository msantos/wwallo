
-module(tw).

-export([search/1]).
-export([req/2]).
%-export([req/2,req/3]).

-define(APP, "wwallo").

-define(RPP, "100").  % Number of requests per page: max: 100, default: 15

-define(URI, "http://search.twitter.com/search.json").
-define(DEFAULT_PIC, "http://s.twimg.com/a/1261519751/images/default_profile_1_normal.png").


search({Type, Term}) ->
    JSON = req(Type, Term),
    {ok, Obj,_} = rfc4627:decode(JSON),

    Results =  [ {rfc4627:get_field(E, "text", "n/a"),
            rfc4627:get_field(E, "from_user", "n/a"),
            rfc4627:get_field(E, "profile_image_url", ?DEFAULT_PIC)}
        || E <- rfc4627:get_field(Obj, "results", []) ],

    {Titles, Authors, Images} =  lists:unzip3(Results),

    Words = [ string:tokens(binary_to_list(N), " ") || N <- Titles ],
    List = reduce(Words),
    [{tweet, Titles}, {author, Authors}, {image, Images}, {count, count(List)}].

req(Type, Term) ->
    req(Type, Term, ?RPP).
req(Type, Term, Rpp) ->
    {URI, Query} = case Type of
        word -> {?URI, "?q="};
        geo -> {?URI, "?rpp=" ++ Rpp ++ "&geocode="}
    end,
    {ok, {{"HTTP/1.1",200,"OK"}, _Headers, Body}} = http:request(get,
        {URI ++ Query ++ edoc_lib:escape_uri(Term), []},
        [],
        [{body_format, binary}]
    ),
    Body.

reduce(L) ->
    reduce(L,[]).
reduce([],Acc) ->
    [ N || N <- lists:sort(lists:concat(Acc)), N /= "" ];
reduce([H|T], Acc) ->
    Words = [ string:to_lower(untag(N)) || N <- H, length(N) > 2 ],
    L = [ stem_en:stem(N) || N <- Words, filter(N) ],
    reduce(T, [L|Acc]).

count([]) ->
    [];
count([H|T]) ->
    count(T, {H,1}, []).
count([], N, Acc) ->
    lists:reverse(lists:keysort(2,[N|Acc]));
count([H|T], {H,N}, Acc) ->
    count(T, {H,N+1}, Acc);
count([H|T], {L,N}, Acc) ->
    count(T, {H,1}, [{L,N}|Acc]).

untag("#" ++ W) -> W;
untag(W) -> W.

filter("are") -> false;
filter("but") -> false;
filter("for") -> false;
filter("the") -> false;
filter("too") -> false;
filter("and") -> false;
filter("you") -> false;
filter("would") -> false;
filter(N) ->
    case re:run(N, "[^a-zA-Z0-9]") of
        nomatch ->
            true;
        _ ->
            false
    end.


