defmodule CoseDellaVitaEx.ErrorTypes.RequireOneOfError do
  @message "At least one of the fields is required."
  @moduledoc """
  #{@message}

  Absinthe type is `:require_one_of_error`. Field `:fields` must be set by the calling resolver.
  """
  use Absinthe.Schema.Notation

  defstruct [:fields, :path, message: @message, error_type: :require_one_of_error]

  @type t :: %__MODULE__{}

  @desc @message
  object :require_one_of_error do
    @desc "List of fields."
    field(:fields, list_of(non_null(:string)))
    interface(:error)
    import_fields(:error)
  end
end
