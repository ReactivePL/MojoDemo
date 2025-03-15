package ReactivePL::Reactive::Components::Input;

use warnings;
use strict;

use Moo;
use namespace::clean;
use Types::Standard qw( Str Int Enum ArrayRef Object );

has name => (is => 'ro', isa => Str, required => 1);
has value => (is => 'rw', isa => Str, default => sub { return '' });

sub render {
    my $self = shift;

    return <<'HTML';
        <input class="custom-input-component" type="text" name="<%= $name %>" reactive:model="value"/>
HTML
}

1;
