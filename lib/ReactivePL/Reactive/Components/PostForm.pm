package ReactivePL::Reactive::Components::PostForm;

use warnings;
use strict;

use Moo;
use namespace::clean;

use Types::Standard qw( Str Int Enum ArrayRef Object );
use Reactive::Core::Types qw( DBIx );

use Data::Printer;

use DateTime;

has post => (is => 'ro', isa => DBIx['ReactivePL::Schema::Result::Post'], coerce => 1);

has title => (is => 'rw', isa => Str);
has content => (is => 'rw', isa => Str);

sub mounted {
    my $self = shift;

    $self->title($self->post->title);
    $self->content($self->post->content);
}

sub save {
    my $self = shift;

    $self->post->title($self->title);
    $self->post->content($self->content);
    $self->post->updated_at(DateTime->now());

    $self->post->update();
}

sub render {
    my $self = shift;

    return <<'HTML';
        <div
            class="post-form"
            style="display: flex; flex-direction: column; border: solid black 1px;"
        >
            <span>Editing Post: <%= $post->id %></span>
            <input type="text" name="title" reactive:model.lazy="title">
            <textarea name="content" reactive:model.lazy="content" rows="10"></textarea>
            <button reactive:click="save">Save</button>
        </div>
HTML
}

1;
