package ReactivePL::TemplateRenderer;

use warnings;
use strict;

use Moo;
use namespace::clean;
use Types::Standard qw(InstanceOf);

use ReactivePL::JSONRenderer;

has json_renderer => (is => 'lazy', isa => InstanceOf['ReactivePL::JSONRenderer']);

sub render {
    my $self = shift;
    my $template = shift;
    my %paramters = @_;

    die "Method `->render(\$template, \%args)` must be overridden in subclass. $self";
}

sub escape {
    my $self = shift;
    my $string = shift;

    die "Method `->escape(\$string)` must be overridden in subclass. $self";
}

sub inject_snapshot {
    my $self = shift;
    my $html = shift;
    my $snapshot = shift;

    my $escaped_snapshot = $self->escape($self->json_renderer->render($snapshot));

    $html =~ s/^\s*(<[a-z\-]+(?:\s[^\/>]+)*)(\s*)(\/?>)/$1 reactive:snapshot="$escaped_snapshot" $3/m;

    return $html;
}

sub _build_json_renderer {
    return ReactivePL::JSONRenderer->new();
}

1;
