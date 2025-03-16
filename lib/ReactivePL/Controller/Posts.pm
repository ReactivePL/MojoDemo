package ReactivePL::Controller::Posts;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub index ($self) {
  $self->render;
}

1;
