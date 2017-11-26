defmodule Rumbl do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(Rumbl.InfoSys.Supervisor, []), # new supervisor
      # Start the Ecto repository
      supervisor(Rumbl.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Rumbl.Endpoint, []),
      # Start your own worker by calling: Rumbl.Worker.start_link(arg1, arg2, arg3)
      # worker(Rumbl.Worker, [arg1, arg2, arg3]),
      # by default the worker will restart automatically with :permanent
      # worker(Rumbl.Counter, [5], restart: :permanent),
      # :permanent -> the child is always restarted (default).
      # :temporary -> the child is never restarted
      # :transient the child is restarted only if it terminates abnormally, with an exist reason other
      # than :normal, :shutdown, or {:shutdown, term}
      worker(Rumbl.Counter, [5]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    # :one_for_one -> if a child terminates, the supervisor restarts only that process
    # :one_for_all -> if a child terminates, the supervisor terminates and restart all the childrens
    # :rest_for_one -> if a child terminates, supervisor terminates all children processes defined after 
    # the one that dies. Then the supervisor restarts all the terminated processes.
    # :simple_one_for_one -> same that :one_for_one but used for dynamically supervise processes.
    opts = [strategy: :one_for_one, name: Rumbl.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Rumbl.Endpoint.config_change(changed, removed)
    :ok
  end
end
