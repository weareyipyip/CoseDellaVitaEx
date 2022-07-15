defmodule CoseDellaVitaEx.Types.ErrorTypes do
  @moduledoc """
  Error types. When implemented, makes it possible for clients to query what exactly went wrong
  """
  use Absinthe.Schema.Notation
  alias CoseDellaVitaEx.Helpers.ErrorHelpers
  require Logger

  @desc "Fields shared by all (domain-related) data-level errors."
  interface :error do
    @desc "Path to the field that caused the error."
    field(:path, non_null(list_of(:string)))
    @desc "A message describing the error."
    field(:message, non_null(:string))

    resolve_type(&__MODULE__.resolve_error_type/2)
  end

  #############
  # Resolvers #
  #############

  @doc """
  Resolve the type of an "object to identify" (a map or a struct) (that is expected to be an error). The object to identify must either:
   - define an `:error_type` atom that matches a specific Absinthe object type
   - have a `:path` and `:message` to be identified as a `:generic_error` type

   ## Examples / doctests

      iex> resolve_error_type(%{error_type: :bicycle_error}, nil)
      :bicycle_error
      iex> resolve_error_type(%{path: ["name"], message: "this is a stupid name"}, nil)
      :generic_error
      iex> resolve_error_type("anything else", nil)
      nil
  """
  @spec resolve_error_type(any, struct()) :: atom() | nil
  def resolve_error_type(object_to_identify, execution) do
    resolve(object_to_identify, execution)
  end

  @doc """
  Same as `resolve_error_type/2` but the resolved type must be in the allowlist or be downgraded to :generic_error. A warning about the downgrade is logged.

  ## Examples / doctests

      iex> resolve_error_type(%{error_type: :bicycle_error}, nil, [:some_other_error])
      :generic_error
      iex> resolve_error_type(%{error_type: :bicycle_error}, nil, [:bicycle_error])
      :bicycle_error
  """
  @spec resolve_error_type(any, struct(), nil | Enum.t()) :: atom() | nil
  def resolve_error_type(object_to_identify, execution, allowlist) do
    resolved_error = resolve(object_to_identify, execution)

    if resolved_error in allowlist || resolved_error == nil || resolved_error == :generic_error do
      resolved_error
    else
      Logger.warning("Error type #{resolved_error} not allowed, downgrading to generic error.")
      :generic_error
    end
  end

  #########
  # Other #
  #########

  @doc """
  Translate changeset errors into `CoseDellaVitaEx.Errors.*` structs that are translated into specific, typed GraphQL data-errors.

  ## Examples / doctests

  See `CoseDellaVitaEx.Helpers.add_changeset_errors/5`.
  """
  @spec graphql_changeset_error_traverser(
          {binary, keyword | map},
          (String.t(), map() -> struct())
        ) :: struct()
  def graphql_changeset_error_traverser({msg, opts}, error_mapper) do
    message = ErrorHelpers.translate_error({msg, opts})
    opts = Map.new(opts)
    error_mapper.(opts, message)
  end

  ###########
  # Private #
  ###########

  defp resolve(%{error_type: error_type}, _), do: error_type
  defp resolve(%{path: _, message: _}, _), do: :generic_error
  defp resolve(_, _), do: nil
end
