### psick::update - Manage packages updates

This class manages how and when a system should be updated, it can be included with the parameter:

    psick::base::linux_classes:
      'update': '::psick::update'

The class just creates a cronjob which runs the system's specific update command. By default the cron schedule is empy so not update is automatically done:

    psick::update::cron_schedule: '0 6 * * *' 

The above setting would create a cron job, executed every day at 6:00 AM, that updates the system's packages.


