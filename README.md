==========
outsourced
==========

Outsourced is a job queue. It is used for scheduling jobs that are picked up by worker process and may be considered a replacement for delayed_job. Instead of your workers being on the same machine as your database or at least on the same filesystem the tasks can run anywhere as long as they can get an http connection to your server. Also, the server decides which workers work on which jobs so that on the machines running the jobs all you need to do is:

    outsourced_worker

And it will automatically connect and start pulling jobs. The workers authenticate themselves using oauth. The oauth key management is done on the server like so (command line for now):

====
Example:
====

    script/outsourcer worker create phill.worker@okayfail.com #create a new worker
    script/outsourcer queue create stuff_to_do #create a new queue
    script/outsourcer queue hire phill.worker@okayfail.com #assign worker to the queue
    script/outsourcer worker config -o foo.yml phill.worker@okayfail.com #dump all the connection info needed 
                                                                         #for the worker to the yaml file

You can embed this into any rack-based app because it mounts in your routes like:

    mount Outsourced::Engine => "/outsourced"

Everything else is handled automatically. 

Queueing up jobs is done with

    Outsourced.enqueue("JobClass", arg1, arg2, etc)

Jobs are saved as JSON drawing inspiration from resque. 

Queues can have limits on them so that they are bounded and reject jobs once they get full. Jobs have the ability to retry after a completion and/or after a failure. Jobs also can have an optional attachment file which is served by the web server without having to encode it in base64.

====
Purpose
====

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
