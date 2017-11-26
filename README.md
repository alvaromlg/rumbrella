# Rumbrella

Elixir mix --umbrella project with two applications:

## Rumbl

Phoenix framework (elixir) application which will allow us to take videos (hosted elsewhere) and attach comments to them in real time and play them back alongside the comments of other users.


## InfoSys

Rumbl backend which talks with Wolfram API


Run tests for all apps:

    $ mix test


You can start rumbl app from main directory:

    $ mix phoenix.server
