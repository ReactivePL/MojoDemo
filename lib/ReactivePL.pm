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

    # Bit of a hack but this is required for DBIx::Class::Result properties in
    # components to work, we need to provide the $schema instance
    $override->replace('Reactive::Core::Types::dbic_schema', sub { $schema });

    $self->helper(schema => sub {
        return $schema;
    });

    # Router
    my $r = $self->routes;

    # Normal route to controller
    $r->get('/')->to('Example#welcome');

    $r->get('/posts')->to('Posts#index');
}

1;
