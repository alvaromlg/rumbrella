defmodule Rumbl.Counter do

  """
  Basic implementation of Counter Server
  def inc(pid), do: send(pid, :inc)

  def dec(pid), do: send(pid, :dec)

  def val(pid, timeout \\ 5000) do
    ref = make_ref()
    send(pid, {:val, self(), ref})
    receive do
      {^ref, val} -> val
    after timeout -> exit(:timeout)
    end
  end

  def start_link(initial_val) do
    {:ok, spawn_link(fn -> listen(initial_val) end)}
  end

  defp(listen(val) do
    receive do
      :inc -> listen(val + 1)
      :dec -> listen(val - 1)
      {:val, sender, ref} ->
        send sender, {ref, val}
        listen(val)
    end
  end
  """

  # Implementation of GenServer
  use GenServer

  def inc(pid), do: GenServer.cast(pid, :inc)

  def dec(pid), do: GenServer.cast(pid, :dec)

  def val(pid) do
    GenServer.call(pid, :val)
  end

  def start_link(initial_val) do
    GenServer.start_link(__MODULE__, initial_val)
  end

  def init(initial_val) do
    #Process.send_after(self, :tick, 1000) sends :tick every 1000 miliseconds
    {:ok, initial_val}
  end

  # crashing server when val lesser or equal to zero
  def handle_info(:tick, val) when val <= 0, do: raise "boom!"
  def handle_info(:tick, val) do
    """
    prints val and sends a :tick every 1000 miliseconds
    IO.puts "tick #{val}"
    Process.send_after(self, :tick, 1000)
    """
    {:noreply, val - 1}
  end

  def handle_cast(:inc, val) do
    {:noreply, val + 1}
  end

  def handle_cast(:dec, val) do
    {:noreply, val - 1}
  end

  def handle_call(:val, _from, val) do
    {:reply, val, val}
  end
end
