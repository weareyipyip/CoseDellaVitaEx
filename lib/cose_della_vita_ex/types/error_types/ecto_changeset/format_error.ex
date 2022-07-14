defmodule CoseDellaVitaEx.ErrorTypes.FormatError do
  @message "The field has the wrong format."
  @moduledoc """
  #{@message}

  Absinthe type is `:format_error`. Field `:expected_format` must be set by the calling resolver.
  """
  use Absinthe.Schema.Notation

  defstruct [:expected_format, :path, message: @message, error_type: :format_error]

  @type t :: %__MODULE__{}

  @desc @message
  object :format_error do
    @desc "Regex (PCRE) that the value must match."
    field :expected_format, non_null(:string)
    interface(:error)
    import_fields(:error)
  end
end
