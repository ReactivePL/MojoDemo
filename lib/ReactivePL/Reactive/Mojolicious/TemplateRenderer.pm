package ReactivePL::Reactive::Mojolicious::TemplateRenderer;

use warnings;
use strict;

use Moo;
use namespace::clean;
use Types::Standard qw(InstanceOf);

use Mojo::ByteStream qw(b);
use Mojo::Util qw(xml_escape);

extends 'ReactivePL::TemplateRenderer';

has app => (is => 'ro', isa => InstanceOf['Mojolicious']);
has controller => (is => 'lazy', isa => InstanceOf['Mojolicious::Controller']);

sub render {
    my $self = shift;
    my $template = shift;
    my %properties = @_;

    return $self->controller->render_to_string(inline => $template, %properties);
}

sub escape {
    my $self = shift;
    my $string = shift;

    return xml_escape($string);
}

sub inject_attribute {
    my $self = shift;
    my $html = shift;
    my $attribute = shift;
    my $value = shift;

    my $result = $self->SUPER::inject_attribute($html, $attribute, $value);

    return b($result);
}

sub _build_controller {
    my $self = shift;

    return $self->app->build_controller;
}

1;
