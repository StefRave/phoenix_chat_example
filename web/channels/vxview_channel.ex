defmodule Chat.VxViewChannel do
  use Phoenix.Channel
  require Logger

  @doc """
  Authorize socket to subscribe and broadcast events on this channel & topic

  Possible Return Values

  `{:ok, socket}` to authorize subscription for channel for requested topic

  `:ignore` to deny subscription/broadcast on this channel
  for the requested topic
  """
  def join("vx_view:" <> terminal_id, _message, socket) do
    Process.flag(:trap_exit, true)
    #send(self, {:after_join, message})
    Logger.info "> vx_view join #{terminal_id}"

    Chat.Endpoint.broadcast! "terminal:" <> terminal_id, "start", %{ } 

    {:ok, assign(socket, :terminal_id, terminal_id)}
  end

  def terminate(reason, socket) do
    terminal_id = socket.assigns.terminal_id

    Logger.info "> terminal leave #{terminal_id} #{inspect reason}"

    Chat.Endpoint.broadcast! "terminal:" <> terminal_id, "stop", %{ } 
    :ok
  end

  def handle_in("keypress", msg, socket) do
    terminal_id = socket.assigns.terminal_id
    Logger.info "> keypress #{terminal_id} #{msg["body"]}"

    Chat.Endpoint.broadcast! "terminal:" <> terminal_id, "keypress", msg 

    {:noreply, socket}
  end

  def handle_in("screenpress", msg, socket) do
    terminal_id = socket.assigns.terminal_id
    Logger.info "> screenpress #{terminal_id} #{msg["body"]}"

    Chat.Endpoint.broadcast! "terminal:" <> terminal_id, "screenpress", msg 

    {:noreply, socket}
  end

end

