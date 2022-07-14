defmodule CoseDellaVitaEx.Helpers do
  @moduledoc """
  Simple helpers that reduce duplicate work for stuff like settign the success field on mutations or adding errors in the correct structure.
  """

  alias Absinthe.Adapter.LanguageConventions
  alias CoseDellaVitaEx.ErrorTypes
  alias Ecto.Changeset
  require Logger

  @doc """
  Add an `:error`-type error to a data response (so the error will not end up in the top-level errors).
  ## Examples / doctests
      iex> add_data_error(message: "does not exist", path: [])
      %{errors: [%{message: "does not exist", path: []}]}
      iex> add_data_error(%{status: :error}, message: "does not exist", path: [])
      %{status: :error, errors: [%{message: "does not exist", path: []}]}
  """
  @spec add_data_error(map, map() | keyword()) :: map
  def add_data_error(response \\ %{}, error)

  def add_data_error(response, %{path: _, message: _} = error) do
    response = Map.put_new(response, :errors, [])
    %{response | errors: [error | response.errors]}
  end

  def add_data_error(response, error) when is_list(error),
    do: add_data_error(response, Map.new(error))

  @doc """
  Translate changeset errors into `CoseDellaVitaEx.ErrorTypes.*` structs that are translated into specific, typed GraphQL data-errors. Unrecognized errors default to `CoseDellaVitaEx.ErrorTypes.GenericError`.
  The `:errors` field is added to the response if it does not exist.
  Supports nested changeset errors, which are added with flattened keys, for example "user.posts".
  Keys are converted to camelCase when they are added to the errors field.
  Additionally, it is possible to override fields of the error structs, matching on the struct's `:error_type` field and the error's path.
  ## Examples / doctests
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
      def changeset(params) do
        # validates all fields as required, casts fields and embeds etc...
      end
      # adds to existing errors
      iex> add_changeset_errors(%{errors: ["boom"]}, changeset(%{}))
      %{errors: ["boom", %RequiredError{message: "This field is required.", path: ["user"], error_type: :required_error}]}
      # adds :errors field
      # supports nested changeset errors
      # supports multiple errors for the same field
      # transforms field names to camelCase
      iex> cs = %{user: %{email: "ab", bi_cycles: [%{wheel_count: 1}]}, something: 3} |> changeset()
      iex> error_overrides = %{{:generic_error, ~w(input something)} => %{message: "overriden message!"}}
      iex> add_changeset_errors(%{}, cs, ~w(input), error_overrides)
      %{
        errors: [
          %LengthError{comparison_type: :max, error_type: :length_error, message: "should be at most 1 character(s)", path: ["input", "user", "email"], reference: 1},
          %NumberError{comparison_type: :greater_than, error_type: :number_error, message: "must be greater than 3", path: ["input", "user", "biCycles", "wheelCount"], reference: 3.0},
          %GenericError{message: "overriden message!", path: ["input", "something"], error_type: :generic_error}
        ]
      }
  """
  @spec add_changeset_errors(map, Changeset.t(), (String.t(), map() -> struct()), [String.t()], map()) :: map
  def add_changeset_errors(response, changeset, module_mapper, base_path \\ [], error_field_overrides \\ %{})

  def add_changeset_errors(
        %{errors: errors} = response,
        changeset,
        module_mapper,
        base_path,
        error_field_overrides
      ) do
    changeset_errors =
      changeset
      |> Changeset.traverse_errors(&ErrorTypes.graphql_changeset_error_traverser(&1, module_mapper))
      |> to_absinthe_errors(error_field_overrides, base_path)

    %{response | errors: errors ++ changeset_errors}
  end

  def add_changeset_errors(response, changeset, module_mapper, base_path, error_field_overrides),
    do:
      response
      |> Map.put(:errors, [])
      |> add_changeset_errors(changeset, module_mapper, base_path, error_field_overrides)

  @doc """
  Sets the `:success` flag of a response to true if there are no errors, and adds an empty error list if there is no errors field.
  ## Examples / doctests
      iex> {:ok, %{}} |> format_success_errors()
      {:ok, %{success: true, errors: []}}
      iex> {:ok, %{errors: []}} |> format_success_errors()
      {:ok, %{success: true, errors: []}}
      iex> {:ok, %{errors: ["boom"]}} |> format_success_errors()
      {:ok, %{success: false, errors: ["boom"]}}
      iex> {:error, %{}} |> format_success_errors()
      {:error, %{}}
  """
  @spec format_success_errors({atom, map}) :: {atom, map}
  def format_success_errors(response_tuple)

  def format_success_errors({:ok, res}) do
    res =
      case res do
        %{errors: []} -> Map.put(res, :success, true)
        %{errors: _} -> Map.put(res, :success, false)
        _ -> Map.merge(res, %{success: true, errors: []})
      end

    {:ok, res}
  end

  def format_success_errors(other), do: other

  ###########
  # Private #
  ###########

  # Example output from Changeset.traverse_errors(&ErrorTypes.graphql_changeset_error_traverser/1)
  # %{
  #   something: [
  #     %CoseDellaVitaEx.ErrorTypes.GenericError{
  #       error_type: :generic_error,
  #       message: "is invalid",
  #       path: nil
  #     }
  #   ],
  #   user: %{
  #     bi_cycles: [
  #       %{
  #         wheel_count: [
  #           %CoseDellaVitaEx.ErrorTypes.GenericError{
  #             error_type: :generic_error,
  #             message: "must be greater than 3",
  #             path: nil
  #           }
  #         ]
  #       }
  #     ],
  #     email: [
  #       %CoseDellaVitaEx.ErrorTypes.LengthError{
  #         count: 1,
  #         error_type: :length_error,
  #         kind: :max,
  #         message: "should be at most 1 character(s)",
  #         path: nil
  #       }
  #     ]
  #   }
  # }
  defp to_absinthe_errors(errors, error_overrides, base_path, accumulator \\ [], path \\ []) do
    Enum.reduce(errors, accumulator, fn error, acc ->
      case error do
        struct = %_{error_type: type} ->
          path = base_path ++ Enum.reverse(path)
          overrides = Map.get(error_overrides, {type, path}, %{})
          [struct |> Map.put(:path, path) |> Map.merge(overrides) | acc]

        nested when is_map(nested) ->
          to_absinthe_errors(nested, error_overrides, base_path, acc, path)

        {path_element, messages_or_nested} ->
          to_absinthe_errors(
            messages_or_nested,
            error_overrides,
            base_path,
            acc,
            prefix(path_element, path)
          )
      end
    end)
  end

  defp prefix(element, path) do
    element = LanguageConventions.to_external_name("#{element}", :field)
    [element | path]
  end
end
