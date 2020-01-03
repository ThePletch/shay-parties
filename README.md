# [Parties for All](https://steve-events.herokuapp.com)

[travis ci badge goes here]

Parties for All is a free, open-source web-based event and RSVP manager written in Ruby on Rails.

It's **free of charge** and **ad-free**, and it **always will be**.

Parties for All provides the following features in a lightweight, simple interface:

* Event discovery at a user level, for both a 'default' user and any other users who want to share their own events.
* Event landing pages, including address management and scheduling.
* Multiple systems for communicating with your guests before the event:
  * Polls, for any questions that need answering
  * Comments (including comment scores/voting/avatars via Gravatar)
* RSVP tracking
* Mailing list management (no support for sending emails directly, but provides an easy-to-copy list of email addresses for sending the email yourself)


## Why?

The main thing keeping me on Facebook was its (admittedly quite good) events system. I looked for alternatives, but all of them were either for-profit startups targeting concerts or event managers with money to burn on advanced features or non-profit services designed for pretty niche use cases (e.g. managing a convention or conference). To make sure I could seamlessly pull myself away, I wrote an alternative.

It's got everything you need for the basics of managing events with friends and loved ones, but intentionally doesn't have many features for people looking to make money off people showing up. I also wouldn't recommend it for events with more than a few dozen attendees - it's not built for interacting with the masses.

I develop this project as a hobby because I feel like this is a service that should exist without any restrictions. There are some associated costs, but they're minimal (and will be minimal unless this really takes off). I might have a donation option here in the future to defray those costs.

And finally, since this is a personal project being provided free of charge and managed in my spare time, I can't guarantee things like service availability, data integrity, or fast issue resolution when bugs occur. I make no guarantees or promises about the service, and don't assume any liability for loss or damage that occurs from failure or undesirable behavior. Use this service at your own risk.

## Developer Info

### Contributing

To contribute to Parties for All, just fork it and open a pull request with your proposed change. I'll respond within a day or two. I accept pull requests from anyone, and encourage people who are new to software development to contribute, even if it's something small like a copy change or a CSS cleanup. I do expect changes to the internal logic to have the following test coverage:

* If you changed or added Javascript, either introduce or modify a feature spec to ensure the logic you introduced works.
* If you changed any user-facing interactions, same as above - it needs a feature spec.
* Any changes to the models or controllers need a corresponding model or controller unit test.
* New or updated models need new or updated factories.

And, of course, your changes shouldn't break any existing tests (though it's fine to change those tests if you've changed the assumptions they're testing).

If you're unsure about how to write any of the above tests, go ahead and submit your PR without them, but note in your description that you'd like help and I'll be happy to oblige.

If your change modifies the UI, it helps a lot to include before/after screenshots in your pull request.

### What to Contribute

Currently, I keep track of what features I want to add or upgrade in the Projects section of this Github repository. Feel free to grab anything in the to-do columns, if you're looking for ideas. If you'd like to implement something not listed there, I'll never say no to someone helping out.

### Local Setup

This app doesn't do anything particularly unusual, as Rails apps go. It runs its database on PostgreSQL, uses Puma for its server, and Bundler for its dependencies. To run locally, you can just run the following commands from the repo's root directory, once you've cloned it:
```bash
$ bundle install
$ rails db:setup
$ rails server
```

Running the tests is as simple as `bundle exec rspec`.


### Running your own instance of Parties for All

If you want to host your own instance for privacy reasons (or whatever other reasons), this app works with Heroku out of the box. Just point it at either this repo directly or your personal fork of it. You'll need to attach (at minimum) a Postgres database add-on. I'd recommend also attaching a logging add-on of some kind.

