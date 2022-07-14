defmodule CoseDellaVitaEx.ErrorTypes.NumberError do
  @message "The field's number has the wrong value."
  @moduledoc """
  #{@message}

  Absinthe type is `:number_error`.
  """
  use Absinthe.Schema.Notation

  defstruct [:path, :comparison_type, :reference, message: @message, error_type: :number_error]

  @type t :: %__MODULE__{}

  @desc "The type of comparison that was made with the reference number."
  enum :number_comparison_type do
    @desc "Value must be less than reference's value."
    value(:less_than)
    @desc "Value must be greater than reference's value."
    value(:greater_than)
    @desc "Value must be less-than-or-equal-to reference's value."
    value(:less_than_or_equal_to)
    @desc "Value must be greater-than-or-equal-to reference's value."
    value(:greater_than_or_equal_to)
    @desc "Value must be equal to reference's value."
    value(:equal_to)
    @desc "Value must NOT be equal to reference's value."
    value(:not_equal_to)
  end

  @desc @message
  object :number_error do
    @desc "The type of comparison that was made with the reference number."
    field :comparison_type, non_null(:number_comparison_type)
    @desc "The reference number that the field was compared with."
    field :reference, non_null(:float)
    interface(:error)
    import_fields(:error)
  end
end
