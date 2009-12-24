%% @author Bryan Fink
%% @doc Serve static content from disk
%%      Note: for a much more full-featured filesystem
%%      resource, have a look at demo_fs_resource.erl
%%      in webmachine's demo directory.
-module(static_resource).
-export([init/1,
	 content_types_provided/2,
	 resource_exists/2,
	 content/2]).

-record(context, {root, filepath}).

-include_lib("webmachine/include/webmachine.hrl").

init(Opts) ->
    {ok, #context{root=proplists:get_value(root, Opts)}}.

content_types_provided(RD, Context) ->
    Path = case wrq:disp_path(RD) of
        "" -> "index.html";
        Any -> Any
    end,
    Mime = webmachine_util:guess_mime(Path),
    {[{Mime, content}], RD, Context}.

resource_exists(RD, Context=#context{root=Root}) ->
    File = case wrq:disp_path(RD) of
        "" -> "index.html";
        Any -> Any
    end,
    FP = filename:join([Root, File]),
    case filelib:is_regular(FP) of
	true ->
	    {true, RD, Context#context{filepath=FP}};
	_ ->
	    {false, RD, Context}
    end.

content(RD, Context=#context{filepath=FP}) ->
    {ok, Data} = file:read_file(FP),
    {Data, RD, Context}.


