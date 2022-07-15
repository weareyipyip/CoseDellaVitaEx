defmodule CoseDellaVitaEx.Errors.RefreshError do
  @message "The session could not be refreshed. Either the user was not found or the user is inactive."
  @moduledoc """
  #{@message}

  Absinthe type is `:refresh_error`.
  """
  use Absinthe.Schema.Notation

  defstruct path: [], message: @message, error_type: :refresh_error

  @type t :: %__MODULE__{}

  @desc @message
  object :refresh_error do
    interface(:error)
    import_fields(:error)
  end
end
