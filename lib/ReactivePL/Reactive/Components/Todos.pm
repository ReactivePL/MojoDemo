package ReactivePL::Reactive::Components::Todos;

use warnings;
use strict;

use Moo;
use namespace::clean;
use Types::Standard qw( Str Int Enum Undef ArrayRef Object Maybe );
use Reactive::Core::Types qw(DateTime);

has todos => (is => 'rw', isa => ArrayRef[Str], default => sub { return [qw/One Two Three/] });
has draft => (is => 'rw', isa => Str->plus_coercions(Undef, q{ '' }), coerce => 1);
has time => (is => 'rw', isa => DateTime, coerce => 1, default => sub { undef });

sub mounted {
    my $self = shift;

    # $self->time(DateTime->now());
}

sub updated {
    my $self = shift;
    my $property = shift;

    printf "updated $property\n";
}

sub addTodo {
    my $self = shift;

    push @{$self->todos}, $self->draft;
    $self->draft('');
}

sub render {
    my $self = shift;

    return <<'HTML';
        <div class="todos">
            <input type="text" reactive:model="draft" placeholder="Todo..."/>
            <button reactive:click="addTodo">Add Todo</button>
            <button reactive:click.unset="draft">Clear</button>

            <ul>
                % foreach my $todo (@{ $todos }) {
                    <li>
                        <%= $todo %>
                    </li>
                % }
            </ul>
        </div>
HTML
}

1;
