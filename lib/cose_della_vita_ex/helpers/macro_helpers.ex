defmodule CoseDellaVitaEx.Helpers.MacroHelpers do
  @moduledoc """
  Macro helpers for Absinthe.
  """
  alias CoseDellaVitaEx.Types.ErrorTypes

  @doc """
  Add boilerplate for a mutation payload.

  # Example

      add_mutation_payload(:create_user, [:generic_error, :not_found_error])

  This generates the following:
  * A `create_user_error_types` function, to get a list of possible errors
  * A `create_user_error` GraphQL union type, representing all possible errors
  * A `create_user_payload` GraphQL object, containing boilerplate fields for mutations

  Additional fields can be added to the payload like so:

      add_mutation_payload(:create_user, [:generic_error, :not_found_error]) do
        field :some_other_field, :string
      end
  """
  defmacro add_mutation_payload(name, error_types, custom_fields \\ nil) do
    error_types_name = :"#{name}_error_types"
    error_name = :"#{name}_error"
    payload_name = :"#{name}_payload"

    quote do
      @doc """
      Get list of applicable error types for the operation: `#{inspect(unquote(error_types))}`
      """
      @spec unquote(error_types_name)() :: [atom()]
      def unquote(error_types_name)(), do: unquote(error_types)

      union unquote(error_name) do
        types(unquote(error_types))

        resolve_type(&ErrorTypes.resolve_error_type(&1, &2, unquote(error_types)))
      end

      object unquote(payload_name) do
        @desc "Is the mutation successful?"
        field(:success, non_null(:boolean))

        @desc "Possible errors that occured during the mutation."
        field(:errors, non_null(list_of(non_null(unquote(error_name)))))

        unquote(custom_fields)
      end
    end
  end

  @doc """
  Add boilerplate for pagination (`limit` and `offset` fields).

  Types can be overriden:

      add_pagination_fields(limit_type: :small_integer)
  """
  defmacro add_pagination_fields(opts \\ []) do
    limit_type = Keyword.get(opts, :limit_type, :integer)
    offset_type = Keyword.get(opts, :offset_type, :integer)

    quote do
      @desc "Limit results to N items."
      field(:limit, unquote(limit_type))

      @desc "Skip N items."
      field(:offset, unquote(offset_type))
    end
  end
end
