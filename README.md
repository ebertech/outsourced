=======
outsourced
==========

This gem descends from and extends DelayedJob because I wanted to solve the following problems:

* Sometimes workers need to be on a different machine that can't share a database (firewalls, general ill-will, etc.)
* Those workers should authenticate themselves appropriately
* Queues shouldn't just keep growing infinitely
* Jobs should have explicit states that aren't implicit to which set of attributes is set. 
* Jobs should have owners that are generic so that a given Thing can ask "how many jobs have I scheduled"
* Jobs should have smarter queues: queues should be tied to workers at the server level based on authentication
* Jobs should be able to be scheduled over http(s) with appropriate authentication and authorization
* Jobs should keep a history of their various transitions and retries with full errors

To do this, outsourced creates two new DelayedJob backends: 

* An ActiveRecord backend on the server that has the functionality described above
* An ActiveResource backend that can be run on a client that will connect to a given endpoint and ask it for jobs
