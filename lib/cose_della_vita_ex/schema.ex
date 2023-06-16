defmodule CoseDellaVitaEx.Schema do
  @moduledoc """
  Import all CoseDellaVitaEx types into an existing schema.
  """

  defmacro __using__(_opts) do
    quote do
      import_types(CoseDellaVitaEx.Types.GenericTypes)
      import_types(CoseDellaVitaEx.Types.ErrorTypes)
      import_types(CoseDellaVitaEx.Errors.AssocError)
      import_types(CoseDellaVitaEx.Errors.FormatError)
      import_types(CoseDellaVitaEx.Errors.GenericError)
      import_types(CoseDellaVitaEx.Errors.InclusionError)
      import_types(CoseDellaVitaEx.Errors.LengthError)
      import_types(CoseDellaVitaEx.Errors.LoginError)
      import_types(CoseDellaVitaEx.Errors.NotFoundError)
      import_types(CoseDellaVitaEx.Errors.NumberError)
      import_types(CoseDellaVitaEx.Errors.OptimisticLockingError)
      import_types(CoseDellaVitaEx.Errors.RefreshError)
      import_types(CoseDellaVitaEx.Errors.RequiredError)
      import_types(CoseDellaVitaEx.Errors.RequireOneOfError)
      import_types(CoseDellaVitaEx.Errors.TokenInvalidError)
      import_types(CoseDellaVitaEx.Errors.UniqueConstraintError)
      import_types(CoseDellaVitaEx.Errors.WrongPasswordError)
      import_types(CoseDellaVitaEx.Errors.AssociationExistsError)
    end
  end
end
