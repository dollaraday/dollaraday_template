### Daily Donation Rails Webapp

*(open-sourced by Dollar a Day on October 30th, 2015)*

Welcome! This is a Rails app that ran [Dollar a Day](http://dollaraday.co), from October 1st, 2014 until October 30th, 2015.

Here's the gist of it:

* people sign up to donate $1 everyday
* 1 nonprofit featured each day to receive donations
* daily newsletters featuring each nonprofit

Take the idea and do whatever you want! This codebase is here to help you if you want to do a similar thing ($5 a Day, $10 a Month, or even just a daily newsletter).

#### Details about the App

This is a Rails 4.1 app built on top of a lot of great services & open-source software:

  * [delayed_job](https://github.com/collectiveidea/delayed_job) to run async jobs
  * [capistrano 3](http://capistranorb.com/) for deployment
  * [unicorn](http://unicorn.bogomips.org/) is included in the Gemfile, but it should be fine with puma, etc
  * [audited](https://github.com/collectiveidea/audited) is also included, and comes in handy quite often
  * either [Network For Good](http://www.thenetworkforgood.org/) or [Stripe](https://stripe.com/) for payments (explained below)
  * [MaxMind GeoIP](https://www.maxmind.com/en/geoip2-databases) for subscriber IP lookup
  * [mailgun](http://www.mailgun.com/) for sending emails.

#### Getting Started

For development environments, just install ruby >=2 and run this:

`script/bootstrap_configs`

And then fill in the necessary credentials in the generated config/*.yml files.

Then setup your database:

`bundle exec rake db:create db:migrate db:seed`

[Pow](http://pow.cx/) as development server and [rbenv](https://github.com/sstephenson/rbenv) as a Ruby version manager work great for running the webapp locally.

#### Payments

This app supports 2 payment methods:

* Stripe
  * flexibility: will let you build cooler features (some ideas we liked were letting
    donors give more than $1 if they like a day's nonprofit, let a donor
    cancel a $1 donation if they don't like that day's choice, etc)
  * overhead: you'll need to be a 501c3 to offer tax deductions to US donors, but their dashboard is very useful for that accounting if you are
  * fees: 2.9% * donation amount + $0.30
  * payouts: requires you to setup and handle disbursements

* Network for Good:
  * flexibility: locked down to their credit card API
  * overhead: provides tax deductible receipts to US donors, because they are a 501c3 and a processor.
  * fees: some negotiated percentage * donation amount
  * payouts: NFG takes care of disbursements for you

The donation form is currently tailored for Stripe, so there'd be a little
extra work to make it fit Network for Good again.

#### Emails

The app is built to send emails via Mailgun (over SMTP and their API). Other services could work too, but Mailgun has a useful UI and just works.

#### Deployment

It should be easy to deploy this with capistrano, after filling out some info in the deploy files. Suggested setup for your servers is:

* unicorn for app server
* nginx for web server / SSL termination
* any old MySQL database
* cron -- the app assumes you have cron running every 15 minutes, like so:
```
  # m  h dom mon dow command
  */15 * * * * export cd /apps/my_app_name/current; bin/rails runner -e $RAILS_ENV 'Cron.tab' > /tmp/cronout
```
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

