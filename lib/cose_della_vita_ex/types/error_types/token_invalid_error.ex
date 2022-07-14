defmodule CoseDellaVitaEx.ErrorTypes.TokenInvalidError do
  @message "The provided token parameter is invalid, meaning it could not be decoded, its signature component is wrong or it has expired."
  @moduledoc """
  #{@message}

  Absinthe type is `:token_invalid_error`.
  """
  use Absinthe.Schema.Notation

  defstruct [:path, message: @message, error_type: :token_invalid_error]

  @type t :: %__MODULE__{}

  @desc @message
  object :token_invalid_error do
    interface(:error)
    import_fields(:error)
  end
end
