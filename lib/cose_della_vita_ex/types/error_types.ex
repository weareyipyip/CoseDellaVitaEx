defmodule CoseDellaVitaEx.ErrorTypes do
  @moduledoc """
  Error types. When implemented, makes it possible for clients to query what exactly went wrong
  """
  use Absinthe.Schema.Notation
  alias CoseDellaVitaEx.Utils.ErrorHelpers
  require Logger

  alias __MODULE__.{
    AssocError,
    FormatError,
    GenericError,
    InclusionError,
    LengthError,
    NumberError,
    NotFoundError,
    OptimisticLockingError,
    RequiredError,
    TokenInvalidError,
    UniqueConstraintError,
    WrongPasswordError,
    RequireOneOfError
  }

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
  Translate changeset errors into `CoseDellaVitaEx.ErrorTypes.*` structs that are translated into specific, typed GraphQL data-errors.

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

  @doc """
  Generate a default error mapper with optional overrides.
  The error mapper is used to convert Ecto Changeset errors to GraphQL types.

  ## Examples / doctests

  See `CosaDellaVitaEx.Helpers.add_changeset_errors/5`.
  """
  defmacro default_error_mapper(opts, message, overrides \\ []) do
    clauses =
      case overrides do
        [do: {:__block__, _, overrides}] -> overrides
        [do: overrides] -> overrides
        _ -> []
      end

    extra_clauses =
      quote do
        {%{custom_validation: :invalid_token}, message} ->
          %TokenInvalidError{message: "The token is #{message}"}

        {%{custom_validation: :password_match}, _message} ->
          %WrongPasswordError{}

        {%{custom_validation: :require_one_of, fields: fields}, _message} ->
          %RequireOneOfError{fields: fields}

        {%{validation: :length, kind: kind, count: count}, message} ->
          %LengthError{comparison_type: kind, reference: count, message: message}

        {%{validation: :number, kind: kind, number: number}, message} ->
          %NumberError{comparison_type: kind, reference: number * 1.0, message: message}

        {%{validation: :required}, _message} ->
          %RequiredError{}

        {%{validation: :inclusion}, _message} ->
          %InclusionError{}

        {%{validation: :assoc}, _message} ->
          %AssocError{}

        {%{validation: :unsafe_unique}, _message} ->
          %UniqueConstraintError{}

        {%{validation: :format}, _message} ->
          %FormatError{}

        {%{stale: true}, _message} ->
          %OptimisticLockingError{}

        {%{constraint: :unique}, _message} ->
          %UniqueConstraintError{}

        {%{constraint: :assoc}, _message} ->
          %NotFoundError{}

        {%{constraint: :foreign}, _message} ->
          %NotFoundError{}

        {opts, message} ->
          Logger.warning(
            "Unknown changeset validation type, defaulting to a generic GraphQL error. Defining a specific error type will improve the API's type strength and usability. Full opts: #{inspect(opts)}"
          )

          %GenericError{message: message}
      end

    quote do
      require Logger

      case {unquote(opts), unquote(message)} do
        unquote(clauses ++ extra_clauses)
      end
    end
  end

  ###########
  # Private #
  ###########

  defp resolve(%{error_type: error_type}, _), do: error_type
  defp resolve(%{path: _, message: _}, _), do: :generic_error
  defp resolve(_, _), do: nil
end
