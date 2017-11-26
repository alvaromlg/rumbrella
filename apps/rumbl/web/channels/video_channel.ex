defmodule Rumbl.VideoChannel do
  use Rumbl.Web, :channel

  alias Rumbl.AnnotationView

  def join("videos:" <> video_id, params, socket) do
    last_seen_id = params["last_seen_id"] || 0
    video_id = String.to_integer(video_id)
    video = Repo.get!(Rumbl.Video, video_id)

    annotations = Repo.all(
      from a in assoc(video, :annotations),
      where: a.id > ^last_seen_id,
      order_by: [asc: a.at, asc: a.id],
      limit: 200,
      preload: [:user]
    )

    resp = %{annotations: Phoenix.View.render_many(annotations, Rumbl.AnnotationView,
                                                   "annotation.json")}

    {:ok, resp, assign(socket, :video_id, video_id)}
  end

  def handle_in(event, params, socket) do
    user = Repo.get(Rumbl.User, socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  # Controllers process a request. Channels hold a conversation.
  def handle_in("new_annotation", params, user, socket) do
    changeset =
    user
    |> build_assoc(:annotations, video_id: socket.assigns.video_id)
    |> Rumbl.Annotation.changeset(params)

    case Repo.insert(changeset) do
      {:ok, ann} ->
        broadcast_annotation(socket, ann)
        # Can be upgraded at elixir 1.2+ with Task.Supervisor.async_nolink
        # Page 232 phoenix book
        # Task.start_link doesnt care about the task result. Its async.
        Task.start_link(fn -> compute_additional_info(ann, socket) end)
        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  defp broadcast_annotation(socket, annotation) do
    annotation = Repo.preload(annotation, :user)
    rendered_ann = Phoenix.View.render(AnnotationView, "annotation.json", %{
      annotation: annotation
    })
    broadcast! socket, "new_annotation", rendered_ann
  end

  defp compute_additional_info(ann, socket) do
    # We ask to InfoSys for one result (limit 1) and we wait only 10 seconds
    for result <- Rumbl.InfoSys.compute(ann.body, limit: 1, timeout: 10_000) do
      attrs = %{url: result.url, body: result.text, at: ann.at}
      # we query the result and get it's backend (Wolfram, Google, etc)
      info_changeset =
        Repo.get_by!(Rumbl.User, username: result.backend)
        |> build_assoc(:annotations, video_id: ann.video_id)
        |> Rumbl.Annotation.changeset(attrs)

      # broadcast to all subscribers
      case Repo.insert(info_changeset) do
        {:ok, info_ann} -> broadcast_annotation(socket, info_ann)
        {:error, _changeset} -> :ignore
      end
    end
  end
end
