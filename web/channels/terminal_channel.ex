defmodule Chat.TerminalChannel do
  use Phoenix.Channel
  require Logger

  @doc """
  Authorize socket to subscribe and broadcast events on this channel & topic

  Possible Return Values

  `{:ok, socket}` to authorize subscription for channel for requested topic

  `:ignore` to deny subscription/broadcast on this channel
  for the requested topic
  """
  def join("terminal:" <> terminal_id, _message, socket) do
    Process.flag(:trap_exit, true)
    #send(self, {:after_join, message})
    Logger.info "> terminal join #{terminal_id}"

    Chat.Endpoint.broadcast! "notification", "new:msg", %{ user: terminal_id, body: "Joined"} 

    {:ok, assign(socket, :terminal_id, terminal_id)}
  end

  def terminate(reason, socket) do
    terminal_id = socket.assigns.terminal_id

    Logger.info "> terminal leave #{terminal_id} #{inspect reason}"

    Chat.Endpoint.broadcast! "notification", "new:msg", %{ user: terminal_id, body: "Left"} 
    :ok
  end

  def handle_in("status", msg, socket) do
    terminal_id = socket.assigns.terminal_id
    Logger.info "> status #{terminal_id} #{msg["body"]}"

    Chat.Endpoint.broadcast! "notification", "new:msg", %{ user: terminal_id, body: msg["body"]} 

    {:noreply, socket}
  end

  def handle_in("pushntf", msg, socket) do
    dest_terminal_id = msg["terminalId"]
    content = msg["content"]

    Logger.info "> pushntf #{dest_terminal_id} #{content}"
    Chat.Endpoint.broadcast! "terminal:" <> dest_terminal_id, "pushntf", %{ body: content} 

    {:noreply, socket}
  end
end
