package ReactivePL::Reactive::Components::Counter;

use warnings;
use strict;

use Moo;
use namespace::clean;

use Types::Standard qw( Int );

has count => (is => 'rw', isa => Int, default => sub { return 0 });

sub render {
    my $self = shift;

    return <<'HTML';
        <div class="counter">
            <button reactive:click.decrement="count">-</button>
            <span><%= $count %></span>
            <button reactive:click.increment="count">+</button>
        </div>
HTML
}

1;
