defmodule CoseDellaVitaEx.ErrorTypes.UniqueConstraintError do
  @message "The field must be unique (or unique in combination with something else)."
  @moduledoc """
  #{@message}

  Absinthe type is `:unique_constraint_error`. Field `:fields` must be set by the calling resolver.
  """
  use Absinthe.Schema.Notation

  defstruct [:fields, :path, message: @message, error_type: :unique_constraint_error]

  @type t :: %__MODULE__{}

  @desc @message
  object :unique_constraint_error do
    @desc "Fields that must be unique together."
    field :fields, non_null(list_of(:string))
    interface(:error)
    import_fields(:error)
  end
end
