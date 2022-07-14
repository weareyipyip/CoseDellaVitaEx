defmodule CoseDellaVitaEx.ErrorTypes.WrongPasswordError do
  @message "The password is wrong."
  @moduledoc """
  #{@message}

  Absinthe type is `:wrong_password_error`.
  """
  use Absinthe.Schema.Notation

  defstruct [:path, message: @message, error_type: :wrong_password_error]

  @type t :: %__MODULE__{}

  @desc @message
  object :wrong_password_error do
    interface(:error)
    import_fields(:error)
  end
end
