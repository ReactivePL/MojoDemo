package ReactivePL::Reactive::Components::Counter;

use warnings;
use strict;

use Moo;
use namespace::clean;
use Types::Standard qw( Str Int Enum ArrayRef Object );

has count => (is => 'rw', isa => Int);

sub render {
    my $self = shift;

    return <<"HTML";
        <div class="counter">
            <span>{$self->count}</span>
            <button wire:click="increment">+</button>
        </div>
HTML
}

1;
