package App::lcpan::Cmd::top_namespaces_by_module_count;

use 5.010001;
use strict;
use warnings;

require App::lcpan;

# AUTHORITY
# DATE
# DIST
# VERSION

our %SPEC;

$SPEC{handle_cmd} = {
    v => 1.1,
    summary => "List top namespaces by module count",
    args => {
        %App::lcpan::common_args,
    },
};

sub handle_cmd {
    my %args = @_;

    my $state = App::lcpan::_init(\%args, 'ro');
    my $dbh = $state->{dbh};

    my $sth = $dbh->prepare("SELECT name,num_modules FROM namespace ORDER BY num_modules DESC LIMIT 50");
    $sth->execute;
    my @rows;
    while (my $row = $sth->fetchrow_hashref) { push @rows, $row }

    [200, "OK", \@rows];
}

1;
# ABSTRACT:

=head1 DESCRIPTION

By default only the top 50 are returned.

=head1 SEE ALSO

L<App::lcpan::Cmd::namespace>
