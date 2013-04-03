![http://classwhole.com](http://imgur.com/1zN99Zc.png)

Classwhole is a drag-and-drop course scheduler, [try it out](http://classwhole.com). 

If you find a bug, please file an [issue](https://github.com/kryali/classwhole/issues?direction=desc&sort=updated&state=open).

Pull requests are welcome!

## Overview

Classwhole is built on [Rails 3](http://rubyonrails.org/) with [AngularJS](http://angularjs.org/). 
We use AngularJS for its excellent data-binding support and for it's dependency injection to organize client-size code.
Rails is reponsible for collection course catalog data as well as persisting user schedule and accounts.
We use [HAML](http://haml.info/) and [SASS](http://sass-lang.com/) to generate our front-end HTML/CSS.

The best way to think about how this application works is that Rails produces the API that the client-side AngularJS consumes it.

## Setup

If you're using linux or a Debian distribution, you can run `ubuntu_bootstrap.sh` to pull in most of your system level dependencies. It's possible that this file may get out of date.

    # Make sure all your gems are up to date 
    bundle install  
    rake db:create db:migrate

    # Scrape course data: This takes a while, I would run this in the background or in a screen
    rake data:update       

### Development
    rails server
    
### Production
    bundle exec rake assets:precompile
    passenger start

## Geeky Stuff

Below are some of the technical highlights in how Classwhole works.

![demo](http://imgur.com/5ORNq5a.png)

#### Course Catalog scraping
We scrape course catalog data from the university via an XML API they provide. This runs as a daily cron job to keep course information fresh.

* [lib/tasks/uiuc_parser.rake](https://github.com/kryali/classwhole/blob/master/lib/tasks/uiuc_parser.rb)

#### Algorithmic scheduling logic
When a user adds a class or select a different group, we attempt to create a possible schedule server-side and then respond to the client with a success or error message. 
Ideally this logic would exist on the client to simplify our back-end services and scale up efficiently.

* [lib/scheduler.rb](https://github.com/kryali/classwhole/blob/master/lib/scheduler.rb)

#### Client side requests
Whenever a user interacts with an element on the page, it ultimately funnels to a service in this folder. This includes class addition, removal, and group modification. 
The requests are usually dispatched through `angular/schedule.js` which is set in the controller `angular/scheduler.ctrl.js`.

* [app/assets/javascripts/schedule/angular/services/](https://github.com/kryali/classwhole/tree/master/app/assets/javascripts/angular/services)

#### Custom autocomplete implementation
In order to pull off a multi-mode search field, custom suggestions, and a Google style typeahead we had to customize the shit out of jQueryUI's autocomplete plugin.

* [app/assets/javascripts/lib/autocomplete.js](https://github.com/kryali/classwhole/tree/master/app/assets/javascripts/lib/autocomplete.js) (admittedly messy)
    
#### Scraping RateMyProfessor
We use [Nokogiri](http://nokogiri.org/) to scrape professor data fom RateMyProfessor as a rake task. This code is pretty easy to pull out if you'd like to use it in your own project.

* [lib/tasks/prof_rate.rake](https://github.com/kryali/classwhole/blob/master/lib/tasks/prof_rake.rb)

#### Interaction (The Magic)
Interacting with the schedule happens in a few ways. Usually a browser event is dispatched to `angular/schedule.js` which decides what to do and how to modify the current state of the page.

* [app/assets/javascripts/schedule/angular/schedule.js](https://github.com/kryali/classwhole/tree/master/app/assets/javascripts/angular/schedule.js)

## Contributing
Lots of general cleanup, bug fixes, and features are needed, any help is greatly appreciated.

1. Fork our project
2. Pull request!


## License
```
Copyright 2011 Jon Hughes, Kiran Ryali, Scott Wilson

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
