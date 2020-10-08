defmodule ExForgerTest do
  use ExUnit.Case
  use Mimic

  describe "default cases" do
    test "Able to handle simplest case of relation ship, independent User" do
      expect(ExForger.Test.Repo, :insert!, fn changeset ->
        Ecto.Changeset.apply_changes(changeset)
      end)

      user = ExForger.forge(ExForger.Test.User)
      assert nil != user.age
      assert nil != user.id
      assert nil != user.name

      Enum.each(user.social_media_profiles, fn profile ->
        assert nil != profile.handle_id
        assert nil != profile.id
        assert nil != profile.type
        assert nil != profile.url
      end)
    end

    test "Able to handle simplest case of relation ship, with custom attribute" do
      expect(ExForger.Test.Repo, :insert!, fn changeset ->
        Ecto.Changeset.apply_changes(changeset)
      end)

      user =
        ExForger.forge(ExForger.Test.User, %{
          name: "John",
          age: 45,
          social_media_profiles: [
            %{
              handle_id: "John Saragih",
              type: "G+",
              url: "https://"
            }
          ]
        })

      assert 45 == user.age
      assert nil != user.id
      assert "John" == user.name
      [profile] = user.social_media_profiles
      assert profile.handle_id == "John Saragih"
      assert profile.type == "G+"
      assert profile.url == "https://"
    end

    test "Able to handle simplest case of relation ship, with custom attribute of nil" do
      expect(ExForger.Test.Repo, :insert!, fn changeset ->
        Ecto.Changeset.apply_changes(changeset)
      end)

      user =
        ExForger.forge(ExForger.Test.User, %{
          name: nil
        })

      assert nil == user.name
    end

    test "Able to handle belongs_to relation ship, Post" do
      expect(ExForger.Test.Repo, :insert!, fn changeset ->
        assert %ExForger.Test.User{} = changeset.data
        Ecto.Changeset.apply_changes(changeset)
      end)

      expect(ExForger.Test.Repo, :insert!, fn changeset ->
        assert %ExForger.Test.Post{} = changeset.data
        Ecto.Changeset.apply_changes(changeset)
      end)

      post = ExForger.forge(ExForger.Test.Post)
      assert post.content != nil
      assert post.id != nil
      assert post.poster_id != nil
      assert post.metadata.id != nil
      assert post.metadata.published_at != nil
      assert post.metadata.publisher_data.publisher != nil
    end

    test "Able to handle belongs_to relation ship, Post with setted up User" do
      expect(ExForger.Test.Repo, :insert!, 2, fn changeset ->
        Ecto.Changeset.apply_changes(changeset)
      end)

      user = ExForger.forge(ExForger.Test.User)
      post = ExForger.forge(ExForger.Test.Post, %{poster_id: user.id})
      assert post.poster_id == user.id
    end

    test "Able to handle multiple embedded schema" do
      stub(ExForger.Test.Repo, :insert!, fn changeset ->
        Ecto.Changeset.apply_changes(changeset)
      end)

      post =
        ExForger.forge(ExForger.Test.Post, %{
          metadata: %{
            published_at: ~U[2020-01-01 00:00:00Z],
            publisher_data: %{
              publisher: "ZSA"
            }
          }
        })

      assert post.metadata.published_at == ~U[2020-01-01 00:00:00Z]
      assert post.metadata.publisher_data.publisher == "ZSA"
    end

    test "Able to handle self-reference schema, Comment" do
      stub(ExForger.Test.Repo, :insert!, fn changeset ->
        Ecto.Changeset.apply_changes(changeset)
      end)

      ExForger.forge(ExForger.Test.Comment)

      # Finished means good
    end
  end

  describe "custom smith" do
    defmodule CustomSocialMediaSmith do
      def forge_schema(ecto_schema, attribute, opt) do
        attribute =
          case ecto_schema do
            ExForger.Test.User.SocialMediaProfile ->
              type = Enum.random(["twitter", "google_plus"])
              handle_id = if type == "twitter", do: "XLSKAS", else: nil
              Map.merge(%{type: type, handle_id: handle_id}, attribute)

            _ ->
              attribute
          end

        ExForger.DefaultSmith.forge_schema(ecto_schema, attribute, opt)
      end

      def generate_field(ecto_schema, field, type, opt) do
        ExForger.DefaultSmith.generate_field(ecto_schema, field, type, opt)
      end
    end

    test "Custom social media smith produce correct social media data" do
      expect(ExForger.Test.Repo, :insert!, fn changeset ->
        Ecto.Changeset.apply_changes(changeset)
      end)

      user = ExForger.forge(ExForger.Test.User, %{}, smith: CustomSocialMediaSmith)

      assert nil != user.age
      assert nil != user.id
      assert nil != user.name

      Enum.each(user.social_media_profiles, fn profile ->
        assert profile.type in ["twitter", "google_plus"]

        if profile.type == "google_plus" do
          assert profile.handle_id == nil
        else
          profile.handle_id == "XLSKAS"
        end
      end)
    end

    defmodule UserAge30Smith do
      def forge_schema(ecto_schema, attribute, opt) do
        ExForger.DefaultSmith.forge_schema(ecto_schema, attribute, opt)
      end

      def generate_field(ExForger.Test.User, :age, _, _) do
        30
      end

      def generate_field(ecto_schema, field, type, opt) do
        ExForger.DefaultSmith.generate_field(ecto_schema, field, type, opt)
      end
    end

    test "UserAge30Smith produce user with age 30" do
      expect(ExForger.Test.Repo, :insert!, fn changeset ->
        Ecto.Changeset.apply_changes(changeset)
      end)

      user = ExForger.forge(ExForger.Test.User, %{}, smith: UserAge30Smith)

      assert 30 == user.age
    end
  end
end
