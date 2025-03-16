package ReactivePL;
use Mojo::Base 'Mojolicious', -signatures;

use Sub::Override;

use Reactive::Core::Types;
use ReactivePL::Schema;

my $override = Sub::Override->new;

# This method will run once at server start
sub startup ($self) {

    # Load configuration from config file
    my $config = $self->plugin('NotYAMLConfig');

    # Configure the application
    $self->secrets($config->{secrets});

    $self->plugin(
        'Reactive::Mojo::Plugin',
        {
            namespaces => [
                'ReactivePL::Reactive::Components',
            ],
        },
    );

    my $schema = ReactivePL::Schema->connect(
        $config->{database}{dsn},
        $config->{database}{username},
        $config->{database}{password}
    );

    $override->replace('Reactive::Core::Types::dbic_schema', sub { $schema });

    $self->helper(schema => sub {
        return $schema;
    });

    # Router
    my $r = $self->routes;

    $r->add_shortcut(resource => sub ($r, $name) {
        # Prefix for resource
        my $resource = $r->any("/$name")->to("$name#");

        # Render a list of resources
        $resource->get('/')->to('#index')->name($name);

        # Render a form to create a new resource (submitted to "store")
        $resource->get('/create')->to('#create')->name("create_$name");

        # Store newly created resource (submitted by "create")
        $resource->post->to('#store')->name("store_$name");

        # Render a specific resource
        $resource->get('/:id')->to('#show')->name("show_$name");

        # Render a form to edit a resource (submitted to "update")
        $resource->get('/:id/edit')->to('#edit')->name("edit_$name");

        # Store updated resource (submitted by "edit")
        $resource->put('/:id')->to('#update')->name("update_$name");

        # Remove a resource
        $resource->delete('/:id')->to('#remove')->name("remove_$name");

        return $resource;
    });

    # Normal route to controller
    $r->get('/')->to('Example#welcome');
    $r->resource('posts');
}

1;
