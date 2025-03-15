package ReactivePL::Types;

use warnings;
use strict;

use DateTime;
use DateTime::Format::ISO8601;

use Type::Library -extends => [ 'Types::Standard' ], -declare => qw/
    DateTime
    Boolean
/;

use Type::Tiny::Class;
use Types::TypeTiny qw/BoolLike/;

use constant ISO8601_REGEX => /(\d{4}-[01]\d-[0-3]\d)T[0-2]\d:[0-5]\d:[0-5]\d(\.\d+)?([+-][0-2]\d:[0-5]\d|Z)/;

my $dt = __PACKAGE__->add_type(
    Type::Tiny::Class->new(
        name    => 'DateTime',
        class   => 'DateTime',
    )
);
$dt->coercion->add_type_coercions(
  Int,                     q{ DateTime->from_epoch(epoch => $_) },
  Undef,                   q{ DateTime->now() },
  StrMatch[ISO8601_REGEX], q{ DateTime::Format::ISO8601->parse_datetime($_) }
);

my $boolean = __PACKAGE__->add_type(
    name => 'Boolean',
    parent => Enum[\0, \1],
);

$boolean->coercion->add_type_coercions(
    BoolLike, q{ $_ ? \1 : \0 },
);

__PACKAGE__->make_immutable;
1;
