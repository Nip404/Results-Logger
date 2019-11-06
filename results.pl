#! perl -s
use JSON;
use Data::Dumper;
use List::Util qw(max);

use feature "say";

our $file = 'data.json';

sub main {
    #-h/help option
    if ($h || $help) {
        say "Usage: perl ./results.pl [-v] [-s] [-r] [Subject Grade % Expected_grade Mock(%) Boundary]";
        say "Use -s option to sort by percentage, no option for alphabetical, -r for reverse for both modes";
        say "-v verbose switch is incompatible with other display switches";
        say "Use spaces for delimiters.";
        say "Fill unknown values with '.' or otherwise - exception will be thrown if args is incomplete";
    } else {
        if (scalar @ARGV < 6) {
            if ($v && ($s || $r)) { # check compatibility between switches
                die "-v verbose switch incomptible with -s -r switches";
            }

            # fetches hashref or encoded json object according to -v switch
            my $resultsref = retrieve($v);

            if ($v) { # displays everything
                say JSON->new->pretty->encode($resultsref);
            } else {
                my $max_len = max map {length} keys %$resultsref; # for formatting output
                my %results = %$resultsref;

                # gets sorted list of keys by alphabetical or by numerical mark
                my @sortedkeys = $s ? sort {eval $results{$b}->{Mark} <=> eval $results{$a}->{Mark}} keys %results : sort keys %results; 

                # loops according to -r reverse switch
                foreach my $subject ($r ? reverse @sortedkeys : @sortedkeys) {
                    my $grade = %results{$subject};

                    # displays formatted output
                    say join '  ', 
                        " $subject" . ' ' x ($max_len - length($subject)),
                        $grade->{Grade}, 
                        ' ' x (length $grade->{Mark} == 6) . $grade->{Mark},
                        sprintf('%.1f%', eval "$grade->{Mark}*100");
                }
            }
        } elsif (scalar @ARGV == 6) {
            # input another record
            store(&format(@ARGV));
        } else {
            die "perl ./results.pl -h for help.";
        }
    }
}

sub store {
    my $subject = shift;
    my @entry = @_;

    my $json = retrieve(1);
    $json->{$subject} = \@entry; #  encodes data into json format

    # writes to json file
    open(FH, ">:encoding(UTF-8)", $file) or die $!;
    print FH encode_json($json);
    close(FH);
}

sub format {
    my (
        $subject, $grade, $mark,
        $expected, $mock, $boundary,
    ) = @_;

    return (
        $subject,
        {
            'Grade' => $grade,
            'Mark' => $mark,
        }, {
            'Expected Grade' => $expected,
            'Mock results' => $mock,
            'Boundary' => $boundary,
        },
    );
}

sub retrieve {
    open(FH, "<:encoding(UTF-8)", $file) or die $!;
    
    my $json = decode_json do {
        local $/; # locally enable slurp mode
        <FH>; # decode returned file contents
    };

    close(FH);

    # ternary op returns encoded json when verbose mode (1st arg evals true)
    return (shift) ? $json : do {
        my %hash = map { # otherwise, first create formatted data
            my $val = %$json{$_}; $_ => @$val[0];
        } keys %$json; \%hash # then return data (do {})
    };
}

unless (caller) {
    main();
}
