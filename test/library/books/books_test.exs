defmodule Library.BooksTest do
  use Library.DataCase

  alias Library.Books

  describe "books" do
    alias Library.Books.Book

    @valid_attrs %{author_list: ["some author"],
                   category: "some category",
                   date_published: "some date_published",
                   isbn_10: "some isbn_10",
                   isbn_13: "some isbn_13",
                   language: "some language",
                   owned: true,
                   preview_link: "some preview_link",
                   thumbnail: "some thumbnail",
                   thumbnail_small: "some thumbnail_small",
                   title: "some title",
                   type: "some type"}
    @update_attrs %{author_list: ["some updated author"],
                    category: "some updated category",
                    date_published: "some updated date_published",
                    isbn_10: "some updated isbn_10",
                    isbn_13: "some updated isbn_13",
                    language: "some updated language",
                    owned: false,
                    preview_link: "some updated preview_link",
                    thumbnail: "some updated thumbnail",
                    thumbnail_small: "some updated thumbnail_small",
                    title: "some updated title",
                    type: "some updated type"}
    @invalid_attrs %{author_list: [],
                     category: nil,
                     date_published: nil,
                     isbn_10: nil,
                     isbn_13: nil,
                     language: nil,
                     owned: nil,
                     preview_link: nil,
                     thumbnail: nil,
                     thumbnail_small: nil,
                     title: nil,
                     type: nil}

    def book_fixture(attrs \\ %{}) do
        attrs
        |> Enum.into(@valid_attrs)
        |> Books.create_book!()
    end

    test "list_books/0 returns all books" do
      book = book_fixture()
      assert Books.list_books() == [book]
    end

    test "get_book!/1 returns the book with given id" do
      book = book_fixture()
      fetched_book = Books.get_book!(book.id)
      assert fetched_book.title == book.title
    end

    test "update_owned_by_id!/1 updates the 'owned' book prop" do
      book = book_fixture()
      new_book = Books.update_owned_by_id!(book.id)
      assert book.owned == true
      assert new_book.owned == false
    end

    test "create_book!/1 with valid data creates a book" do
      assert %Book{} = book = Books.create_book!(@valid_attrs)
      assert book.author_list == ["some author"]
      assert book.category == "some category"
      assert book.date_published == "some date_published"
      assert book.isbn_10 == "some isbn_10"
      assert book.isbn_13 == "some isbn_13"
      assert book.language == "some language"
      assert book.owned == true
      assert book.preview_link == "some preview_link"
      assert book.thumbnail == "some thumbnail"
      assert book.thumbnail_small == "some thumbnail_small"
      assert book.title == "some title"
      assert book.type == "some type"
    end

    test "update_book/2 with valid data updates the book" do
      book = book_fixture()
      assert {:ok, book} = Books.update_book(book, @update_attrs)
      assert %Book{} = book
      assert book.author_list == ["some updated author"]
      assert book.category == "some updated category"
      assert book.date_published == "some updated date_published"
      assert book.isbn_10 == "some updated isbn_10"
      assert book.isbn_13 == "some updated isbn_13"
      assert book.language == "some updated language"
      assert book.owned == false
      assert book.preview_link == "some updated preview_link"
      assert book.thumbnail == "some updated thumbnail"
      assert book.thumbnail_small == "some updated thumbnail_small"
      assert book.title == "some updated title"
      assert book.type == "some updated type"
    end

    test "update_book/2 with invalid data returns error changeset" do
      book = book_fixture()
      assert {:error, %Ecto.Changeset{}} =
        Books.update_book(book, @invalid_attrs)
      assert book == Books.get_book!(book.id)
    end

    test "delete_book/1 deletes the book" do
      book = book_fixture()
      assert {:ok, %Book{}} = Books.delete_book(book)
      assert_raise Ecto.NoResultsError, fn -> Books.get_book!(book.id) end
    end

    test "change_book/1 returns a book changeset" do
      book = book_fixture()
      assert %Ecto.Changeset{} = Books.change_book(book)
    end

    test "create_book_authors/1 adds a book and all the listed authors" do
      Books.create_book_authors!(%{title: "some book", author_list: ["some author", "another author"]})
      Books.create_book_authors!(%{title: "another book", author_list: ["some author", "another author"]})
      [%{title: title}, %{title: title_two}] = Books.list_books
      %{author: author_one} = Books.get_author_by_name("some author")
      %{author: author_two} = Books.get_author_by_name("another author")
      assert title == "some book"
      assert title_two == "another book"
      assert author_one == "some author"
      assert author_two == "another author"
    end
  end

  test "get_books_by_author/1 gets all the books by an author" do
    Books.create_book_authors!(%{title: "some book",
                                author_list: ["some author", "another author"]})
    Books.create_book_authors!(%{title: "another book",
                                author_list: ["some author"]})
    num_books_one =
    "some author"
    |> Books.get_books_by_author
    |> Enum.count

    num_books_two =
    "another author"
    |> Books.get_books_by_author
    |> Enum.count

    assert num_books_one == 2
    assert num_books_two == 1
  end

  test "delete_book_and_unique_authors/1 removes a book and authors unique to it" do
    Books.create_book_authors!(%{title: "some book",
                                author_list: ["some author", "another author"]})
    Books.create_book_authors!(%{title: "another book",
                                author_list: ["some author"]})

    [book_one, book_two] = Books.list_books

    assert Enum.count(Books.list_authors) == 2
    assert Enum.count(Books.list_books) == 2

    Books.delete_book_and_unique_authors(book_one)

    assert Enum.count(Books.list_authors) == 1
    assert Enum.count(Books.list_books) == 1
  end

  describe "authors" do
    alias Library.Books.Author

    @valid_attrs %{author: "some author"}
    @update_attrs %{author: "some updated author"}
    @invalid_attrs %{author: nil}

    def author_fixture(attrs \\ %{}) do
      attrs
      |> Enum.into(@valid_attrs)
      |> Books.create_author!()
    end

    test "list_authors/0 returns all authors" do
      author = author_fixture()
      assert Books.list_authors() == [author]
    end

    test "get_author!/1 returns the author with given id" do
      author = author_fixture()
      assert Books.get_author!(author.id) == author
    end

    test "create_author!/1 with valid data creates a author" do
      assert %Author{} = author = Books.create_author!(@valid_attrs)
      assert author.author == "some author"
    end

    test "update_author/2 with valid data updates the author" do
      author = author_fixture()
      assert {:ok, author} = Books.update_author(author, @update_attrs)
      assert %Author{} = author
      assert author.author == "some updated author"
    end

    test "update_author/2 with invalid data returns error changeset" do
      author = author_fixture()
      assert {:error, %Ecto.Changeset{}} =
        Books.update_author(author, @invalid_attrs)
      assert author == Books.get_author!(author.id)
    end

    test "delete_author/1 deletes the author" do
      author = author_fixture()
      assert {:ok, %Author{}} = Books.delete_author(author)
      assert_raise Ecto.NoResultsError, fn -> Books.get_author!(author.id) end
    end
  end

  describe "requests" do
    alias Library.Books.Request

    @valid_attrs %{}
    @update_attrs %{}

    def request_fixture(attrs \\ %{}) do
      {:ok, request} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Books.create_request()

      request
    end

    test "list_requests/0 returns all requests" do
      request = request_fixture()
      assert Books.list_requests() == [request]
    end

    test "get_request!/1 returns the request with given id" do
      request = request_fixture()
      assert Books.get_request!(request.id) == request
    end

    test "create_request/1 with valid data creates a request" do
      assert {:ok, %Request{} = request} = Books.create_request(@valid_attrs)
    end

    test "update_request/2 with valid data updates the request" do
      request = request_fixture()
      assert {:ok, request} = Books.update_request(request, @update_attrs)
      assert %Request{} = request
    end

    test "delete_request/1 deletes the request" do
      request = request_fixture()
      assert {:ok, %Request{}} = Books.delete_request(request)
      assert_raise Ecto.NoResultsError, fn -> Books.get_request!(request.id) end
    end
  end

  describe "requests" do
    alias Library.Books.Request

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def request_fixture(attrs \\ %{}) do
      {:ok, request} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Books.create_request()

      request
    end

    test "list_requests/0 returns all requests" do
      request = request_fixture()
      assert Books.list_requests() == [request]
    end

    test "get_request!/1 returns the request with given id" do
      request = request_fixture()
      assert Books.get_request!(request.id) == request
    end

    test "create_request/1 with valid data creates a request" do
      assert {:ok, %Request{} = request} = Books.create_request(@valid_attrs)
    end

    test "update_request/2 with valid data updates the request" do
      request = request_fixture()
      assert {:ok, request} = Books.update_request(request, @update_attrs)
      assert %Request{} = request
    end

    test "delete_request/1 deletes the request" do
      request = request_fixture()
      assert {:ok, %Request{}} = Books.delete_request(request)
      assert_raise Ecto.NoResultsError, fn -> Books.get_request!(request.id) end
    end

    test "change_request/1 returns a request changeset" do
      request = request_fixture()
      assert %Ecto.Changeset{} = Books.change_request(request)
    end
  end
end
