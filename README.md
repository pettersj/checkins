# README

## Sorry, this project is no longer available as an app. But I've open sourced it, feel free to fork and host on your own.

## Warning - unmaintained!
This repo is not maintained, it's just the original project opensourced.

## What is it?
Checkin is a recurring email-checkin, based on Basecamps Check-in feature.
This is an Ruby on Rails app with starter template from [jumpstart](https://github.com/excid3/jumpstart)


# Get startet
Fork and run `bundle install`


### Credentials
To get the app working in production, you need to add some credentials.
Create a credentials and master key: `rails credentials:edit`
```
action_mailbox:
  ingress_password: ''

postmark_api_token: ''

aws:
  access_key_id: ''
  secret_access_key: ''
  bucket: ''
  
development:
  stripe:
    secret_key: ''
    public_key: ''
    signing_secret: ''

production:
  stripe:
    secret_key: ''
    public_key: ''
    signing_secret: ''
```

### CronJob
Add a cron job every for every hour with `rake schedule_check_ins`

