defmodule CoseDellaVitaEx.Errors.AssocError do
  @message "An associated entity is invalid, meaning that you are trying to remove or replace an associated entity, but this is not supported."
  @moduledoc """
  #{@message}

  Absinthe type is `:assoc_error`.
  """
  use Absinthe.Schema.Notation

  defstruct [:path, message: @message, error_type: :assoc_error]

  @type t :: %__MODULE__{}

  @desc @message
  object :assoc_error do
    interface(:error)
    import_fields(:error)
  end
end
