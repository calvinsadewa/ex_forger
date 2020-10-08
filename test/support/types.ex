defmodule ExForger.Test.User do
  use Ecto.Schema

  schema "users" do
    field(:name, :string)
    field(:age, :integer, default: 0)

    has_many(:posts, ExForger.Test.Post)

    embeds_many :social_media_profiles, SocialMediaProfile do
      field(:type, :string)
      field(:handle_id, :string)
      field(:url, :string)
    end
  end
end

defmodule ExForger.Test.Post do
  use Ecto.Schema

  schema "posts" do
    field(:content, :string)
    belongs_to(:poster, ExForger.Test.User)

    embeds_one :metadata, Metadata do
      field(:published_at, :utc_datetime)

      embeds_one :publisher_data, PublisherData do
        field(:publisher, :string)
      end
    end

    has_many(:comments, ExForger.Test.Comment)
  end
end

defmodule ExForger.Test.Comment do
  use Ecto.Schema

  schema "comments" do
    field(:content, :string)
    field(:parent_id, :integer)
    belongs_to(:post, ExForger.Test.Post)

    belongs_to(:parent, ExForger.Test.Comment,
      foreign_key: :id,
      references: :parent_id,
      define_field: false
    )

    has_many(:children, ExForger.Test.Comment, foreign_key: :parent_id, references: :id)
  end
end
