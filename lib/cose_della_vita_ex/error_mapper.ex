defmodule CoseDellaVitaEx.ErrorMapper do
  @moduledoc """
  Functions to map Ecto Changeset errors to GraphQL error types.
  """

  alias CoseDellaVitaEx.Errors.{
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

  require Logger

  @doc """
  Maps a custom Ecto Changeset error to a GraphQL error type.

  To handle built-in Ecto Changeset errors, call `map_default/2` as a fallback.

  ## Examples / doctests

      defmodule MyApp.ErrorMapper do
        @behaviour CoseDellaVitaEx.ErrorMapper

        def map(%{custom_validation: :something}, message), do: %SomeError{message: message}
        def map(opts, message), do: CoseDellaVitaEx.ErrorMapper.map_default(opts, message)
      end
  """
  @callback map(map(), String.t()) :: struct()

  @doc """
  Maps a built-in Ecto Changeset error to a GraphQL error type.

  ## Examples / doctests

  See `CosaDellaVitaEx.Helpers.add_changeset_errors/5`.
  """
  @spec map_default(map(), String.t()) :: struct()
  def map_default(%{custom_validation: :invalid_token}, message),
    do: %TokenInvalidError{message: "The token is #{message}"}

  def map_default(%{custom_validation: :password_match}, _message), do: %WrongPasswordError{}

  def map_default(%{custom_validation: :require_one_of, fields: fields}, _message),
    do: %RequireOneOfError{fields: fields}

  def map_default(%{validation: :length, kind: kind, count: count}, message),
    do: %LengthError{comparison_type: kind, reference: count, message: message}

  def map_default(%{validation: :number, kind: kind, number: number}, message) do
    ref_as_float =
      case number do
        d = %Decimal{} -> Decimal.to_float(d)
        n when is_integer(n) -> n * 1.0
        float -> float
      end

    %NumberError{comparison_type: kind, reference: ref_as_float, message: message}
  end

  def map_default(%{validation: :required}, _message), do: %RequiredError{}
  def map_default(%{validation: :inclusion}, _message), do: %InclusionError{}
  def map_default(%{validation: :assoc}, _message), do: %AssocError{}
  def map_default(%{validation: :unsafe_unique}, _message), do: %UniqueConstraintError{}
  def map_default(%{validation: :format}, _message), do: %FormatError{}
  def map_default(%{stale: true}, _message), do: %OptimisticLockingError{}
  def map_default(%{constraint: :unique}, _message), do: %UniqueConstraintError{}
  def map_default(%{constraint: :assoc}, _message), do: %NotFoundError{}
  def map_default(%{constraint: :foreign}, _message), do: %NotFoundError{}

  def map_default(opts, message) do
    Logger.warning(
      "Unknown changeset validation type, defaulting to a generic GraphQL error. Defining a specific error type will improve the API's type strength and usability. Full opts: #{inspect(opts)}"
    )

    %GenericError{message: message}
  end
end
