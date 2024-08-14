defmodule ElixirconfVoxelsWeb.VoxelsLive do
  use ElixirconfVoxelsWeb, :live_view
  use ElixirconfVoxelsNative, :live_view

  @templates %{
    "Castle" => ElixirconfVoxels.WorldTemplates.castle,
    "Island" => ElixirconfVoxels.WorldTemplates.island,
    "Elixir Logo" => ElixirconfVoxels.WorldTemplates.elixir_logo,
    "DockYard Logo" => ElixirconfVoxels.WorldTemplates.dockyard_logo,
    "Phoenix Logo" => ElixirconfVoxels.WorldTemplates.phoenix_logo,
  }

  def mount(_params, _session, socket) do
    ElixirconfVoxelsWeb.Endpoint.subscribe(ElixirconfVoxels.World.pubsub_topic)

    id = self() |> :erlang.pid_to_list() |> to_string()
    socket = if connected?(socket) do
      ElixirconfVoxelsWeb.Presence.track_user(id, %{id: id})
      ElixirconfVoxelsWeb.Presence.subscribe()
      assign(socket, presences: ElixirconfVoxelsWeb.Presence.list_online_users())
    else
      assign(socket, presences: [])
    end

    {:ok, assign(
      socket,
      scale: 0.7,
      rotation: 0,
      width: ElixirconfVoxels.World.size,
      height: ElixirconfVoxels.World.size,
      depth: ElixirconfVoxels.World.size,
      blocks: ElixirconfVoxels.World.world,
      color: "system-red",
      templates: Map.keys(@templates)
    )}
  end

  def handle_info({ElixirconfVoxelsWeb.Presence, {:join, presence}}, socket) do
    {:noreply, assign(socket, presences: [presence | socket.assigns.presences])}
  end

  def handle_info({ElixirconfVoxelsWeb.Presence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply, assign(socket, presences: List.delete(socket.assigns.presences, presence))}
    else
      {:noreply, assign(socket, presences: List.delete(socket.assigns.presences, presence))}
    end
  end

  def handle_info(%{topic: "world", payload: state}, socket) do
    {:noreply, assign(socket, blocks: state)}
  end

  def render(assigns) do
    ~H"hello, world!"
  end

  def handle_event("set-block-base", %{ "x" => x, "z" => z }, socket) do
    {:noreply, assign(socket, blocks: ElixirconfVoxels.World.put({String.to_integer(x), 0, String.to_integer(z)}, socket.assigns.color))}
  end

  def handle_event(
    "set-block-relative",
    %{
      "x" => x, "y" => y, "z" => z,
      "_location" => [tap_x, tap_y, tap_z]
    },
    socket
  ) do
    x = String.to_integer(x)
    y = String.to_integer(y)
    z = String.to_integer(z)

    [tap_x, tap_y, tap_z] = case rem(socket.assigns.rotation, 4) do
      0 ->
        [tap_x, tap_y, tap_z]
      1 ->
        [-tap_z, tap_y, tap_x]
      2 ->
        [-tap_x, tap_y, -tap_z]
      3 ->
        [tap_z, tap_y, -tap_x]
    end

    case socket.assigns.color do
      nil ->
        {:noreply, assign(socket, blocks: ElixirconfVoxels.World.put({x, y, z}, socket.assigns.color))}
      color ->
        {tap_x, tap_y, tap_z} = {
          (tap_x + (socket.assigns.scale / 2) - (socket.assigns.scale / socket.assigns.width / 2)) * (socket.assigns.width / socket.assigns.scale),
          (tap_y + (socket.assigns.scale / 2) - (socket.assigns.scale / socket.assigns.height / 2)) * (socket.assigns.height / socket.assigns.scale),
          (tap_z + (socket.assigns.scale / 2) - (socket.assigns.scale / socket.assigns.depth / 2)) * (socket.assigns.depth / socket.assigns.scale)
        }

        offset = %{ 0 => tap_x - x, 1 => tap_y - y, 2 => tap_z - z }

        {axis, direction} = Enum.max_by(offset, fn {_, v} -> abs(v) end)

        pos = {x, y, z}
        pos = put_elem(pos, axis, elem(pos, axis) + (if direction > 0, do: 1, else: -1))
        {:noreply, assign(socket, blocks: ElixirconfVoxels.World.put(pos, color))}
    end

  end

  def handle_event("pick-color", %{ "color" => "delete" }, socket) do
    {:noreply, assign(socket, color: nil)}
  end

  def handle_event("pick-color", %{ "color" => color }, socket) do
    {:noreply, assign(socket, color: color)}
  end

  def handle_event("rotate", _params, socket) do
    {:noreply, assign(socket, rotation: socket.assigns.rotation + 1)}
  end

  def handle_event("clear", _params, socket) do
    {:noreply, assign(socket, blocks: ElixirconfVoxels.World.clear())}
  end

  def handle_event("load", %{ "template" => template }, socket) do
    blocks = @templates[template]
    ElixirconfVoxels.World.load(blocks)
    {:noreply, assign(socket, blocks: blocks)}
  end

  def handle_event("fill-base", %{ "color" => color }, socket) do
    size = ElixirconfVoxels.World.size()
    blocks = Enum.reduce(List.flatten(for x <- 0..size do
      for z <- 0..size do
        {x, 0, z}
      end
    end), %{}, fn coord, acc -> Map.put(acc, coord, color) end)
    ElixirconfVoxels.World.load(blocks)
    {:noreply, assign(socket, blocks: blocks)}
  end
end
