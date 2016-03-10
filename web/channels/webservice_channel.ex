defmodule Chat.WebServiceChannel do
  use Phoenix.Channel
  require Logger

  @doc """
  Authorize socket to subscribe and broadcast events on this channel & topic

  Possible Return Values

  `{:ok, socket}` to authorize subscription for channel for requested topic

  `:ignore` to deny subscription/broadcast on this channel
  for the requested topic
  """
  def join("webservice:" <> client_id, _message, socket) do
    Process.flag(:trap_exit, true)
    #send(self, {:after_join, message})
    Logger.info "> webservice join #{client_id}"

    {:ok, assign(socket, :client_id, client_id)}
  end

  def terminate(reason, socket) do
    client_id = socket.assigns.client_id

    Logger.info "> webservice leave #{client_id} #{inspect reason}"

    :ok
  end

  def handle_in("webservicecall", msg, socket) do
    client_id = socket.assigns.client_id
    dest_terminal_id = msg["terminalId"]
    Logger.info "> webservicecall #{client_id} #{msg["body"]}"

    Chat.Endpoint.broadcast! "terminal:" <> dest_terminal_id, "webservicecall", Map.merge(msg, %{"clientId" => client_id}) 

    {:noreply, socket}
  end


end

