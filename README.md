# Ruby on Rails Tutorial sample application

This is the sample application created while following the
[*Ruby on Rails Tutorial:
Learn Web Development with Rails*](https://www.railstutorial.org/)
by [Michael Hartl](https://www.michaelhartl.com/).

For now the page is not available on the Live Web. But you can open it locally - instructions below.

## License

All source code in the [Ruby on Rails Tutorial](https://www.railstutorial.org/)
is available jointly under the MIT License and the Beerware License. See
[LICENSE.md](LICENSE.md) for details.

## Getting started

To get started with the app, clone the repo and then install the needed gems:

```
$ gem install bundler -v 2.3.14
$ bundle _2.3.14_ config set --local without 'production'
$ bundle _2.3.14_ install
```

Next, migrate the database:

```
$ rails db:migrate
```

Next, if you want sample users in the app, seed the database:

```
$ rails db:seed
```

Finally, run the test suite to verify that everything is working correctly:

```
$ rails test
```

If the test suite passes, you'll be ready to run the app in a local server:

```
$ rails server
```

Login using the following credentials:
**Email:**    example@railstutorial.org
**Password:** foobar

Signup will require you to check the server logs for the e-mail confirmation link.

For more information, see the
[*Ruby on Rails Tutorial* book](https://www.railstutorial.org/book).
