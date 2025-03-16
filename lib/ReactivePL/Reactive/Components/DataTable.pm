package ReactivePL::Reactive::Components::DataTable;

use warnings;
use strict;

use Moo;
use namespace::clean;

use Types::Standard qw( Str Int Enum ArrayRef Object );
use ReactivePL::Types qw( DBIx );

use Data::Printer;

use DateTime;

has resultset => (is => 'ro', isa => Str);

has limit => (is => 'rw', isa => Int, default => sub { 25 });
has page => (is => 'rw', isa => Int, default => sub { 1 });

has search => (is => 'rw', isa => Str, default => sub {''});

sub _schema {
    my $self = shift;

    return Reactive::Core::Types->dbic_schema();
}

sub results {
    my $self = shift;

    my $rs = $self->_schema
        ->resultset($self->resultset)
        ->search({
            'me.deleted_at' => undef,
        },{
            rows => $self->limit,
            page => $self->page,
            order_by => {
                -desc => 'me.id',
            },
        });

    if (my $search = $self->search) {
        my $match = \["match(me.title, me.content) against (? IN BOOLEAN MODE)" => $search];
        $rs = $rs->search({
            -and => [
                $match,
            ],
        },{
            order_by => {
                -desc => $match,
            },
        });
    }

    my @results = $rs->all();

    return @results;
}

sub prevPage {
    my $self = shift;

    return unless $self->page > 1;

    $self->page($self->page - 1);
}

sub nextPage {
    my $self = shift;

    $self->page($self->page + 1);
}

sub render {
    my $self = shift;

    return <<'HTML';
        <div
            class="datatable"
            style="
                display: flex;
                flex-direction: column;
                border: solid black 1px;
            "
        >
            <div
                class="datatable-controls"
                style="display: flex; justify-content: space-between;"
            >
                <input type="text" name="search" reactive:model="search">
                <div class="pagination">
                    <button reactive:click="prevPage">Previous</button>
                    <span><%= $page %></span>
                    <button reactive:click="nextPage">Next</button>

                    <select reactive:model="limit">
                        <option>5</option>
                        <option>10</option>
                        <option>15</option>
                        <option>20</option>
                        <option>25</option>
                    </select>
                </div>
            </div>
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Title</th>
                        <th>Author</th>
                        <th>Created At</th>
                        <th>Modified At</th>
                    </tr>
                </thead>
                <tbody>
                    % foreach my $post ($self->results) {
                        <tr>
                            <td><%= $post->id %></td>
                            <td><%= $post->title %></td>
                            <td><%= $post->user_id %></td>
                            <td><%= $post->created_at %></td>
                            <td><%= $post->updated_at %></td>
                        </tr>
                    % }
                </tbody>
            </table>
        </div>
HTML
}

1;
