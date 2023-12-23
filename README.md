# [Parties for All](https://partiesforall.events)

![Build status](https://github.com/ThePletch/shay-parties/actions/workflows/test.yml/badge.svg)

Parties for All is a free, open-source web-based event and RSVP manager written in Ruby on Rails.

It's **free of charge** and **ad-free**, and it **always will be**.

Parties for All provides the following features in a lightweight, simple interface:

* Event discovery at a general level and for events specific to an individual host.
* Support for secret/hidden events, blocked from displaying in the events index unless you've RSVPed to them already.
* Event landing pages, including address management and scheduling.
* Multiple systems for communicating with your guests before the event:
  * Polls, for any questions that need answering
  * Threaded comments (including avatars via Gravatar)
* RSVP tracking
* Mailing list management (no support for sending emails directly, but provides an easy-to-copy list of email addresses for sending the email yourself)
  * Additionally, access to easily contact all users who have RSVPed.

## Why?

The main thing keeping me on Facebook was its (admittedly quite good) events system. I looked for alternatives, but all of them were either for-profit startups targeting concerts or event managers with money to burn on advanced features or non-profit services designed for pretty niche use cases (e.g. managing a convention or conference). To make sure I could seamlessly pull myself away, I wrote an alternative.

It's got everything you need for the basics of managing events with friends and loved ones, but intentionally doesn't have any features for people looking to make money off people showing up. I also wouldn't recommend it for events with more than a few dozen attendees - it's not built for interacting with the masses (the comments section, for instance, designed under the assumption that discussions won't involve more than a few dozen comments)

I develop this project as a hobby because I feel like this is a service that should exist without any restrictions. There are some associated costs, but they're minimal (and will be minimal unless this really takes off). I might have a donation option here in the future to defray those costs.

And finally, since this is a personal project being provided free of charge and managed in my spare time, I can't guarantee things like service availability, data integrity, or fast issue resolution when bugs occur. I make no guarantees or promises about the service, and don't assume any liability for loss or damage that occurs from failure or undesirable behavior. Use this service at your own risk.

## Developer Info

### Contributing

To contribute to Parties for All, just fork it and open a pull request with your proposed change. I'll respond within a day or two. I accept pull requests from anyone, and encourage people who are new to software development to contribute, even if it's something small like a copy change or a CSS cleanup. I do expect changes to the internal logic to have the following test coverage:

* If you changed or added Javascript, either introduce or modify an integration test to ensure the logic you introduced works. I don't currently have scaffolding set up for JS unit tests, since the custom JS on the site is minimal. 
* If you changed any user-facing interactions, same as above - it needs an integration test.
* Any changes to the models or controllers need a corresponding model or controller unit test.
* New or updated models need new or updated factories.

And, of course, your changes shouldn't break any existing tests (though it's fine to change those tests if you've changed the assumptions they're testing).

If you're unsure about how to write any of the above tests, go ahead and submit your PR without them, but note in your description that you'd like help and I'll be happy to oblige.

If your change modifies the UI, it helps a lot to include before/after screenshots in your pull request.

### What to Contribute

Currently, I keep track of what features I want to add or upgrade in the Projects section of this Github repository. Feel free to grab anything in the to-do columns, if you're looking for ideas. If you'd like to implement something not listed there, I'll never say no to someone helping out.

### Local Setup

This app doesn't do anything particularly unusual, as Rails apps go. It runs its database on PostgreSQL, uses Puma for its server, and Bundler for its dependencies.

#### Run with Docker Compose (preferred)

Running `docker compose up` will spin up a server and all dependencies. The local development server will listen on [port 23000](http://localhost:23000). Sidecar containers will also run on boot handle installing your bundle and running any pending migrations. If you change your dependency versions or add a new migration, you'll need to run the sidecars again to get things up to date:

```bash
docker compose run bundle-installer && docker compose run db-migrater
```

If you just want to run the test suite, you can spin up a shell (with dependencies) for testing by running the `docker-shell` executable in the `bin` directory:

```bash
./bin/dockershell
```


#### Run directly

To run locally without using Docker, you can just run the following commands from the repo's root directory, once you've cloned it:

```bash
bundle install
rails db:setup
rails server
```

The above commands assume you have Ruby and Bundler installed and have a Postgres server running on your machine.

Running the tests is as simple as `bundle exec rspec`.

### Running your own instance of Parties for All

If you want to host your own instance for privacy reasons (or whatever other reasons), take a look at the infrastructure folder in the repository. You can spin up your own copy of that infrastructure with Terraform on your personal AWS account. Work to make setup more automated and require less manual input is underway.

shay is testing deploys
