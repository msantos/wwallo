%% @author Michael Santos <michael.santos@gmail.com>
%% @copyright 2009 Michael Santos.
%% @doc Provides resources for tweets based on geolocation.

-module(wwallo_resource).
-export([
        init/1,
        resource_exists/2,
        to_json/2,
        content_types_provided/2,

        handle_request/3
    ]).

-include_lib("webmachine/include/webmachine.hrl").

-define(Q, $"). %"
-define(S, $'). %'

init([]) ->
    %{{trace, "priv/tmp/trace"}, undefined}.
    {ok, undefined}.

content_types_provided(ReqData, Context) ->
    {[{"application/json", to_json}], ReqData, Context}.

to_json(ReqData, Context) ->
    {rfc4627:encode(Context), ReqData, Context}.

resource_exists(ReqData, _Context) ->
    handle_request(wrq:path_tokens(ReqData), ReqData, _Context).

handle_request(["null,"], ReqData, Context) ->
        handle_request(["null,5km"], ReqData, Context);

handle_request(["null," ++ Distance], ReqData, _Context) ->
    Peer = ipaddr:ipv4(wrq:peer(ReqData)),
    {ok, Rec} = egeoip:lookup(Peer),
    Latitude = hd(io_lib:format("~f", [egeoip:get(Rec, latitude)])),
    Longitude = hd(io_lib:format("~f", [egeoip:get(Rec, longitude)])),
    handle_request([Latitude ++ "," ++ Longitude ++ "," ++ Distance], ReqData, {Rec, Peer});

handle_request([Location], ReqData, Context) ->
    error_logger:info_report([{url, "/geocode/" ++ Location}, {context, Context}]),

    well_formed(Location),

    {Peer, City, Country} =  case Context of 
        {Rec, IP} ->
            C1 = egeoip:get(Rec, city),
            C2 = egeoip:get(Rec, country_name),
            {IP, C1, C2};
        _ ->
            IP = ipaddr:ipv4(wrq:peer(ReqData)),
            {ok, Rec} = egeoip:lookup(IP),
            C1 = egeoip:get(Rec, city),
            C2 = egeoip:get(Rec, country_name),
            {IP, C1, C2}
    end,

    error_logger:info_report([{peer, Peer}, {city, City}, {country, Country}]),

    [{tweet,Tweet},{author, Authors},{image, Images},{count,Count}] = tw:search({geo, Location}),
    Result = [ 
        {pos, list_to_binary(Location)},
        {address, list_to_binary(Peer)},
        {country, list_to_binary(Country)},
        {city, City},
        {tweet, Tweet},
        {author, Authors},
        {image, Images},
        {count, {obj, [ {list_to_binary(W), list_to_binary(integer_to_list(N))}
                    || {W,N} <- Count ]}}
    ],
    {true, ReqData, {obj, Result}};

handle_request(_, ReqData, Context) ->
    {false, ReqData, Context}.

well_formed(Str) ->
    {match,_} = re:run(Str, "^-*\\d+\\.\\d+,-*\\d+\\.\\d+,\\d+km").


