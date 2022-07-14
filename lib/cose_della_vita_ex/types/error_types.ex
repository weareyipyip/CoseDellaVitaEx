defmodule CoseDellaVitaEx.ErrorTypes do
  @moduledoc """
  Error types. When implemented, makes it possible for clients to query what exactly went wrong
  """
  use Absinthe.Schema.Notation
  alias CoseDellaVitaEx.ErrorHelpers
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
  """
  @spec graphql_changeset_error_traverser({binary, keyword | map}) :: struct()
  def graphql_changeset_error_traverser({msg, opts}) do
    message = ErrorHelpers.translate_error({msg, opts})
    opts = Map.new(opts)
    error_module(opts, message)
  end

  ###########
  # Private #
  ###########

  defp resolve(%{error_type: error_type}, _), do: error_type
  defp resolve(%{path: _, message: _}, _), do: :generic_error
  defp resolve(_, _), do: nil

  defp error_module(%{custom_validation: :invalid_token}, message),
    do: %TokenInvalidError{message: "The token is #{message}"}

  defp error_module(%{custom_validation: :password_match}, _message), do: %WrongPasswordError{}

  defp error_module(%{custom_validation: :require_one_of, fields: fields}, _message),
    do: %RequireOneOfError{fields: fields}

  defp error_module(%{validation: :length, kind: kind, count: count}, message),
    do: %LengthError{comparison_type: kind, reference: count, message: message}

  # we cast the number to a float, because graphql wants either an integer or
  # float scalar type and creating a new scalar type that can be both seems unnecessary
  defp error_module(%{validation: :number, kind: kind, number: number}, message),
    do: %NumberError{comparison_type: kind, reference: number * 1.0, message: message}

  defp error_module(%{validation: :required}, _message), do: %RequiredError{}
  defp error_module(%{validation: :inclusion}, _message), do: %InclusionError{}
  defp error_module(%{validation: :assoc}, _message), do: %AssocError{}
  defp error_module(%{validation: :unsafe_unique}, _message), do: %UniqueConstraintError{}
  defp error_module(%{validation: :format}, _message), do: %FormatError{}
  defp error_module(%{stale: true}, _message), do: %OptimisticLockingError{}

  defp error_module(%{constraint: :unique}, _message), do: %UniqueConstraintError{}
  defp error_module(%{constraint: :assoc}, _message), do: %NotFoundError{}
  defp error_module(%{constraint: :foreign}, _message), do: %NotFoundError{}

  defp error_module(opts, message) do
    Logger.warning(
      "Unknown changeset validation type, defaulting to a generic GraphQL error. Defining a specific error type will improve the API's type strength and usability. Full opts: #{inspect(opts)}"
    )

    %GenericError{message: message}
  end
end
