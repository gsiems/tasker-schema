# Tasker

Tasker is an exploration into what the datamodel for a, hopefully good,
general purpose, multi-user, collaborative task tracking application
might look like.

## Activities and Tasks

There is only one main organizing object being considered-- the task.

### Activity

* An activity is a form of task.
* An activity is a collection of, or context under which, tasks are tracked/performed.
* A project is an activity. All projects are activities but not all activities are projects.
* Activities may also contain sub-activities.

### Task

* A task is any work unit that time is spent on.
* There are different categories of tasks and each category may have different attributes.
* A meeting is a form of task.
* An issue report is also a form of task.
* Requirements are also tasks.
* Tasks may be broken down into one or more sub-tasks.

## Users

The kinds of users that might interact with the task tracking application probably consist of:

* **Worker**: The person performing the task.
* **Supervisor**: The person that the worker reports to.
* **Manager**: The person that is somewhere above the supervisor or who is resposible for ensureing that the activity is performed.
* **Sponsor**: The entity that is paying for/requesting the activity be performed.
* **Community**: The external entity or entities that, while not a part of the activity, benefit from/are impacted by the activity.

## User Stories

This is my attempt at trying to wear the hat of each user type and
considering what, in no particular order, that user might want out of
a, hopefully good, general purpose, multi-user, collaborative task
tracking application.

At a minimum, whether or when the application supports any particular
user story, the data model should support, or at least not preclude,
the ability of realising the user story.

### Worker

* 1.1 - Wants to know what is on their task list.
* 1.2 - Has finished a task and is deciding what they should work on next.
* 1.3 - Has just come back from a long vacation and is trying to remember what they had been working on prior to the vacation.
* 1.4 - Wishes to review their accomplishments over the past year.
* 1.5 - Has an issue that they wish to report/track.
* 1.6 - Has two meetings scheduled at the same time and wants to know what is on the meeting agendas so they can determine which meeting they most need to be at.
* 1.7 - Has missed an important meeting due to conflicts and wants to know what was discussed or decided.
* 1.8 - Is waiting on some other task to be finished so they can start on a task.
* 1.9 - Wants to track their own personal/administrative tasks.
* 1.10 - Wants to be notified when a task is added to their list.
* 1.11 - Does not want to be notified when a task is added to their list.
* 1.12 - Only wants to be notified when a high priority task is added to their list.
* 1.13 - Wants to be notified when a task is removed from their list.
* 1.14 - Wants to be notified when the status of a task changes.
* 1.15 - Wants notifications by email/IM/SMS/"Bat Signal"/etc.
* 1.16 - Has questions about a task and wants to have/document a conversation about it.

### Supervisor

* 2.1 - Wants to know what their workers are currently working on.
* 2.2 - Wants to know where their workers have been spending the most time.
* 2.3 - Wants to balance the work load between their workers.
* 2.4 - Has an issue that they wish to report/track.
* 2.5 - Wants to be aware of any issues that are impacting their workers.
* 2.6 - Wants to assign a training task to each of their workers. (multiple tasks, one per user)
* 2.7 - Wants to schedule meeting with all their users. (single task, multiple users)
* 2.8 - Wishes to review their workers accomplishments over the past year.
* 2.9 - Wants to schedule a recurring meeting with one or more of their workers. (multiple tasks, one or more users)
* 2.10 - Wants to unschedule a recurring meeting.
* 2.11 - Wants to schedule a recurring task with one or more of their workers. (multiple tasks, one or more users)

### Manager

* 3.1 - Wants to know which activities/tasks are being worked on.
* 3.2 - Wants to know/specify which users are assigned to which activities/tasks.
* 3.3 - Wants to know the status of an activity/task.
* 3.4 - Wants to know if an activity/task is on schedule.
* 3.5 - Wants to know how much time was/is being spent on an activity/task.
* 3.6 - Has an issue that they wish to report/track.
* 3.7 - Wants to be aware of any issues.
* 3.8 - Wants to schedule meeting with all users assigned to an activity. (single task, multiple users)
* 3.9 - Wants to know which, if any, tasks are holding up progress.
* 3.10 - Wants to schedule a recurring standup meeting for an activity. (multiple tasks, multiple users)
* 3.11 - Wants to unschedule a recurring meeting.
* 3.12 - Wants to be notified when the status of a task changes.
* 3.13 - Wants to specify due dates for tasks but understands that some due dates are much "firmer" than others-- that is, some are true deadlines while others are more aspirational goals.
* 3.14 - Needs to limit access to some activities. Not all activities can be public.
* 3.15 - Would like, for project like activities, to see a GANTT chart (or equivalent) report for visualizing the activity timeline.

### Sponsor

* 4.1 - Wants to track the activities that they are sponsoring.
* 4.2 - Wants to know the status of an activity.
* 4.3 - Wants to know if an activity/task is on schedule.
* 4.4 - Wants know how much time is being spent on an activity.
* 4.5 - Wants to be aware of any issues.
* 4.6 - Has an issue that they wish to report/track.
* 4.7 - Wants to be notified when the status of an issue that they submitted changes.
* 4.8 - Might want to be notified when the status of an issue that they did not submit changes.
* 4.9 - Wants to know which, if any, tasks are holding up progress.

### Community

* 5.1 - Wants to know the status of an activity.
* 5.2 - Is interested in the progress of an activity.
* 5.3 - Has an issue that they wish to report/track.
* 5.4 - Wants to be notified when the status of an issue that they submitted changes.
* 5.5 - Wants to know what to expect from an activity.
* 5.6 - Wants to know what, if any, changes they need to be aware of.

## Schema

Note that the (initial at least) database supported is PostgreSQL.

### Naming conventions

 * Table name prefixes
   * dt_ : signifies a data table for containing user supplied data.
   * rt_ : signifies a reference table that may be edited by the application administrator.
   * st_ : signifies a system table that is not to be edited.

 * View name prefixes
   * dv_ : signifies a view of the dt_-named data table for containing user supplied data.
   * rv_ : signifies a view of the rt_-named reference table that may be edited by the application administrator.
   * sv_ : signifies a view of the st_-named system table that is not to be edited.

 * No mixed-case, or forced case, identifiers are allowed. In fact, no identifiers that require quoting are allowed.
