defmodule CoseDellaVitaEx.Errors.InclusionError do
  @message "The field does not part of predefind set of options"
  @moduledoc """
  #{@message}

  Absinthe type is `:inclusion_error`. Field `:inclusion_list` must be set by the calling resolver.
  """
  use Absinthe.Schema.Notation

  defstruct [:inclusion_list, :path, message: @message, error_type: :inclusion_error]

  @type t :: %__MODULE__{}

  @desc @message
  object :inclusion_error do
    @desc "List of acceptable values."
    field(:inclusion_list, list_of(non_null(:string)))
    interface(:error)
    import_fields(:error)
  end
end
