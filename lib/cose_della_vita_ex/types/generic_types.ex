defmodule CoseDellaVitaEx.GenericTypes do
  @moduledoc """
  Generic Absinthe types.
  """
  use Absinthe.Schema.Notation
  require Logger

  @desc "Implementing types have a unique integer-type ID."
  interface :integer_id do
    @desc "Stable, unique integer ID."
    field :id, non_null(:id)
  end

  @desc "Implementing types have a universally unique string ID type."
  interface :string_id do
    @desc "Stable, universally unique string ID."
    field :id, non_null(:id)
  end

  @desc "Implementing types have UTC datetimes indicating when the entity was first created and last updated."
  interface :timestamps do
    @desc "UTC datetime indicating when the entity was first created."
    field :inserted_at, non_null(:datetime)
    @desc "UTC datetime indicating when the entity was last updated."
    field :updated_at, non_null(:datetime)
  end

  @desc "Implementing types can opt-in to optimistic locking by echoing the value of lockVersion in mutations that update an entity of the type."
  interface :optimistic_lockable do
    @desc "Current (optimistic) lock version of the entity."
    field :lock_version, non_null(:integer)
  end

  # "interface" exists only to be able to import types because input_objects can't implement interfaces
  interface :optimistic_lockable_input do
    @desc "Current (optimistic) lock version of the entity."
    field :lock_version, :integer
  end

  interface :base_query do
    @desc "Possible errors that occurred during the query."
    field(:errors, list_of(:error))
  end

  @desc "Sorting directions for orderBy filter fields."
  enum :order_by_direction do
    value(:asc_nulls_first, as: :asc_nulls_first)
    value(:asc_nulls_last, as: :asc_nulls_last)
    value(:asc, as: :asc)
    value(:desc_nulls_first, as: :desc_nulls_first)
    value(:desc_nulls_last, as: :desc_nulls_last)
    value(:desc, as: :desc)
  end

  # not used as an interface, merely as a field collection
  interface :order_by_direction_field do
    @desc "Direction to order by."
    field :direction, non_null(:order_by_direction)
  end

  # not used as an interface, merely as a field collection
  interface :filterable do
    @desc "Limit results to n items"
    field :limit, :integer
    @desc "Skip n items. Warning: may lead to performance issues with large values."
    field :offset, :integer
    @desc "Filter by entity's inserted-at timestamp is smaller than value."
    field :inserted_at_lt, :datetime
    @desc "Filter by entity's inserted-at timestamp is greater than or equal to value."
    field :inserted_at_gte, :datetime
    @desc "Filter by entity's updated-at timestamp is smaller than value."
    field :updated_at_lt, :datetime
    @desc "Filter by entity's updated-at timestamp is greater than or equal to value."
    field :updated_at_gte, :datetime
  end

  interface :searchable do
    @desc "Filter by free-input search string."
    field :search, :string
  end

  interface :soft_deletable do
    @desc "Boolean that indicates if the entity has been deleted."
    field :is_deleted, :boolean
  end
end
