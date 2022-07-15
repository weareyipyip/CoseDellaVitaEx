defmodule CoseDellaVitaEx.Errors.RequireOneOfError do
  @message "At least one of the fields is required."
  @moduledoc """
  #{@message}

  Absinthe type is `:require_one_of_error`. Field `:fields` must be set by the calling resolver.
  """
  use Absinthe.Schema.Notation

  alias Ecto.Changeset

  defstruct [:fields, :path, message: @message, error_type: :require_one_of_error]

  @type t :: %__MODULE__{}

  @desc @message
  object :require_one_of_error do
    @desc "List of fields."
    field(:fields, list_of(non_null(:string)))
    interface(:error)
    import_fields(:error)
  end

  @doc """
  Validate if the changeset has at least one of the fields set.
  """
  @spec validate(Changeset.t(), atom(), list(atom())) :: Changeset.t()
  def validate(changeset, key, fields) do
    if Enum.all?(fields, fn field -> is_nil(Changeset.get_field(changeset, field)) end) do
      changeset
      |> Changeset.add_error(key, @message, custom_validation: :require_one_of, fields: fields)
    else
      changeset
    end
  end
end
