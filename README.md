# Tasker

Tasker is an exploration into what the datamodel for a, hopefully good,
general purpose, multi-user, collaborative task tracking application
might look like.

* The core of the datamodel is the task.
* A task is any item of work that time is spent on.
* Tasks may be have one or more sub-tasks.
* There are different categories of tasks and each category may have additional attributes that are specific to that category.
* Categories include, but are not limited to:
  * Ordinary tasks
  * Meetings
  * Issues
  * Requirements
  * Activities
    * An activity is a collection of, or context under which, tasks are tracked/performed.
    * A project is an activity. All projects are activities but not all activities are projects.
    * Activities may contain sub-activities.
* Each category may have one or more sub-categories or types
