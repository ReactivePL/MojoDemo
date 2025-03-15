package ReactivePL::Reactive::Mojolicious::Plugin;
use Mojo::Base 'Mojolicious::Plugin', -signatures;

use ReactivePL::Reactive;
use ReactivePL::Reactive::Mojolicious::TemplateRenderer;

sub register ($self, $app, $conf) {
    my $renderer = ReactivePL::Reactive::Mojolicious::TemplateRenderer->new(
        app => $app,
    );

    my $reactive = ReactivePL::Reactive->new(
        template_renderer => $renderer,
        secret => $app->secrets->[0],
        component_namespaces => $conf->{namespaces} // [],
    );

    $app->helper(reactive => sub ($c, $component, %args) {
        return $reactive->initial_render($component, %args);
    });

    $app->routes->post('/reactive' => sub ($c) {
        my $data = $c->req->json;

        $c->render(
            json => $reactive->process_request($data)
        );
    });
}


1;
