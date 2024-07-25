defmodule ElixirconfVoxelsWeb.VoxelsLive.SwiftUI do
  use ElixirconfVoxelsNative, [:render_component, format: :swiftui]

  attr :blocks, :any

  attr :width, :any
  attr :height, :any
  attr :depth, :any

  attr :scale, :any
  attr :rotation, :any

  attr :rest, :global
  def world(assigns) do
    ~LVN"""
    <Entity
      id="world"
      transform:rotation={Nx.to_list(Quaternion.euler(0, :math.pi / 2 * @rotation, 0))}
      transform:duration={1}

      cameraTarget

      {@rest}
    >
      <ModelEntity
        id="base"

        generateCollisionShapes
        generateCollisionShapes:static

        transform:translation={[
          0,
          -(@scale / 2),
          0
        ]}

        phx-click="set-block-base"
      >
        <SimpleMaterial
          template="materials"
          color="system-white"
        />
        <Group template="mesh">
          <%= for x <- 0..(@width - 1)//5 do %>
            <Plane
              :for={z <- 0..(@depth - 1)//5}

              offset={[
                -(@scale / 2) + ((@scale / @width) * 5 / 2) + (x * (@scale / @width)),
                0,
                -(@scale / 2) + ((@scale / @width) * 5 / 2) + (z * (@scale / @width)),
              ]}

              width={(@scale / @width) * 5 - 0.0025}
              depth={(@scale / @depth) * 5 - 0.0025}

              cornerRadius={0.01}
            />
          <% end %>
        </Group>
        <Group template="components">
          <OpacityComponent opacity={0.5} />
          <HoverEffectComponent />
        </Group>
      </ModelEntity>
      <%= for {{x, y, z}, color} <- @blocks do %>
        <ModelEntity
          id={"#{x},#{y},#{z}"}

          transform:translation={[
            (x * (@scale / @width)) - (@scale / 2) + (@scale / @width / 2),
            (y * (@scale / @height)) - (@scale / 2) + (@scale / @height / 2),
            (z * (@scale / @depth)) - (@scale / 2) + (@scale / @depth / 2)
          ]}

          generateCollisionShapes
          generateCollisionShapes:static

          phx-click="set-block-relative"
          phx-value-x={x}
          phx-value-y={y}
          phx-value-z={z}
        >
          <SimpleMaterial
            template="materials"
            color={color}
            roughness={0.8}
          />
          <Box
            template="mesh"
            size={[@scale / @width, @scale / @height, @scale / @depth]}
          />
          <Group template="components">
            <HoverEffectComponent />
          </Group>
        </ModelEntity>
      <% end %>
    </Entity>
    """
  end

  attr :color, :any
  def palette(assigns) do
    ~LVN"""
    <HStack style="buttonStyle(.plain); padding(8); glassBackgroundEffect();">
      <Button phx-click="rotate">
        <Image systemName="arrow.2.circlepath.circle.fill" style="imageScale(.large); symbolRenderingMode(.hierarchical);" />
      </Button>
      <Button
        :for={color <- ["system-red", "system-orange", "system-yellow", "system-green", "system-mint", "system-teal", "system-cyan", "system-blue", "system-indigo", "system-purple", "system-pink", "system-brown", "system-white", "system-gray", "system-black"]}
        phx-click="pick-color"
        phx-value-color={color}
      >
        <ZStack style="frame(width: 24, height: 24)">
          <Circle class={color} />
          <Circle :if={@color == color} style="stroke(.white, lineWidth: 4)" />
        </ZStack>
      </Button>
      <Button
        phx-click="pick-color"
        phx-value-color="delete"
        style="foregroundStyle(.red);"
      >
        <ZStack style="frame(width: 24, height: 24)">
          <Image
            systemName="trash.circle.fill"
            style="resizable(); scaledToFill(); symbolRenderingMode(.hierarchical)"
          />
          <Circle :if={@color == nil} style="stroke(.red, lineWidth: 3)" />
        </ZStack>
      </Button>
    </HStack>
    """
  end
end
