defmodule CoseDellaVitaEx.Utils.FilterableType do
  @moduledoc """
  Use this module to add functions `default_order/0` and `default_filters/0` to an Absinthe type module.
  Requires a `:type` option, and that module attributes `@default_order` and `@default_filters` have been set.
  """

  defmacro __using__(opts) do
    quote do
      type = unquote(opts)[:type] || raise "type is required"

      @doc "Default ordering of a list of `#{type}`: `#{inspect(@default_order)}`"
      @spec default_order() :: [map()]
      def default_order, do: @default_order

      @doc "Default filters of a list of `#{type}`: `#{inspect(@default_filters)}`"
      @spec default_filters() :: map()
      def default_filters, do: @default_filters
    end
  end
end
