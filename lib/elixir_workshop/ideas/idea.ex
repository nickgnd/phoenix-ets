defmodule ElixirWorkshop.Ideas.Idea do
  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          description: String.t(),
          picture_url: String.t()
        }
  @enforce_keys [:name, :description, :picture_url]
  @derive {Jason.Encoder, except: [:__meta__, :__struct__]}
  defstruct id: nil, name: nil, description: nil, picture_url: nil
end
