defmodule CoseDellaVitaEx.ErrorTypes.NotFoundError do
  @message "The specified entity could not be found."
  @moduledoc """
  #{@message}

  Absinthe type is `:not_found_error`.
  """
  use Absinthe.Schema.Notation

  defstruct [:path, message: @message, error_type: :not_found_error]

  @type t :: %__MODULE__{}

  @desc @message
  object :not_found_error do
    interface(:error)
    import_fields(:error)
  end
end
