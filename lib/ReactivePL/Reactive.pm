package ReactivePL::Reactive;

use warnings;
use strict;

use Moo;
use namespace::clean;
use Types::Standard qw( Str Int HashRef ArrayRef InstanceOf);

use Scalar::Util 'blessed';

use Data::Printer;

use Module::Load;
use Module::Loader;
use JSON;

use ReactivePL::JSONRenderer;

use Module::Installed::Tiny qw(module_source);
use Digest::SHA qw(sha256_hex);

use Mojo::Util qw(xml_escape);
use Mojo::ByteStream qw(b);

has app => (is => 'ro');

has component_namespaces => (is => 'lazy', isa => ArrayRef[Str]);
has component_map => (is => 'lazy', isa => HashRef[Str]);
has json_renderer => (is => 'lazy', isa => InstanceOf['ReactivePL::JSONRenderer']);

sub initialize_component {
    my $self = shift;
    my $component_name = shift;
    my %args = @_;

    my $component_class = $self->component_map->{$component_name};

    my $component = $component_class->new(%args);

    if ($component->can('mounted')) {
        $component->mounted();
    }

    return $component;
}

sub get_property_names {
    my $self = shift;
    my $component = shift;

    my $component_class = $component;
    if (ref $component) {
        $component_class = blessed $component;
    }

    my @keys = keys(%{
        'Moo'->_constructor_maker_for($component_class)->all_attribute_specs
    });

    return @keys;
}

sub get_properties {
    my $self = shift;
    my $component = shift;

    my @keys = $self->get_property_names($component);

    my %properties = map { $_ => $component->$_ } @keys;

    return %properties;
}

sub get_component_name {
    my $self = shift;
    my $component = shift;

    my $name = blessed $component;
    $name =~ s/.*:://gi;

    return $name;
}

sub snapshot_data {
    my $self = shift;
    my $component = shift;

    my %properties = $self->get_properties($component);

    return {
        component => $self->get_component_name($component),
        data => \%properties,
    };
}

sub initial_render {
    my $self = shift;
    my $component_name = shift;
    my %args = @_;

    my $component = $self->initialize_component($component_name, %args);

    my ($html, $snapshot) = $self->to_snapshot($component);

    my $escaped_snapshot = xml_escape($self->json_renderer->render($snapshot));

    $html =~ s/^\s*(<[a-z\-]+(?:\s[^\/>]+)*)(\s*)(\/?>)/$1 reactive:snapshot="$escaped_snapshot" $3/m;

    return b($html);
}

sub from_snapshot {
    my $self = shift;
    my $snapshot = shift;

    my $checksum_from_snapshot = delete $snapshot->{checksum};
    my $checksum = $self->generate_checksum($snapshot);

    if ($checksum_from_snapshot ne $checksum) {
        die "checksum doesnt match";
    }

    my $component = $self->initialize_component($snapshot->{component}, %{$snapshot->{data}});

    return $component;
}

sub to_snapshot {
    my $self = shift;
    my $component = shift;

    my %properties = $self->get_properties($component);

    my $template = $component->render;

    my $html = $ReactivePL::CONTROLLER->render_to_string(
        inline => $template,
        %properties,
    );

    my $snapshot = $self->snapshot_data($component);
    $snapshot = $self->json_renderer->process_data($snapshot);

    $snapshot->{checksum} = $self->generate_checksum($snapshot);

    return ($html, $snapshot);
}

sub generate_checksum {
    my $self = shift;
    my $snapshot = shift;

    my $component_class = $self->component_map->{$snapshot->{component}};

    my $module_src_digest = sha256_hex(module_source($component_class));
    my $snapshot_digest = sha256_hex($self->json_renderer->canonical_json->encode($snapshot));
    my $secret_digest = sha256_hex($self->app->secrets->[0]);

    return sha256_hex(sprintf '%s:%s:%s', $module_src_digest, $snapshot_digest, $secret_digest);
}

sub call_method {
    my $self = shift;
    my $component = shift;
    my $method = shift;

    $component->$method();
}

sub update_property {
    my $self = shift;
    my $component = shift;
    my $property = shift;
    my $value = shift;

    $component->$property($value);

    if ($component->can('updated')) {
        $component->updated($property);
    }
}

sub _build_component_namespaces {
    my $self = shift;
    # TODO: Make this configurable
    return [qw/
        ReactivePL::Reactive::Components
    /];
}

sub _build_component_map {
    my $self = shift;

    my $loader  = Module::Loader->new;
    my %result;

    foreach my $ns (@{$self->component_namespaces}) {
        printf "Checking namespace $ns\n";
        foreach my $component ($loader->find_modules($ns)) {
            printf "Found component $component\n";
            $loader->load($component);

            my $name = $component;
            $name =~ s/.*:://gi;

            $result{$name} = $component;
        }
    }

    return \%result;
}

sub _build_json_renderer {
    return ReactivePL::JSONRenderer->new();
}

1;
