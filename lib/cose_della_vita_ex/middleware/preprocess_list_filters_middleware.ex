defmodule CoseDellaVitaEx.Middleware.PreprocessListFiltersMiddleware do
  @moduledoc """
  Map the GraphQL API format for `orderBy` filter input fields to the internal format
  of `Ecto.Query.order_by/3`.
      iex> arguments = %{filters: %{order_by: [%{field: :name, direction: :asc}]}}
      iex> resolution = %Resolution{arguments: arguments}
      iex> resolution = PreprocessListFiltersMiddleware.call(resolution, :filters)
      iex> %{arguments: %{filters: %{order_by: [asc: :name]}}} = resolution
      iex> resolution = %Resolution{}
      iex> %{arguments: %{filters: %{}}} = PreprocessListFiltersMiddleware.call(resolution, :filters)
  """
  @behaviour Absinthe.Middleware

  @impl true
  def call(%{arguments: arguments} = resolution, field_name) do
    filters = arguments[field_name] || %{}
    filters = graphql_preprocess_order_by(filters)
    %{resolution | arguments: Map.put(arguments, field_name, filters)}
  end

  ###########
  # Private #
  ###########

  # Map the GraphQL API format for `orderBy` filter input fields to the internal format
  # of `Ecto.Query.order_by/3`.
  defp graphql_preprocess_order_by(%{order_by: order_by} = filters) do
    order_by = Enum.map(order_by, fn %{field: field, direction: dir} -> {dir, field} end)
    %{filters | order_by: order_by}
  end

  defp graphql_preprocess_order_by(filters), do: filters
end
