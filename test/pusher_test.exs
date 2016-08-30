defmodule EdgurgelPusherTest do
  use ExUnit.Case
  import Mock
  import EdgurgelPusher

  # `setup` is called before each test is run
  setup do
    :application.set_env(:edgurgel_pusher, :app_id, "app_id")
    {:ok, []}
  end

  test "configure! should change application env" do
    configure!("host", "port", "updated_app_id", "app_key", "secret")
    vars = :application.get_all_env(:edgurgel_pusher)

    assert vars[:host]    == "host"
    assert vars[:port]    == "port"
    assert vars[:app_id]  == "updated_app_id"
    assert vars[:app_key] == "app_key"
    assert vars[:secret]  == "secret"
  end

  @response_succesful_message %HTTPoison.Response{
    body: %{},
    status_code: 200
  }

  @expected_payload %{
    name: "event-name",
    channels: ["channel"],
    data: "data"
  } |> JSX.encode!

  test_with_mock ".trigger sends the payload to a single channel", EdgurgelPusher.HttpClient,
  [post!: fn("/apps/app_id/events", @expected_payload, _) -> @response_succesful_message end] do
    result = EdgurgelPusher.trigger("event-name", "data", "channel")
    expected = :ok
    assert result == expected
  end

  @expected_payload_with_socket_id %{
    name: "event-name",
    channels: ["channel"],
    data: "data",
    socket_id: "blah"
    } |> JSX.encode!

    test_with_mock ".trigger sends the payload with a socket_id", EdgurgelPusher.HttpClient,
    [post!: fn("/apps/app_id/events", @expected_payload_with_socket_id, _) -> @response_succesful_message end] do
      result = EdgurgelPusher.trigger("event-name", "data", "channel", "blah")
      expected = :ok
      assert result == expected
    end

  @response_with_channel %HTTPoison.Response{
    body: %{"channels" => %{"test_channel" => %{}}},
    status_code: 200
  }

  test_with_mock ".channels calls the http client for list of channels", EdgurgelPusher.HttpClient,
  [get!: fn("/apps/app_id/channels") -> @response_with_channel end] do
    result = EdgurgelPusher.channels
    expected = {:ok, %{"test_channel" => %{}}}
    assert result == expected
  end

  @response_with_channel_info %HTTPoison.Response{
    body: %{"occupied" => true, "user_count" => 42},
    status_code: 200
  }

  test_with_mock ".channel with an argument returns the user count for the channel", EdgurgelPusher.HttpClient,
  [get!: fn("/apps/app_id/channels/test_info_channel", %{}, qs: %{info: "subscription_count"}) -> @response_with_channel_info end] do
    result = EdgurgelPusher.channel "test_info_channel"
    expected = {:ok, %{"occupied" => true, "user_count" => 42}}
    assert result == expected
  end

  @response_with_users %HTTPoison.Response{
    body: %{"users" => [%{"id" => 3}, %{"id" => 57}]},
    status_code: 200
  }

  test_with_mock ".users returns users in a presence channel", EdgurgelPusher.HttpClient,
  [get!: fn("/apps/app_id/channels/presence-foobar/users") -> @response_with_users end] do
    result = EdgurgelPusher.users "presence-foobar"
    expected = {:ok, [%{"id" => 3}, %{"id" => 57}]}
    assert result == expected
  end

end
