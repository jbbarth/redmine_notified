Redmine Notified plugin
=======================

This plugin allows you to see notifications that are about to be sent when updating or creating issues.

Screenshots
-----------

The plugin adds a link on issues:

![redmine_notified screenshot](http://jbbarth.com/screenshots/redmine_notified_1.png)

... which opens a popup where you can see who has actually been notified at each step:

![redmine_notified screenshot](http://jbbarth.com/screenshots/redmine_notified_2.png)

Install
-------

This plugin is compatible with Redmine 2.5.x, and should be compatible with future versions.

You can first take a look at general instructions for plugins [here](http://www.redmine.org/wiki/redmine/Plugins).

Then :
* clone this repository in your "plugins/" directory ; if you have a doubt you put it at the good level, you can check you have a plugins/redmine_notified/init.rb file
* run the migrations from your redmine root directory with command : `RAILS_ENV=production rake redmine:plugins`
* install dependencies (gems) by running the following command: `bundle install`
* restart your Redmine instance (depends on how you host it)

Test status
------------

|Plugin branch| Redmine Version   | Test Status      |
|-------------|-------------------|------------------|
|master       | 4.2.7             | [![4.2.7][1]][5] |  
|master       | 4.1.7             | [![4.1.7][2]][5] |
|master       | master            | [![master][4]][5]|

[1]: https://github.com/jbbarth/redmine_notified/actions/workflows/4_2_7.yml/badge.svg
[2]: https://github.com/jbbarth/redmine_notified/actions/workflows/4_1_7.yml/badge.svg
[4]: https://github.com/jbbarth/redmine_notified/actions/workflows/master.yml/badge.svg
[5]: https://github.com/jbbarth/redmine_notified/actions

Contribute
----------

If you like this plugin, it's a good idea to contribute :
* by giving feed back on what is cool, what should be improved
* by reporting bugs : you can open issues directly on github
* by forking it and sending pull request if you have a patch or a feature you want to implement
