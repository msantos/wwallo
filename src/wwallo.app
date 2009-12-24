{application, wwallo,
 [{description, "wwallo"},
  {vsn, "0.1"},
  {modules, [
    wwallo,
    wwallo_app,
    wwallo_sup,
    wwallo_deps,
    wwallo_resource
  ]},
  {registered, []},
  {mod, {wwallo_app, []}},
  {env, []},
  {applications, [kernel, stdlib, crypto]}]}.
