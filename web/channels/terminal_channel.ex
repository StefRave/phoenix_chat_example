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
  def join("terminal:" <> terminal_id, message, socket) do
    Process.flag(:trap_exit, true)
    #send(self, {:after_join, message})

    # Register this terminal in the registry.
    Chat.Registry.register(terminal_id, message)

    # For debugging purposes, print all connected terminals.
    Logger.info "Terminal #{terminal_id} connected. Currently connected terminals: "
    Logger.info (inspect Chat.Registry.get())

    Chat.Endpoint.broadcast! "notification", "new:msg", %{ user: terminal_id, body: "Joined"} 

    {:ok, assign(socket, :terminal_id, terminal_id)}
  end

  def terminate(reason, socket) do
    terminal_id = socket.assigns.terminal_id

    # Unregister this terminal in the registry.
    Chat.Registry.unregister(terminal_id)

    # For debugging purposes, print all connected terminals.
    Logger.info "Terminal #{terminal_id} disconnected (#{inspect reason}). Currently connected terminals: "
    Logger.info (inspect Chat.Registry.get())

    Chat.Endpoint.broadcast! "notification", "new:msg", %{ user: terminal_id, body: "Left"} 
    :ok
  end

  def handle_in("status", msg, socket) do
    terminal_id = socket.assigns.terminal_id
    Logger.info "> status #{terminal_id} #{msg["body"]}"

    # Update the status of this terminal in our registry.
    Chat.Registry.update_status(terminal_id, msg["body"])

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

  def handle_in("vxscreenshot", msg, socket) do
    terminal_id = socket.assigns.terminal_id
    Logger.info "> vxscreenshot #{terminal_id} #{msg["body"]}"

    Chat.Endpoint.broadcast! "vx_view:" <> terminal_id, "screenshot", msg 

    {:noreply, socket}
  end

  def handle_in("webserviceresponse", msg, socket) do
    terminal_id = socket.assigns.terminal_id
    client_id = msg["clientId"]
    Logger.info "> webservicersp #{terminal_id} #{client_id}"

    Chat.Endpoint.broadcast! "webservice:" <> client_id, "webserviceresponse", msg 

    {:noreply, socket}
  end

end
