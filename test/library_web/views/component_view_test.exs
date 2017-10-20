defmodule LibraryWeb.ComponentViewTest do
  use LibraryWeb.ConnCase, async: true
  alias LibraryWeb.ComponentView

  describe "Test view functions" do
    @admin_user %{assigns: %{user: %{id: 1, is_admin: true}}}
    @normal_user %{assigns: %{user: %{id: 1}}}
    @second_user %{assigns: %{user: %{id: 2}}}
    @non_user %{assigns: %{}}
    @web_book %{title: "Some book",
                author_list: ["Some author", "Some other author"],
                owned: false,
                web: true}
    @owned_book %{title: "Some book",
                author_list: ["Some author", "Some other author"],
                owned: true,
                web: false}
    @on_loan_book Map.put(@owned_book, :book_loan, %{id: 1})
    @requested_book Map.put(@web_book, :request, [1])

    test "create_query_string builds a book querystring" do
      string = "author_list=Some+author%3BSome+other+author&owned=false&title=Some+book&web=true"

      assert ComponentView.create_query_string(@web_book) == string
    end

    test "get_user returns user details if they exist" do
      assert ComponentView.get_user(@normal_user)
      assert !ComponentView.get_user(@non_user)
    end

    test "admin checks to see if a user is an admin" do
      admin = ComponentView.get_user(@admin_user)
      normal = ComponentView.get_user(@normal_user)

      assert ComponentView.admin?(admin)
      assert !ComponentView.admin?(normal)
    end

    test "get_button_text with no user" do
      assert ComponentView.get_button_text(@web_book, @non_user) == "Login"
    end

    test "get_button_text displays 'Check in' for the correct values" do
      assert ComponentView.get_button_text(@on_loan_book, @admin_user) == "Check in"
      assert ComponentView.get_button_text(@on_loan_book, @normal_user) == "Check in"
      assert ComponentView.get_button_text(@on_loan_book, @second_user) != "Check in"
    end

    test "get_button_text displays 'Join queue' for the correct values" do
      assert ComponentView.get_button_text(@on_loan_book, @admin_user) != "Join queue"
      assert ComponentView.get_button_text(@on_loan_book, @normal_user) != "Join queue"
      assert ComponentView.get_button_text(@on_loan_book, @second_user) == "Join queue"
    end

    test "get_button_text displays 'Check out' for the correct values" do
      assert ComponentView.get_button_text(@owned_book, @normal_user) == "Check out"
      assert ComponentView.get_button_text(@owned_book, @admin_user) != "Check out"
    end

    test "get_button_text displays 'Remove' for the correct values" do
      assert ComponentView.get_button_text(@owned_book, @admin_user) == "Remove"
    end

    test "get_button_text displays 'Add book' for the correct values" do
      assert ComponentView.get_button_text(@web_book, @admin_user) == "Add book"
      assert ComponentView.get_button_text(@web_book, @normal_user) != "Add book"
    end

    test "get_button_text displays 'Request' for the correct values" do
      assert ComponentView.get_button_text(@web_book, @normal_user) == "Request"
      assert ComponentView.get_button_text(@web_book, @admin_user) != "Request"
    end

    test "get_button_text displays 'Requested' for the correct values" do
      assert ComponentView.get_button_text(@requested_book, @normal_user) == "Requested"
      assert ComponentView.get_button_text(@requested_book, @admin_user) != "Requested"
    end
  end
end
