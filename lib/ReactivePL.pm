package ReactivePL;
use Mojo::Base 'Mojolicious', -signatures;

use ReactivePL::Types;
use ReactivePL::Schema;

# This method will run once at server start
sub startup ($self) {

    # Load configuration from config file
    my $config = $self->plugin('NotYAMLConfig');

    # Configure the application
    $self->secrets($config->{secrets});

    $self->plugin(
        'ReactivePL::Reactive::Mojolicious::Plugin',
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

    *ReactivePL::Types::dbic_schema = sub { $schema };

    $self->helper(schema => sub {
        return $schema;
    });

    # Router
    my $r = $self->routes;

    # Normal route to controller
    $r->get('/')->to('Example#welcome');
}

1;
