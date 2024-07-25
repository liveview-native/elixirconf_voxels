defmodule ElixirconfVoxelsWeb.CoreComponents.SwiftUI do
  @moduledoc """
  Provides core UI components built for SwiftUI.
  > #### No LiveForm Installed! {: .warning}
  >
  > You will not get access to any of the form related inputs without LiveForm. After it is installed regenerate
  > this file with `mix lvn.swiftui.gen --no-xcodegen`

  This file contains feature parity components to your applications's CoreComponent module.
  The goal is to retain a common API for fast prototyping. Leveraging your existing knowledge
  of the `ElixirconfVoxelsWeb.CoreComponents` functions you should expect identical functionality for similarly named
  components between web and native. That means utilizing your existing `handle_event/3` functions to manage state
  and stay focused on adding new templates for your native applications.

  The default components use `LiveViewNative.SwiftUI.UtilityStyles`, a generated styling syntax
  that allows you to call nearly any modifier. Refer to the documentation in `LiveViewNative.SwiftUI` for more information.

  Icons are referenced by a system name. Read more about the [Xcode Asset Manager](https://developer.apple.com/documentation/xcode/asset-management)
  to learn how to include different assets in your LiveView Native applications. In addition, you can also use [SF Symbols](https://developer.apple.com/sf-symbols/).
  On any MacOS open Spotlight and search `SF Symbols`. The catalog application will provide a reference name that can be used. All SF Symbols
  are incuded with all SwiftUI applications.

  Most of this documentation was "borrowed" from the analog Phoenix generated file to ensure this project is expressing the same behavior.
  """

  use LiveViewNative.Component

  @doc """
  Renders a header with title.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~LVN"""
    <VStack style={[
      "navigationTitle(:title)",
      "navigationSubtitle(:subtitle)",
      "toolbar(content: :toolbar)"
    ]}>
      <Text template="title">
        <%= render_slot(@inner_block) %>
      </Text>
      <Text :if={@subtitle != []} template="subtitle">
        <%= render_slot(@subtitle) %>
      </Text>
      <ToolbarItemGroup template="toolbar">
        <%= render_slot(@actions) %>
      </ToolbarItemGroup>
    </VStack>
    """
  end

  @doc """
  Renders a modal.

  ## Examples

      <.modal show={@show} id="confirm-modal">
        This is a modal.
      </.modal>

  An event name may be passed to the `:on_cancel` to configure
  the closing/cancel event, for example:

      <.modal show={@show} id="confirm" on_cancel="toggle-show">
        This is another modal.
      </.modal>

  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, :string, default: nil
  slot :inner_block, required: true

  def modal(assigns) do
    ~LVN"""
    <VStack
      id={@id}
      :if={@show}
      style='sheet(isPresented: attr("presented"), content: :content)'
      presented={@show}
      phx-change={@on_cancel}
    >
      <VStack template="content">
        <%= render_slot(@inner_block) %>
      </VStack>
    </VStack>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~LVN"""
    <% msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind) %>
    <VStack
      :if={msg != nil}
      style={[
        "hidden()",
        ~s[alert(attr("title"), isPresented: attr("presented"), actions: :actions, message: :message)]
      ]}
      title={@title}
      presented={msg != nil}
      id={@id}
      {@rest}
      phx-change="lv:clear-flash"
      phx-value-key={@kind}
    >
      <Text template="message"><%= msg %></Text>
      <Button template="actions">Ok</Button>
    </VStack>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~LVN"""
    <Group id={@id}>
      <.flash kind={:info} title={"Success!"} flash={@flash} />
      <.flash kind={:error} title={"Error!"} flash={@flash} />
    </Group>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  @doc type: :component

  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    ~LVN"""
    <Table id={@id}>
      <Group template="columns">
        <TableColumn :for={col <- @col}><%= col[:label] %></TableColumn>
        <TableColumn :if={@action != []} />
      </Group>
      <Group template="rows">
        <TableRow
          :for={{row, i} <- Enum.with_index(@rows)}
          id={(@row_id && @row_id.(row)) || i}
        >
          <VStack :for={col <- @col}>
            <%= render_slot(col, @row_item.(row)) %>
          </VStack>
          <HStack :if={@action != []}>
            <%= for action <- @action do %>
              <%= render_slot(action, @row_item.(row)) %>
            <% end %>
          </HStack>
        </TableRow>
      </Group>
    </Table>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~LVN"""
    <List>
      <LabeledContent :for={item <- @item}>
        <Text template="label"><%= item.title %></Text>
        <%= render_slot(item) %>
      </LabeledContent>
    </List>
    """
  end

  @doc """
  Renders a system image from the Asset Manager in Xcode
  or from SF Symbols.

  ## Examples

      <.icon name="xmark.diamond" />
  """
  @doc type: :component

  attr :name, :string, required: true
  attr :rest, :global

  def icon(assigns) do
    ~LVN"""
    <Image systemName={@name} {@rest} />
    """
  end

  @doc """
  Renders an image from a url

  Will render an [`AsyncImage`](https://developer.apple.com/documentation/swiftui/asyncimage)
  You can customize the lifecycle states of with the slots.
  """

  attr :url, :string, required: true
  attr :rest, :global
  slot :empty, doc: """
    The empty state that will render before has successfully been downloaded.

        <.image url={~p"/assets/images/logo.png"}>
          <:empty>
            <Image systemName="myloading.spinner" />
          </:empty>
        </.image>

    [See SwiftUI docs](https://developer.apple.com/documentation/swiftui/asyncimagephase/success(_:))
    """
  slot :success, doc: """
    The success state that will render when the image has successfully been downloaded.

        <.image url={~p"/assets/images/logo.png"}>
          <:success class="main-logo"/>
        </.image>

    [See SwiftUI docs](https://developer.apple.com/documentation/swiftui/asyncimagephase/success(_:))
    """
  do
    attr :class, :string
    attr :style, :string
  end
  slot :failure, doc: """
    The failure state that will render when the image fails to downloaded.

        <.image url={~p"/assets/images/logo.png"}>
          <:failure class="image-fail"/>
        </.image>

    [See SwiftUI docs](https://developer.apple.com/documentation/swiftui/asyncimagephase/failure(_:))

  """
  do
    attr :class, :string
    attr :style, :string
  end

  def image(assigns) do
    ~LVN"""
    <AsyncImage url={@url} {@rest}>
      <Group template="phase.empty" :if={@empty != []}>
        <%= render_slot(@empty) %>
      </Group>
      <.image_success slot={@success} />
      <.image_failure slot={@failure} />
    </AsyncImage>
    """
  end

  defp image_success(%{ slot: [%{ inner_block: nil }] } = assigns) do
    ~LVN"""
    <AsyncImage image template="phase.success" :for={slot <- @slot} class={Map.get(slot, :class)} {%{ style: Map.get(slot, :style) }} />
    """
  end

  defp image_success(assigns) do
    ~LVN"""
    <Group template="phase.success" :if={@slot != []}>
      <%= render_slot(@slot) %>
    </Group>
    """
  end

  defp image_failure(%{ slot: [%{ inner_block: nil }] } = assigns) do
    ~LVN"""
    <AsyncImage error template="phase.failure" :for={slot <- @slot} class={Map.get(slot, :class)} {%{ style: Map.get(slot, :style) }} />
    """
  end

  defp image_failure(assigns) do
    ~LVN"""
    <Group template="phase.failure" :if={@slot != []}>
      <%= render_slot(@slot) %>
    </Group>
    """
  end
end
