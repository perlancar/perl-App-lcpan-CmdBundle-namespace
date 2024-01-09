package App::lcpan::Cmd::namespace_authors;

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
    summary => "Given a namespace, list authors in that namespace sorted by module count",
    args => {
        %App::lcpan::common_args,
        namespace => {
            schema => ['perl::modname*'],
            req => 1,
            pos => 0,
            completion => \&App::lcpan::_complete_ns,
        },
    },
};
sub handle_cmd {
    my %args = @_;

    my $state = App::lcpan::_init(\%args, 'ro');
    my $dbh = $state->{dbh};

    my $sth = $dbh->prepare("SELECT num_modules FROM namespace WHERE name=?");
    $sth->execute($args{namespace});
    my $row = $sth->fetchrow_arrayref or return [404, "No such namespace"];
    my $num_modules = $row->[0];
    return [200, "OK", []] unless $num_modules;

    $sth = $dbh->prepare("SELECT cpanid AS author,COUNT(*) AS num_modules, 100.0*COUNT(*)/$num_modules AS pct_modules FROM module WHERE name LIKE '$args{namespace}\::%' GROUP BY cpanid ORDER BY num_modules DESC");
    $sth->execute;

    my @rows;
    while (my $row = $sth->fetchrow_hashref) { $row->{pct_modules} = sprintf "%.2f", $row->{pct_modules}; push @rows, $row }

    [200, "OK", \@rows];
}

1;
# ABSTRACT:
