defmodule InfoSysTest do
  use ExUnit.Case
  alias InfoSys.Result

  defmodule TestBackend do
    @moduledoc """
    Stub backend response which simulates Wolfram backend
    """

    def start_link(query, ref, owner, limit) do
      Task.start_link(__MODULE__, :fetch, [query, ref, owner, limit])
    end
    def fetch("result", ref, owner, _limit) do
      send(owner, {:results, ref, [%Result{backend: "test", text: "result"}]})
    end
    def fetch("none", ref, owner, _limit) do
      send(owner, {:results, ref, []})
    end
    def fetch("timeout", _ref, owner, _limit) do
      send(owner, {:backend, self()})
      :timer.sleep(:infinity) # forces a timeout
    end
  end

  test "compute/2 with backend results" do
    assert [%Result{backend: "test", text: "result"}] =
      InfoSys.compute("result", backends: [TestBackend])
  end

  test "compute/2 with no backend results" do
    assert [] = InfoSys.compute("none", backends: [TestBackend])
  end

  test "compute/2 with timeout returns no results and kills workers" do
    results = InfoSys.compute("timeout", backends: [TestBackend], timeout: 10)
    assert results == []
    assert_receive {:backend, backend_pid}
    # not using refute Process.alive?(pid) because it calls Process.exit as an
    # asynchronous exit signal and will lead to a race condition and test will
    # pass or fail depending on the race condition.
    ref = Process.monitor(backend_pid)
    assert_receive {:DOWN, ^ref, :process, _pid, _reason}
    refute_received {:DOWN, _, _, _, _}
    refute_received :timedout
  end
end
