defmodule CoseDellaVitaEx.ErrorTypes.GenericError do
  @message "The default implementation of interface Error."
  @moduledoc """
  #{@message}

  Absinthe type is `:generic_error`
  """
  use Absinthe.Schema.Notation

  defstruct [
    :path,
    message: "There is a disturbance in the Force. Something went wrong.",
    error_type: :generic_error
  ]

  @type t :: %__MODULE__{}

  @desc @message
  object :generic_error do
    interface(:error)
    import_fields(:error)
  end
end
