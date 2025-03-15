package ReactivePL::Reactive;

use warnings;
use strict;

use Moo;
use namespace::clean;
use Types::Standard qw( Str Int Enum ArrayRef Object );

sub initial_render {
    my $self = shift;
    my $component = shift;

    return $component->new->render;
}

1;
