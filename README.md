# library

> You know, whenever anybody asks Elon [Musk] how he learned to build rockets, he says, 'I read books.' Well, it's true. He devoured those books.  
~ Jim Cantrell, Aerospace consultant, on Elon Musk

## Why?
Reading books allows you to acquire in a few hours or days, the knowledge that the author a few _years_ to research, synthesise and collate.

dwyl has a good-sized collection of books on a variety of subjects, chiefly:
+ Programming
+ Business / startups
+ Psychology

We look to actively encourage dwylers to borrow and use these books
(see https://github.com/dwyl/summer/issues/31) but routinely run up against a few issues problems which we need to resolve:
+ With no way of tracking who has borrowed these books, they are often forgotten and go missing (ontop of this we share an office space
where we don't have the contact details for those who are not dwylers)
+ It became clear from our previous attempts to capture key lessons and feedback
from the books that were read (by asking people to PR to
[this `md` file](https://github.com/dwyl/start-here/blob/master/books-to-read.md)),
that if this process is in any way onerous, it will not be done
and the knowledge will be lost
+ Current requests for books are verbal and we need a more efficient way of
capturing this so that we can automate the decision-making process

## What?
Preliminary research indicates that the current open source _library_ software that exists
is both complex and adheres to the rules that govern traditional _libraries_.

We aim to build something ***simple*** which _minimises dependencies_ (reducing maintenance) and is _fully tested_.

The embryonic first iteration of the application will allow dwylers to carry out a small number of essential tasks:
+ Search for books
+ See the information for the searched book
+ Determine whether or not the book already exists in the dwyl library
+ If the book is part of the library:
  + Open the listing to see more information
  + Check whether the book is currently checked out by another dwyler
    + If this is the case, add themselves to a _waitlist_ for the book which triggers
    an email to the current dwyler who has the book to let them know someone else
    has an interest in reading the book (MVP iteration)
  + If the book is part of the library and available, check it out
+ If the book is not part of the library:
  + Add a request for dwyl to acquire the book
  + This must include filling in a one question form to explain why
  + Allow an admin to mark the book as part of the library, so that when new books are purchased
  they can easily be added
+ Check in the book when it is returned
  + This should include adding the answer to two short questions as a review
+ Favourite the book

## Running the Library locally
To run the Library locally clone the repo, install the node modules, initialise
the database and finally start the server:

```shell
git clone https://github.com/dwyl/library.git
cd library
mix deps.get
cd assets && npm i && cd ..
mix do ecto.create, ecto.migrate, phx.server
```

If the above commands don't work, make sure you have Phoenix 1.3 and Postgres
installed on your machine.
