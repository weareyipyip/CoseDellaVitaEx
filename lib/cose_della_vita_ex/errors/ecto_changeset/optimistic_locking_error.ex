defmodule CoseDellaVitaEx.Errors.OptimisticLockingError do
  @message "The entity is stale, reload the entity and retry the update. This error should only occur when clients opt-in to optimistic locking by specifying a value for lockVersion in a mutation's input object."
  @moduledoc """
  #{@message}

  Absinthe type is `:optimistic_locking_error`.
  """
  use Absinthe.Schema.Notation

  defstruct [:path, message: @message, error_type: :optimistic_locking_error]

  @type t :: %__MODULE__{}

  @desc @message
  object :optimistic_locking_error do
    interface(:error)
    import_fields(:error)
  end
end
