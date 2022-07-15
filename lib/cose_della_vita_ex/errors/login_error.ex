defmodule CoseDellaVitaEx.Errors.LoginError do
  @message "A session could not be created. Either the user was not found, the user is inactive or the password is wrong."
  @moduledoc """
  #{@message}

  Absinthe type is `:login_error`.
  """
  use Absinthe.Schema.Notation

  defstruct path: [], message: @message, error_type: :login_error

  @type t :: %__MODULE__{}

  @desc @message
  object :login_error do
    interface(:error)
    import_fields(:error)
  end
end
