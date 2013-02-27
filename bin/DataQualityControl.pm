package DataQualityControl;

use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter AutoLoader);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use DataQualityControl ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
CheckFq
);

our $VERSION = '0.01';

sub CheckFq
{
	my $usage = "CheckFq('input.fq.gz',['thoroughly'])";

	my $out_para;
	my $file  = shift @_;
	if($file=~/\.tar\..z.?$/) { $file = "tar -xf $file -O|"; } #gz bz2 xz
	elsif($file=~/\.gz$/)  	  { $file = "gzip -dc $file|";  } 
	elsif($file=~/\.zip$/)    { $file = "unzip -p $file|";  }
	elsif($file=~/\.7z$/)     { $file = "7za e -so $file|"; }
	elsif($file=~/\.rar$/)    { $file = "rar p -inul $file|"; }

	my $thoroughly = shift;
	undef $thoroughly unless $thoroughly eq 'thoroughly';

	my $phred_score;
	my $line_count;
	my $internalBlank = 0;
	my $evidence;

	open(IN, "$file") || die "Error 0000: can't open file($file)\n$usage";
	while(my $line = <IN>){
    		$line_count++;
		if ($line =~ /^\s+$/){
			if ($internalBlank){
				return "Bad Fastq";
				die "Line$line_count: internal blank line is NOT allowed.\n";
			}
			$internalBlank = 1;
			next ;
		}
		if($line !~/^@/){
			return "Bad Fastq";
   	    		die "Line$line_count: Reads name not begin with @\n$line";
   		}

		$line = <IN>;
		my $seq_len;
   		$line_count++;
    		$line =~ s/\s+$//;
		unless ($seq_len = length($line)){
			return "Bad Fastq";
   	    		die "Line$line_count: internal blank line is NOT allowed.\n";
   		}
		if($line =~/[^ATGCN]/i){
			return "Bad Fastq";
   	    		die "Line$line_count:$line\nbase should be ACGTN\n";
   		}

		$line = <IN>;
    		$line_count++;
		if($line !~/^\+/){
			return "Bad Fastq";
   	   		die "Line$line_count: quality score title not begin with +\n$line";
   		}

		$line = <IN>;
    		$line_count++;
    		$line =~ s/\s+$//;
		if($seq_len != length($line)){
			return "Bad Fastq";
   	   		die "Line$line_count: quality score line is NOT as long as nucleotide line($seq_len bp):\n$line";
   		}

		if(defined $thoroughly) {
			if($line =~ /[^!-~]/){
				return "Bad Fastq";
				die "Line$line_count: quality score is beyond ASCII 33~126\n$$line";
        		}
			if($line =~ /[!-:]/){
				if(! defined $phred_score){
					$phred_score = 33;
	                        	$evidence = "Line$line_count: $line";
        		        }elsif($phred_score == 64){
                        		return 'Bad Fastq';
                        		die "Line$line_count: $line quality score line is based on phred33, conflicted with $evidence\n";
                		}
        		}
			if($line =~ /[a-h]/){
				if(! defined $phred_score){
                        		$phred_score = 64;
                        		$evidence = "Line$line_count: $$line";
                		}elsif($phred_score == 33){
                        		return 'Bad Fastq';
                        		die "Line$line_count: $line quality score  line is based on phred64, conflicted with $evidence\n";
                		}
        		}
		}elsif(! defined $phred_score){
			if($line =~ /([!-:])/){
				$phred_score = 33;		#warn "phred = 33 since '$1' in '$line'";
			}elsif($line =~ /([a-h])/){ 
				$phred_score = 64;		#warn "phred = 64 since '$1' in '$line'";
		        }
		}
	}

#output
	if(! defined $phred_score){
		return 'phred64';
		warn "Can't make sure. guess as phred64.";
	}elsif($phred_score == 33){
		return 'phred33';
	}else{
		return 'phred64';
	}

}


# Preloaded methods go here.

1;
__END__

# Below is stub documentation for your module. 

=head1 NAME

DataQualityControl - Perl extension for data quality check

=head1 SYNOPSIS

  use DataQualityControl;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Integer::Doubler, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

A. U. Thor, E<lt>cyang@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by A. U. Thor

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
