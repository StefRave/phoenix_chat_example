defmodule Chat.Registry do

	# Currently connected terminals are accumulated in a list.
	# This might not be the most desirable container due to 
	# lookups being linear. 
	# TODO: Modify this to something more efficient in the future.

	require Logger

	# The state is a map, with keys being terminal IDs and 
	# values being the latest notification supplied by the
	# terminal.
	#
	def start_link() do
		Agent.start_link(fn -> %{} end, name: __MODULE__)
	end

	def register(terminal_id, message) do
		Agent.update(__MODULE__, &add_terminal(&1, terminal_id, message))
	end

	def update_status(terminal_id, status) do
		Agent.update(__MODULE__, &Map.put(&1, terminal_id, status))
	end

	def unregister (terminal_id) do
		Agent.update(__MODULE__, &Map.delete(&1, terminal_id))
	end

	def count do
		Agent.get(__MODULE__, &Enum.count(&1))
	end

	def get do
		Agent.get(__MODULE__, fn map -> map end)
	end

	defp add_terminal(map, terminal_id, message) do
		if Map.has_key?(map, terminal_id) do
			Logger.info "[registry.ex] Duplicate terminal registration for #{terminal_id}." 
			map
		else
			# Initially, the terminal has no status. Just hacked it as empty string. 
			# TODO: We could maybe have some default state, or atleast a :no_status
			#       and {:status, status} format?
			Map.put(map, terminal_id, message)
		end
	end
end

