package ReactivePL;
use Mojo::Base 'Mojolicious', -signatures;

use ReactivePL::Reactive;

# This method will run once at server start
sub startup ($self) {

  # Load configuration from config file
  my $config = $self->plugin('NotYAMLConfig');

  # Configure the application
  $self->secrets($config->{secrets});

  $self->helper(reactive => sub {
    my $c = shift;
    my $component = shift;

    return ReactivePL::Reactive->new->initial_render($component);
  });

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('Example#welcome');
}

1;
