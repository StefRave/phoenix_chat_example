defmodule Chat.TerminalController do
  use Chat.Web, :controller

  def index(conn, _params) do
  	terminals = Chat.Registry.get()
    render conn, "terminals.json", terminals: terminals
  end
end
