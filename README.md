### Daily Donation Webapp

*(open-sourced by Dollar a Day on October 30th, 2015)*

Welcome! This is a Rails app that ran [Dollar a Day](dollaraday.co).

Dollar a Day ran from October 1st, 2014 until October 30th, 2015.

Here's the gist of it:

* let people sign up to donate $1 everyday
* feature a different nonprofit everyday
* send out daily newsletters featuring each nonprift

Take the idea and do whatever you want! This codebase is here to help you if you want to do a similar thing ($5 a Day, $10 a Month, or even just a daily newsletter).

#### Details about the App

This is a Rails 4.1 app built on top of a lot of great services & open-source software:

  * delayed_job to run async jobs
  * capistrano 3 for deployment
  * unicorn is included in the Gemfile, but it should be fine with puma, etc
  * audited is also included, and comes in handy quite often
  * either NFG or Stripe for payments (explained below)
  * maxmind geoip for subscriber IP lookup

#### Getting Started

For development environments, just run this:

`script/bootstrap_configs`

And then fill in the necessary credentials in the generated config/*.yml files.

[Pow](http://pow.cx/) as development server and [rbenv](https://github.com/sstephenson/rbenv) as a Ruby version manager work great for development work.

#### Payments

This app supports 2 payment methods:

* Stripe
  * flexibility: will let you build cooler features (some ideas we liked were letting
    donors give more than $1 if they like a day's nonprofit, let a donor
    cancel a $1 donation if they don't like that day's choice, etc)
  * overhead: you do more work re:nonprofits, but their dashboard is very useful
  * fees: $0.29 * donation amount + $0.30
  * payouts: requires you to setup and handle disbursements

* Network for Good:
  * flexibility: locked down to their credit card API
  * overhead: best choice for non-501c3s, you do less work
  * fees: some negotiated percentage * donation amount
  * payouts: NFG takes care of disbursements for you

The donation form is currently tailored for Stripe, so there's a little
extra work to make it fit Network for Good.

#### Emails

The app is built to send emails via Mailgun (over SMTP and their API). Other services could work too, but Mailgun has a useful UI and just works.

#### Deployment

It should be pretty easy to deploy this with capistrano, after filling out some info in the deploy files. Suggested setup is:

* unicorn for app server
* nginx for web server / SSL termination
* any old MySQL database
* cron -- the app assumes you have cron running every 15 minutes, like so:
  # m  h dom mon dow command
  */15 * * * * export cd /apps/my_app_name/current; bin/rails runner -e $RAILS_ENV 'Cron.tab' > /tmp/cronout
* job server -- the app uses DelayedJob and provides rake/cap integration to restart it on deploys

#### Features

* Subscriber-only newsletters
* Donor-only newsletters
* Gifting
* Calendar of upcoming nonprofits
* Donations are batched and executed every 30 days to avoid paying fees for $1 donations.
* Favoriting nonprofits
* Intercom.io integration

#### Models

NB: the `User` model is currently reserved for admin use, for which it uses Devise.

### Subscriber-only Scenario

```
SUBSCRIBER
  |
  -> EMAIL -> NEWSLETTER
  -> EMAIL -> NEWSLETTER
  -> EMAIL -> NEWSLETTER
  -> ...
```

### Donor Scenario

```
DONOR
  |
  -> SUBSCRIBER
    |
    -> EMAIL -> NEWSLETTER
    -> EMAIL -> NEWSLETTER
    -> EMAIL -> NEWSLETTER
    -> ...
  |
  -> CARD
    |
    -> DONATIONS
      |
      -> DONATION-NONPROFIT -> NONPROFIT
      -> DONATION-NONPROFIT -> NONPROFIT
      -> DONATION-NONPROFIT -> NONPROFIT
      -> ...
```

### Gift Scenario

```
GIFT
  |
  -> GIVER_SUBSCRIBER
  |
  -> DONOR
    |
    -> SUBSCRIBER
      |
      -> EMAIL -> NEWSLETTER
      -> EMAIL -> NEWSLETTER
      -> EMAIL -> NEWSLETTER
      -> ...
    |
    -> CARD
      |
      -> DONATIONS
        |
        -> DONATION-NONPROFIT -> NONPROFIT
        -> DONATION-NONPROFIT -> NONPROFIT
        -> DONATION-NONPROFIT -> NONPROFIT
        -> ...
```




#### TODO

* Fill out missing functional tests
* Fill out missing unit tests
* Cleanup auth code in controllers
* A few models could benefit from a state machine: donation, donor, subscriber, &gift.
* Update hashes to 1.9 hash syntax (ie replace hashrockets on symbol keys)
* Auto-create an Email record after we deliver emails, instead of manually doing it each time
* Other TODOs scattered around the app

