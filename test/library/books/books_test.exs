defmodule Library.BooksTest do
  use Library.DataCase

  alias Library.Books

  describe "books" do
    alias Library.Books.Book

    @valid_attrs %{authors: [],
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
    @update_attrs %{authors: [],
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
    @invalid_attrs %{authors: nil,
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
      {:ok, book} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Books.create_book()

      book
    end

    test "list_books/0 returns all books" do
      book = book_fixture()
      assert Books.list_books() == [book]
    end

    test "get_book!/1 returns the book with given id" do
      book = book_fixture()
      assert Books.get_book!(book.id) == book
    end

    test "create_book/1 with valid data creates a book" do
      assert {:ok, %Book{} = book} = Books.create_book(@valid_attrs)
      assert book.authors == []
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

    test "create_book/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Books.create_book(@invalid_attrs)
    end

    test "update_book/2 with valid data updates the book" do
      book = book_fixture()
      assert {:ok, book} = Books.update_book(book, @update_attrs)
      assert %Book{} = book
      assert book.authors == []
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
  end

  describe "authors" do
    alias Library.Books.Author

    @valid_attrs %{author: "some author"}
    @update_attrs %{author: "some updated author"}
    @invalid_attrs %{author: nil}

    def author_fixture(attrs \\ %{}) do
      {:ok, author} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Books.create_author()

      author
    end

    test "list_authors/0 returns all authors" do
      author = author_fixture()
      assert Books.list_authors() == [author]
    end

    test "get_author!/1 returns the author with given id" do
      author = author_fixture()
      assert Books.get_author!(author.id) == author
    end

    test "create_author/1 with valid data creates a author" do
      assert {:ok, %Author{} = author} = Books.create_author(@valid_attrs)
      assert author.author == "some author"
    end

    test "create_author/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Books.create_author(@invalid_attrs)
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

    test "change_author/1 returns a author changeset" do
      author = author_fixture()
      assert %Ecto.Changeset{} = Books.change_author(author)
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
