defmodule Chat.UserSocket do
  use Phoenix.Socket

  channel "notification", Chat.NotificationChannel
  channel "terminal:*", Chat.TerminalChannel

  transport :websocket, Phoenix.Transports.WebSocket
  transport :longpoll, Phoenix.Transports.LongPoll

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
