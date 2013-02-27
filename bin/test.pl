use DataQualityControl;
use IniFiles;
use File::Basename qw(basename dirname);

my $usr_para = new Config::IniFiles( -file => "../conf/usr.ini" );
my $sys_para = new Config::IniFiles( -file => "../conf/sys.ini" );
my $output_path = $usr_para->val('output','path');
#print $usr_para->val('InputFile','type')."\n";
#print $sys_para->val('software','fastqc')."\n";

if($usr_para->val('InputFile','type') eq 'pair-end'){
	my ($read1_path,$read2_path) = split(/\&\&/,$usr_para->val('InputFile','path'));
	#print $read1_path."\n";
	my ($pe1,$pe2,$se1,$se2,$base1,$base2,$b1,$b2)=();
	$base1=basename($read1_path);
	$base2=basename($read2_path);
	$fastqcRst .= "sample_id	base_quality_read1	base_quality_read2	read1_result	read2_result\n";
    	$fastqcRst .= "$sample_id";
	if($base1=~m/(.+?)(\.fq|\.fastq|\.[^\.\d]+$|$)/i){
		$pe1=$1.".clean.fq.gz";
		$se1=$1.".se.fq.gz";
		$fastqcRst .= "	ref=$output_path/fastqc/$1.clean.fq_fastqc/Images/per_base_quality.png;title=src=$output_path/fastqc/$1.clean.fq_fastqc/Images/per_base_quality.png";
		$b1 = $1;
	}
	if($base2=~m/(.+?)(\.fq|\.fastq|\.[^\.\d]+$|$)/i){
		$pe2=$1.".clean.fq.gz";
		$se2=$1.".se.fq.gz";
		$fastqcRst .= "	ref=$output_path/fastqc/$1.clean.fq_fastqc/Images/per_base_quality.png;title=src=$output_path/fastqc/$1.clean.fq_fastqc/Images/per_base_quality.png";
		$b2 = $1;
	}
}







