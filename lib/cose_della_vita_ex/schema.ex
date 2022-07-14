defmodule CoseDellaVitaEx.Schema do
  defmacro __using__(_opts) do
    quote do
      import_types(CoseDellaVitaEx.GenericTypes)
      import_types(CoseDellaVitaEx.ErrorTypes)
      import_types(CoseDellaVitaEx.ErrorTypes.AssocError)
      import_types(CoseDellaVitaEx.ErrorTypes.FormatError)
      import_types(CoseDellaVitaEx.ErrorTypes.GenericError)
      import_types(CoseDellaVitaEx.ErrorTypes.InclusionError)
      import_types(CoseDellaVitaEx.ErrorTypes.LengthError)
      import_types(CoseDellaVitaEx.ErrorTypes.LoginError)
      import_types(CoseDellaVitaEx.ErrorTypes.NotFoundError)
      import_types(CoseDellaVitaEx.ErrorTypes.NumberError)
      import_types(CoseDellaVitaEx.ErrorTypes.OptimisticLockingError)
      import_types(CoseDellaVitaEx.ErrorTypes.RefreshError)
      import_types(CoseDellaVitaEx.ErrorTypes.RequiredError)
      import_types(CoseDellaVitaEx.ErrorTypes.RequireOneOfError)
      import_types(CoseDellaVitaEx.ErrorTypes.TokenInvalidError)
      import_types(CoseDellaVitaEx.ErrorTypes.UniqueConstraintError)
      import_types(CoseDellaVitaEx.ErrorTypes.WrongPasswordError)
    end
  end
end
