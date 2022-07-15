defmodule CoseDellaVitaEx.Errors.RequiredError do
  @message "This field is required."
  @moduledoc """
  #{@message}

  Absinthe type is `:required_error`.
  """
  use Absinthe.Schema.Notation

  defstruct [:path, message: @message, error_type: :required_error]

  @type t :: %__MODULE__{}

  @desc @message
  object :required_error do
    interface(:error)
    import_fields(:error)
  end
end
