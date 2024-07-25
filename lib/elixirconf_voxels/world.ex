defmodule ElixirconfVoxels.World do
  use GenServer

  @pubsub_topic "world"
  @size 25

  # Callbacks

  @impl true
  def init(world \\ %{}) do
    {:ok, world}
  end

  @impl true
  def handle_call(:world, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:put, coord, nil}, _from, state) do
    state = Map.delete(state, coord)
    ElixirconfVoxelsWeb.Endpoint.broadcast(@pubsub_topic, "world_changed", state)
    {:reply, state, state}
  end

  @impl true
  def handle_call({:put, {x, y, z} = coord, color}, _from, state)
    when x < @size and y < @size and z < @size
      and x >= 0 and y >= 0 and z >= 0
  do
    state = Map.put(state, coord, color)
    ElixirconfVoxelsWeb.Endpoint.broadcast(@pubsub_topic, "world_changed", state)
    {:reply, state, state}
  end

  # invalid coord
  @impl true
  def handle_call({:put, _coord, _color}, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:clear, _from, _state) do
    ElixirconfVoxelsWeb.Endpoint.broadcast(@pubsub_topic, "world_changed", %{})
    {:reply, %{}, %{}}
  end

  @impl true
  def handle_call({:load, template}, _from, _state) do
    ElixirconfVoxelsWeb.Endpoint.broadcast(@pubsub_topic, "world_changed", template)
    {:reply, template, template}
  end

  # API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def size, do: @size
  def world, do: GenServer.call(__MODULE__, :world)

  def put(coord, color), do: GenServer.call(__MODULE__, {:put, coord, color})

  def clear(), do: GenServer.call(__MODULE__, :clear)

  def load(template), do: GenServer.call(__MODULE__, {:load, template})

  def pubsub_topic, do: @pubsub_topic
end
