defmodule CoseDellaVitaEx.HelpersTest do
  use ExUnit.Case

  alias CoseDellaVitaEx.Helpers
  alias CoseDellaVitaEx.Types.ErrorTypes
  alias CoseDellaVitaEx.Errors.{GenericError, LengthError, NumberError, RequiredError}

  import Helpers
  import ErrorTypes

  defmodule TestSchema do
    import Ecto.Changeset

    use Ecto.Schema

    @primary_key false
    embedded_schema do
      field(:something, :string)

      embeds_one :user, User, primary_key: false do
        field(:email, :string)

        embeds_many :bi_cycles, Bicycle, primary_key: false do
          field(:wheel_count, :integer)
        end
      end
    end

    def changeset(schema \\ %__MODULE__{}, params) do
      schema
      |> cast(params, [:something])
      |> cast_embed(:user, with: &user_changeset/2, required: true)
    end

    def user_changeset(schema, params) do
      schema
      |> cast(params, [:email])
      |> cast_embed(:bi_cycles, with: &bicycle_changeset/2)
      |> validate_length(:email, max: 1)
    end

    def bicycle_changeset(schema, params) do
      schema
      |> cast(params, [:wheel_count])
      |> validate_number(:wheel_count, greater_than: 3)
    end
  end

  doctest Helpers
end
