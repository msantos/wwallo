%% @author Michael Santos <michael.santos@gmail.com>
%% @copyright 2009 Michael Santos.

%% @doc TEMPLATE.

-module(wwallo).
-author('Michael Santos <michael.santos@gmail.com>').
-export([start/0, start_link/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
	ok ->
	    ok;
	{error, {already_started, App}} ->
	    ok
    end.

%% @spec start_link() -> {ok,Pid::pid()}
%% @doc Starts the app for inclusion in a supervisor tree
start_link() ->
    wwallo_deps:ensure(),
    ensure_started(crypto),
    ensure_started(webmachine),
    wwallo_sup:start_link().

%% @spec start() -> ok
%% @doc Start the wwallo server.
start() ->
    wwallo_deps:ensure(),
    ensure_started(crypto),
    ensure_started(webmachine),
    application:start(wwallo).

%% @spec stop() -> ok
%% @doc Stop the wwallo server.
stop() ->
    Res = application:stop(wwallo),
    application:stop(webmachine),
    application:stop(crypto),
    Res.
