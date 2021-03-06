defmodule Exzeitable.FilterTest do
  @moduledoc false
  use TestWeb.DataCase, async: true
  alias Exzeitable.{Database, Filter}
  alias TestWeb.{Post, User}

  @assigns %{
    query: from(p in Post, preload: [:user]),
    parent: nil,
    routes: TestWeb.Router.Helpers,
    repo: Exzeitable.Repo,
    path: :post_path,
    fields: [title: [], content: []],
    action_buttons: [],
    belongs_to: nil,
    per_page: 50,
    module: TestWeb.PostTable,
    page: 1,
    order: nil,
    count: 0,
    list: [],
    search: ""
  }

  test "parent_for/1 selects the parent for the item" do
    {:ok, user} = %User{name: "Dufus", age: 2} |> Repo.insert()

    {:ok, _post} =
      %Post{
        title: "I picked my nose today",
        content: "It was rather amazing. Would do again.",
        user_id: user.id
      }
      |> Repo.insert()

    assigns = %{@assigns | belongs_to: :user, list: Database.get_records(@assigns)}

    db =
      assigns
      |> Map.get(:list)
      |> List.first()
      |> Filter.parent_for(assigns)

    assert db.name == user.name
  end

  test "parent_for/1 raises an error when it cannot find the field" do
    {:ok, user} = %User{name: "Dufus", age: 2} |> Repo.insert()

    {:ok, _post} =
      %Post{
        title: "I picked my nose today",
        content: "It was rather amazing. Would do again.",
        user_id: user.id
      }
      |> Repo.insert()

    assigns = %{
      @assigns
      | list: Database.get_records(@assigns),
        query: from(p in Post, select: [:id])
    }

    assert_raise RuntimeError,
                 "You need to select the association in :belongs_to",
                 fn ->
                   assigns
                   |> Map.get(:list)
                   |> List.first()
                   |> Filter.parent_for(assigns)
                 end
  end

  test "filter_pages/2 returns no more than 7 buttons no matter the entry" do
    for pages <- 1..20 do
      button_count = Filter.filter_pages(pages, 1) |> Enum.count()
      assert button_count <= 7
      button_count = Filter.filter_pages(pages, 5) |> Enum.count()
      assert button_count <= 7
    end
  end

  test "filter_pages/2 returns the first, and last numbers, and the numbers surrounding the current page" do
    buttons = Filter.filter_pages(12, 8)
    expected_result = [1, "....", 7, 8, 9, "....", 12]
    assert buttons == expected_result
  end

  test "fields_where/2 returns all the fields for which an attribute is true" do
    list = [
      item_one: %{boogers: false},
      item_two: %{boogers: true},
      item_three: %{boogers: true},
      item_four: %{boogers: false}
    ]

    resulting_list = [
      item_two: %{boogers: true},
      item_three: %{boogers: true}
    ]

    assert Filter.fields_where(list, :boogers) == resulting_list
  end

  test "fields_where_not/2 returns all the fields for which an attribute is false" do
    list = [
      item_one: %{boogers: false},
      item_two: %{boogers: true},
      item_three: %{boogers: true},
      item_four: %{boogers: false}
    ]

    resulting_list = [
      item_one: %{boogers: false},
      item_four: %{boogers: false}
    ]

    assert Filter.fields_where_not(list, :boogers) == resulting_list
  end

  test "set_fields/2 merges fields over the defaults" do
    opts = [
      fields: [
        first: [label: "something"]
      ]
    ]

    after_merge = [
      first: [function: false, hidden: false, search: true, order: true, label: "something"]
    ]

    assert Filter.set_fields(opts) == after_merge
  end

  test "set_fields/2 overwrites other options when virtual: true is set" do
    opts = [
      fields: [
        first: [label: "something", virtual: true]
      ]
    ]

    after_merge = [
      first: [
        hidden: false,
        label: "something",
        virtual: true,
        function: true,
        search: false,
        order: false
      ]
    ]

    assert Filter.set_fields(opts) == after_merge
  end
end
