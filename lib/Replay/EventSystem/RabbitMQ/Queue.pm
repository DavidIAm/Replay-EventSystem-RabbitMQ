package Replay::EventSystem::RabbitMQ::Queue;

use Moose;
use Replay::Message;
use Replay::EventSystem::RabbitMQ::Message;
use Carp qw/carp croak confess/;
use Data::UUID;

our $VERSION = '0.03';

has rabbit => (
    is       => 'ro',
    isa      => 'Replay::EventSystem::RabbitMQ',
    handles  => [qw( get queue_bind connection )],
    required => 1,
);

has queue => (
    is      => 'ro',
    isa     => 'Replay::EventSystem::RabbitMQ::Queue',
    builder => '_build_queue',
    lazy    => 1,
);

has unique => (is => 'ro', isa => 'Num',);

has bound_queue => (
    is      => 'ro',
    isa     => 'Replay::EventSystem::RabbitMQ::Queue',
    builder => '_build_bound_queue',
    lazy    => 1,
);

has channel => (
    is        => 'ro',
    isa       => 'Num',
    builder   => '_new_channel',
    lazy      => 1,
    predicate => 'has_channel',
);

has purpose => (is => 'ro', isa => 'Str', required => 1,);

has topic => (
    is       => 'ro',
    isa      => 'Replay::EventSystem::RabbitMQ::Topic',
    required => 1,
);

has passive => (is => 'ro', isa => 'Bool', default => 0,);

has durable => (is => 'ro', isa => 'Bool', default => 1,);

has exclusive => (is => 'ro', isa => 'Bool', default => 0,);

has auto_delete => (is => 'ro', isa => 'Bool', default => 0,);

has queue_name =>
    (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_queue_name',);

#has consumer_tag =>
#    (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_consumer',);

has no_local => (is => 'ro', isa => 'Bool', lazy => 1, default => 0,);

has no_ack => (is => 'ro', isa => 'Bool', default => 0,);

sub _new_channel {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my $self = shift;
    return $self->rabbit->channel_open();
}

sub _receive {        ## no critic (ProhibitUnusedPrivateSubroutines)
    my ($self, $message) = @_;

    my $frame = $self->bound_queue->get($self->channel, $self->queue_name,
        { no_ack => $self->no_ack });
    return if !defined $frame;
    return if exists $frame->{frame_type} && $frame->{frame_type} eq 'heartbeat';
    my $rmes = Replay::EventSystem::RabbitMQ::Message->new(
        rabbit  => $self->rabbit,
        channel => $self->channel,
        %{$frame}
    );

    # frames look like this
    #     {
    #       body => 'Magic Transient Payload', # the reconstructed body
    #       routing_key => 'nr_test_q',        # route the message took
    #       exchange => 'nr_test_x',           # exchange used
    #       delivery_tag => 1,                 # (used for acks)
    #       consumer_tag => 'c_tag',           # tag from consume()
    #       props => $props,                   # hashref sent in
    #     }
    return $rmes;
}

sub purge {
    my ($self) = @_;
    return $self->connection->purge($self->channel, $self->queue_name);
}

sub _build_bound_queue {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my ($self) = @_;
    $self->queue->queue_bind($self->channel, $self->queue_name,
        $self->topic->topic->topic_name, q{*});
    return $self;
}

sub DEMOLISH {
    my ($self) = @_;
    if ($self->has_channel && defined $self->rabbit) {
        $self->rabbit->channel_close($self->channel);
    }
    return;
}

sub _build_queue_name {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my $self = shift;
    my $ug   = Data::UUID->new;
    return join q(_), 'replay', $self->rabbit->config->{stage}, $self->purpose,
        ($self->unique ? $ug : ());
}

sub _build_queue {         ## no critic (ProhibitUnusedPrivateSubroutines)
    my ($self) = @_;
    my $opt = {
        passive     => $self->passive,
        durable     => $self->durable,
        exclusive   => $self->exclusive,
        auto_delete => $self->auto_delete,
    };
    $self->rabbit->queue_declare($self->channel, $self->queue_name, $opt,);
    return $self;
}

sub _build_consumer_tag {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my $self = shift;
    my $tag  = $self->queue->consume(
        $self->channel,
        $self->queue_name,
        {   no_local  => $self->no_local,
            no_ack    => $self->no_ack,
            exclusive => $self->exclusive,
        }
    );
    return $tag;
}

1;

__END__

=pod

=head1 NAME

Replay::EventSystem::RabbitMQ::Queue - RabbitMQ Queue implimentation

=head1 VERSION

Version 0.03

=head1 SYNOPSIS

    my $queue = Replay::EventSystem::RabbitMQ::Queue->new(
        rabbit        => $replay-eventsystem-rabbitmq object,
        purpose       => $replay-channenl-name,
        topic         => $replay-channenl-name,
        exchange_type => $rabbitmqexchangetype,
        unique        => $areWeUnique,
    );

=head1 DESCRIPTION

Used to open a rabbitmq queue that will provide a message collection
for a particular Replay purpose from the RabbitMQ server

=head1 SUBROUTINES/METHODS

=head2 _receive

returns a new Replay::Message object materialized out of the RabbitMQ frame

=head2 purge

Delete all the messages from this queue

=head2 DEMOLISH

Makes sure to properly clean up and disconnect from queues

=head1 DIAGNOSTICS

Rather closely tied to Net::RabbitMQ, probably should mostly look there.

=head1 CONFIGURATION AND ENVIRONMENT

The Replay framework

=head1 DEPENDENCIES

=over 4

=item Data::UUID

=back

=head1 INCOMPATIBILITIES

Reality, perhaps

=head1 BUGS AND LIMITATIONS

This code is not yet known to work for any but the simplest tests.

=head1 AUTHOR

David Ihnen, C<< <davidihnen at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-replay at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Replay>.  I will be notified, and then you'

        ll automatically be notified of progress on your bug as I make changes .

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Replay


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Replay>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Replay>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Replay>

=item * Search CPAN

L<http://search.cpan.org/dist/Replay/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 David Ihnen.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS 'AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;
