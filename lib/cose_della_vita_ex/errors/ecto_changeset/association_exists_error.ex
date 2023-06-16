defmodule CoseDellaVitaEx.Errors.AssociationExistsError do
  @message "An association still exists, preventing this entity from being deleted."
  @moduledoc """
  #{@message}

  Absinthe type is `:association_exists_error`.
  """
  use Absinthe.Schema.Notation

  defstruct [:constraint_name, :path, message: @message, error_type: :association_exists_error]

  @type t :: %__MODULE__{}

  @desc @message
  object :association_exists_error do
    @desc "Name of the constraint."
    field(:constraint_name, non_null(:string))
    interface(:error)
    import_fields(:error)
  end
end
