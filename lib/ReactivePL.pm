package ReactivePL;
use Mojo::Base 'Mojolicious', -signatures;

use ReactivePL::Reactive;
use Data::Printer;

our $CONTROLLER;

# This method will run once at server start
sub startup ($self) {

    # Load configuration from config file
    my $config = $self->plugin('NotYAMLConfig');

    # Configure the application
    $self->secrets($config->{secrets});

    $self->helper(reactive => sub {
        my $c = shift;
        my $component = shift;
        my %args = @_;

        return ReactivePL::Reactive->new(app => $self)->initial_render($component, %args);
    });

    $self->hook(around_dispatch => sub {
        my $next = shift;
        my $c = shift;

        local $ReactivePL::CONTROLLER = $c;

        $next->();
    });

    # Router
    my $r = $self->routes;

    # Normal route to controller
    $r->get('/')->to('Example#welcome');

    $r->post('/reactive' => sub ($c) {
        my $data = $c->req->json;

        my $reactive = ReactivePL::Reactive->new(app => $self);

        my $component = $reactive->from_snapshot($data->{snapshot});

        if (my $method = $data->{callMethod}) {
            $reactive->call_method($component, $method);
        }

        if (my $update = $data->{updateProperty}) {
            $reactive->update_property($component, @{$update})
        }

        my ($html, $snapshot) = $reactive->to_snapshot($component);

        $c->render(json => {
            html => $html,
            snapshot => $snapshot,
        });
    });
}

1;
