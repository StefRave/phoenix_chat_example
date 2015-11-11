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
  def join("status", message, socket) do
    Process.flag(:trap_exit, true)
    #send(self, {:after_join, message})
    terminal_id = message["terminalId"]
    Logger.info "> join #{terminal_id}"

    {:ok, assign(socket, :terminal_id, terminal_id)}
  end

  # def handle_info({:after_join, msg}, socket) do
  #   broadcast! socket, "user:entered", %{user: msg["user"]}
  #   push socket, "join", %{status: "connected"}
  #   {:noreply, socket}
  # end

  def terminate(reason, socket) do
    Logger.info "> leave #{socket.assigns.terminal_id} #{inspect reason}"
    :ok
  end

  def handle_in("status", msg, socket) do
    Logger.info "> status #{socket.assigns.terminal_id} #{msg["body"]}"
    {:reply, :ok, socket}
  end
end
