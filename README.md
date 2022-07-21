# CoseDellaVitaEx

Generic helpers for GraphQL API's.

## Setup

1. Add to your dependencies:
   ```elixir
   def deps do
     [
       {:cose_della_vita_ex, "~> 0.0.0+development"}
     ]
   end
   ```
1. Include the generic GraphQL types in your schema:
   ```elixir
   defmodule MyApp.Schema do
     use Absinthe.Schema
     use CoseDellaVitaEx.Schema

     # Your own types here
   end
   ```
1. Create an error mapper:
   ```elixir
   defmodule MyApp.ErrorMapper do
     alias CoseDellaVitaEx.ErrorMapper

     @behaviour ErrorMapper

     def map(%{custom_validation: :my_validation}, message): %MyError{message: message}
     # Add more custom errors here, then fall back to the included errors
     def map(opts, message), do: ErrorMapper.map_default(opts, message)
   end
   ```

## Error handling

Convert Ecto changeset errors to GraphQL types.

1. Define possible errors for your mutation, so the client can match on those:
   *The `generic_error` type will be used as a fallback*
   ```elixir
   defmodule MyApp.MyTypes
     alias CoseDellaVitaEx.Types.ErrorTypes

     @my_mutation_error_types [:my_error]

     union :my_mutation_error do
       types(unquote(@my_mutation_error_types))
       resolve_type(&ErrorTypes.resolve_error_type(&1, &2, @my_mutation_error_types))
     end

     object :my_mutation_result do
       field(:success, :boolean)
       field(:errors, list_of(:my_mutation_error))
     end
   end
   ```
1. Automatically convert Ecto changeset errors in your resolver:
   ```elixir
   defmodule MyApp.MyResolver do
     import CoseDellaVitaEx.Helpers

     alias MyApp.ErrorMapper

     def create(_parent, _fields, _resolution) do
       with {:ok, my_entity} <- MyDB.insert() do
         {:ok, %{my_entity: my_entity}}
       else
         {:error, %Ecto.Changeset{} = changeset} ->
           {:ok, add_changeset_errors(%{}, changeset, &ErrorMapper.map/2)}
       end
       |> format_success_errors()
     end
   end
   ```
