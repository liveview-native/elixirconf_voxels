defmodule ElixirconfVoxelsWeb.Layouts.SwiftUI do
  use ElixirconfVoxelsNative, [:layout, format: :swiftui]

  embed_templates "layouts_swiftui/*"
end
