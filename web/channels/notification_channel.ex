defmodule Chat.NotificationChannel do
  use Phoenix.Channel
  require Logger

  @doc """
  Authorize socket to subscribe and broadcast events on this channel & topic

  Possible Return Values

  `{:ok, socket}` to authorize subscription for channel for requested topic

  `:ignore` to deny subscription/broadcast on this channel
  for the requested topic
  """
  def join("notification", _message, socket) do
    Process.flag(:trap_exit, true)
    Logger.info "> notification join"

    {:ok, socket}
  end

  def terminate(reason, _socket) do
    Logger.info "> notification leave #{inspect reason}"
    :ok
  end

  def handle_in("pushntf", msg, socket) do
    terminal_id = msg["terminalId"]
    content = msg["content"]

    Logger.info "> pushntf #{terminal_id} #{content}"
    Chat.Endpoint.broadcast! "terminal:" <> terminal_id, "pushntf", %{ body: content} 

    {:reply, :ok, socket}
  end
end
