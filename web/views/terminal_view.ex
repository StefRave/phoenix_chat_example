defmodule Chat.TerminalView do
  use Chat.Web, :view

  def render("terminals.json", %{terminals: terminals}) do
  	terminals
  end
end
