Replay::EventSystem::RabbitMQ
======

#RabbitMQ implimentation for the EventSystem component of the Replay framework

The Replay framework depends on the ability to pass messages around. This 
implimentation passes messages around using RabbitMQ.

Configuring your Replay to use this module

In your configuration hash, the EventSystem/Mode member must be set to
'RabbitMQ'.

You must additional define the particulars for connecting to the RabbitMQ 
instance you wish the system to use, with the appropriate host and options.

    {
        ...
        EventSystem => {
            Mode     => 'RabbitMQ',
            RabbitMQ => {
                host    => 'localhost',
                options => {
                    port        => '5672',
                    user        => 'replay',
                    password    => 'replaypass',
                    vhost       => '/replay',
                    timeout     => 30,
                    tls         => 1,
                    heartbeat   => 1,
                    channel_max => 0,
                    frame_max   => 131072
                },
            },
        },
        ...
    }



