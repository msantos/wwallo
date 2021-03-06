%% @author Michael Santos <michael.santos@gmail.com>
%% @copyright 2009 Michael Santos.

%% @doc Callbacks for the wwallo application.

-module(wwallo_app).
-author('author <author@example.com>').

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for wwallo.
start(_Type, _StartArgs) ->
    wwallo_deps:ensure(),
    wwallo_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for wwallo.
stop(_State) ->
    ok.
