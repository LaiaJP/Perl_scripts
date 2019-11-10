#!/usr/bin/perl
use    File::Copy qw/cp mv/;

die "missing input arguments\n" if ($#ARGV!=3);
my $pdb = shift;
my $run = shift;
my $originresidues = shift;
my $directory = shift;
#$pdb =~ tr/[A-Z]/[a-z]/;
#$bm =~ tr/[A-Z]/[a-z]/;

die "all done" if ($run >100);

$path = "/gpfs/projects/ub79/ub79617/LAIA/ngb_wt";


$queue="class_a";
$tlimit= "24:00:00";
$cpus=1;
$gpus=1;

make_submit ($pdb, $run, $originresidues, $directory);

print "sending $pdb with status $run to queue $queue.";

#`/usr/local/bin/mnsubmit $path/$pdb.submit_md.cmd 2>/dev/null` =~ /The job \"(.+)\" has been submitted/ ;
$jobname = $1;
sleep 1;
##
##s30c1b01-gigabit1.496.0  ub79617     5/5  18:19 NQ 50  small
##
#my $status = substr (`/usr/local/bin/mnq  | grep STATE`,48,2);
print "..job $jobname gone with queue_status \n";

exit(0);

#####################################################################################
##                              Subrutines                                          #
#####################################################################################

sub make_submit {
my $pdb = shift;
my $run = shift;
my $originresidues = shift;
my $directory = shift;
my $last = $run -1;
my $next = $run +1;
my $dir = $pdb;
$dir =~ tr/[a-z]/[A-Z]/;
open (OUT, ">$path/$directory/$pdb.$run.submit_md.cmd");
print OUT "#!/bin/bash
# \@ job_name = $pdb.$run
# \@ initialdir = $path/$directory
# \@ wall_clock_limit = $tlimit
# \@ output = ${pdb}_$run.out
# \@ error =  ${pdb}_$run.err
# \@ total_tasks = 1
# \@ tasks_per_node = 1
# \@ gpus_per_node = $gpus

cd $path/$directory

module load intel/14.0.1
module load mkl/11.1
module load cuda/5.0
module load AMBER/14

srun \$AMBERHOME/bin/pmemd.cuda -O \\
                           -i mdin \\
                           -p $pdb.prmtop \\
                           -c $pdb.md_$last.rst7\\
                           -r $pdb.md_$run.rst7 \\
                           -o $pdb.md_$run.mdout \\
                           -x $pdb.md_$run.nc \\
                           -e $pdb.md_$run.ene \\
                           -inf mdinfo_$run 

cat <<eof > ptraj.in
trajin $pdb.md_$run.rst7
center :$originresidues
autoimage
trajout $pdb.md_$run.rst7 restart
eof

cpptraj prmtop < ptraj.in > ptraj_$run.out

if [ -s $pdb.md_$run.rst7 ]
then
gzip -f $pdb.md_$run.mdout $pdb.md_$run.ene 
module unload AMBER/14
nohup  /usr/bin/perl $path/send.md.pl $pdb $next $originresidues $directory

mnsubmit $pdb.$next.submit_md.cmd

fi
exit\n";


close OUT;
}

exit(0);
