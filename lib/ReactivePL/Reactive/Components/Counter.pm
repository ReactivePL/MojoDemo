package ReactivePL::Reactive::Components::Counter;

use warnings;
use strict;

use Moo;
use namespace::clean;
use Types::Standard qw( Str Int Enum ArrayRef Object );

use Data::Printer;

has count => (is => 'rw', isa => Int, default => sub { return 0 });

sub increment {
    my $self = shift;

    $self->count($self->count + 1);
}

sub render {
    my $self = shift;

    return <<'HTML';
        <div class="counter">
            <span><%= $count %></span>
            <button reactive:click="increment">+</button>
        </div>
HTML
}

1;
