defmodule LibraryWeb.ComponentHelpers do
  alias LibraryWeb.ComponentView

  def component(template, assigns) do
    ComponentView.render "#{template}.html", assigns
  end
end
