## Overview
Most of the dashboard application is built using Backbone. The main routes: `/`, `/projects`, `/quickstart`, `/account` are rendered from JavaScript templates. The templates and code for setting up the views is found in `app/assets/javascript/backbone`.

## Key People
Jon Mumm: Build most of this code base  
Ankur Oberoi: Interacted with provided JSON API to implement user login and signup, and getting started on TokBox.com  
Julia: Takes Stripe and user data daily from scheduled rake tasts, processes it, and creates report.  
Garrett: Will be implementing interaction with dashboard from new website (as of Feb 19, 2013)  
Mike Sander: QAs the dashboard  
Melih / Betsy: Design and specced the dashboard  

## Setup

### Create a vhost 
Add a vhost that includes .tokbox.com (i.e. db.tokbox.com). This is so that cookies will work for authentication. When developing, always use that URL to test.

```
sudo sh -c 'echo 127.0.0.1 db.tokbox.com >> /etc/hosts'
```

### Install the dependencies

```
bundle install
```

### Migrate the database

```
rake db:migrate
RAILS_ENV=test rake db:migrate
```

### Set Environment variables

```
# Havelock server for generating keys / sessions
TB_API_URL=http://api.opentok.com/hl

# Location of TokBox website
TB_WWW_HOST=www.tokbox.com

# Available from jWade
TB_AWS_ACCESS_KEY=
TB_AWS_SECRET_KEY=

# available on bizdev@tokbox.com Stripe account
TB_STRIPE_PUBLISHABLE_KEY=
TB_STRIPE_SECRET_KEY=
```

### Start the server
```
rails s
```

You should now be able to access the application from the vhost you set up on port 3000 (i.e. http://db.tokbox.com:3000).

## Automated Testing
Run the following command to initialize the test suite

```
bundle exec guard
```

## Editing account info
You must be a collaborator on the application on Heroku. Once your account is connected, run this command:

```bash
heroku run rails c --app tb-dashboard-prod
```

This will give you the console which you can then use to access and
modify account information. For example, to delete a persons account do:

```ruby
u = User.find_by_email "mumm@tokbox.com"
u.destroy
```

or to update a username:

```ruby
u = User.find_by_username "mumm"
u.username = "mumm2point0"
u.save
```

## API Endpoints

The dashboard uses [Devise](https://github.com/plataformatec/devise) for authentication. When authenticating from the dashboard via CORS, you must make the request from a tokbox.com domain.

#### Verifying if the user is logged in

To see if a user is logged in, check for the presence of the cookie `tb_sso_token`. If this cookie exists, the user is logged in. If it does not exist, the user is not logged in.

#### Login

```javascript
$.ajax({
  url: DASHBOARD_URL + "/users/sign_in.json",
  dataType: 'json',
  type: 'POST',
  xhrFields: { withCredentials: true },
  data: {
    "user[email]": "mumm@tokbox.com",
    "user[password]": "mypassword"
  } 
});
```

If the email or password is bad, this request will return a cross domain error.

#### Forgot Password

```javascript
$.ajax({
  url: DASHBOARD_URL + "/users/password.json",
  dataType: 'json',
  type: 'POST',
  xhrFields: { withCredentials: true },
  data: {
    "user[email]": "mumm@tokbox.com"  
  } 
});
```

#### Sign Up

```javascript
$.ajax({
  url: DASHBOARD_URL + "/signups.json",
  dataType: 'json',
  type: 'POST',
  xhrFields: { withCredentials: true },
  data: {
    "signup[username]": "jonmumm",
    "signup[email]": "mumm@tokbox.com",
    "signup[terms_of_service]": 1,
    "signup[password]": "mypassword"  
  } 
});
```

#### Resend Email Confirmation

```javascript
$.ajax({
  url: DASHBOARD_URL + "/users/confirmation.json",
  dataType: 'json',
  type: 'POST',
  xhrFields: { withCredentials: true },
  data: {
    "user[email]": "mumm@tokbox.com"
  } 
});
```

#### Validation and Errors

For all API requests, validation is done on the server and will send a 422 response with a JSON string error response if it fails. An example error response:

```javascript
{"errors":{"email":["has already been taken"],"username":["has already been taken"]}}
```

## Single-Sign On

The TokBox forums, and some other applications (TokTime), uses the Dashboard for single-sign on authentication. Authentication relies on dashboard setting the tb_sso_token cookie in Dashboard. Dependent applications (must be on .tokbox.com domain) use the value of that token to call `/sso/#{tb_sso_token}.json`, which returns a JSON representation of that user.

## Payments
Payment invoices are calculated at the end of the month. 

We prorate support plan, so if a user was on tier 2 for 15 days and tier
1 for 15 days, we would charge .5 * 250 + .5 * 1000 at the end of the
month.

We charge usage plan based on whatever plan the customer has selected at
the end of the billing cycle. If the user goes over the selected plan,
we will charge overrage (don't do that today).

Stripe sends a request that is caught by WebhooksController at the end
of every billing cicle. There is a class PlanCalculator that takes the
logs of when users changed plans and calculates how they should be
charged for the month.

## Rake Tasks
There are two rake tasks that are run everyday to generate data for Mike and
Julia's reports. `rake user_plan_list` and `rake plan_change_list`.

These grabs all the data, creates a CSV file, then pushes it to S3 where
Julia parses it and spits our a daily report. We are using the Heroku
scheduler addon to run these tasks daily.


## Run Jobs
rake jobs:work
