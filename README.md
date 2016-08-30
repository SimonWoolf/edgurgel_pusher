# Pusher [![Build Status](https://travis-ci.org/edgurgel/pusher.png?branch=master)](https://travis-ci.org/edgurgel/pusher) [![Hex pm](http://img.shields.io/hexpm/v/pusher.svg?style=flat)](https://hex.pm/packages/pusher)
## Description

Elixir library to access the Pusher REST API.

## Usage

```elixir
EdgurgelPusher.configure!("localhost", 8080, "app_id", "app_key", "secret")
```

```elixir
EdgurgelPusher.trigger("message", [text: "Hello!"], "chat-channel")
```

To get occupied channels:

```elixir
EdgurgelPusher.channels
```

To get users connected to a presence channel

```elixir
EdgurgelPusher.users("presence-demo")
```

## TODO

* Add tests
