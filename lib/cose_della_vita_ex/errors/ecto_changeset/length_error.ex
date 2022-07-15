defmodule CoseDellaVitaEx.Errors.LengthError do
  @message "The field has the wrong length."
  @moduledoc """
  #{@message}

  Absinthe type is `:length_error`.
  """
  use Absinthe.Schema.Notation

  defstruct [:path, :comparison_type, :reference, message: @message, error_type: :length_error]

  @type t :: %__MODULE__{}

  @desc "The type of comparison that was made with the reference length."
  enum :length_comparison_type do
    @desc "Value must be at least reference's items/characters length."
    value(:min)
    @desc "Value must be at most reference's items/characters length."
    value(:max)
  end

  @desc @message
  object :length_error do
    @desc "The type of comparison that was made with the reference length."
    field(:comparison_type, non_null(:length_comparison_type))
    @desc "The reference length that the field was compared with."
    field(:reference, non_null(:integer))
    interface(:error)
    import_fields(:error)
  end
end
